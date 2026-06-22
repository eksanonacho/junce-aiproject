# TESTING_GUIDE.md — AI 初诊网站测试指南

> **这个文件是给谁看的**：任何要测试 AI 初诊网站的人（或 AI）。
> **什么时候用**：开发每个模块后、回归测试时。
> 最后更新：2026-06-22（Phase 3.1 补齐）。

---

## 一、通用约定

- 后端 Base URL：`http://localhost:3001`
- 前端 Base URL：`http://localhost:5173`
- curl 必须加 `--noproxy "*"`（本机有代理）
- 当前问卷 ID = 6（数据库 auto-increment 导致）
- 当前题目 ID 范围：51-60

---

## 二、Phase 0 测试（基础设施）

```bash
# 后端 health
curl -s --noproxy "*" http://localhost:3001/health
# 预期: {"status":"ok","service":"ai-diagnosis-server",...}

# 前端首页
curl -s --noproxy "*" -o /dev/null -w "%{http_code}" http://localhost:5173/
# 预期: 200
```

---

## 三、Phase 1 测试（问卷）

### 3.1 获取问卷

```bash
curl -s --noproxy "*" http://localhost:3001/api/questionnaire | python3 -m json.tool
# 预期: 5 groups, 10 questions
```

### 3.2 正常提交

```bash
curl -s --noproxy "*" -X POST http://localhost:3001/api/submissions \
  -H "Content-Type: application/json" \
  -d '{"questionnaireId":6,"answers":[
    {"questionId":51,"value":"互联网"},{"questionId":52,"value":"5年以上"},
    {"questionId":53,"value":"多股东"},{"questionId":54,"value":"50-100万"},
    {"questionId":55,"value":"1-5人"},{"questionId":56,"value":"是"},
    {"questionId":57,"value":"否"},{"questionId":58,"value":"是"},
    {"questionId":59,"value":"是"},{"questionId":60,"value":"否"}
  ]}'
# 预期: {"submissionPublicId":"...","status":"SUBMITTED","diagnosisStatus":"COMPLETED","reportStatus":"READY",...}
```

### 3.3 必填缺失

```bash
curl -s --noproxy "*" -X POST http://localhost:3001/api/submissions \
  -H "Content-Type: application/json" \
  -d '{"questionnaireId":6,"answers":[{"questionId":51,"value":"互联网"}]}'
# 预期: {"code":"REQUIRED_ANSWER_MISSING",...}
```

### 3.4 非法选项

```bash
curl -s --noproxy "*" -X POST http://localhost:3001/api/submissions \
  -H "Content-Type: application/json" \
  -d '{"questionnaireId":6,"answers":[{"questionId":51,"value":"非法行业"},...所有必填...]}'
# 预期: {"code":"INVALID_ANSWER_VALUE",...}
```

---

## 四、Phase 2 测试（规则引擎 & 风险等级）

### 4.1 低风险（0 命中 → LOW）

```bash
# 全部安全答案: Q56=是, Q57=否, Q60=否
curl ... (同 3.2)
# 查询诊断结果:
curl -s --noproxy "*" http://localhost:3001/api/diagnosis/submissions/<publicId>
# 预期: overallRiskLevel=LOW, needReview=false
```

### 4.2 中风险（1 MEDIUM）

```bash
# Q57=是 → 命中 TAX_001 (MEDIUM)
curl ... Q57=是 ...
# 预期: overallRiskLevel=MEDIUM, needReview=false
```

### 4.3 高风险 A（1 HIGH）

```bash
# Q56=否 → 命中 TAX_002 (HIGH)
curl ... Q56=否 ...
# 预期: overallRiskLevel=HIGH, needReview=true
```

### 4.4 3 MEDIUM 升级 HIGH

```bash
# Q57=是 + Q52=不到1年 + Q59=否 → 3 MEDIUM
# 预期: overallRiskLevel=HIGH, needReview=true
```

---

## 五、Phase 3 测试（报告生成 & 安全）

### 5.1 LOW 报告可见

```bash
# 提交 LOW 场景 → 获取 reportPublicId + reportAccessToken
curl -s --noproxy "*" "http://localhost:3001/api/reports/<publicId>/status"
# 预期: riskLevel=LOW, reviewStatus=AUTO_RELEASED, customerVisible=true

curl -s --noproxy "*" "http://localhost:3001/api/reports/<publicId>?token=<token>"
# 预期: customerVisible=true, htmlContent 包含完整报告
```

### 5.2 MEDIUM 报告待复核

```bash
# 提交 MEDIUM 场景 → 报告自动生成
curl -s --noproxy "*" "http://localhost:3001/api/reports/<publicId>/status"
# 预期: riskLevel=MEDIUM, reviewStatus=NEED_REVIEW, customerVisible=false

curl -s --noproxy "*" "http://localhost:3001/api/reports/<publicId>?token=<token>"
# 预期: customerVisible=false, message 包含"需要专业人员复核"
```

### 5.3 HIGH 报告待复核

```bash
# 同 MEDIUM，reviewStatus=NEED_REVIEW, customerVisible=false
```

### 5.4 错误 token

```bash
curl -s --noproxy "*" "http://localhost:3001/api/reports/<publicId>?token=wrongtoken"
# 预期: {"code":"INVALID_REPORT_TOKEN","message":"报告访问凭证无效"}
```

### 5.5 过期 token

```bash
# 手动将 token expiresAt 改为过去
psql -d junce_ai_diagnosis -c "
  UPDATE \"ReportAccessToken\" SET \"expiresAt\"='2020-01-01'
  WHERE \"reportId\"=(SELECT id FROM \"Report\" WHERE \"publicId\"='<publicId>');
"
# 使用原来有效的 token 访问
curl -s --noproxy "*" "http://localhost:3001/api/reports/<publicId>?token=<originalToken>"
# 预期: {"code":"REPORT_TOKEN_EXPIRED","message":"报告访问凭证已过期"}
```

### 5.6 ForbiddenPhrase 命中替换（正向测试）

```bash
# 1. 检查禁用词列表
psql -d junce_ai_diagnosis -c "SELECT phrase, \"safeAlternative\" FROM \"ForbiddenPhrase\" WHERE \"isActive\"=true;"

# 2. 临时插入含禁用词的规则
psql -d junce_ai_diagnosis -c "
  INSERT INTO \"DiagnosisRule\" (\"ruleCode\", dimension, \"questionId\",
    \"triggerCondition\", \"riskLevel\", \"riskTitle\", \"riskDescription\", suggestion,
    \"needReview\", \"recommendServices\", \"isActive\", \"createdAt\", \"updatedAt\")
  VALUES ('TEST_FP_001', '税务维度', 51,
    '{\"operator\":\"equals\",\"value\":\"互联网\"}', 'MEDIUM', '禁用词测试',
    '您的公司违法了，必须补税，保证帮您解决', '可以避税，税局不会查',
    false, '[\"代理记账\"]', true, NOW(), NOW());
"

# 3. 触发该规则（选 Q51=互联网）
curl ...

# 4. 验证报告 HTML 不含原禁用词
psql -d junce_ai_diagnosis -c "SELECT \"htmlContent\" FROM \"Report\" ORDER BY id DESC LIMIT 1;" -t \
  | grep -o "可能存在合规风险\|建议核查申报\|可以为您提供专业\|合法合规的税务筹划\|降低被稽查"

# 5. 清理测试规则
psql -d junce_ai_diagnosis -c "DELETE FROM \"DiagnosisRule\" WHERE \"ruleCode\"='TEST_FP_001';"
```

### 5.7 Disclaimer 缺失禁止生成

```bash
# 1. 临时禁用 disclaimer
psql -d junce_ai_diagnosis -c "UPDATE \"Disclaimer\" SET \"isActive\"=false WHERE \"isActive\"=true;"

# 2. 尝试生成报告
curl -s --noproxy "*" -X POST "http://localhost:3001/api/reports/submissions/<submissionPublicId>/generate"
# 预期: {"code":"NO_ACTIVE_DISCLAIMER","message":"系统中没有活跃的免责声明，无法生成报告"}

# 3. 恢复
psql -d junce_ai_diagnosis -c "UPDATE \"Disclaimer\" SET \"isActive\"=true WHERE \"isActive\"=false;"
```

### 5.8 重跑报告不产生脏数据

```bash
# 同一 submission 重跑两次
curl -s --noproxy "*" -X POST "http://localhost:3001/api/reports/submissions/<publicId>/generate"
curl -s --noproxy "*" -X POST "http://localhost:3001/api/reports/submissions/<publicId>/generate"
# 验证: Report 只有 1 条, token 只有 1 条（旧 token 已清理）
psql -d junce_ai_diagnosis -c "
  SELECT COUNT(*) as report_count FROM \"Report\" WHERE \"diagnosisResultId\"=
    (SELECT id FROM \"DiagnosisResult\" WHERE \"submissionId\"=
      (SELECT id FROM \"Submission\" WHERE \"publicId\"='<publicId>'));
"
# 预期: report_count=1
```

---

## 六、前端测试

### 6.1 页面可访问

```bash
curl -s --noproxy "*" -o /dev/null -w "%{http_code}" http://localhost:5173/
curl -s --noproxy "*" -o /dev/null -w "%{http_code}" http://localhost:5173/questionnaire
curl -s --noproxy "*" -o /dev/null -w "%{http_code}" http://localhost:5173/questionnaire/success
# 全部预期: 200
```

### 6.2 报告页四状态

| 状态 | 触发条件 | 页面表现 |
|---|---|---|
| loading | token 有效，报告加载中 | "加载报告中..." |
| error | token 无效/过期/缺失 | 错误提示 + "返回首页" |
| PENDING_REVIEW | MEDIUM/HIGH 报告 | 黄色警告 + "报告待复核" |
| READY | LOW 报告 | 完整报告：画像/风险/问题/推荐 |

---

## 七、数据库验证

```bash
# 所有表正常
psql -d junce_ai_diagnosis -c "\dt"

# 种子数据正常
psql -d junce_ai_diagnosis -c "SELECT COUNT(*) FROM \"DiagnosisRule\";"  # 预期: 5
psql -d junce_ai_diagnosis -c "SELECT COUNT(*) FROM \"ForbiddenPhrase\";" # 预期: 15
psql -d junce_ai_diagnosis -c "SELECT COUNT(*) FROM \"Disclaimer\" WHERE \"isActive\"=true;" # 预期: >=1
```

---

## 八、Phase 4 测试（后台管理 & 人工复核）

### 8.1 Auth 测试

```bash
# 正确登录
curl -s --noproxy "*" -X POST http://localhost:3001/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"Admin@123456"}'
# 预期: {"accessToken":"...","user":{...}}

# 错误密码
curl -s --noproxy "*" -X POST http://localhost:3001/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"wrong"}'
# 预期: {"code":"INVALID_CREDENTIALS","message":"用户名或密码错误"}
```

### 8.2 权限矩阵实测

测试账号：`admin/Admin@123456`、`manager/Manager@123456`、`accountant/Accountant@123456`

| 操作 | ACCOUNTANT | MANAGER | ADMIN |
|---|---|---|---|
| 查看列表 | ✅ | ✅ | ✅ |
| PATCH htmlContent | 403 | ✅ | ✅ |
| PATCH riskLevel | 403 | 403 | ✅ |
| POST generate | 403 | ✅ | ✅ |

```bash
TOK=$(...)  # 先登录获取 token
# MANAGER 修改 htmlContent → OK
curl -s --noproxy "*" -X PATCH "http://localhost:3001/api/admin/reports/<pid>" \
  -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
  -d '{"htmlContent":"<p>修改后</p>"}'
# 预期: OK

# MANAGER 修改 riskLevel → 403
curl -s --noproxy "*" -X PATCH "http://localhost:3001/api/admin/reports/<pid>" \
  -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
  -d '{"riskLevel":"HIGH"}'
# 预期: {"code":"FORBIDDEN",...}
```

### 8.3 APPROVE / REJECT

```bash
# APPROVE
curl -s --noproxy "*" -X POST "http://localhost:3001/api/admin/reports/<pid>/review" \
  -H "Authorization: Bearer $TOK" -H "Content-Type: application/json" \
  -d '{"action":"APPROVE","comment":"复核通过"}'
# 预期: reviewStatus=REVIEWED, customerVisible=true

# 客户侧联动：APPROVE 后可查看完整报告
curl -s --noproxy "*" "http://localhost:3001/api/reports/<pid>?token=<rtok>"
# 预期: customerVisible=true, htmlContent 非空
```

### 8.4 ReviewRecord 留痕验证

```bash
psql -d junce_ai_diagnosis -c "SELECT action, comment, \"createdAt\" FROM \"ReviewRecord\" ORDER BY id DESC LIMIT 5;"
# 每次 APPROVE/REJECT/MODIFY 都应该有一条记录
```

---

> 测试未通过时，先查 `pnpm build` 编译错误，再查接口返回的 code/message，最后查数据库数据一致性。

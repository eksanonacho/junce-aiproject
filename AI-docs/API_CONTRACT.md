# API_CONTRACT.md — AI 初诊网站前后端接口契约

> **这个文件是给谁看的**：前端开发者（及任何需要调用后端的人/AI）。
> **什么时候用**：开发前端、联调、排查接口问题时。
> 最后更新：2026-06-22（Phase 1 完成）。

---

## 一、通用约定

| 项目 | 值 |
|---|---|
| Base URL | `http://localhost:3001`（后端）/ 前端通过 Vite proxy 转发 `/api` |
| Content-Type | `application/json` |
| 客户侧认证 | 无需（Phase 1） |
| 错误码 | 200 成功 / 400 参数错误 / 404 资源不存在 |

### 错误返回格式

```json
{
  "code": "ERROR_CODE",
  "message": "人类可读的错误说明",
  "details": [{ "questionId": 3, "text": "题目文字", "reason": "具体原因" }]
}
```

---

## 二、问卷接口

### 2.1 GET /api/questionnaire — 获取当前活跃问卷

- **方法**：GET
- **认证**：无需
- **返回结构**：

```json
{
  "id": 1,
  "version": "v1",
  "title": "君册财税·企业初诊问卷",
  "description": "用于企业财税初步筛查",
  "groups": [
    {
      "label": "企业基础信息",
      "order": 1,
      "questions": [
        {
          "id": 1,
          "publicId": "xxx",
          "text": "贵公司所属行业？",
          "type": "SINGLE_CHOICE",
          "options": ["餐饮", "贸易", "建筑", "运输", "其他"],
          "required": true,
          "riskDimension": "基础画像"
        }
      ]
    }
  ]
}
```

- **题型**：SINGLE_CHOICE / MULTI_CHOICE / YES_NO / RANGE / TEXT
- **options 格式**：字符串数组（SINGLE_CHOICE / MULTI_CHOICE / YES_NO），或 `{"options":["选项1","选项2"]}`（RANGE）
- **排序**：groups 按 order 升序，questions 按 groupOrder + orderInGroup 升序
- **错误**：404（无活跃问卷，code: NO_ACTIVE_QUESTIONNAIRE）

---

## 三、提交接口

### 3.1 POST /api/submissions — 提交问卷答案

- **方法**：POST
- **认证**：无需
- **请求体**：

```json
{
  "questionnaireId": 1,
  "phone": "13800138000",
  "answers": [
    { "questionId": 1, "value": "餐饮" },
    { "questionId": 2, "value": ["代理记账", "社保"] },
    { "questionId": 3, "value": "yes" }
  ]
}
```

- **value 格式**：
  - SINGLE_CHOICE：字符串，必须在 options 中
  - MULTI_CHOICE：字符串数组，每项必须在 options 中
  - YES_NO：字符串，必须在 options 中
  - RANGE：字符串或对象
  - TEXT：任意字符串

- **phone**：可选，格式 `/^1[3-9]\d{9}$/`

- **成功返回**（201）：

```json
{
  "submissionPublicId": "cmqoo5wso00002d9k3d6t1oqv",
  "status": "SUBMITTED",
  "message": "提交成功"
}
```

- **错误场景**：

| code | 说明 |
|---|---|
| QUESTIONNAIRE_NOT_FOUND | 问卷 ID 不存在（404） |
| QUESTIONNAIRE_INACTIVE | 问卷已下线（400） |
| ANSWERS_EMPTY | 答案数组为空（400） |
| INVALID_QUESTION_ID | questionId 不属于该问卷（400） |
| REQUIRED_ANSWER_MISSING | 必填题未填写，details 列出缺失题目（400） |
| INVALID_ANSWER_VALUE | 答案格式不正确，details 列出具体错误（400） |

> Phase 2 更新：提交接口返回新增 `diagnosisStatus` 字段（COMPLETED / FAILED / NOT_RUN）

---

## 四、诊断接口（Phase 2 新增）

### 4.1 POST /api/diagnosis/submissions/:publicId/run — 手动触发诊断

- **方法**：POST
- **认证**：无需（开发调试用）
- **路径参数**：`publicId` — Submission 的 publicId
- **成功返回**：

```json
{
  "submissionPublicId": "xxx",
  "diagnosisResultId": 1,
  "overallRiskLevel": "MEDIUM",
  "findingCount": 2,
  "recommendationCount": 1,
  "needReview": true
}
```

- **错误**：404 `SUBMISSION_NOT_FOUND`

### 4.2 GET /api/diagnosis/submissions/:publicId — 查询诊断结果

- **方法**：GET
- **认证**：无需（开发调试用）
- **返回结构**：

```json
{
  "submissionPublicId": "xxx",
  "overallRiskLevel": "MEDIUM",
  "needReview": false,
  "dimensionResults": [
    {
      "dimension": "税务维度",
      "riskLevel": "MEDIUM",
      "findings": [
        {
          "title": "长期零申报",
          "riskLevel": "MEDIUM",
          "description": "连续零申报可能引起税务关注",
          "suggestion": "建议规范账务处理",
          "recommendServices": ["代理记账", "合规项目"]
        }
      ]
    }
  ],
  "findings": [...],
  "recommendations": [
    {
      "serviceType": "代理记账",
      "reason": "根据命中的风险项推荐",
      "priority": "STRONG"
    }
  ]
}
```

- **错误**：404 `SUBMISSION_NOT_FOUND` / `DIAGNOSIS_RESULT_NOT_FOUND`

---

## 五、报告接口（Phase 3 新增）

> ⚠️ 客户侧访问必须通过 report publicId + access token。token 明文仅返回一次，数据库仅存 bcrypt hash。

### 5.1 GET /api/reports/:publicId/status — 查询报告状态

- **方法**：GET
- **认证**：无需（不泄露敏感内容）
- **路径参数**：`publicId` — Report 的 publicId
- **返回示例（READY）**：

```json
{
  "reportPublicId": "cmqp09mia0003vs9kefoso2iw",
  "reportNumber": "JC-AI-20260622-0001",
  "title": "君册财税·企业初诊报告",
  "riskLevel": "LOW",
  "reviewStatus": "AUTO_RELEASED",
  "customerVisible": true,
  "generatedAt": "2026-06-22T10:00:00.000Z"
}
```

- **返回示例（PENDING_REVIEW）**：

```json
{
  "reportPublicId": "xxx",
  "reportNumber": "JC-AI-20260622-0003",
  "title": "君册财税·企业初诊报告",
  "riskLevel": "HIGH",
  "reviewStatus": "NEED_REVIEW",
  "customerVisible": false,
  "generatedAt": "2026-06-22T10:05:00.000Z"
}
```

- **错误**：404 `{"code":"REPORT_NOT_FOUND","message":"报告不存在"}`

### 5.2 GET /api/reports/:publicId?token=xxx — 获取报告详情

- **方法**：GET
- **认证**：report access token（URL query 参数 `token`）
- **token 校验逻辑**：
  1. 根据 publicId 找到 Report 及其 accessTokens
  2. bcrypt.compare(传入token, 存储的tokenHash)
  3. 检查 expiresAt < now
  4. 匹配成功 → 标记 usedAt
- **token 过期时间**：7 天
- **customerVisible=false 时返回（PENDING_REVIEW）**：

```json
{
  "reportPublicId": "xxx",
  "reportNumber": "JC-AI-20260622-0003",
  "title": "君册财税·企业初诊报告",
  "riskLevel": "HIGH",
  "reviewStatus": "NEED_REVIEW",
  "customerVisible": false,
  "message": "您的初诊结果包含需要专业人员进一步确认的内容。君册工作人员将结合完整资料进行复核后，再向您说明具体情况。"
}
```

- **customerVisible=true 时返回（READY）**：

```json
{
  "reportPublicId": "cmqp09mia0003vs9kefoso2iw",
  "reportNumber": "JC-AI-20260622-0001",
  "title": "君册财税·企业初诊报告",
  "riskLevel": "LOW",
  "reviewStatus": "AUTO_RELEASED",
  "customerVisible": true,
  "generatedAt": "2026-06-22T10:00:00.000Z",
  "companyProfile": { "贵公司所属行业？": "互联网", "..." : "..." },
  "summary": "根据您目前填写的信息，系统暂未发现明显高风险项。",
  "dimensionResults": [],
  "findings": [
    {
      "riskLevel": "MEDIUM",
      "title": "长期零申报",
      "description": "连续零申报可能引起税务关注",
      "suggestion": "建议规范账务处理",
      "recommendServices": ["代理记账", "合规项目"]
    }
  ],
  "recommendations": [
    {
      "serviceType": "代理记账",
      "reason": "根据命中的风险项推荐",
      "priority": "STRONG"
    }
  ],
  "disclaimer": "本报告仅作为初步风险筛查参考...",
  "htmlContent": "<!DOCTYPE html>..."
}
```

- **无效 token**：400 `{"code":"INVALID_REPORT_TOKEN","message":"报告访问凭证无效"}`
- **过期 token**：400 `{"code":"REPORT_TOKEN_EXPIRED","message":"报告访问凭证已过期"}`
- **报告不存在**：404 `{"code":"REPORT_NOT_FOUND","message":"报告不存在"}`

### 5.3 POST /api/reports/submissions/:submissionPublicId/generate — 生成/重跑报告

- **方法**：POST
- **认证**：⚠️ 当前无 JWT（开发调试用），Phase 4 后需要加后台权限
- **路径参数**：`submissionPublicId` — Submission 的 publicId
- **前置条件**：该 Submission 必须已有 DiagnosisResult
- **重跑逻辑**：删除旧 Report 及关联 token，重新生成
- **成功返回**：

```json
{
  "submissionPublicId": "xxx",
  "reportPublicId": "yyy",
  "reportNumber": "JC-AI-20260622-0002",
  "riskLevel": "LOW",
  "reviewStatus": "AUTO_RELEASED",
  "customerVisible": true,
  "reportAccessToken": "plain-token-only-return-once"
}
```

- **报告生成失败**：400 `{"code":"NO_DIAGNOSIS_RESULT","message":"该提交尚未完成诊断，无法生成报告"}`
- **免责声明缺失**：400 `{"code":"NO_ACTIVE_DISCLAIMER","message":"系统中没有活跃的免责声明，无法生成报告"}`
- **提交不存在**：404 `{"code":"SUBMISSION_NOT_FOUND","message":"提交记录不存在"}`

### 5.4 reviewStatus 和 customerVisible 规则

| overallRiskLevel | needReview | reviewStatus | customerVisible |
|---|---|---|---|
| LOW | false | AUTO_RELEASED | true |
| LOW | true | NEED_REVIEW | false |
| MEDIUM | 任意 | NEED_REVIEW | false |
| HIGH | 任意 | NEED_REVIEW | false |
| UNKNOWN | 任意 | NEED_REVIEW | false |

---

## 六、Health 检查（基础设施）

### 6.1 GET /health

```json
{ "status": "ok", "service": "ai-diagnosis-server", "timestamp": "..." }
```

---

## 七、当前接口总数

| 模块 | 接口数 | 状态 |
|---|---|---|
| Health | 1 | ✅ `[06-22]` |
| Questionnaire | 1 | ✅ `[06-22]` Phase 1 |
| Submission | 1 | ✅ `[06-22]` Phase 1 |
| Diagnosis | 2 | ✅ `[06-22]` Phase 2 |
| Report | 3 | ✅ `[06-22]` Phase 3 |
| **总计** | **8** | |

后续接口：后台管理、人工复核 — Phase 4 开发。

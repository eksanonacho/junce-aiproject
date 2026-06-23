# TEST_RESULTS.md — AI 初诊网站测试结果记录

> 最后更新：2026-06-23（V2 全量重构验证）

---

## V1 Phase 0-5 测试（2026-06-22 完成）

| 模块 | 测试项 | 结果 |
|------|--------|------|
| Health | GET /health → 200 `{"status":"ok"}` | ✅ |
| Questionnaire | GET /api/questionnaire → 返回 V1 10 题 5 组 | ✅ |
| Submission | POST /api/submissions → 创建答案+触发诊断+生成报告 | ✅ |
| Submission | 必填校验 → 400 REQUIRED_ANSWER_MISSING | ✅ |
| Submission | 无效 questionId → 400 INVALID_QUESTION_ID | ✅ |
| Diagnosis | POST /api/diagnosis/submissions/:id/run → 返回风险等级 | ✅ |
| Diagnosis | GET /api/diagnosis/submissions/:id → 返回 findings+recommendations | ✅ |
| Diagnosis | 0 findings → overallRiskLevel=LOW | ✅ |
| Diagnosis | 3 MEDIUM → 升级为 HIGH | ✅ |
| Report | POST generate → 返回 reportPublicId + accessToken（明文仅一次） | ✅ |
| Report | GET /:publicId?token=xxx → customerVisible=true 返回完整报告 | ✅ |
| Report | GET /:publicId?token=xxx → customerVisible=false 返回 PENDING_REVIEW | ✅ |
| Report | 无效 token → 400 INVALID_REPORT_TOKEN | ✅ |
| Report | 过期 token → 400 REPORT_TOKEN_EXPIRED | ✅ |
| Report | HTML 含禁用词 → 自动替换为 safeAlternative | ✅ |
| Report | 无活跃 Disclaimer → 400 NO_ACTIVE_DISCLAIMER | ✅ |
| Admin | POST /api/admin/auth/login → 正确密码返回 JWT | ✅ |
| Admin | POST /api/admin/auth/login → 错误密码 401 | ✅ |
| Admin | GET /api/admin/submissions → 无 JWT 401 | ✅ |
| Admin | GET /api/admin/submissions → ACCOUNTANT 可访问 | ✅ |
| Admin | POST /api/admin/reports/:id/review → APPROVE 后 customerVisible=true | ✅ |
| Admin | POST /api/admin/reports/:id/review → REJECT 后 customerVisible=false | ✅ |
| Admin | PATCH /api/admin/reports/:id → ACCOUNTANT 403 | ✅ |
| Admin | PATCH /api/admin/reports/:id htmlContent → MANAGER 可修改 + 禁用词检查 | ✅ |
| Admin | PATCH /api/admin/reports/:id riskLevel → 仅 ADMIN 可修改 | ✅ |
| Admin | 复核留痕 → ReviewRecord 含 reviewerName + action + timestamp | ✅ |
| Docker | docker-compose up → 3 容器启动（postgres/server/client） | ✅ |
| Build | 后端 `nest build` 通过 | ✅ |
| Build | 前端 `vite build` 通过 | ✅ |

---

## V2 全量重构测试（2026-06-23）

### V2 Schema + Seed

| 测试项 | 命令/验证 | 结果 |
|--------|----------|------|
| Schema migration | `prisma db push` 成功 | ✅ |
| Seed V1 保留 | AdminUser=1, Questionnaire(v1)=1, DiagnosisRule=5, RiskScenario=3 | ✅ |
| Seed V2 DocumentRequirements | 19 条，含 QUICK/STANDARD/DEEP required 标记 | ✅ |
| Seed V2 Questionnaire | 65 题，9 组，version=v2 | ✅ |
| Seed V2 Rules | 55 条，含 9 COMPOSITE，全部挂九维 code | ✅ |
| Seed V2 Scenarios | 12 个 | ✅ |
| Seed V2 Disclaimer | 1 条 | ✅ |

### V2 API 端点

| 测试项 | 结果 |
|--------|------|
| `GET /api/questionnaire?version=v2` → 返回 V2 65 题 9 组 | ✅ |
| `GET /api/questionnaire`（无参）→ 返回 V1 10 题，不破坏 | ✅ |
| `POST /api/submissions/start` → 201, status=DRAFT, 返回 submissionAccessToken | ✅ |
| `POST /api/submissions/start` → submissionAccessToken 明文仅一次 | ✅ |
| `GET /api/submissions/:id/document-checklist` → 返回 mode+score+requirements | ✅ |
| `GET /api/document-requirements?mode=STANDARD` → 19 条，10 条 required | ✅ |
| `POST /api/submissions/:id/documents` → 上传成功，文件存入 uploads/ | ✅ |
| `GET /api/submissions/:id/documents` → 列出已上传文件（无 storagePath） | ✅ |
| `DELETE /api/submissions/:id/documents/:docId` → 本地文件和数据记录均删除 | ✅ |
| `POST /api/submissions/:id/complete` → 完成诊断，返回 report+token | ✅ |
| `POST /api/submissions/:id/complete` → 非 DRAFT 状态 400 INVALID_STATUS | ✅ |
| `POST /api/admin/auth/login` → admin/Admin@123456 登录成功 | ✅ |
| `GET /api/admin/submissions` → 分页列表（手机号脱敏） | ✅ |
| `GET /api/admin/reports/:id` → 含 dashboard+documents+dimensionRuleHits | ✅ |
| `GET /api/admin/documents/:docId/download` → JWT 校验 + 文件流返回 | ✅ |
| 资料上传—路径穿越防护 | storagePath 含 `..` 拒绝 | ✅ |
| 资料上传—MIME 白名单 | 非白名单类型拒绝 | ✅ |
| 资料删除—确认在 uploads/ 内 | 防路径穿越 | ✅ |
| customerVisible=false → `{"status":"PENDING_REVIEW"}` | ✅ |
| customerVisible=true → 含 dashboard+documentCompleteness | ✅ |
| 复合规则 AND 条件 | 零申报 AND 仍有经营 → HIGH | ✅ |
| dashboardData 写入 DiagnosisResult | ✅ |
| 四维评分范围 1.0-5.0 | ✅ |
| V1 POST /api/submissions 旧端点不受影响 | ✅ |

### V2 前端 Build

| 测试项 | 结果 |
|--------|------|
| `pnpm build` 通过（vue-tsc + vite） | ✅ |
| 新路由 `/diagnosis/start`、`/diagnosis/upload` 注册 | ✅ |
| ECharts + vue-echarts 导入正常 | ✅ |
| Pinia stores 编译通过 | ✅ |
| 新组件 BusinessDashboard/DimensionCard/TopActions 编译通过 | ✅ |
| ReportPage 重写编译通过 | ✅ |

### V2 安全

| 测试项 | 结果 |
|--------|------|
| SubmissionAccessToken bcrypt hash 存储 | ✅ |
| Token 不出现在 URL query 中 | ✅ |
| 后台文件下载需要 JWT | ✅ |
| 文件 storagePath 不返回前端 | ✅ |
| 文件 MIME + 扩展名双校验 | ✅ |
| 文件名 sanitize（去除路径分隔符） | ✅ |
| customerVisible 门控（待复核不可见详情） | ✅ |

---

## 未覆盖测试

| 测试项 | 原因 |
|--------|------|
| 文件上传 20MB 超限 | 未构造大文件测试（multer 已配置 limits） |
| 并发上传 | 单线程 curl 测试 |
| ReportAccessToken 过期 | 7 天过期，未做时间模拟 |
| 前端浏览器 E2E | 仅 build 验证，未启动浏览器测试 |
| 三套演示案例完整流程 | DEMO_CASES_V2.md 未编写 |

---

## 最终统计

| 指标 | 值 |
|------|-----|
| V1 测试项 | 28 |
| V2 测试项 | 30 |
| 总测试项 | 58 |
| 通过 | 58 |
| 失败 | 0 |
| 未覆盖 | 5 |
| 通过率 | 100%（已执行项） |

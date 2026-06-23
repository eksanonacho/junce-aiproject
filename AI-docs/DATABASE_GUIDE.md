# DATABASE_GUIDE.md — AI 初诊网站数据库设计说明

> **最后更新**：2026-06-23（V2 全量重构，18 模型 8 枚举）
> **数据库**：PostgreSQL 16，独立库 `junce_ai_diagnosis`

---

## 一、当前模型清单（18 个）

| 模型 | 表名 | 用途 | 阶段 |
|------|------|------|------|
| Questionnaire | `Questionnaire` | 问卷模板（V1 10题 / V2 65题） | Phase 0 `[06-22]` |
| Question | `Question` | 题目：题干、类型、选项、分组、风险维度、跳题逻辑 | Phase 0 `[06-22]` |
| Submission | `Submission` | 客户提交记录：答案、状态(V2新增DRAFT/QUESTIONNAIRE_COMPLETED等)、初诊模式、资料完整度、accessToken | Phase 0 `[06-22]` |
| Answer | `Answer` | 客户答案（questionId → value JSON） | Phase 0 `[06-22]` |
| DiagnosisRule | `DiagnosisRule` | 诊断规则：60条(V1 5 + V2 55)，支持 SIMPLE/COMPOSITE 条件模式 | Phase 0 `[06-22]` |
| RiskScenario | `RiskScenario` | 风险场景库：15个(V1 3 + V2 12) | Phase 0 `[06-22]` |
| DiagnosisResult | `DiagnosisResult` | 诊断结果：风险等级+维度结果+四维看板数据(dashboardData) | Phase 0 `[06-22]` |
| RiskFinding | `RiskFinding` | 命中风险项 | Phase 0 `[06-22]` |
| ServiceRecommendation | `ServiceRecommendation` | 服务推荐 | Phase 0 `[06-22]` |
| Report | `Report` | 初诊报告：含 publicId、reportNumber、HTML、复核状态、客户可见性 | Phase 0 `[06-22]` |
| ReportAccessToken | `ReportAccessToken` | 报告访问 token（bcrypt hash） | Phase 0 `[06-22]` |
| ReviewRecord | `ReviewRecord` | 人工复核记录（审批/驳回/修改留痕） | Phase 0 `[06-22]` |
| ForbiddenPhrase | `ForbiddenPhrase` | 禁用话术库（15条） | Phase 0 `[06-22]` |
| Disclaimer | `Disclaimer` | 免责声明（v1 + v2） | Phase 0 `[06-22]` |
| SmsVerificationCode | `SmsVerificationCode` | 短信验证码（bcrypt hash） | Phase 0 `[06-22]` |
| AdminUser | `AdminUser` | 后台用户（admin/Admin@123456, role=ADMIN） | Phase 0 `[06-22]` |
| **DocumentRequirement** | `DocumentRequirement` | **V2新增** 资料类型定义（19条） | V2 `[06-23]` |
| **UploadedDocument** | `UploadedDocument` | **V2新增** 已上传文件记录（submissionId non-null + Cascade） | V2 `[06-23]` |

---

## 二、枚举定义（8 个）

| 枚举 | 值 | 阶段 |
|------|-----|------|
| QuestionType | `SINGLE_CHOICE` `MULTI_CHOICE` `RANGE` `YES_NO` | Phase 0 |
| SubmissionStatus | `PENDING` `DRAFT` `DOCUMENT_UPLOADING` `SUBMITTED` `QUESTIONNAIRE_COMPLETED` `DIAGNOSING` `COMPLETED` `FAILED` | Phase 0 + V2 追加3个 `[06-23]` |
| SubmissionSource | `WEB` `MINIPROGRAM` `STAFF` | Phase 0 |
| RiskLevel | `LOW` `MEDIUM` `HIGH` `UNKNOWN` | Phase 0 |
| ReviewStatus | `NEED_REVIEW` `AUTO_RELEASED` `REVIEWED` `REJECTED` | Phase 0 |
| ReviewAction | `APPROVE` `REJECT` `MODIFY` | Phase 0 |
| RecommendPriority | `STRONG` `SUGGEST` `INFO` | Phase 0 |
| AdminRole | `ACCOUNTANT` `MANAGER` `ADMIN` | Phase 0 |
| **DiagnosisMode** | `QUICK` `STANDARD` `DEEP` | **V2 新增** `[06-23]` |

---

## 三、V2 新增模型详细字段

### DocumentRequirement

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int PK | 自增 |
| code | String @unique | 资料代码（如 BUSINESS_LICENSE） |
| name | String | 资料名称（如"营业执照"） |
| category | String | 分类（如"工商证照"） |
| requiredForQuick | Boolean | 快速初诊是否必传 |
| requiredForStandard | Boolean | 标准初诊是否必传 |
| requiredForDeep | Boolean | 深度出诊是否必传 |
| affectsDimensions | Json? | 影响维度数组（如 ["RISK"]） |
| description | String? | 用途说明 |
| sortOrder | Int | 排序 |
| isActive | Boolean | 是否启用 |

### UploadedDocument

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int PK | 自增 |
| publicId | String @unique | 公开 ID（cuid） |
| submissionId | Int FK → Submission | 所属提交（Cascade 删除） |
| docType | String | 对应 DocumentRequirement.code |
| originalName | String | 原始文件名（仅展示用） |
| mimeType | String | MIME 类型 |
| sizeBytes | Int | 文件大小 |
| storagePath | String | 存储路径（不返回前端，格式：uploads/{submissionPublicId}/{documentPublicId}.{ext}） |
| uploadStatus | String @default("UPLOADED") | 上传状态 |

---

## 四、V2 现有模型新增字段

| 模型 | 新增字段 | 类型 | 说明 |
|------|---------|------|------|
| Submission | mode | DiagnosisMode? | V2 初诊模式 |
| Submission | documentCompletenessScore | Int? | 资料完整度 0-100 |
| Submission | documentCompletenessDetail | Json? | 完整度详情（含 missingDocuments + dimensionConfidence） |
| Submission | accessTokenHash | String? | submissionAccessToken bcrypt hash |
| Submission | accessTokenCreatedAt | DateTime? | token 创建时间 |
| DiagnosisResult | dashboardData | Json? | 四维看板数据（BusinessDashboardResult JSON） |
| Question | skipLogic | Json? | 跳题逻辑（hideInModes / showIfAnswer） |
| DiagnosisRule | conditionMode | String @default("SIMPLE") | 条件模式：SIMPLE / COMPOSITE |

---

## 五、关键关系图

```
Questionnaire 1──* Question
Questionnaire 1──* Submission
Submission 1──* Answer (→ Question)
Submission 1──* UploadedDocument (V2)
Submission 1──1 DiagnosisResult
DiagnosisResult 1──* RiskFinding (→ DiagnosisRule)
DiagnosisResult 1──* ServiceRecommendation
DiagnosisResult 1──1 Report
Report 1──* ReportAccessToken
Report 1──* ReviewRecord (→ AdminUser)
Question 1──* DiagnosisRule
```

---

## 六、Migration 规范

1. **所有结构变更必须走 Prisma migration**：`npx prisma db push`（开发）/ `npx prisma migrate dev --name xxx`（正式）
2. **V2 字段均为 nullable**：不破坏 V1 数据完整性
3. **新增枚举值只追加不删除不重命名**：SubmissionStatus 追加 DRAFT/DOCUMENT_UPLOADING/QUESTIONNAIRE_COMPLETED，不改 V1 已有值
4. **外键约束**：UploadedDocument.submissionId → Cascade 删除
5. **金额字段**：如有金额使用 Decimal(12,2)，当前无直接金额列
6. **Prisma adapter**：使用 `@prisma/adapter-pg` 直连 PostgreSQL

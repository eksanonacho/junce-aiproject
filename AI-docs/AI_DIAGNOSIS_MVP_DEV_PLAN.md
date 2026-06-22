# 君册财税 AI 初诊网站 — MVP 开发方案 v2

> **编制日期**：2026-06-22（v2 修订版）
> **修订依据**：P0 审查意见（10 项修正）
> **小程序状态**：12 模块、55 接口、63/63 回归通过、后端封板
> **本文目的**：输出一份可直接指导编码的 AI 初诊网站 MVP 开发方案

---

## 1. 项目理解

### 1.1 AI 初诊网站和小程序的关系

两个独立项目，不同用户、不同代码仓库、不同数据库、独立 Docker Compose。

| 维度 | 内部管理小程序 | AI 初诊网站 |
|------|-------------|-----------|
| 用户 | 君册内部员工 | 潜在客户 + 内部员工 |
| 终端 | 微信小程序 + H5 | H5 响应式网站 |
| 定位 | OA + CRM + 任务流转 | 对外获客 + 初筛诊断 |
| 部署 | Docker :3000 | Docker :3001 |
| 数据库 | `junce_dev` | `junce_ai_diagnosis`（独立库） |
| 代码 | `/Users/a1234/cpp/junce-miniprogram/` | `/Users/a1234/Desktop/junce-aiproject/` |

- 两个项目拥有各自的 docker-compose.yml，本地开发和生产部署均独立。
- 生产部署时可通过 Nginx 反向代理和小程序并列运行，但 compose 文件不合并。
- 预留数据打通 API，后续对接。

### 1.2 小程序字段后续可复用

小程序 `customers` 表已有字段 → AI 初诊可对应：companyName、industry、taxType、annualRevenue、staffCount、companyType、customerCategory。

第一版**不自动同步**，问卷字段设计时预留对应关系。

---

## 2. MVP 功能范围

### 2.1 MVP-A：最小可演示版

| 功能 | 本期 | 说明 |
|---|---|---|
| 客户填写初诊问卷 | ✅ | 约 25-30 题，手机端优先 |
| 规则引擎初步诊断 | ✅ | 配置驱动 |
| 生成初诊报告（HTML） | ✅ | 含风险等级+问题清单+建议 |
| 报告访问控制 | ✅ | publicId + ReportAccessToken |
| 客户留资（手机号） | ✅ | SmsVerificationCode 验证 |
| 内部后台 + 人工复核 | ✅ | JWT 登录、复核留痕 |
| 免责声明 | ✅ | 每份报告强制 |
| PDF 导出 | ⚠️ MVP-B | MVP-A 只做 HTML 报告 |
| AI 文字润色 | ⚠️ 默认关闭 | `AI_POLISH_ENABLED=false` |

### 2.2 二期功能（本次不做）

- 复杂多轮 AI Agent、自动报价、自动同步小程序、后台规则编辑器、数据统计看板、客户账号系统、微信小程序内嵌版

---

## 3. 推荐技术栈

| 层 | 选型 | 理由 |
|---|---|---|
| **前端** | Vue3 + Vite + TypeScript + Pinia + Tailwind CSS | 与小程序前端 Vue3 体系一致，降低学习成本 |
| **后端** | NestJS (TypeScript) + Prisma 7 | 复用小程序技术栈经验 |
| **数据库** | PostgreSQL 16，独立库 `junce_ai_diagnosis` | 与小程序共用实例，数据隔离 |
| **AI 调用** | Claude API / DeepSeek API | 仅报告文字润色，默认关闭 |
| **部署** | 独立 docker-compose.yml | 不修改小程序 compose |

---

## 4. 页面流程设计

### 4.1 客户侧页面

| 页面 | 路由 | 核心内容 |
|---|---|---|
| 首页 | `/` | 标题、CTA「开始免费初诊」 |
| 问卷页 | `/questionnaire` | 分组展示、单选/多选/区间/是-否 |
| 留资/验证 | `/verify/:publicId` | 手机号 + 验证码 |
| 报告页 | `/report/:publicId?token=xxx` | HTML 报告，含所有板块 |

### 4.2 后台页面

| 页面 | 路由 | 核心内容 |
|---|---|---|
| 登录 | `/admin/login` | 用户名+密码 |
| 提交列表 | `/admin/submissions` | 筛选：风险等级、复核状态 |
| 报告详情/复核 | `/admin/reports/:publicId` | 报告内容 + 复核面板 |

---

## 5. 数据模型设计（修订后）

### 5.1 枚举定义

```prisma
enum QuestionType       { SINGLE_CHOICE  MULTI_CHOICE  RANGE  YES_NO }
enum SubmissionStatus   { PENDING  SUBMITTED  DIAGNOSING  COMPLETED }
enum SubmissionSource   { WEB  MINIPROGRAM  STAFF }
enum RiskLevel          { LOW  MEDIUM  HIGH  UNKNOWN }
enum ReviewStatus       { NEED_REVIEW  AUTO_RELEASED  REVIEWED  REJECTED }
enum ReviewAction       { APPROVE  REJECT  MODIFY }
enum RecommendPriority  { STRONG  SUGGEST  INFO }
enum AdminRole          { ACCOUNTANT  MANAGER  ADMIN }
```

### 5.2 核心模型（16 个）

```prisma
model Questionnaire {
  id          Int       @id @default(autoincrement())
  version     String
  title       String
  description String?
  isActive    Boolean   @default(true)
  questions   Question[]
  submissions Submission[]
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
}

model Question {
  id              Int          @id @default(autoincrement())
  questionnaireId Int
  questionnaire   Questionnaire @relation(fields: [questionnaireId], references: [id])
  groupLabel      String
  groupOrder      Int
  orderInGroup    Int
  questionText    String
  questionType    QuestionType
  options         Json
  isRequired      Boolean       @default(false)
  riskDimension   String?
  answers         Answer[]
  diagnosisRules  DiagnosisRule[]
  createdAt       DateTime      @default(now())
  updatedAt       DateTime      @updatedAt
}

model Submission {
  id                    Int              @id @default(autoincrement())
  publicId              String           @unique @default(cuid())
  questionnaireId       Int
  questionnaire         Questionnaire    @relation(fields: [questionnaireId], references: [id])
  status                SubmissionStatus @default(PENDING)
  phone                 String?
  phoneVerified         Boolean          @default(false)
  source                SubmissionSource @default(WEB)
  miniProgramCustomerId Int?
  submittedAt           DateTime?
  answers               Answer[]
  diagnosisResult       DiagnosisResult?
  createdAt             DateTime         @default(now())
  updatedAt             DateTime         @updatedAt
}

model Answer {
  id           Int        @id @default(autoincrement())
  submissionId Int
  submission   Submission @relation(fields: [submissionId], references: [id])
  questionId   Int
  question     Question   @relation(fields: [questionId], references: [id])
  answerValue  Json
  createdAt    DateTime   @default(now())
}

model DiagnosisRule {
  id                 Int       @id @default(autoincrement())
  ruleCode           String    @unique
  dimension          String
  questionId         Int?
  question           Question? @relation(fields: [questionId], references: [id])
  triggerCondition   Json
  compositeCondition Json?
  riskLevel          RiskLevel
  riskTitle          String
  riskDescription    String
  suggestion         String
  needReview         Boolean   @default(false)
  recommendServices  Json?
  isActive           Boolean   @default(true)
  createdAt          DateTime  @default(now())
  updatedAt          DateTime  @updatedAt
}

model RiskScenario {
  id                Int       @id @default(autoincrement())
  scenarioName      String
  scenarioCode      String    @unique
  description       String
  riskLevel         RiskLevel
  triggerRules      Json
  safeExplanation   String
  forbiddenPhrases  String[]
  suggestion        String
  recommendServices Json?
  needManualReview  Boolean   @default(false)
  isActive          Boolean   @default(true)
  createdAt         DateTime  @default(now())
  updatedAt         DateTime  @updatedAt
}

model DiagnosisResult {
  id                 Int                    @id @default(autoincrement())
  submissionId       Int                    @unique
  submission         Submission             @relation(fields: [submissionId], references: [id])
  overallRiskLevel   RiskLevel
  summary            String?
  dimensionResults   Json
  findings           RiskFinding[]
  recommendations    ServiceRecommendation[]
  needReview         Boolean                @default(true)
  report             Report?
  createdAt          DateTime               @default(now())
  updatedAt          DateTime               @updatedAt
}

model RiskFinding {
  id                 Int             @id @default(autoincrement())
  diagnosisResultId  Int
  diagnosisResult    DiagnosisResult @relation(fields: [diagnosisResultId], references: [id])
  ruleId             Int?
  rule               DiagnosisRule?  @relation(fields: [ruleId], references: [id])
  scenarioId         Int?
  scenario           RiskScenario?   @relation(fields: [scenarioId], references: [id])
  riskLevel          RiskLevel
  title              String
  description        String
  suggestion         String
  recommendServices  Json?
  createdAt          DateTime        @default(now())
}

model ServiceRecommendation {
  id                 Int               @id @default(autoincrement())
  diagnosisResultId  Int
  diagnosisResult    DiagnosisResult   @relation(fields: [diagnosisResultId], references: [id])
  serviceType        String
  reason             String
  priority           RecommendPriority
  createdAt          DateTime          @default(now())
}

// ★ P0 修正 2：客户侧使用 publicId，不暴露自增 ID
model Report {
  id                 Int                    @id @default(autoincrement())
  publicId           String                 @unique @default(cuid())
  diagnosisResultId  Int                    @unique
  diagnosisResult    DiagnosisResult        @relation(fields: [diagnosisResultId], references: [id])
  reportNumber       String                 @unique
  title              String
  riskLevel          RiskLevel
  // ★ P0 修正 4：默认 NEED_REVIEW，规则引擎再设置
  reviewStatus       ReviewStatus           @default(NEED_REVIEW)
  customerVisible    Boolean                @default(false)
  htmlContent        String?
  disclaimerText     String
  reviewedById       Int?
  reviewedAt         DateTime?
  reviewRecords      ReviewRecord[]
  // ★ P0 修正 1：ReportAccessToken 关联
  accessTokens       ReportAccessToken[]
  createdAt          DateTime               @default(now())
  updatedAt          DateTime               @updatedAt
}

// ★ P0 修正 1：新增 ReportAccessToken 模型
model ReportAccessToken {
  id         Int       @id @default(autoincrement())
  reportId   Int
  report     Report    @relation(fields: [reportId], references: [id])
  tokenHash  String    // bcrypt hash，不存明文
  expiresAt  DateTime  // token 过期时间（如 7 天）
  usedAt     DateTime? // 首次使用时间
  createdAt  DateTime  @default(now())
}

model ReviewRecord {
  id         Int          @id @default(autoincrement())
  reportId   Int
  report     Report       @relation(fields: [reportId], references: [id])
  reviewerId Int          // FK → AdminUser
  reviewer   AdminUser    @relation(fields: [reviewerId], references: [id])
  action     ReviewAction
  changes    Json?
  comment    String?
  createdAt  DateTime     @default(now())
}

model ForbiddenPhrase {
  id              Int     @id @default(autoincrement())
  phrase          String
  safeAlternative String
  category        String
  isActive        Boolean @default(true)
}

model Disclaimer {
  id       Int     @id @default(autoincrement())
  version  String
  content  String
  isActive Boolean @default(true)
}

// ★ P0 修正 3：新增 SmsVerificationCode 模型
model SmsVerificationCode {
  id         Int       @id @default(autoincrement())
  phone      String
  codeHash   String    // bcrypt hash，不存明文
  scene      String    // "REPORT_ACCESS"
  expiresAt  DateTime  // 5 分钟过期
  verifiedAt DateTime?
  attempts   Int       @default(0)  // 最多 5 次
  createdAt  DateTime  @default(now())
}

model AdminUser {
  id           Int          @id @default(autoincrement())
  username     String       @unique
  passwordHash String
  realName     String
  role         AdminRole
  reviewRecords ReviewRecord[]
  createdAt    DateTime     @default(now())
  updatedAt    DateTime     @updatedAt
}
```

---

## 6. API 设计（修订后）

### 6.1 客户侧接口

| 方法 | 路径 | 说明 | 认证 |
|---|---|---|---|
| GET | `/api/questionnaire` | 获取当前问卷 | 无 |
| POST | `/api/submissions` | 提交问卷 | 无 |
| POST | `/api/leads/send-code` | 发送验证码 | 无 |
| POST | `/api/leads/verify` | 校验验证码 → 返回 reportToken | 无 |
| GET | `/api/reports/:publicId/status` | 查询报告状态 | 无 |
| GET | `/api/reports/:publicId?token=xxx` | 查看报告 | reportToken |

### 6.2 内部后台接口

| 方法 | 路径 | 说明 | 权限 |
|---|---|---|---|
| POST | `/api/admin/auth/login` | 登录 | 无 |
| GET | `/api/admin/submissions` | 提交列表 | 全部后台角色 |
| GET | `/api/admin/reports/:publicId` | 报告详情+复核记录 | 全部后台角色 |
| POST | `/api/admin/reports/:publicId/review` | 复核（APPROVE/REJECT） | 全部后台角色 |
| PATCH | `/api/admin/reports/:publicId` | 修改报告 | 主管+管理员 |

> ★ P0 修正 8：删除了 `GET /api/admin/stats` 统计接口（二期再做）。

---

## 7. 规则引擎设计

核心原则不变：规则配置驱动，AI 不参与风险判断。

```
客户答案 → 逐规则匹配 → 生成 RiskFinding → 计算风险等级 → 判断是否复核 → 映射推荐服务
```

总体风险等级规则：
- 任一 HIGH → HIGH
- 3+ MEDIUM → HIGH
- 有 MEDIUM 无 HIGH → MEDIUM
- 全 LOW 或无匹配 → LOW

进入 NEED_REVIEW 条件：
- 任一 HIGH → 强制复核
- 3+ MEDIUM → 可配置
- 信息矛盾/不足 → 强制复核
- 规则显式 needReview=true

★ P0 修正 4：Report.reviewStatus 默认 NEED_REVIEW。规则引擎后续设置 AUTO_RELEASED 仅当 LOW + 无敏感项。

---

## 8. 报告生成设计

11 步生成流程不变。★ P0 修正 10：AI 润色默认关闭。

```env
AI_POLISH_ENABLED=false
```

第一版报告使用规则配置中的原始文案生成。AI 润色为可选增强，不阻塞核心闭环。

---

## 9. 人工复核流程

### 9.1 报告状态流转

```
默认 NEED_REVIEW ──规则引擎判断──▶ 低风险无敏感 → AUTO_RELEASED, customerVisible=true
                                  ▶ 中/高风险 → NEED_REVIEW, customerVisible=false

NEED_REVIEW → 复核 APPROVE → REVIEWED, customerVisible=true
NEED_REVIEW → 复核 REJECT  → REJECTED,  customerVisible=false
AUTO_RELEASED → 后台可手动改为 NEED_REVIEW
```

### 9.2 客户侧访问控制（★ P0 修正 1）

```
客户查看报告流程：
1. 手机验证 → 获得 ReportAccessToken（明文 token 返回给客户）
2. 数据库存 tokenHash（bcrypt），不存明文
3. 客户携带 ?token=xxx 访问 GET /api/reports/:publicId
4. 后端 bcrypt.compare(token, tokenHash) 校验
5. 校验通过 + customerVisible=true → 返回报告
6. 校验通过 + customerVisible=false → 返回 { status: "PENDING_REVIEW" }
```

---

## 10. AI 调用边界

★ P0 修正 10：`AI_POLISH_ENABLED=false`。

| 环节 | AI 参与 | 说明 |
|---|---|---|
| 风险识别 | ❌ | 规则决定 |
| 风险等级 | ❌ | 规则决定 |
| 是否复核 | ❌ | 规则决定 |
| 服务推荐 | ❌ | 规则决定 |
| 报告文字润色 | ⚠️ 关闭 | 使用规则文案 |

---

## 11. 安全策略（★ P0 修正 7）

MVP 采用：

- HTTPS 生产传输
- 手机号脱敏展示（138****8000）
- .env 管理密钥，不入 git
- 数据库最小权限账号
- 后台 JWT 鉴权
- 操作日志可追溯
- 测试数据不使用真实客户敏感信息

字段级加密（AES-256）列为二期或上线前增强项。

---

## 12. 和小程序后续联动预留

- `Submission.miniProgramCustomerId` 预留字段
- 后续通过 API 对接（三种方式：被动同步 / API 拉取 / URL 跳转），不在 MVP 实现

---

## 13. 开发任务拆分（含 Phase 0）

| Phase | 内容 | 预计 |
|---|---|---|
| **Phase 0** | 项目初始化：后端骨架 + 前端骨架 + Prisma schema + seed + docker-compose | 2-3 天 |
| Phase 1 | 问卷提交 | 2-3 天 |
| Phase 2 | 规则引擎 | 3-4 天 |
| Phase 3 | 报告生成 | 2-3 天 |
| Phase 4 | 后台+人工复核 | 2-3 天 |
| Phase 5 | PDF + 部署（MVP-B） | 2-3 天 |

---

## 14. 风险与注意事项

| 风险 | 应对 |
|---|---|
| AI 越界 | Prompt 约束 + 后置规则检查 + 默认关闭 AI 润色 |
| 客户信息泄露 | HTTPS + 脱敏 + JWT + 操作日志 |
| 财税结论责任 | 免责声明 + 高风险强制复核 + 不设指令性结论 |
| 过度设计 | 严守 MVP 边界，配置优于代码 |
| 规则不完整 | 规则配置化，缺失项 TODO 占位 |

---

## 部署边界（★ P0 修正 5）

- AI 初诊项目拥有独立 docker-compose.yml。
- 本地开发和部署都不修改小程序项目。
- 生产部署时可通过 Nginx 反向代理和小程序并列运行。
- 后续如需同服务器部署，只在部署文档中说明，不直接改小程序 compose。

---

> **v2 修订记录**（2026-06-22）：共修正 10 项 P0 问题。
> 1. 新增 ReportAccessToken 模型及客户侧访问控制流程
> 2. Submission/Report 增加 publicId，客户侧接口统一使用
> 3. 新增 SmsVerificationCode 模型
> 4. Report.reviewStatus 默认 NEED_REVIEW
> 5. 独立 docker-compose，不合并小程序
> 6. 前端技术栈改为 Vue3 + Vite + TS + Pinia + Tailwind CSS
> 7. 删除 AES-256 全量加密，改为 MVP 基础安全策略
> 8. 删除 GET /api/admin/stats
> 9. PDF 列为 MVP-B
> 10. AI_POLISH_ENABLED=false

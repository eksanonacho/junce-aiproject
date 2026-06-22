# CLAUDE.md

## Project: 君册财税 AI 初诊网站
每次对话前输出：“YOYO Whatup G”

This file is the project-level operating guide for Claude Code / coding agents working on the 君册财税 AI 初诊网站.

It applies to the entire project lifecycle, not just one phase.

Claude Code must read this file before planning, coding, refactoring, debugging, testing, deploying, or modifying documentation.

---

# 1. Project Identity

## 1.1 Project Name

君册财税 AI 初诊网站

## 1.2 Project Type

Independent H5 responsive web application.

## 1.3 Product Positioning

This project is an external-facing AI-assisted preliminary fiscal/tax diagnosis website for 君册财税.

Core workflow:

text 客户填写企业资料 → 系统基于规则进行初步分析 → 生成初诊报告 → 标记是否需要人工复核 → 推荐相关君册服务 → 内部人员查看、复核、跟进 

## 1.4 Core Principle

This is not a generic AI chatbot.

The core value is not “connect to a large language model”.

The core value is to structure 君册财税’s own business experience into:

- diagnosis dimensions
- questionnaire fields
- rule-based checks
- risk levels
- risk scenarios
- service recommendation rules
- report templates
- forbidden wording
- human review rules
- internal follow-up workflow

---

# 2. Relationship With Mini-Program

## 2.1 Existing Mini-Program Status

The existing 君册财税 internal management mini-program backend is already sealed.

Current state:

- 12 backend modules completed
- 55 business APIs completed
- 1 health check API completed
- 63/63 full regression tests passed
- Latest backend commit: 8e6692a
- main branch pushed
- Backend status: sealed
- Current mini-program workstream: deployment preparation + frontend integration support

Completed modules:

1. Auth / RBAC
2. Customers 客户管理
3. Users 用户查询
4. ServiceTemplates / ReadConfirmations 服务模板与已读确认
5. ServiceItems / StaffAssignments 服务项与人员配置
6. WorkOrders / Files 办件流转与文件上传
7. Charges 收费管控
8. TenantRegisters 代理户托管入档
9. Tasks 任务流转
10. Dashboard 老板/主管看板
11. Fission 业务裂变
12. ManualDashboard 经营/工资手动看板

Frontend status:

- Phase 1-3 integration completed
- 21 APIs and 11 pages verified
- Phase 4 Charges integration is next
- Frontend must follow API_CONTRACT.md and FRONTEND_HANDOFF.md

---

## 2.2 Absolute Boundary

The AI 初诊 website is not a new mini-program module.

The mini-program is for internal management:

text OA + CRM + task flow + charge control + dashboard 

The AI 初诊 website is for external diagnosis and lead generation:

text questionnaire + rule screening + report + review + service recommendation 

They are related, but independent.

---

## 2.3 Do Not Modify Mini-Program

Mini-program project path:

bash /Users/a1234/cpp/junce-miniprogram/ 

Unless the project owner explicitly instructs otherwise, do not modify anything under that path.

Forbidden actions:

- Do not change mini-program backend code
- Do not change mini-program frontend code
- Do not change mini-program Prisma schema
- Do not change mini-program migrations
- Do not change mini-program Docker configuration
- Do not add AI diagnosis APIs to mini-program backend
- Do not add AI diagnosis as a mini-program module
- Do not alter sealed business logic
- Do not use chat history as API contract

Mini-program docs copied into this project are read-only references.

---

## 2.4 Future Integration Is Allowed, But Not MVP Coupling

The AI 初诊 website may later integrate with mini-program customer files.

Possible future integrations:

- prefill AI diagnosis questionnaire from existing customer profile
- sync AI diagnosis result into customer file
- create customer in mini-program from AI lead
- generate follow-up task for business staff
- attach diagnosis report to customer record

However, MVP must run independently.

First version must not depend on mini-program backend changes.

---

# 3. Project Directory

AI 初诊 project root:

bash /Users/a1234/Desktop/junce-aiproject/ 

Expected long-term structure:

bash junce-aiproject/ ├── CLAUDE.md ├── README.md ├── docs/                         # copied mini-program docs, read-only reference ├── AI-docs/                      # AI diagnosis project docs ├── AI_DIAGNOSIS_MVP_DEV_PLAN.md ├── ai-diagnosis-server/          # NestJS backend ├── ai-diagnosis-client/          # Vue3 frontend ├── docker-compose.yml            # independent AI project compose └── deployment/                   # deployment notes, nginx config, env templates 

If this structure changes, update documentation immediately.

---

# 4. Source of Truth Priority

When information conflicts, use this priority order:

1. CLAUDE.md
2. AI_DIAGNOSIS_MVP_DEV_PLAN.md
3. AI diagnosis requirements / analysis docs
4. Current code in this AI project
5. Copied mini-program docs under docs/
6. Conversation context

For mini-program API details, trust only:

- docs/API_CONTRACT.md
- docs/FRONTEND_HANDOFF.md

Do not rely on chat history as API contract.

---

# 5. Product Scope

## 5.1 MVP Core Loop

The MVP must complete this loop:

text 客户打开网站 → 填写初诊问卷 → 提交联系方式 → 系统执行规则诊断 → 生成结构化报告 → 判断是否需要人工复核 → 客户查看允许展示的报告 → 内部人员查看提交记录 → 内部人员复核敏感/高风险报告 

---

## 5.2 MVP Required Capabilities

MVP should include:

- customer questionnaire
- answer persistence
- rule-based diagnosis
- risk finding generation
- overall risk level calculation
- service recommendation mapping
- report generation
- disclaimer injection
- forbidden wording check
- customer report access control
- admin login
- admin submission list
- admin report detail
- human review status
- review record
- basic deployment readiness

---

## 5.3 MVP Optional / Later Capabilities

Do not build these unless the current phase explicitly requires them:

- visual rule editor
- visual questionnaire editor
- advanced dashboard statistics
- automatic mini-program synchronization
- multi-turn AI agent conversation
- automatic quotation
- customer account system
- complex CRM workflow
- automatic business assignment
- multi-template report designer
- AI training on historical cases
- full field-level encryption

---

# 6. Technical Stack

## 6.1 Backend

Use:

- NestJS
- TypeScript
- Prisma
- PostgreSQL
- JWT for admin authentication
- bcrypt for password hashing
- class-validator / class-transformer
- pnpm

Backend port:

text 3001 

Health endpoint:

http GET /health 

Expected response:

json {   "status": "ok",   "service": "ai-diagnosis-server" } 

---

## 6.2 Frontend

Use:

- Vue3
- Vite
- TypeScript
- Pinia
- Vue Router
- Tailwind CSS

Reason:

- The existing mini-program frontend ecosystem is Vue-based
- The AI diagnosis site is mainly form/report/admin pages
- Vue3 is sufficient and easier to maintain in this project context

Do not switch to React unless explicitly requested by the project owner.

---

## 6.3 Database

Use PostgreSQL.

Recommended database name:

text junce_ai_diagnosis 

The AI diagnosis database must be independent from the mini-program database.

Shared PostgreSQL instance is acceptable, but use a separate database.

---

## 6.4 Deployment

Use independent Docker Compose for this AI project.

Do not merge with or modify mini-program Docker Compose unless explicitly instructed.

Production may later run both projects on the same server via Nginx reverse proxy.

---

# 7. System Architecture

## 7.1 High-Level Architecture

text Customer Browser / Mobile H5         |         v Vue3 Client         |         v NestJS API Server         |         +--> PostgreSQL         |         +--> Rule Engine         |         +--> Report Generator         |         +--> Optional AI Polish Service         |         +--> SMS Provider         |         +--> PDF Generator 

---

## 7.2 Core Modules

Backend modules should be separated clearly:

text health              health check auth                admin JWT auth admin               admin user and permissions questionnaire       questionnaire definitions submissions         customer submissions and answers diagnosis           rule engine and diagnosis result reports             report generation and report access review              manual review workflow sms                 SMS verification forbidden-phrases   forbidden wording check disclaimers         disclaimer management common              shared utilities, filters, guards 

---

# 8. Domain Model

Core business objects:

text Questionnaire          问卷模板 Question               问卷题目 Submission             客户提交 Answer                 客户答案 DiagnosisRule          诊断规则 RiskScenario           风险场景 RiskFinding            命中风险项 DiagnosisResult        诊断结果 ServiceRecommendation  服务推荐 Report                 初诊报告 ReportAccessToken      报告访问令牌 ReviewRecord           人工复核记录 ForbiddenPhrase        禁用话术 Disclaimer             免责声明 SmsVerificationCode    短信验证码 AdminUser              后台用户 

---

# 9. Data Model Invariants

These rules apply throughout the project.

## 9.1 Do Not Expose Auto-Increment IDs to Customers

Customer-facing URLs and APIs must not expose internal numeric IDs.

Use publicId.

Required for customer-visible resources:

prisma publicId String @unique @default(cuid()) 

At minimum:

- Submission.publicId
- Report.publicId

Admin APIs may use internal IDs when appropriate.

---

## 9.2 Report Access Must Be Tokenized

Customer report access must require:

text report publicId + report access token 

Do not store report tokens in plaintext.

Store:

- tokenHash
- expiresAt
- usedAt
- createdAt

Required model:

prisma model ReportAccessToken {   id        Int      @id @default(autoincrement())   reportId  Int   report    Report   @relation(fields: [reportId], references: [id])   tokenHash String   expiresAt DateTime   usedAt    DateTime?   createdAt DateTime @default(now()) } 

---

## 9.3 SMS Codes Must Not Be Stored in Plaintext

Required model:

prisma model SmsVerificationCode {   id         Int       @id @default(autoincrement())   phone      String   codeHash   String   scene      String   expiresAt  DateTime   verifiedAt DateTime?   attempts   Int       @default(0)   createdAt  DateTime  @default(now()) } 

Required behavior:

- 5-minute expiration
- 60-second resend interval
- max 5 verification attempts
- hash code before storing
- mark verifiedAt on success

---

## 9.4 Reports Must Default to Not Visible

Reports should not default to visible.

Default:

prisma reviewStatus ReviewStatus @default(NEED_REVIEW) customerVisible Boolean @default(false) 

Visibility is decided after diagnosis.

Allowed transitions:

text LOW + safe → AUTO_RELEASED + customerVisible=true MEDIUM → usually NEED_REVIEW HIGH → NEED_REVIEW UNKNOWN → NEED_REVIEW conflicting answers → NEED_REVIEW sensitive trigger → NEED_REVIEW 

---

# 10. Required Enums

Recommended enums:

prisma enum RiskLevel {   LOW   MEDIUM   HIGH   UNKNOWN }  enum ReviewStatus {   AUTO_RELEASED   NEED_REVIEW   REVIEWED   REJECTED }  enum SubmissionStatus {   PENDING   SUBMITTED   DIAGNOSING   COMPLETED   FAILED }  enum QuestionType {   SINGLE_CHOICE   MULTI_CHOICE   RANGE   YES_NO   TEXT }  enum RecommendPriority {   STRONG   SUGGEST   INFO }  enum AdminRole {   ACCOUNTANT   MANAGER   ADMIN } 

Customer-facing text must not directly show internal enum names.

Example:

text STRONG → 建议优先了解 SUGGEST → 建议关注 INFO → 可作为后续优化方向 

---

# 11. Rule Engine Principles

## 11.1 Rules Decide Diagnosis

The rule engine decides:

- which findings are triggered
- each finding risk level
- overall risk level
- whether manual review is required
- which services are recommended
- whether report may be customer-visible

AI must not decide these.

---

## 11.2 Rule Configuration

MVP may use:

- seed data
- JSON config
- YAML config
- database rows created by seed

Do not build a visual rule editor in MVP unless explicitly required.

---

## 11.3 Diagnosis Dimension Handling

Do not invent “九维” or “四维”.

If confirmed business docs define 九维/四维, use them.

If not confirmed, use generic:

text diagnosis dimensions 

The system should support configurable dimensions without hardcoding the number of dimensions.

---

## 11.4 Overall Risk Logic

Recommended MVP logic:

text Any HIGH finding → overall HIGH 3 or more MEDIUM findings → overall HIGH, configurable later Any MEDIUM finding → overall MEDIUM No meaningful finding → overall LOW Insufficient/conflicting answers → UNKNOWN 

Manual review required if:

- overall risk is HIGH
- overall risk is UNKNOWN
- rule has needReview = true
- customer answers conflict
- too many “不清楚” answers
- required data is missing
- sensitive scenario is triggered

---

# 12. AI Usage Boundary

## 12.1 AI Disabled by Default

MVP must work without AI.

Use:

env AI_POLISH_ENABLED=false 

If AI API fails, report generation must still work using rule text.

---

## 12.2 Allowed AI Tasks

AI may only polish already-structured content:

- report summary
- risk explanation
- suggestion wording

AI must not:

- create new risks
- change risk level
- remove findings
- add services
- change manual review status
- remove disclaimer
- invent facts
- make professional final conclusions
- use forbidden words

---

## 12.3 Rule-First Report Generation

Report flow:

text answers → rules → findings → risk level → review status → recommendations → report JSON → optional AI polish → forbidden phrase check → disclaimer → save report 

Never let AI generate the report from raw answers without structured rules.

---

# 13. Compliance and Wording Boundary

## 13.1 Forbidden Wording

Do not allow report content to contain dangerous phrasing such as:

text 违法了 必须补税 一定会被罚 保证解决 保证通过 一定没有风险 可以避税 走私人账户 税局不会查 肯定能注销成功 一定能省多少钱 

Use safer wording:

text 可能存在合规风险 建议进一步核查 建议由专业人员复核 根据目前信息暂未发现明显高风险项 具体情况需结合完整资料判断 

---

## 13.2 Disclaimer Required

Every customer-visible report must include disclaimer text.

The report must clearly state:

- it is preliminary screening only
- it is based on information provided by the customer
- it is not final tax/legal/financial advice
- high-risk or sensitive issues require manual review
- final conclusions must be confirmed by professionals

---

# 14. API Design Rules

## 14.1 Customer APIs

Customer APIs must be simple and tokenized.

Recommended:

http GET  /api/questionnaire POST /api/submissions POST /api/leads/send-code POST /api/leads/verify GET  /api/reports/:publicId/status GET  /api/reports/:publicId?token=xxx GET  /api/reports/:publicId/pdf?token=xxx 

PDF may be MVP-B.

---

## 14.2 Admin APIs

Admin APIs require JWT.

Recommended:

http POST /api/admin/auth/login GET  /api/admin/submissions GET  /api/admin/reports/:id POST /api/admin/reports/:id/review PATCH /api/admin/reports/:id 

Do not add statistics/dashboard APIs until needed.

---

## 14.3 Error Handling

Use clear error responses.

Examples:

json {   "message": "Report not found",   "code": "REPORT_NOT_FOUND" } 

Do not expose internal stack traces to clients.

---

# 15. Frontend Rules

## 15.1 Customer Pages

Customer pages should be mobile-first.

Required route categories:

text /  /questionnaire  /questionnaire/success  /report/:publicId 

Important UX principles:

- simple language
- low friction
- progress indicator for questionnaire
- support “不清楚” option where appropriate
- do not overwhelm customer with too many questions at once
- make disclaimer visible but not hostile

---

## 15.2 Admin Pages

Admin pages can be desktop-first.

Required route categories:

text /admin/login /admin/submissions /admin/reports/:id 

Admin pages should prioritize:

- risk level visibility
- review status visibility
- phone masking
- submission time
- report detail
- review actions
- review logs

---

# 16. Security Rules

Minimum security requirements:

- no secrets in Git
- .env.example must not contain real secrets
- bcrypt for passwords
- JWT for admin auth
- DTO validation on backend
- tokenized customer report access
- no numeric IDs in customer-facing URLs
- no plaintext SMS codes
- no plaintext report tokens
- phone masking in admin list
- basic rate limiting for SMS
- production HTTPS
- no real customer data in seed files

Do not overbuild full field-level encryption unless explicitly requested.

---

# 17. Development Phases

This project may be developed in phases.

The phase plan below is a guide. Current task prompts decide the active phase.

## Phase 0: Project Initialization

Goal:

text independent skeleton works 

Includes:

- backend project
- frontend project
- PostgreSQL
- Prisma schema
- migration
- seed
- health check
- basic frontend routes
- independent docker-compose

---

## Phase 1: Questionnaire

Goal:

text customer can fetch questionnaire and submit answers 

Includes:

- questionnaire seed
- questionnaire API
- submission API
- answer persistence
- frontend questionnaire flow
- basic validation

---

## Phase 2: Rule Engine

Goal:

text answers produce structured diagnosis result 

Includes:

- rule loading
- rule matching
- finding generation
- risk level calculation
- review status decision
- service recommendation mapping
- unit tests

---

## Phase 3: Report Generation

Goal:

text diagnosis result renders into customer report 

Includes:

- report JSON
- HTML report
- disclaimer
- forbidden phrase check
- report token
- report visibility logic
- customer report page

---

## Phase 4: Admin Review

Goal:

text internal staff can review and control reports 

Includes:

- admin login
- submission list
- report detail
- approve/reject
- modify report content if permitted
- review logs
- customer visibility control

---

## Phase 5: PDF and Deployment

Goal:

text MVP-B launch readiness 

Includes:

- PDF export
- Docker deployment
- production env docs
- Nginx notes
- smoke test checklist

---

## Phase 6: Mini-Program Integration

Goal:

text optional future data linkage 

Includes only if explicitly required:

- sync AI diagnosis lead to mini-program customer file
- prefill AI questionnaire from mini-program customer data
- create follow-up task in mini-program
- attach report to customer record

This phase must not be started without explicit approval.

---

# 18. Coding Standards

## 18.1 General

- TypeScript strictness preferred
- no hidden side effects
- readable code over clever abstractions
- avoid premature generalization
- do not overbuild MVP
- write DTOs for API input validation
- use services for business logic
- keep controllers thin
- keep rule engine testable
- use explicit enums
- write meaningful error messages

---

## 18.2 Backend Structure

Recommended backend structure:

text src/ ├── main.ts ├── app.module.ts ├── health/ ├── prisma/ ├── auth/ ├── admin/ ├── questionnaire/ ├── submissions/ ├── diagnosis/ ├── reports/ ├── review/ ├── sms/ ├── forbidden-phrases/ ├── disclaimers/ └── common/ 

Business logic should not live in controllers.

Rule matching should be isolated and testable.

---

## 18.3 Frontend Structure

Recommended frontend structure:

text src/ ├── main.ts ├── router/ ├── stores/ ├── api/ ├── types/ ├── components/ ├── pages/ └── admin/ 

Customer-side and admin-side UI should be clearly separated.

---

# 19. Testing Rules

Before claiming completion, run relevant checks.

Minimum checks over project lifecycle:

- backend starts
- frontend starts
- health check works
- Prisma migration works
- seed works
- questionnaire fetch works
- submission creates answers
- rule engine returns expected risk
- high-risk input triggers review
- low-risk safe input can auto-release
- report access token works
- forbidden phrase check works
- admin login works
- review creates record
- customer visibility follows review status

Do not claim tests passed without running them.

If a test is not run, say so.

---

# 20. AI-docs 项目记忆层使用规则

AI-docs/ 是本项目的"项目记忆层"。以后即使换 agent、换大模型、换对话，只要读取 CLAUDE.md + AI-docs/，就必须能马上知道：

- 项目是什么
- 当前做到哪
- 哪些已经验证
- 哪些不能乱改
- 下一步该做什么
- 哪些资料缺失
- 哪些风险要避开
- 数据库和接口如何演进

---

## 20.1 每次开发前必须读取的文件

每次开始新模块、新功能、修 bug、改接口、改数据库、联调前，都必须先阅读并参考：

- AI-docs/README.md（项目总览，第一次必读）
- AI-docs/AI_DIAGNOSIS_MVP_DEV_PLAN.md（MVP 开发方案，当前最高开发依据）
- AI-docs/PROJECT_CONTEXT.md（项目背景、与小程序关系、商务条款、技术约束）
- AI-docs/PROJECT_STATE_SNAPSHOT.md（当前项目进度快照，必须保持最新）
- AI-docs/ROADMAP.md（开发路线图和依赖关系）
- AI-docs/API_CONTRACT.md（前后端接口契约）
- AI-docs/DATABASE_GUIDE.md（数据库表、枚举、关系、migration 规则）
- AI-docs/SYSTEM_ARCHITECTURE.md（系统架构、前后端分层、请求链路）
- AI-docs/TESTING_GUIDE.md（测试命令、回归测试、已知测试坑）
- AI-docs/RISK_ANALYSIS.md（项目风险、合规风险、技术风险）
- AI-docs/CTO_NOTES.md（技术负责人提醒、不能乱改的地方、已知技术债）
- AI-docs/AI_WEBDEVELOP_REQS.md（面向纪姐的需求资料清单，需要补充业务规则时参考）
- AI-docs/project-note.md（开发日志/学习手册，了解已有实现细节和踩坑记录）

如果本次任务涉及前端或前后端联调，还必须读取：

- AI-docs/FRONTEND_HANDOFF.md

如果本次任务涉及部署、Docker、环境变量、上线，还必须读取：

- AI-docs/DEPLOYMENT_GUIDE.md

---

## 20.2 每个文件的用途

| 文件 | 用途 |
|------|------|
| README.md | AI 初诊项目总览/入口文档，技术栈、硬边界、阻塞项、商务信息、文档索引 |
| AI_DIAGNOSIS_MVP_DEV_PLAN.md | MVP 开发方案，最高开发依据，含功能范围、数据模型、API 设计、规则引擎、报告生成、分阶段任务 |
| PROJECT_CONTEXT.md | 项目背景、与小程序关系、商务条款、部署架构、小程序可复用字段 |
| PROJECT_STATE_SNAPSHOT.md | 当前项目进度快照，必须保持最新 |
| ROADMAP.md | 模块开发顺序和依赖关系，决定下一步先做什么 |
| API_CONTRACT.md | 前后端接口契约。新增或修改后端接口后必须同步更新 |
| DATABASE_GUIDE.md | 数据库表、枚举、关系、migration 规则。涉及数据库前必须阅读 |
| SYSTEM_ARCHITECTURE.md | 整体架构、前后端分层、请求链路、模块关系 |
| TESTING_GUIDE.md | 测试命令、回归测试、已知测试坑。每次改完代码必须参考 |
| RISK_ANALYSIS.md | 项目风险、合规风险、AI 越界风险、资料缺失风险。开发前必须检查是否触发风险 |
| CTO_NOTES.md | 技术负责人提醒、不能乱改的地方、已知技术债、产品风险 |
| FRONTEND_HANDOFF.md | 给前端同学的交接说明。涉及前端页面或联调时必须同步 |
| DEPLOYMENT_GUIDE.md | 部署、Docker、环境变量、备份、上线 checklist |
| AI_WEBDEVELOP_REQS.md | 面向纪姐的需求资料清单，含问卷字段、九维/四维规则、风险场景、FAQ、服务推荐、禁用话术、提问清单 |
| project-note.md | 开发日志/学习手册，每一步操作的教学讲解、大白话解释、踩坑记录、验证命令 |

---

## 20.3 固定开发流程

每次开发模块必须按以下流程：

1. 先阅读 CLAUDE.md、AI_DIAGNOSIS_MVP_DEV_PLAN.md 和 AI-docs/ 下相关文档。
2. 先输出 plan，不要直接写代码。
3. plan 必须包含：
   - 本模块目标
   - 依赖的客户资料是否齐全
   - 缺失资料如何 TODO、占位，不编造规则
   - 涉及哪些数据库表
   - 是否需要新增或修改 Prisma migration
   - 是否影响已有数据
   - 涉及哪些接口
   - 涉及哪些权限
   - 是否涉及 AI 调用、风险判断、禁用话术
   - 是否影响前端
   - 正向和反向验证方案
   - 需要同步更新哪些 AI-docs 文件
4. 主理人确认 plan 后，才能写代码。
5. 写完后必须 pnpm build 通过。
6. 必须给出测试命令并执行。
7. 测试必须包含：
   - 正向测试：该成功的请求必须成功
   - 反向测试：未登录、越权、参数错误必须被正确拦截
8. 主理人测试通过后，再更新相关文档。
9. 每次结束必须报告：
   - 本次完成了什么
   - 验证了什么
   - 修改了哪些文件
   - 更新了哪些 AI-docs
   - 下一步建议做什么
   - 是否触碰小程序项目

---

## 20.4 AI-docs 更新规则

### 20.4.1 什么时候必须更新（触发条件）

以下任何一种情况发生时，必须在当前任务结束前更新对应的 AI-docs 文件：

| 触发条件 | 必须更新的文件 |
|---------|-------------|
| 新增/修改/删除后端接口 | AI-docs/API_CONTRACT.md |
| 新增/修改数据库表、枚举、字段 | AI-docs/DATABASE_GUIDE.md |
| 新增/修改 Prisma migration | AI-docs/DATABASE_GUIDE.md |
| 模块状态变化（未开始→进行中→已完成） | AI-docs/PROJECT_STATE_SNAPSHOT.md、AI-docs/ROADMAP.md |
| 项目阶段推进（Phase N → Phase N+1） | AI-docs/PROJECT_STATE_SNAPSHOT.md（更新快照日期）、AI-docs/ROADMAP.md |
| 新增/修改测试命令或测试流程 | AI-docs/TESTING_GUIDE.md |
| 测试通过（模块验收） | AI-docs/TEST_RESULTS.md |
| 系统架构变化（新增模块、改变分层） | AI-docs/SYSTEM_ARCHITECTURE.md |
| 前端页面新增/修改 | AI-docs/FRONTEND_HANDOFF.md |
| 发现新风险、技术债、关键坑 | AI-docs/RISK_ANALYSIS.md 和/或 AI-docs/CTO_NOTES.md |
| 部署配置变化（Docker、Nginx、环境变量） | AI-docs/DEPLOYMENT_GUIDE.md |
| 项目全局变化（新增/删除模块、接口总数变化、表总数变化） | AI-docs/README.md 对应章节 |
| 完成任何开发步骤（编码、配置、调试、修复） | AI-docs/project-note.md |
| 客户资料到货（纪姐提供了新规则、新场景、新模板等） | AI-docs/AI_WEBDEVELOP_REQS.md（标记已到货）、AI-docs/PROJECT_STATE_SNAPSHOT.md |
| 方案修订（MVP 范围变化、技术选型变化） | AI-docs/AI_DIAGNOSIS_MVP_DEV_PLAN.md |
| 需求边界澄清（纪姐确认或否定某个功能） | AI-docs/AI_DIAGNOSIS_MVP_DEV_PLAN.md、AI-docs/PROJECT_CONTEXT.md |

### 20.4.2 怎么更新（更新规范）

**更新任何 AI-docs 文件时，必须遵守以下规范：**

1. **更新时间戳**：文件顶部有"最后更新"日期的，必须更新为当天日期。
2. **保留原有结构**：不要随意改变文件的章节结构。新增内容时，在合适的章节内追加，而不是重写整个文件。
3. **标注状态**：涉及状态变化时，使用统一标记：
   - ✅ 已完成
   - 🔄 进行中
   - ⬜ 未开始
   - ⏳ 等客户补资料
   - ⚠️ 有风险/需关注
4. **不要删除历史内容**：project-note.md 和 TEST_RESULTS.md 是累加记录，新内容追加在文件顶部（新日期在上）或按时间顺序追加。
5. **快照类文件覆盖更新**：PROJECT_STATE_SNAPSHOT.md 是"当前快照"，更新时替换旧状态为新状态（但保留已完成模块的历史记录）。
6. **接口/数据库文档必须精确**：API_CONTRACT.md 和 DATABASE_GUIDE.md 中的字段名、类型、枚举值必须与实际代码完全一致，一字不差。
7. **占位文件转为正式文件时**：如果某个文件从"占位"变为"有实际内容"，必须：
   - 删除文件顶部的"⚠️ 本文件为占位"提示
   - 填充正式内容
   - 在 AI-docs/README.md 中将状态从 ⏳ 更新为 ✅

### 20.4.3 project-note.md 特别规范

project-note.md 是本项目的开发日志和学习手册，每次开发步骤都必须追加记录。

格式要求：

- 每个条目带日期标题（`## YYYY-MM-DD 第N步：做了什么`）
- 每个条目包含：
  - **做了什么**：具体操作和产出
  - **为什么这么做**：设计决策的原因
  - **大白话解释**：新工具、新概念用通俗语言解释（面向未来的学习者）
  - **踩坑记录**：遇到的错误、原因、解决方案
  - **验证命令**：可复制的 bash 命令和预期结果
- 不要在 project-note.md 中写"见某某文档"——直接写清楚，保证独立可读
- 如果本次开发涉及多个子步骤，可以在一个日期标题下分小节记录

### 20.4.4 更新完成后必须向用户报告

每次 AI-docs 更新完成后，必须在回复中明确告知用户：

```
📝 AI-docs 更新报告：

| 文件 | 更新内容 | 原因 |
|------|---------|------|
| AI-docs/xxx.md | 具体改了什么 | 为什么需要改 |
| AI-docs/yyy.md | 具体改了什么 | 为什么需要改 |
```

如果有文件按触发条件应该更新但本次未更新，必须说明原因（如"API_CONTRACT.md 本次不涉及接口变更，跳过"）。

---

## 20.5 AI-docs 和 docs/ 的关系

- **AI-docs/**：AI 初诊网站专属文档，开发过程中主动维护和更新。
- **docs/**：小程序文档的只读拷贝，用于理解业务背景和小程序已有功能。**不做任何修改。**
- 小程序的技术约束（金额 Decimal 12,2、JWT RBAC 模式、Prisma migration 规范等）已提取到 AI-docs/PROJECT_CONTEXT.md，开发 AI 初诊时以 AI-docs 为准。
- docs/ 中的 AI_WEBDEVELOP_REQS.md 已拷贝到 AI-docs/，后续如需补充纪姐的需求资料，更新 AI-docs 版本。

---

## 20.6 当前 AI 初诊项目硬边界

必须牢记：

- AI 初诊网站是独立项目，不是小程序新模块。
- 小程序后端已封板，不新增接口、不改 schema、不改 docker-compose。
- AI 不做最终专业判断，只做初筛。
- 风险识别、风险等级、是否复核、推荐服务必须由规则决定，AI 不参与判断。
- AI 润色默认关闭（AI_POLISH_ENABLED=false）。
- 第一版只做 MVP 范围：问卷 → 规则诊断 → 报告 → 人工复核 → 服务推荐。
- 不做复杂多轮 Agent、不做自动报价、不做后台可视化规则编辑器、不做自动同步小程序。
- 九维/四维规则缺失时，统一称"诊断维度"，不编造具体内容。
- 客户侧 URL 和接口不得暴露自增 ID，必须使用 publicId。
- 报告默认 customerVisible=false，高风险报告必须人工复核后才能给客户。
- SMS 验证码和 ReportAccessToken 不得明文存储。
- 每份客户可见报告必须包含免责声明。
- 所有金额字段使用 Decimal(12,2)，禁止 float。
- 涉及纪姐未提供的业务规则，只标记 TODO，不允许编造。

---

# 21. Git Rules

Before work:

bash pwd git status 

Confirm current directory is AI project, not mini-program project.

After meaningful completion:

bash git status git add . git commit -m "..." 

Commit message should be specific.

Do not commit:

- .env
- secrets
- real customer data
- generated local cache
- node_modules
- database dumps with real data

---

# 22. Reporting Rules

After each task, report:

- what was done
- files created
- files modified
- commands run
- tests run
- test results
- migration result
- seed result
- known issues
- next recommended step
- whether mini-program project was touched

If mini-program project was not touched, explicitly say:

text 未修改 /Users/a1234/cpp/junce-miniprogram/ 

---

# 23. Decision Rules

When uncertain:

1. Prefer MVP simplicity.
2. Prefer rule-driven logic over AI-driven logic.
3. Prefer explicit configuration over hidden inference.
4. Prefer independent AI project over mini-program coupling.
5. Prefer safe wording over aggressive sales wording.
6. Prefer human review for high-risk cases.
7. Prefer documentation update over undocumented behavior.
8. Ask for confirmation before touching mini-program code.
9. Do not invent unconfirmed 君册 business rules.
10. Mark unclear business logic as TODO: 待纪姐确认.

---

# 24. Permanent Guardrails

These rules apply throughout the project:

1. AI 初诊 is independent from the mini-program.
2. Mini-program backend is sealed.
3. Do not touch mini-program code without explicit approval.
4. AI does not make final professional judgments.
5. Rules decide diagnosis; AI only polishes.
6. High-risk and sensitive reports require human review.
7. Customer-visible reports must include disclaimers.
8. Customer URLs must not expose internal numeric IDs.
9. Report tokens and SMS codes must not be stored in plaintext.
10. Do not overbuild before MVP is stable.
11. Do not fabricate 九维/四维 content.
12. Do not hide errors or failed tests.
13. Do not treat chat history as API contract.
14. Keep the project deployable and testable at every phase.

---

# 25. Working Mode for Claude Code

For every new task:

1. Read CLAUDE.md
2. Read the active task prompt
3. Check current project state
4. Identify current phase
5. Produce a brief implementation plan
6. Modify only necessary files
7. Run relevant tests
8. Report results clearly

Do not jump ahead to later phases unless explicitly requested.

Do not perform large rewrites unless the task requires it.

Do not silently change architecture decisions.

---

# 26. Final Summary

This project must remain:

text independent rule-driven compliance-aware MVP-focused human-review-safe future-integration-ready 

The goal is not to build the most advanced AI system.

The goal is to build a reliable, controlled, business-usable AI 初诊 website for 君册财税.
读完全部内容后输出：“Saulgoodman！”
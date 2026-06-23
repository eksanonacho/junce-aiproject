# 君册财税 AI 初诊网站 — 开发日志 / 学习手册

> 每完成一步就记录在这里。格式：**做了什么** + **为什么这么做** + **踩了哪些坑** + **怎么验证**。

---

## 2026-06-23 第12步：V2 企业经营初诊系统 — 全量重构

### 做了什么

完成 V2 全量重构，将系统从「AI财税问卷」升级为「君册企业经营初诊系统」。

**后端（9 个新接口 + 5 个模块扩展）**：
1. **新增 DocumentModule**：资料上传/列表/删除/checklist + 管理员下载。本地文件存储 `uploads/{submissionPublicId}/{documentPublicId}.{ext}`，含 MIME 白名单、20MB 限制、文件名 sanitize、路径穿越防护。
2. **新增 BusinessDashboardModule**：四维评分引擎。基础分4.0，扣分 = HIGH×1.5 + MEDIUM×0.8 + 文档缺失×0.3-0.8。综合 = 利润×0.25 + 风险×0.35 + 现金流×0.25 + 效率×0.15。自动生成一句话结论 + TOP3 行动建议。
3. **扩展 SubmissionModule**：POST /start（创建 DRAFT + bcrypt tokenHash）、POST /:id/complete（保存答案→计算完整度→诊断→看板→报告）
4. **扩展 QuestionnaireModule**：`?version=v2` 返回 65 题九维问卷
5. **扩展 RuleEngine**：conditionMode = SIMPLE/COMPOSITE。COMPOSITE 支持 `{logic:"AND"|"OR", conditions:[...]}`，每个子条件可用 `questionPublicId`。
6. **扩展 ReportService**：customerVisible=false → 返回 `{status:"PENDING_REVIEW"}` 禁止返回详情。
7. **扩展 AdminService**：返回 dashboard + uploadedDocuments + dimensionRuleHits。

**数据库（18 模型 8 枚举）**：
- 新增 DiagnosisMode 枚举（QUICK/STANDARD/DEEP）
- 新增 DocumentRequirement + UploadedDocument 模型
- Submission 新增 5 字段（mode/documentCompletenessScore/documentCompletenessDetail/accessTokenHash/accessTokenCreatedAt）
- DiagnosisResult 新增 dashboardData (Json?)
- DiagnosisRule 新增 conditionMode @default("SIMPLE")
- Question 新增 skipLogic (Json?)
- SubmissionStatus 追加 3 个值（DRAFT/DOCUMENT_UPLOADING/QUESTIONNAIRE_COMPLETED）

**Seed 数据（65 题 + 55 规则 + 12 场景）**：
- 拆分结构：prisma/seed/v2-*.ts × 5 个文件，seed.ts 末尾追加调用，V1 不动
- 65 题 V2 问卷，按九维分组（REVENUE_MARGIN/COST_EXPENSE/CUSTOMER_PRODUCT/TAX_DECLARATION/INVOICE_FUND/SOCIAL_BUSINESS/RECEIVABLE_COLLECTION/INVENTORY_PAYABLE/HUMAN_ASSET_EFFICIENCY），每维 5-8 题
- 55 条 V2 规则：46 SIMPLE + 9 COMPOSITE（AND 多条件）
- 12 个风险场景

**前端（9 路由 + 2 新页面 + 5 新组件 + 2 Pinia stores）**：
- 新增 DiagnosisStartPage（手机号+三档模式选择）
- 新增 DocumentUploadPage（双栏：资料清单+完整度面板，SVG 环形进度）
- 新增 BusinessDashboard（ECharts 雷达图 + 综合健康度 + 四维卡片 + 结论 + TOP3）
- ReportPage 完全重写（9 段式 + PENDING_REVIEW/READY 两态）
- 新增 Pinia stores：diagnosis.ts + report.ts
- 新增 API 层：documents.ts + diagnosis.ts
- client.ts 扩展：支持自定义 headers + FormData + DELETE
- 安装新依赖：echarts + vue-echarts + @formkit/auto-animate + @vueuse/motion

### 为什么这么做

- V2 Prompt（AI_DIAGNOSIS_V2_FULL_REBUILD_PROMPT.md）明确要求：当前产品像"大学生期末作业"，需要做出"漂亮、专业、完整、能让纪姐觉得超过预期"的系统
- 资料上传不是装饰，而是提升诊断可信度的核心——告诉客户和君册哪些资料缺失、各维度可信度
- 四维看板是"老板能看懂的经营诊断"，不是普通文字报告
- 九维规则模型必须落地——不再等待客户资料，基于行业经验自建 55 条规则
- customerVisible 门控是合规底线——高风险报告必须人工复核后才能给客户
- SubmissionAccessToken 保护资料上传安全——敏感资料不能只依赖 publicId

### 踩了哪些坑

1. **HTTP 代理拦截 curl 请求**：本地有 `http_proxy=http://127.0.0.1:7890`，curl 测试全部返回 502。解决：`--noproxy '*'` 或 `unset http_proxy`
2. **pnpm 安装依赖时代理导致 ECONNRESET**：proxy 影响 npm registry 连接。解决：`unset http_proxy https_proxy`
3. **Prisma db push --force-reset 被 AI 安全机制拦截**：Prisma 检测到 AI agent 调用危险操作。解决：需用户明确同意 + 设置 `PRISMA_USER_CONSENT_FOR_DANGEROUS_AI_ACTION` 环境变量
4. **dotenv 从项目根目录无法找到 .env**：服务器从项目根目录启动，dotenv 默认在 cwd 找 .env，但 .env 在 `ai-diagnosis-server/` 子目录。解决：启动时显式传入环境变量或使用 `DOTENV_CONFIG_PATH`
5. **Prisma migration drift**：数据库存在未记录在 migration 中的变更（FAILED 枚举值、publicId 列）。解决：使用 `prisma db push` 直接同步
6. **V1 seed 使用 createMany 不可幂等**：第二次运行 seed 时报 unique constraint 冲突。解决：force-reset 后重新 seed
7. **CWD 不持久化**：Bash 每次调用都在项目根目录，但 nest build 需要从 server 目录运行。解决：使用 `pnpm --prefix` 或在 subshell 中 cd
8. **ECharts 导致 ReportPage chunk 1.1MB**：全量引入 ECharts。后续可优化为按需加载

### 验证命令

```bash
# 数据库验证
psql "postgresql://a1234@localhost:5432/junce_ai_diagnosis" \
  -c "SELECT version, count(*) FROM \"Question\" GROUP BY version;" \
  -c "SELECT count(*) FROM \"DiagnosisRule\";" \
  -c "SELECT count(*) FROM \"DocumentRequirement\";"

# 后端 build
pnpm --prefix ai-diagnosis-server build

# 前端 build
unset http_proxy https_proxy && pnpm --prefix ai-diagnosis-client build

# API 测试
curl -s --noproxy '*' http://localhost:3001/api/questionnaire?version=v2
curl -s --noproxy '*' -X POST http://localhost:3001/api/submissions/start \
  -H "Content-Type: application/json" -d '{"phone":"13800000000","mode":"STANDARD"}'


## 2026-06-22 第11步：Phase 5 — 轻量打印方案、Docker 部署与全量冒烟

### 做了什么

1. **打印/保存 PDF**：报告页增加打印按钮，`window.print()` + print CSS（隐藏按钮、保留报告内容、适配 A4、免责声明强制打印）
2. **Dockerfile ×2**：server（node:22-alpine 多阶段构建）+ client（Vite build + nginx serve）
3. **docker-compose**：postgres(5433) + server(3001) + client(8080)，端口不与小程序冲突
4. **环境变量标准化**：.env.example ×3（根目录、server、client）
5. **部署文档**：DEPLOYMENT_GUIDE.md 完整重写

### 为什么不用 Puppeteer

- AI 初诊和小程序共用同一台服务器，Puppeteer(无头 Chrome)内存占用高
- 浏览器 `window.print()` + print CSS 已能满足 MVP 的 PDF 需求
- 服务端 PDF 列为二期增强

### print CSS 关键规则

```css
@media print {
  .no-print { display: none !important; }     /* 隐藏按钮 */
  .print-section { break-inside: avoid; }      /* 避免分页切断 */
  print-color-adjust: exact;                   /* 保留颜色 */
}
```

### Docker 端口规划

| 服务 | 容器端口 | 宿主机端口 | 不与小程序冲突 |
|---|---|---|---|
| postgres | 5432 | 5433 | ✅ 小程序用 5432 |
| server | 3001 | 3001 | ✅ 小程序用 3000 |
| client | 80 | 8080 | ✅ |

### 全链路冒烟测试通过项

- LOW 报告：打印按钮可见 ✅
- MEDIUM/HIGH：打印按钮不可见 ✅
- APPROVE 后打印按钮出现 ✅
- 打印预览免责声明存在 ✅
- 后端 build ✅
- 前端 build ✅

---

## 2026-06-22 第10步：Phase 4 — 内部后台与人工复核闭环

### 做了什么

实现了完整的后台管理和人工复核功能：

1. **AuthModule**：后台 JWT 登录、JwtAuthGuard、RolesGuard、@Roles() 装饰器
2. **AdminModule**：提交列表（分页+筛选+手机脱敏）、报告详情、复核（APPROVE/REJECT）、报告修改（PATCH + 留痕）
3. **接口权限**：generate 接口从开放改为 MANAGER/ADMIN only
4. **前端**：登录页、提交列表、报告详情/复核页、API 封装（401 自动跳转）

### 权限设计

```
ACCOUNTANT → 查看 + 复核（通过/驳回），不能修改报告内容
MANAGER    → 查看 + 复核 + 修改 htmlContent/customerVisible，不能改 riskLevel
ADMIN      → 全部权限（含 riskLevel/reviewStatus 修改 + generate 重跑）
```

用 NestJS 的 `@Roles('MANAGER','ADMIN')` 装饰器 + RolesGuard 实现，和 mini-program 项目的 RBAC 模式一致。

### ReviewRecord 留痕机制

每次 APPROVE/REJECT/MODIFY 都会写入 ReviewRecord：
- reviewerId → 关联 AdminUser
- action → APPROVE/REJECT/MODIFY
- changes → MODIFY 时记录差异（如 `{"riskLevel":"LOW→MEDIUM"}`）
- comment → 复核备注
- createdAt → 时间戳

### 踩的坑

**坑：AdminController 全局 @UseGuards 导致 RolesGuard 在所有方法上生效**

- 类级别 `@UseGuards(JwtAuthGuard, RolesGuard)` 意味着所有方法都需要 role 权限
- 但 AdminModule 中的 list/detail/review 没有显式 `@Roles()` → 等于所有角色都能访问
- 而 PATCH 有 `@Roles('MANAGER','ADMIN')` → 只有 MANAGER/ADMIN 能访问
- 这个设计是故意的：默认开放给所有后台用户，敏感操作加 @Roles() 限制

**坑：generate 接口从开放改权限后，SubmissionService 自动调 generate 仍能成功**

- SubmissionService 内部调用 ReportService.generateReport()，不走 HTTP controller
- 所以 generate 接口的 JWT 限制不影向自动提交流程
- 这是正确的行为：自动提交时由系统生成报告，手动重跑需要 MANAGER/ADMIN 权限

---

## 2026-06-22 第9步：Phase 2.1 — 修复无风险场景基线逻辑 + 固化测试规则

### P0 问题

Phase 2 完成后发现：无风险场景（规则正常加载但 0 命中）返回 `UNKNOWN + needReview=true`，这不对。

正确逻辑：规则引擎正常工作 + 所有答案通过检查 + 0 命中 → **LOW + needReview=false**（系统成功评估，未发现风险）。

UNKNOWN 只能用于：没有活跃规则、答案矛盾、信息不足等**无法判断**的场景。

### 修复内容

**risk-level.service.ts**：
- `findings.length === 0` 分支：从 `UNKNOWN + needReview=true` 改为 `LOW + needReview=false`
- 新增 `context.hasActiveRules` 参数：当 0 findings + 没有活跃规则时，才返回 UNKNOWN
- MEDIUM 区域的 needReview 修正：1-2 个 MEDIUM 不强制复核（3 个已升级为 HIGH）

**rule-engine.service.ts**：
- `evaluate()` 返回值从 `RuleRecord[]` 改为 `{matchedRules, hasActiveRules}`
- 支持区分"评估后无风险"和"无法评估"

**diagnosis.service.ts**：
- 适配新的 `evaluate()` 返回结构，传递 `hasActiveRules` 给 risk-level service

### 种子数据修复

**问题**：`Promise.all` 并行创建 question，导致 ID 顺序不可预测。seed 多次运行后产生重复数据。

**修复**：
- 改为 `for...of` 顺序创建，保证 `questions[0]` ↔ `id=N`, `questions[1]` ↔ `id=N+1` ...
- TEST_M001、TEST_M002 固化到 seed.ts，标注 `TODO: 测试占位规则，待纪姐确认后替换`
- 不再依赖手动 SQL 插入

### LOW 和 UNKNOWN 的区别

| 条件 | 结果 | needReview |
|---|---|---|
| 规则正常加载 + 0 命中 | LOW | false |
| 没有活跃规则 | UNKNOWN | true |
| 答案矛盾/信息不足 | UNKNOWN（预留）| true |

### 5 组测试结果（全部通过）

| # | 场景 | overallRisk | needReview | Findings |
|---|---|---|---|---|
| 1 | 无风险 | **LOW** ✅ | **false** ✅ | 0 |
| 2 | 中风险 | MEDIUM | false | 1 |
| 3 | 高风险A | HIGH | true | 1 |
| 4 | 高风险B | HIGH | true | 1 |
| 5 | 3MED升级 | HIGH | true | 3 |

---

## 2026-06-22 第8步：Phase 2 — AI 初诊规则引擎

### 做了什么

实现了从客户答案到结构化诊断结果的完整后端链路：

1. **rule-engine.service.ts**：规则加载 + 答案归一化 + 10 种 operator 匹配
2. **risk-level.service.ts**：总体风险等级计算（取最高风险 + 3 MEDIUM 升级）
3. **service-recommendation.service.ts**：服务推荐去重 + 优先级排序
4. **diagnosis.service.ts**：诊断主流程编排 + transaction 安全写入
5. **diagnosis.controller.ts**：手动触发诊断 + 查询诊断结果 2 个接口
6. **Submission 自动诊断**：提交后自动触发，diagnosis 失败不影响数据入库
7. **Schema 变更**：SubmissionStatus 新增 FAILED 枚举

### 规则引擎设计

```
客户答案 → normalizeAnswer → 标准化格式
                ↓
        DiagnosisRule[] → 逐条匹配 → evaluateCondition
                ↓
        matchedRules[] → RiskLevelService → overallRiskLevel + needReview
                ↓
        matchedRules[] → ServiceRecService → 去重排序后推荐
                ↓
        DiagnosisResult ← transaction ← 写入 DB
```

### 答案归一化（normalizeAnswer）

为什么需要归一化？Answer.answerValue 是 `Json` 类型，可能是 string、number、array、object 等多种格式。每个 operator 如果自己处理这些格式，代码会非常杂乱。

归一化后的结构：
```typescript
{
  questionId: number,
  value: unknown,          // 原始值
  arrayValue: string[] | null,  // 数组场景
  numericValue: number | null,  // 数值场景（gt/gte/lt/lte）
  stringValue: string | null,   // equals/not_equals 场景
  exists: boolean,              // exists 场景
}
```

### 支持的 operator（10 种）

| operator | 用途 | 示例 |
|---|---|---|
| equals | 精确匹配 | `{"operator":"equals","value":"是"}` |
| not_equals | 不等于 | `{"operator":"not_equals","value":"否"}` |
| includes | 多选包含 | `{"operator":"includes","value":"代理记账"}` |
| in | 值在列表中 | `{"operator":"in","value":["A","B"]}` |
| gt | 大于 | `{"operator":"gt","value":500000}` |
| gte | 大于等于 | `{"operator":"gte","value":6}` |
| lt | 小于 | `{"operator":"lt","value":100}` |
| lte | 小于等于 | `{"operator":"lte","value":12}` |
| range | 区间匹配 | `{"operator":"range","value":{"min":100,"max":500}}` |
| exists | 答案存在 | `{"operator":"exists"}` |

### 风险等级计算规则

```
任一 HIGH → 整体 HIGH, needReview=true
3+ MEDIUM → 整体 HIGH, needReview=true (叠加升级)
有 MEDIUM 无 HIGH → 整体 MEDIUM
只有 LOW → 整体 LOW
0 findings → UNKNOWN, needReview=true
```

### 安全写入（transaction）

删除旧结果 + 写入新结果必须在同一个 Prisma transaction 中完成。如果写 RiskFinding 失败，不能留下"DiagnosisResult 存在但 findings 为空"的半成品。

### 踩的坑

**坑1：Prisma Json 字段的类型转换**

- 现象：`dimensionResults: array` 报 TS2322 类型不匹配
- 原因：Prisma 的 `Json` 字段在 TypeScript 中是 `InputJsonValue` 类型，直接赋值对象数组会报类型错误
- 解决：使用 `as any` 断言
- 教训：Prisma 的 Json 字段在 TS 中需要显式类型断言

**坑2：$transaction 中 include 不会自动推断嵌套类型**

- 现象：`result.findings` 报 Property does not exist
- 原因：Prisma 的 `$transaction` 回调返回值类型推断有限制
- 解决：在 transaction 内部使用 `findMany` 单独查询关联数据，用外部变量计数

**坑3：复合条件（compositeCondition）需要同时支持**

- 实现：`compositeCondition` 为数组时，所有子条件 AND 组合
- 预留：OR 组合标记 TODO，当前不需要

### 测试结果（5/5 通过）

| 测试 | 答案特征 | 规则 | 风险 | needReview |
|---|---|---|---|---|
| 1 无风险 | 全部安全答案 | 0 命中 | UNKNOWN | true |
| 2 中风险 | Q7=是(零申报) | TAX_001 | MEDIUM | false |
| 3 高风险A | Q6=否(未报税) | TAX_002 | HIGH | true |
| 4 高风险B | Q10=是(个人收款) | FUND_001 | HIGH | true |
| 5 3MEDIUM→HIGH | Q7=是+Q2=不到1年+Q8=否 | 3 MEDIUM | HIGH | true |

---

## 2026-06-22 第7步：Phase 1 — 问卷获取与提交闭环

### 做了什么

实现了 AI 初诊网站的第一条业务闭环：

1. 后端 GET /api/questionnaire — 返回当前活跃问卷（5 组 10 题）
2. 后端 POST /api/submissions — 接收答案、校验、入库
3. 前端问卷页面 — 分组展示、进度条、必填校验、题型适配
4. 前端提交成功页 — 展示 submissionPublicId
5. Question 模型新增 publicId 字段

### 后端实现要点

**QuestionnaireModule**：
- 从数据库查询 isActive=true 的问卷，include questions
- 按 groupOrder + orderInGroup 排序
- 服务层手动分组（groupBy groupLabel），避免 N+1 查询
- 返回字段做了精简，不暴露数据库内部字段

**SubmissionModule**：
- DTO 使用 class-validator 做声明式校验
  - `@IsInt()` questionId
  - `@Matches(/^1[3-9]\d{9}$/)` phone
  - `@ValidateNested` + `@Type(() => SubmitAnswerDto)` 嵌套数组
- Service 层校验逻辑：
  1. 问卷存在 + active
  2. answers 非空
  3. questionId 归属校验
  4. 必填项全覆盖
  5. 按 questionType 逐项校验 value 格式
- YES_NO 题型校验修正：从硬编码 `yes/no/unknown` 改为读取 question.options 列表校验，兼容中文"是/否"
- 提交成功后 status=SUBMITTED, submittedAt=now

**DTO 与 class-validator 的使用方法**

```typescript
// DTO 定义：声明每个字段的类型和校验规则
export class SubmitAnswerDto {
  @IsInt()
  questionId!: number;  // 必须是整数

  @IsNotEmpty()
  value!: unknown;  // 不能为空
}

// Controller 中：通过 @Body() 自动校验
@Post()
async submit(@Body() dto: SubmitQuestionnaireDto) {
  // 到这里时 DTO 已经通过 class-validator 校验
  return this.submissionService.submit(dto);
}
```

**main.ts 中的 ValidationPipe 配置**：
```typescript
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,           // 自动删除 DTO 未定义的字段
  forbidNonWhitelisted: true, // 传了未定义字段 → 400
  transform: true,            // 自动把字符串 "1" 转成数字 1
}));
```

### 前端实现要点

**API 封装层**（`src/api/`）：
- `client.ts`：封装 fetch，统一 BASE_URL、错误处理
- `questionnaire.ts`：fetchQuestionnaire()
- `submissions.ts`：submitQuestionnaire()
- 页面不直接调 fetch，通过 API 层调用

**问卷页面**（QuestionnairePage.vue）：
- 分组展示：一次只显示一组题
- 进度条：`(currentGroupIndex + 1) / totalGroups * 100%`
- 题型适配：
  - SINGLE_CHOICE → 自定义 radio（圆形选择器 + 边框高亮）
  - MULTI_CHOICE → checkbox
  - YES_NO → 按钮组
  - RANGE / TEXT → input
- 必填校验：当前组必填项全部填完才能进入下一组
- 提交时再次全量校验必填项

### 踩的坑

**坑1：YES_NO 校验硬编码 vs 种子数据不匹配**

- 现象：用"是"提交被拒，报"YES_NO 答案必须是 yes / no / unknown"
- 原因：种子数据的 YES_NO 题目 options 是 `["是", "否"]`，但校验写死了英文值
- 解决：改为统一从 question.options 读取可接受值，SINGLE_CHOICE / MULTI_CHOICE / YES_NO 共用同一段校验逻辑
- 教训：不要根据题型名称假设选项值，始终从数据源读取

**坑2：Question 加 publicId 的 migration 问题**

- 现象：`prisma migrate dev` 报"无法添加 required column 到已有数据的表"
- 原因：表中已有 10 行种子数据，加 NOT NULL 列时这些行没有默认值
- 解决：先改为 `String?`（nullable），用 `prisma db push --accept-data-loss` 同步 schema，后续可回填数据后再改 required
- 教训：已有数据的表加 required 字段时，需要分两步 migration

**坑3：class-validator 未安装**

- 现象：NestJS controller 使用 `@Body() dto: SubmitQuestionnaireDto` 不报错但也不校验
- 原因：未安装 `class-validator` 和 `class-transformer`，ValidationPipe 中 transform 需要后者
- 解决：`pnpm add class-validator class-transformer`
- 教训：NestJS 项目的 DTO 校验依赖这两个包，脚手架不会自动安装

### 验证命令

```bash
# 1. 获取问卷
curl -s --noproxy "*" http://localhost:3001/api/questionnaire | python3 -m json.tool

# 2. 完整提交（10 题全部答完）
curl -s --noproxy "*" -X POST http://localhost:3001/api/submissions \
  -H "Content-Type: application/json" \
  -d '{"questionnaireId":1,"phone":"13800138000","answers":[
    {"questionId":1,"value":"餐饮"},{"questionId":2,"value":"1-3年"},
    {"questionId":3,"value":"个体户"},{"questionId":4,"value":"10-50万"},
    {"questionId":5,"value":"1-5人"},{"questionId":6,"value":"是"},
    {"questionId":7,"value":"否"},{"questionId":8,"value":"是"},
    {"questionId":9,"value":"否"},{"questionId":10,"value":"否"}
  ]}'

# 3. 必填缺失
curl -s --noproxy "*" -X POST http://localhost:3001/api/submissions \
  -H "Content-Type: application/json" \
  -d '{"questionnaireId":1,"answers":[{"questionId":1,"value":"餐饮"}]}'
# 预期: {"code":"REQUIRED_ANSWER_MISSING",...}

# 4. 非法选项
curl -s --noproxy "*" -X POST http://localhost:3001/api/submissions \
  -H "Content-Type: application/json" \
  -d '{"questionnaireId":1,"answers":[...填满必填但 q1 value="无效选项"...]}'
# 预期: {"code":"INVALID_ANSWER_VALUE",...}

# 5. 数据库验证
psql -d junce_ai_diagnosis -c 'SELECT "publicId", status, phone FROM "Submission" ORDER BY id DESC LIMIT 3;'
psql -d junce_ai_diagnosis -c 'SELECT COUNT(*) FROM "Answer" WHERE "submissionId"=(SELECT MAX(id) FROM "Submission");'
```

### 前端验证

```bash
# 所有路由正常
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/questionnaire
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/questionnaire/success

# Vite 代理正常
curl -s http://localhost:5173/api/questionnaire | python3 -c "import sys,json; print(json.load(sys.stdin)['title'])"
```

---

## 2026-06-21 第1步：项目前期调研与需求分析

### 做了什么

阅读了小程序项目全部文档（CLAUDE.md、需求文档 v2、API_CONTRACT、PROJECT_STATE_SNAPSHOT、ROADMAP、AI_WEBDEVELOP_REQS.md、.docs 开发日志等），理解了：

- 小程序当前状态：12 个模块、55 个接口、63/63 回归通过、后端已封板
- AI 初诊网站定位：独立对外获客工具，不做小程序新模块
- 两个项目关系：共享服务器、容器隔离、不同数据库、预留 API 互通

输出了《AI 初诊网站对接内容分析稿》（15 章节 + 3 个输出版本），明确了需要向纪姐索要的资料清单。

### 为什么先做需求分析

AI 初诊不是"接一个大模型就能做诊断"。核心是把君册自己的财税经验、诊断规则、风险标准、报告模板结构化。如果跳过需求分析直接写代码，大概率方向跑偏。

### 关键认识

1. **AI 初诊 ≠ 通用 AI 问答**：规则引擎决定风险判断，AI 只润色文字。
2. **独立但不孤立**：第一版独立开发，但预留小程序对接接口。
3. **人工复核是合规底线**：高风险报告必须人工审核后才能给客户。
4. **不编造规则**：九维/四维、风险标准、FAQ 必须由纪姐提供。

---

## 2026-06-21 第2步：建立 AI-docs 文档体系

### 做了什么

参照小程序 docs/ 的完整结构，为 AI 初诊建立了独立的 AI-docs/ 文档体系，共 15 个文件：

| 文件 | 性质 |
|------|------|
| README.md | 项目入口文档 |
| PROJECT_CONTEXT.md | 项目上下文（从小程序 11 个文档提取汇总） |
| AI_WEBDEVELOP_REQS.md | 完整需求资料清单（从 docs 拷贝） |
| PROJECT_STATE_SNAPSHOT.md | 当前进度快照 |
| ROADMAP.md | 开发路线图 |
| RISK_ANALYSIS.md | 风险分析 |
| CTO_NOTES.md | 技术负责人提醒 |
| API_CONTRACT.md | 接口契约（占位） |
| DATABASE_GUIDE.md | 数据库设计（占位） |
| SYSTEM_ARCHITECTURE.md | 系统架构（占位） |
| TESTING_GUIDE.md | 测试指南（占位） |
| TEST_RESULTS.md | 测试结果（占位） |
| FRONTEND_HANDOFF.md | 前端交接（占位） |
| DEPLOYMENT_GUIDE.md | 部署说明 |
| AI_DIAGNOSIS_MVP_DEV_PLAN.md | MVP 开发方案 v2 |

### 为什么 docs 和 AI-docs 要分开

- docs/ 是小程序文档，属于另一个项目，不能改。
- AI-docs/ 是 AI 初诊专属文档，开发过程中会频繁更新。
- 两个项目的阶段不同（小程序已封板、AI 初诊刚起步），文档混在一起会干扰判断。

### 文档设计原则

1. 每个文件开头说明"给谁看、什么时候用、解决什么问题"。
2. 占位文件（如 API_CONTRACT.md）写清了框架结构和填充时机，不是空文件。
3. 有实际内容的文件标注了信息来源（如 PROJECT_CONTEXT.md 标注了每条信息来自哪个原始文档）。

---

## 2026-06-22 第3步：编写 MVP 开发方案 v2

### 做了什么

基于 Phase 0 之前的全部调研，编写了《AI 初诊网站 MVP 开发方案》，覆盖 14 个章节：

1. 项目理解
2. MVP 功能范围
3. 推荐技术栈
4. 页面流程设计
5. 数据模型设计（16 个 Prisma Model）
6. API 设计（13 个接口 + 权限矩阵）
7. 规则引擎设计
8. 报告生成设计
9. 人工复核流程设计
10. AI 调用边界设计
11. 和小程序后续联动预留
12. 开发任务拆分（6 个 Phase）
13. 风险与注意事项
14. 最终建议

### v2 修订（10 项 P0 修正）

根据审查意见修正了以下问题：

| P0 | 问题 | 修正 |
|---|---|---|
| 1 | reportToken 设计缺失 | 新增 ReportAccessToken 模型，tokenHash + expiresAt |
| 2 | 外部 ID 暴露自增 ID | Submission/Report 增加 publicId (cuid) |
| 3 | 短信验证码模型缺失 | 新增 SmsVerificationCode 模型，codeHash + 5分钟过期 + 5次重试 |
| 4 | 报告默认 AUTO_RELEASED | 改为默认 NEED_REVIEW |
| 5 | docker-compose 合并小程序 | 改为独立 docker-compose.yml |
| 6 | 前端 React | 改为 Vue3 + Vite + TS + Pinia + Tailwind CSS |
| 7 | AES-256 全量加密 | 改为 MVP 基础安全策略 |
| 8 | 统计接口在 MVP | 删除 GET /api/admin/stats |
| 9 | PDF 阻塞 MVP | PDF 列为 MVP-B |
| 10 | AI 润色默认开启 | AI_POLISH_ENABLED=false |

### 什么是 P0 修正

P0 = Priority 0，意思是"不改就不能往下做"的问题。比如客户侧 URL 暴露数据库自增 ID，不仅不安全，而且后续对接小程序时没法对齐客户身份。这类问题必须在 Phase 0 就修掉。

---

## 2026-06-22 第4步：Phase 0 项目初始化 — 后端

### 做了什么

创建了 AI 初诊网站的后端项目骨架：

1. 用 NestJS CLI 创建项目
2. 安装 Prisma + @prisma/adapter-pg
3. 创建 PostgreSQL 数据库 `junce_ai_diagnosis`
4. 编写 Prisma schema（16 个模型 + 8 个枚举）
5. 执行 migration 建表
6. 编写 seed.ts 写入种子数据
7. 创建 PrismaService（adapter 模式）
8. 实现 /health 接口
9. 配置 main.ts（dotenv + CORS + 3001 端口）

### 每件工具是干什么的（大白话）

| 工具 | 一句话解释 |
|------|-----------|
| **NestJS** | Node.js 后端框架，强制模块化，代码组织整齐 |
| **Prisma** | 数据库工具。用代码定义表结构，自动生成 SQL，不用手写 |
| **@prisma/adapter-pg** | Prisma 7 的 PostgreSQL 适配器。Prisma 7 不再自动读 .env，必须通过 adapter 显式传入数据库连接 |
| **PostgreSQL** | 关系型数据库。所有数据存在这里 |
| **dotenv** | 从 .env 文件加载环境变量到 process.env |
| **bcryptjs** | 密码哈希库。存密码哈希而不是明文 |
| **tsx** | TypeScript 执行器。可以直接运行 .ts 文件（如 seed.ts），不需要先编译成 .js |
| **cuid** | 生成唯一 ID 的算法。用于 publicId，比 UUID 短，适合 URL |

### Prisma 7 adapter 模式详解

Prisma 7 改变了客户端初始化方式。以前的写法：

```typescript
// Prisma 6 及以前（不再适用）
const prisma = new PrismaClient(); // 自动读 .env 的 DATABASE_URL
```

Prisma 7 的新写法：

```typescript
// Prisma 7：必须通过 adapter 显式传入连接
import { PrismaPg } from '@prisma/adapter-pg';

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env['DATABASE_URL'] }),
});
```

为什么 Prisma 7 要这样改？因为它想支持更多种类的数据库连接方式（不只是 PostgreSQL，还有 Prisma Postgres 云服务等），所以把连接方式做成了可插拔的 adapter。

### 数据库命名约定（Prisma → PostgreSQL）

Prisma schema 中字段用 camelCase（如 `companyName`），Prisma 自动映射到 PostgreSQL 的 snake_case（如 `company_name`）。但枚举值用中文（如 `"税务维度"`），这是君册的业务特点决定的——客户和内部员工都认中文。

### 为什么独立数据库

AI 初诊和小程序虽然共享 PostgreSQL 实例，但使用不同的数据库：
- 小程序：`junce_dev`
- AI 初诊：`junce_ai_diagnosis`

好处：
1. 数据隔离，互不影响
2. Migration 独立，不会误改小程序的表
3. 备份恢复独立
4. 后续如果需要迁移到独立服务器，直接导出整个数据库即可

### 踩的坑

**坑1：pnpm approve-builds 交互式菜单无法非交互运行**

- 现象：`pnpm install` 后 prisma 和 esbuild 的构建脚本被忽略，导致 `pnpm build` 失败
- 原因：pnpm v10+ 出于安全考虑，默认不执行依赖的构建脚本，需要手动批准
- 尝试了的方法（都不行）：
  - `echo "a" | pnpm approve-builds` — 交互式菜单仍然需要手动输入
  - `pnpm config set approve-builds` — 不支持这个 key
  - `package.json` 的 `pnpm.onlyBuiltDependencies` — pnpm v11 已废弃这个字段
- 最终解决：在项目根目录创建 `.npmrc`，写入 `onlyBuiltDependencies=@prisma/engines prisma unrs-resolver esbuild`
- .npmrc 语法注意：值是**空格分隔**的包名列表，不是数组格式

**坑2：Prisma schema 缺少反向关系字段**

- 现象：`prisma migrate dev` 报 `P1012: The relation field is missing an opposite relation field`
- 原因：RiskFinding 中有 `rule DiagnosisRule? @relation(...)`，但 DiagnosisRule 中没有对应的 `findings RiskFinding[]`
- 解决：在 DiagnosisRule 和 RiskScenario 中分别加上 `findings RiskFinding[]`
- 教训：Prisma 7 要求所有 @relation 必须是双向的，有外键的一方和反向的一方都需要声明

**坑3：NestJS build 产物在 dist/src/ 而非 dist/**

- 现象：`node dist/main.js` 报 MODULE_NOT_FOUND
- 原因：NestJS 的 tsconfig 配置导致编译输出保留了 src/ 目录结构
- 正确路径：`node dist/src/main.js`
- 后续解决：可以在 nest-cli.json 中配置 `"sourceRoot": "src"` 让 build 产物直接输出到 dist/ 根目录

**坑4：npm registry 网络不稳定**

- 现象：`pnpm add` 频繁报 `ECONNRESET`、`UND_ERR_CONNECT_TIMEOUT`
- 原因：本地网络到 npm registry 的连接不稳定
- 临时方案：重试即可（pnpm 有自动重试机制，1分钟后重试）
- 备选方案：使用淘宝镜像 `--registry https://registry.npmmirror.com`
- 教训：在 package.json 中锁定关键依赖版本，避免频繁新增依赖

### 怎么确认后端 OK

```bash
# 1. 确认数据库创建成功
psql -d junce_ai_diagnosis -c "\dt"
# 预期：看到 16 张业务表 + _prisma_migrations

# 2. 启动后端
cd ai-diagnosis-server
node dist/src/main.js

# 3. 测试 health check
curl --noproxy "*" http://localhost:3001/health
# 预期：{"status":"ok","service":"ai-diagnosis-server","timestamp":"..."}

# 4. 验证种子数据
psql -d junce_ai_diagnosis -c 'SELECT id, username, "realName", role FROM "AdminUser";'
# 预期：1 行，admin / 管理员 / ADMIN

psql -d junce_ai_diagnosis -c 'SELECT "ruleCode", dimension, "riskLevel" FROM "DiagnosisRule";'
# 预期：3 行

psql -d junce_ai_diagnosis -c 'SELECT COUNT(*) FROM "ForbiddenPhrase";'
# 预期：15
```

---

## 2026-06-22 第5步：Phase 0 项目初始化 — 前端

### 做了什么

创建了 AI 初诊网站的前端项目骨架：

1. 用 Vite 创建 Vue3 + TypeScript 项目
2. 安装 Vue Router、Pinia、Tailwind CSS
3. 配置路由（6 条）
4. 创建占位页面（3 个客户侧 + 3 个后台）
5. 配置 Vite 代理（/api → localhost:3001）

### 每件工具是干什么的（大白话）

| 工具 | 一句话解释 |
|------|-----------|
| **Vue 3** | 前端框架。用组件化方式构建用户界面 |
| **Vite** | 前端构建工具。开发时热更新极快，构建时打包优化 |
| **TypeScript** | 带类型检查的 JavaScript。编译时就能发现字段拼写错误 |
| **Vue Router** | Vue 的路由库。URL 变了就显示对应的页面组件 |
| **Pinia** | Vue 的状态管理库。存全局数据（如 token、用户信息），各个页面都能读写 |
| **Tailwind CSS** | CSS 工具库。用 class 名直接写样式（如 `bg-blue-600 text-white p-4`），不用写 .css 文件 |

### 为什么选 Vue3 而不是 React

1. 小程序前端用的就是 Vue3（uni-app），技术体系一致，降低学习成本。
2. AI 初诊页面偏表单和报告展示，不需要 React 的复杂生态。
3. Vue3 的单文件组件（template + script + style 写在一个 .vue 文件里）对小项目更友好。

### 为什么用 Tailwind CSS v4

Tailwind v4 相比 v3 的改进：
- **零配置**：不需要 `tailwind.config.js`，自动扫描模板中的 class
- **Vite 原生插件**：`@tailwindcss/vite` 直接集成，不需要 PostCSS 配置
- **CSS-first 配置**：在 CSS 中用 `@theme` 定义自定义值，而不是 JS 配置

项目中只需要两件事：
1. `vite.config.ts` 中加 `import tailwindcss from '@tailwindcss/vite'`
2. CSS 入口文件中写 `@import "tailwindcss"`

### Vite 代理的作用

```typescript
// vite.config.ts
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:3001',  // 后端地址
      changeOrigin: true,
    },
  },
},
```

开发时前端跑在 `localhost:5173`，后端跑在 `localhost:3001`。如果前端直接请求 `localhost:3001/api/...`，浏览器会因为跨域（不同端口）拦截。Vite 代理让前端所有 `/api` 请求自动转发到后端，浏览器以为请求的是同源地址，就不存在跨域问题。

### 路由设计说明

```
客户侧（无需登录）：         后台侧（需 JWT 登录）：
/                           /admin/login
/questionnaire              /admin/submissions
/report/:publicId           /admin/reports/:publicId
```

`:publicId` 是动态路由参数。比如 `/report/abc123` 和 `/report/xyz789` 都匹配同一个 ReportPage 组件，组件内通过 `route.params.publicId` 拿到具体值。

### 怎么确认前端 OK

```bash
# 1. 启动前端
cd ai-diagnosis-client
npm run dev

# 2. 确认页面可访问
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/
# 预期：200

curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/questionnaire
# 预期：200

curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/report/test123
# 预期：200

curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/admin/login
# 预期：200
```

---

## 2026-06-22 第6步：编写独立 docker-compose.yml

### 做了什么

创建了 AI 初诊项目独立的 docker-compose.yml，包含 3 个服务：

1. **postgres**：PostgreSQL 16 Alpine 镜像，独立数据卷 `ai_diagnosis_pgdata`
2. **server**：NestJS 后端，依赖 postgres 健康检查通过后才启动
3. **client**：前端静态文件，依赖 server

### 为什么独立 compose

- 不修改小程序的 docker-compose（小程序已封板，动 compose 风险大）
- AI 初诊可以独立启停，不影响小程序运行
- 后续如需同服务器部署，通过 Nginx 反向代理把两个项目的端口统一即可

### docker-compose 关键配置解释

```yaml
depends_on:
  postgres:
    condition: service_healthy
```

`condition: service_healthy` 表示等 postgres 的健康检查通过后，才启动 server。这比简单的 `depends_on: - postgres` 更可靠——后者只等容器启动，不保证数据库已经能接受连接。

postgres 的健康检查：

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U a1234 -d junce_ai_diagnosis"]
  interval: 5s
  timeout: 5s
  retries: 5
```

`pg_isready` 是 PostgreSQL 自带的工具，只检查数据库是否准备好接受连接，不查询任何业务表。

---

## 当前项目完整结构

```
junce-aiproject/
├── CLAUDE.md                         # AI 开发纪律 + 铁律 + 工作流
├── docs/                             # 小程序文档（只读参考，不修改）
├── AI-docs/                          # AI 初诊项目文档（主动维护）
│   ├── README.md                     # 项目入口文档
│   ├── PROJECT_CONTEXT.md            # 项目上下文
│   ├── PROJECT_STATE_SNAPSHOT.md     # 进度快照
│   ├── ROADMAP.md                    # 开发路线图
│   ├── API_CONTRACT.md               # 接口契约
│   ├── DATABASE_GUIDE.md             # 数据库设计
│   ├── SYSTEM_ARCHITECTURE.md        # 系统架构
│   ├── TESTING_GUIDE.md             # 测试指南
│   ├── TEST_RESULTS.md              # 测试结果
│   ├── RISK_ANALYSIS.md             # 风险分析
│   ├── CTO_NOTES.md                 # 技术负责人提醒
│   ├── FRONTEND_HANDOFF.md          # 前端交接
│   ├── DEPLOYMENT_GUIDE.md          # 部署说明
│   ├── AI_WEBDEVELOP_REQS.md        # 需求资料清单
│   ├── AI_DIAGNOSIS_MVP_DEV_PLAN.md # MVP 开发方案 v2
│   └── project-note.md              # ← 你正在看的这个文件
├── ai-diagnosis-server/              # NestJS 后端（3001 端口）
│   ├── prisma/
│   │   ├── schema.prisma            # 16 个模型 + 8 个枚举
│   │   ├── seed.ts                  # 种子数据
│   │   └── migrations/              # 迁移文件
│   ├── src/
│   │   ├── main.ts                  # 入口（dotenv + CORS + 3001）
│   │   ├── app.module.ts            # 根模块
│   │   ├── app.controller.ts        # / + /health
│   │   └── prisma/                  # PrismaService + PrismaModule
│   ├── .env                         # 环境变量（不入 git）
│   ├── .env.example                 # 环境变量模板
│   └── .npmrc                       # pnpm 配置
├── ai-diagnosis-client/              # Vue3 前端（5173 端口）
│   ├── src/
│   │   ├── main.ts                  # 入口（Pinia + Router）
│   │   ├── App.vue                  # 根组件
│   │   ├── style.css                # Tailwind CSS 入口
│   │   ├── router/index.ts          # 路由配置（6 条）
│   │   ├── pages/                   # 客户侧页面
│   │   └── admin/                   # 后台页面
│   └── vite.config.ts               # Vite + Tailwind + 代理
└── docker-compose.yml                # 独立 compose（3 服务）
```

---

## 下一步

Phase 0 已全部完成。下一步进入 Phase 1：问卷提交模块开发。

Phase 1 需要做的：
1. 后端：Questionnaire GET API + Submission POST API
2. 前端：问卷页面（分组展示、单选/多选/区间选择/是-否、进度条）
3. 验证：curl 提交完整问卷 → 数据库可见 Submission + Answer 记录

---

> 最后更新：2026-06-22

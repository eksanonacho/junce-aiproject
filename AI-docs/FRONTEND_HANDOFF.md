# FRONTEND_HANDOFF.md — AI 初诊网站前端交接手册

> 最后更新：2026-06-28  
> 当前状态：客户侧 V2 技术闭环 + Stitch 黑金视觉升级已完成；后台管理页仍保持既有实现。

---

## 一、前端边界

前端只消费现有 API，不新增接口，不改后端规则。

硬边界：

- 不改 Prisma schema。
- 不改 seed 规则 / 题库。
- 不改文件上传接口。
- 不改问卷流程接口。
- 不改管理后台接口。
- 不修改 `/Users/a1234/cpp/junce-miniprogram/`。

---

## 二、客户侧页面

| 页面 | 路径 | 文件 | 状态 |
|---|---|---|---|
| 首页 | `/` | `ai-diagnosis-client/src/pages/HomePage.vue` | ✅ Stitch `_1` 风格 |
| 开始初诊 | `/diagnosis/start` | `DiagnosisStartPage.vue` | ✅ Stitch `_2` 风格 |
| 上传资料 | `/diagnosis/upload` | `DocumentUploadPage.vue` | ✅ Stitch `_3` 风格 |
| 问卷填写 | `/questionnaire` | `QuestionnairePage.vue` | ✅ Stitch `_4` 风格 |
| 提交成功 | `/questionnaire/success` | `SuccessPage.vue` | ✅ Stitch `_5` 风格 |
| 报告页 | `/report/:publicId?token=xxx` | `ReportPage.vue` | ✅ Stitch `_6` + V2 报告高级化 |

---

## 三、核心前端流程

### 1. 首页

入口：

```text
/diagnosis/start
```

说明：

- 首页只负责获客入口和能力说明。
- 不直接创建 submission。
- 使用本地背景图：`public/brand/home-hero-office.png`。

### 2. 开始初诊

真实逻辑：

1. 输入手机号。
2. 调用 lookup。
3. 若无历史记录，展示三档模式：
   - QUICK 快速初诊
   - STANDARD 标准初诊
   - DEEP 深度经营初诊
4. 选择模式后调用 `store.startDiagnosis()`。
5. 跳转 `/diagnosis/upload`。

分支状态：

- 未完成流程：可继续填写。
- 已有可见报告：可查看已有报告。
- 报告待复核：只展示复核状态，不泄露详情。

### 3. 上传资料

真实逻辑：

- `store.loadChecklist()`
- `store.uploadDoc(docType, file)`
- `store.removeDoc(publicId)`

页面结构：

- 左侧资料清单。
- 右侧资料完整度仪表盘。
- 底部固定操作栏：跳过并进入问卷 / 继续填写问卷。

### 4. 问卷页

真实逻辑：

- `fetchQuestionnaire(version)`
- V2 按 `skipLogic.hideInModes` 过滤题目。
- 必填校验通过后：
  - V2：`diagnosisStore.completeDiagnosis(answersList)`
  - V1：`submitQuestionnaire(...)`

注意：

- 不要破坏 `visibleQuestions`、`allRequiredDone`、`handleSubmit`。
- 手机号字段仍用于 V1 兼容。

### 5. 成功页

通过 query 展示状态：

```text
submissionPublicId
diagnosisStatus
reportStatus
reportPublicId
reportAccessToken
v2
mode
documentCompletenessScore
```

只有当 `reportStatus === READY && reportPublicId && reportAccessToken` 时，才展示报告按钮。

### 6. 报告页

关键门控：

- `PENDING_REVIEW`：只展示等待复核页。
- `READY`：展示完整报告。
- `customerVisible=false` 时不得展示 dashboard/findings/documentCompleteness/htmlContent。

打印：

- 保留 `window.print()`。
- print CSS 隐藏动态/深色大背景，保留报告结构。

---

## 四、品牌与视觉资产

设计稿归档：

```text
AI-docs/JUNCE-DESIGN-DOC/
```

前端品牌资产：

```text
ai-diagnosis-client/public/brand/junce-seal-icon.png
ai-diagnosis-client/public/brand/junce-wordmark.png
ai-diagnosis-client/public/brand/home-hero-office.png
ai-diagnosis-client/public/brand/start-security-dashboard.png
```

公共组件：

```text
ai-diagnosis-client/src/components/common/JcBrand.vue
ai-diagnosis-client/src/components/common/JcDynamicBackground.vue
```

当前主视觉：

- 暖白 / 象牙纸色
- 深黑 / 墨黑
- 铜金 / 古金
- 玻璃卡片
- 咨询报告感

---

## 五、构建验证

前端构建：

```bash
cd ai-diagnosis-client
pnpm build
```

当前结果：✅ 通过。

已知提示：

- `ReportPage` chunk 超过 500KB，主要原因是 ECharts，后续可做按需加载优化。

---

## 六、后续前端建议

1. 用真实 READY/PENDING_REVIEW 报告各截一次图，做视觉验收。
2. 走完整端到端流程，确认上传、问卷、成功、报告、后台复核均正常。
3. ECharts 按需加载或异步拆包，降低报告页首包。
4. 后续若 Stitch 再出新版，只按页面逐个替换，不要一次性改后端。

# FRONTEND_STITCH_REDESIGN_20260628.md — Stitch 视觉升级交接记录

> 最后更新：2026-06-28  
> 范围：仅前端客户侧页面与品牌视觉资产，不改后端、不改接口、不改 Prisma、不改 seed、不改小程序。

---

## 一、本轮目标

将 V2 客户侧页面从基础系统界面升级为更接近 Stitch 设计稿的高端黑金咨询风格。

核心观感：

- 暖白 / 象牙纸张背景
- 深黑 / 墨黑信息区
- 铜金 / 古金强调色
- 玻璃拟态卡片
- 企业咨询、经营诊断、正式报告感

---

## 二、设计稿归档

Stitch 原始设计稿已归档到：

```text
AI-docs/JUNCE-DESIGN-DOC/
```

主要页面对应关系：

| Stitch 目录 | 对应页面 | 本项目路径 |
|---|---|---|
| `_1` | 首页 | `/` |
| `_2` | 开始初诊页 | `/diagnosis/start` |
| `_3` | 资料上传页 | `/diagnosis/upload` |
| `_4` | 问卷页 | `/questionnaire` |
| `_5` | 提交成功页 | `/questionnaire/success` |
| `_6` | 报告页 | `/report/:publicId?token=xxx` |

---

## 三、品牌资产

本轮采用“左款方印章 icon + 右款君册财税字标”的组合。

设计文档资产：

```text
AI-docs/JUNCE-DESIGN-DOC/logo-assets/junce-seal-icon.png
AI-docs/JUNCE-DESIGN-DOC/logo-assets/junce-wordmark.png
AI-docs/JUNCE-DESIGN-DOC/logo-assets/junce-logo-source-three-options.png
```

前端运行资产：

```text
ai-diagnosis-client/public/brand/junce-seal-icon.png
ai-diagnosis-client/public/brand/junce-wordmark.png
```

说明：

- logo 资产已重新抠图为 RGBA 透明 PNG。
- 已移除 `mix-blend-mode` / `filter`，避免前端造成色差。
- 品牌组件统一入口为 `JcBrand.vue`。

---

## 四、已改页面

### 1. 首页 `/`

文件：

```text
ai-diagnosis-client/src/pages/HomePage.vue
ai-diagnosis-client/public/brand/home-hero-office.png
```

主要改动：

- 对齐 Stitch `_1`。
- 首页结构调整为 Hero、风险穿透、流程、后续服务、深色 CTA、页脚。
- 使用本地办公空间背景图，不依赖外网图片。
- 保留 `/diagnosis/start` 真实入口。

### 2. 开始初诊 `/diagnosis/start`

文件：

```text
ai-diagnosis-client/src/pages/DiagnosisStartPage.vue
ai-diagnosis-client/public/brand/start-security-dashboard.png
```

主要改动：

- 对齐 Stitch `_2`。
- 保留手机号查重、继续填写、查看已有报告、复核状态、重新发起流程。
- 三档模式选择升级为大卡片：快速初诊、标准初诊、深度经营初诊。

### 3. 上传资料 `/diagnosis/upload`

文件：

```text
ai-diagnosis-client/src/pages/DocumentUploadPage.vue
```

主要改动：

- 对齐 Stitch `_3`。
- 左侧文件清单、右侧完整度仪表盘、底部固定操作栏。
- 保留真实上传、删除、资料完整度、维度可信度逻辑。

### 4. 问卷 `/questionnaire`

文件：

```text
ai-diagnosis-client/src/pages/QuestionnairePage.vue
```

主要改动：

- 对齐 Stitch `_4` 的沉浸式诊断问卷风格。
- 保留题目过滤、答题、必填校验、提交和 V2 complete 流程。
- 右侧进度卡和移动端底部进度条改为黑金体系。

### 5. 提交成功 `/questionnaire/success`

文件：

```text
ai-diagnosis-client/src/pages/SuccessPage.vue
```

主要改动：

- 对齐 Stitch `_5`。
- 大成功徽章、五步进度、状态 Bento 卡、下一步操作区。
- 未加入无接口支撑的“下载 PDF”等功能。

### 6. 报告页 `/report/:publicId?token=xxx`

文件：

```text
ai-diagnosis-client/src/pages/ReportPage.vue
ai-diagnosis-client/src/components/report/BusinessDashboard.vue
ai-diagnosis-client/src/components/report/DimensionCard.vue
ai-diagnosis-client/src/components/report/TopActions.vue
```

主要改动：

- 报告页已按 Stitch `_6` 和 V2 报告高级化要求升级。
- 保留 `PENDING_REVIEW` 门控：customerVisible=false 时不展示报告详情。
- 保留打印按钮与 print CSS。

---

## 五、前端公共组件

新增：

```text
ai-diagnosis-client/src/components/common/JcBrand.vue
ai-diagnosis-client/src/components/common/JcDynamicBackground.vue
```

说明：

- `JcBrand.vue`：统一品牌入口，使用透明印章 + 字标。
- `JcDynamicBackground.vue`：早期动态背景组件仍保留，但当前客户侧主视觉更多采用静态 Stitch 背景体系。

---

## 六、边界确认

本轮未修改：

- 后端业务逻辑
- API 结构
- Prisma schema
- seed 规则 / 题库
- 文件上传接口
- 问卷提交接口
- 管理后台接口
- `/Users/a1234/cpp/junce-miniprogram/`

---

## 七、验证

已执行：

```bash
pnpm build
```

结果：前端 build 通过。

已知提醒：

- Vite 仍提示 `ReportPage` chunk 超过 500KB，原因是 ECharts 相关依赖较大，属于既有优化项。

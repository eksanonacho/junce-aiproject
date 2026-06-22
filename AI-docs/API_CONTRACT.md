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

---

## 四、Health 检查（基础设施）

### 4.1 GET /health

```json
{ "status": "ok", "service": "ai-diagnosis-server", "timestamp": "..." }
```

---

## 五、当前接口总数

| 模块 | 接口数 | 状态 |
|---|---|---|
| Health | 1 | ✅ |
| Questionnaire | 1 | ✅ Phase 1 |
| Submission | 1 | ✅ Phase 1 |
| **总计** | **3** | |

后续接口：报告生成、后台管理、人工复核 — Phase 2-4 开发。

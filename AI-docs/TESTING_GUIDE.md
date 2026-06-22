# TESTING_GUIDE.md — AI 初诊网站测试指南

> **这个文件是给谁看的**：任何要测试 AI 初诊网站的人（或 AI）。
> **什么时候用**：开发每个模块后、回归测试时。
> **解决什么问题**：知道怎么测、测什么、怎么确认通过。
>
> ⚠️ **AI 初诊项目尚未进入开发阶段，暂无测试内容。** 本文件为占位，开发启动后逐模块补充。
> 最后更新：2026-06-21。

---

## 当前状态

**暂无测试。** 项目处于需求对接阶段。

---

## 测试策略（预编）

### 规则引擎测试（优先级最高）

规则引擎是 AI 初诊的核心，每个检查项至少需要：

- **正向测试**：输入符合"正常"标准的答案 → 输出正常
- **边界测试**：输入临界值 → 输出正确的风险等级
- **异常测试**：输入缺失/矛盾 → 标记"待人工复核"
- **叠加测试**：多个风险项叠加 → 总风险等级计算正确

### 报告生成测试

- **完整性测试**：报告包含所有必需的板块
- **文案测试**：无禁用词、免责声明存在
- **数据一致性**：报告内容与规则引擎输出一致

### 接口测试（开发后逐接口）

参照小程序测试方法：
- 正向：该成功的请求必须成功
- 反向：未认证 401、越权 403、参数错误 400
- 每个模块完成后 curl 验证通过

---

## 预计测试命令格式

```bash
# 登录后台（获取 token）
TOKEN=$(curl -s --noproxy "*" -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"123456"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['accessToken'])")

# 提交问卷（客户侧，无需 token）
curl -s --noproxy "*" -X POST http://localhost:3001/submissions \
  -H "Content-Type: application/json" \
  -d '{"answers": [...]}'

# 查看报告（后台，需 token）
curl -s --noproxy "*" http://localhost:3001/admin/reports/1 \
  -H "Authorization: Bearer $TOKEN"
```

---

> 开发启动后，参照小程序 docs/TESTING_GUIDE.md 的格式逐模块补充测试命令。每个模块必须正向+反向全部通过才算验收。

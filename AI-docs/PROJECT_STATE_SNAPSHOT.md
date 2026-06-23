# PROJECT_STATE_SNAPSHOT.md — AI 初诊项目当前快照

> **最后更新**：2026-06-23（V2 全量重构完成）

---

## 快照时间

**2026-06-23（V2 企业经营初诊系统 — feature/v2-business-diagnosis）**

---

## 当前完成度（按阶段）

| 阶段 | 状态 |
|------|------|
| Phase 0：项目初始化 | ✅ 已完成 `[06-22]` |
| Phase 1：问卷获取与提交 | ✅ 已完成 `[06-22]` |
| Phase 2：规则引擎 | ✅ 已完成 `[06-22]` |
| Phase 2.1：基线逻辑修复 | ✅ 已完成 `[06-22]` |
| Phase 3：报告生成 | ✅ 已完成 `[06-22]` |
| Phase 3.1：文档补齐 + 安全测试 | ✅ 已完成 `[06-22]` |
| Phase 4：后台管理 + 人工复核 | ✅ 已完成 `[06-22]` |
| Phase 5：打印/Docker/冒烟 | ✅ 已完成 `[06-22]` |
| **V2 Phase 1**：产品文档 + Schema 迁移 + 分支 | ✅ 已完成 `[06-23]` |
| **V2 Phase 2**：资料上传模块（DocumentModule 4端点 + 完整度评分 + 文件安全） | ✅ 已完成 `[06-23]` |
| **V2 Phase 3**：题库扩展（65题九维问卷） + 规则扩展（55条规则含复合条件） + 场景扩展（12个） | ✅ 已完成 `[06-23]` |
| **V2 Phase 4**：四维经营看板服务（BusinessDashboardService 评分引擎） | ✅ 已完成 `[06-23]` |
| **V2 Phase 5**：前端基础设施（echarts/vue-echarts/auto-animate/motion + Pinia stores + API层） | ✅ 已完成 `[06-23]` |
| **V2 Phase 6**：前端客户流程重构（DiagnosisStartPage + DocumentUploadPage + 3组件） + 看板可视化（BusinessDashboard + RadarChart + 2子组件） + ReportPage重写（9段式报告） | ✅ 已完成 `[06-23]` |
| V2 后续：AI-docs 文档同步 | 🔄 进行中 `[06-23]` |
| V2 后续：演示案例编写 | ⬜ 未开始 |
| 部署上线 | ⬜ 未开始 |
| 小程序数据打通 | ⬜ 未开始（二期） |

---

## V2 已完成并验证通过

| 模块 | 产出 | 状态 |
|------|------|------|
| 产品文档 | `AI-docs/V2_BUSINESS_DIAGNOSIS_MODEL.md` | ✅ |
| DB Schema | 新增 DiagnosisMode 枚举 + DocumentRequirement + UploadedDocument + 5 模型扩展字段 | ✅ |
| Seed 数据 | 19 资料类型 + 65 题 V2 问卷 + 55 V2 规则 + 12 V2 场景 + V2 免责声明 | ✅ |
| Document 模块 | 上传/列表/删除/checklist/管理员下载 7 端点 + 完整度评分 + 文件安全 | ✅ |
| Submission V2 | POST /start + POST /:id/complete + SubmissionAccessToken (bcrypt) | ✅ |
| Questionnaire V2 | `?version=v2` 返回 65 题九维问卷 | ✅ |
| BusinessDashboard | 四维评分引擎：利润/风险/现金流/效率 1.0-5.0 + 综合健康度 + 一句话结论 + TOP3 | ✅ |
| RuleEngine 扩展 | conditionMode=SIMPLE/COMPOSITE + AND/OR + questionPublicId 解析 | ✅ |
| ReportService 升级 | customerVisible 门控（PENDING_REVIEW 不返回详情） + dashboard + documentCompleteness | ✅ |
| AdminService 升级 | dashboard + uploadedDocuments + dimensionRuleHits | ✅ |
| 前端 DiagnosisStartPage | 手机号 + 三档模式选择 | ✅ |
| 前端 DocumentUploadPage | 双栏：资料清单 + 完整度面板（环形SVG进度） | ✅ |
| 前端 BusinessDashboard | 综合健康度卡 + ECharts雷达图 + 四维卡片 + 结论 + TOP3 | ✅ |
| 前端 ReportPage | 9段式重写（PENDING_REVIEW / READY 两态） | ✅ |
| 前端 Store | diagnosis.ts (Pinia) + report.ts (Pinia) | ✅ |
| 前端 API | documents.ts + diagnosis.ts + client.ts 扩展 | ✅ |
| Build | 后端 `nest build` 通过 + 前端 `vite build` 通过 | ✅ |

---

## V2 数据库统计

| 类型 | 数量 |
|------|------|
| 模型总数 | 18（原有 16 + 新增 2） |
| 枚举总数 | 8（原有 7 + 新增 1） |
| V1 问卷 | 1（v1，10 题，5 组） |
| V2 问卷 | 1（v2，65 题，9 组） |
| 诊断规则 | 60（5 V1 + 55 V2，含 9 条 COMPOSITE） |
| 风险场景 | 15（3 V1 + 12 V2） |
| 资料类型 | 19 |
| 禁用话术 | 15 |
| 免责声明 | 2（v1 + v2） |
| 管理员 | 1（admin/Admin@123456） |

---

## V2 API 统计

| 模块 | 接口数 | V1 原有 | V2 新增 |
|------|--------|---------|---------|
| Health | 1 | 1 | 0 |
| Questionnaire | 1 | 1 | 0（version 参数追加） |
| Submission | 3 | 1 | 2（start + complete） |
| Diagnosis | 2 | 2 | 0 |
| Document | 7 | 0 | 7（含 admin 2 个） |
| Report | 3 | 3 | 0（响应扩展） |
| Auth | 1 | 1 | 0 |
| Admin | 4 | 4 | 0（响应扩展） |
| **总计** | **22** | **13** | **9** |

---

## V2 前端统计

| 类型 | 数量 |
|------|------|
| 路由 | 9（V1 7 + V2 2） |
| 页面 | 9（V1 7 + V2 2） |
| 组件 | 7（V1 2 + V2 5） |
| Pinia stores | 2（V2 新增） |
| API 模块 | 6（V1 4 + V2 2） |
| npm 依赖 | 16（V1 12 + V2 4） |

---

## 当前正在推进

- **AI-docs 文档同步**：更新 PROJECT_STATE_SNAPSHOT、API_CONTRACT、DATABASE_GUIDE、ROADMAP、README、project-note

---

## 下一步建议

1. 编写 `AI-docs/DEMO_CASES_V2.md`（3 套演示案例）
2. 浏览器手动走通完整 V2 流程验证
3. 前端实现 skipLogic hideInModes 按模式过滤题量
4. ECharts 按需加载优化（减小 ReportPage chunk 1.1MB）
5. 提交 PR → Code Review → 合并 main

---

## 小程序后端状态（参考）

| 指标 | 值 |
|------|-----|
| 模块数 | 12 |
| 业务接口数 | 55 + 1（health） |
| 回归测试 | 63/63 全部通过 |
| 状态 | 后端封板 |
| 本次修改 | 未触碰 ✅ |

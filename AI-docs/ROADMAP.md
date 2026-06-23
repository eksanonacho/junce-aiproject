# ROADMAP.md — AI 初诊网站开发路线图

> 最后更新：2026-06-23（V2 全量重构完成）。

---

## V2 阶段（2026-06-23 完成）

### V2：企业经营初诊系统全量重构

**目标**：从"AI财税问卷"升级为"君册企业经营初诊系统"，打造演示级一期产品。

**已完成模块**：

| 序号 | 模块 | 产出 | 状态 |
|------|------|------|------|
| V2-1 | 产品模型文档 | `AI-docs/V2_BUSINESS_DIAGNOSIS_MODEL.md` | ✅ `[06-23]` |
| V2-2 | Schema 迁移 | DiagnosisMode 枚举 + DocumentRequirement + UploadedDocument + 5 模型扩展字段 | ✅ `[06-23]` |
| V2-3 | 资料上传体系 | 三档模式(QUICK/STANDARD/DEEP) + 19种资料类型 + 完整度评分 + 四维可信度 + 文件安全 | ✅ `[06-23]` |
| V2-4 | 九维规则模型 | 65 题 V2 问卷 + 55 条诊断规则(含 COMPOSITE AND/OR) + 12 个风险场景 | ✅ `[06-23]` |
| V2-5 | 四维经营看板 | BusinessDashboardService 评分引擎(利润×0.25+风险×0.35+现金流×0.25+效率×0.15) | ✅ `[06-23]` |
| V2-6 | 报告升级 | 9 段式结构 + customerVisible 门控 + 客户/后台双通道 | ✅ `[06-23]` |
| V2-7 | Submission 生命周期 | DRAFT → DOCUMENT_UPLOADING → QUESTIONNAIRE_COMPLETED → DIAGNOSING → COMPLETED + SubmissionAccessToken | ✅ `[06-23]` |
| V2-8 | 前端客户流程 | DiagnosisStartPage + DocumentUploadPage + V2 问卷支持 + Pinia stores | ✅ `[06-23]` |
| V2-9 | 前端四维看板 | BusinessDashboard + ECharts 雷达图 + DimensionCard + TopActions | ✅ `[06-23]` |
| V2-10 | 前端报告页重写 | 9 段式 + PENDING_REVIEW/READY 两态 + 打印优化 | ✅ `[06-23]` |
| V2-11 | 后台升级 | AdminService 返回 dashboard + uploadedDocuments + dimensionRuleHits | ✅ `[06-23]` |
| V2-12 | 文档同步 | PROJECT_STATE_SNAPSHOT / API_CONTRACT / DATABASE_GUIDE / ROADMAP / README / project-note | ✅ `[06-23]` |

---

## Phase 0-5（2026-06-22 完成）

V1 核心闭环：项目初始化 → 问卷 → 规则引擎 → 报告生成 → 人工复核 → Docker 部署

全部 13 个 API + 16 个模型 + 7 个前端路由，详见 PROJECT_STATE_SNAPSHOT.md。

---

## V2 后续

| 序号 | 任务 | 状态 | 预计 |
|------|------|------|------|
| V2-F1 | 编写 DEMO_CASES_V2.md（3套案例：低/中/高风险） | ⬜ | 0.5天 |
| V2-F2 | 浏览器端到端完整流程验证 | ⬜ | 0.5天 |
| V2-F3 | 前端 skipLogic hideInModes 按模式过滤题量 | ⬜ | 0.5天 |
| V2-F4 | ECharts 按需加载优化（减小 ReportPage chunk） | ⬜ | 0.5天 |
| V2-F5 | 代码 Review + PR → 合并 main | ⬜ | 0.5天 |

---

## 阶段 5：部署上线（待启动）

- Docker 化部署（Dockerfile ×2 + docker-compose 已就绪）
- 生产环境变量配置
- Nginx 反向代理
- HTTPS 证书
- 冒烟测试

---

## 阶段 6：小程序数据打通（二期）

- 预留 `Submission.miniProgramCustomerId` 字段

---

## 施工依赖关系（当前）

```
V1 Phase 0-5 (✅ 已完成)
    └─→ V2 全量重构 (✅ 已完成)
            ├─→ V2-F1 演示案例 (⬜)
            ├─→ V2-F2 端到端验证 (⬜)
            └─→ V2-F5 合并 main (⬜)
                    └─→ 部署上线 (⬜)
```

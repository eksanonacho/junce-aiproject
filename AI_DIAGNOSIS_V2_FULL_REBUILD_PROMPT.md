# 君册财税 AI 初诊系统 V2 全量重构任务

## 0. 当前项目路径

当前项目根目录：

bash /Users/a1234/Desktop/junce-aiproject/ 

这是独立的 AI 初诊网站项目。

小程序项目路径：

bash /Users/a1234/cpp/junce-miniprogram/ 

严禁修改小程序项目。

---

# 1. 任务背景

当前 AI 初诊网站已经具备基础技术闭环：

text 客户填写问卷 → 提交 → 规则诊断 → 报告生成 → 客户侧查看 → 后台复核 → Docker 本地运行验证 

但当前产品仍然存在严重问题：

text 1. 问卷像客户画像录入，不像真正的诊断分析。 2. 结果页缺少老板能看懂的经营看板。 3. 没有资料上传，诊断可信度不足。 4. 风险规则不够完整。 5. 四维九维模型没有真正落地。 6. 页面和报告还不够专业，无法超过客户预期。 7. 当前状态拿给客户看，会像大学生期末作业。 

现在不再等待客户补齐所有业务资料。  
本轮任务要求你基于现有项目，自作主张构建完整的一期演示版。

目标不是“能跑”，而是：

text 做出一个漂亮、专业、完整、能让纪姐觉得超过预期的 AI 初诊系统。 

---

# 2. 核心产品重新定义

本系统不再只是：

text AI 财税问卷 

而是：

text 君册企业经营初诊系统 

核心组成：

text 手机号入口 + 资料上传 + 问卷补充 + 九维规则判断 + 四维经营看板 + 人工复核 + 服务转化 

---

# 3. 四维九维的正确理解

## 3.1 四维是什么

四维是最终老板看板的输出维度。

四维必须按照以下结构设计：

text 1. 利润 2. 风险 3. 现金流 4. 效率 

四维不是普通问卷分类。  
四维是客户最终看到的“经营诊断看板”。

最终报告/结果页必须展示：

text 综合经营健康度 利润评分 风险评分 现金流评分 效率评分 一句话结论 TOP3 优先行动建议 资料完整度 复核状态 服务建议 

---

## 3.2 九维是什么

九维是支撑四维看板的底层规则模块。

九维必须定义为：

| 九维代码 | 九维名称 | 支撑四维 |
|---|---|---|
| REVENUE_MARGIN | 收入与毛利维 | 利润 |
| COST_EXPENSE | 成本费用维 | 利润 |
| CUSTOMER_PRODUCT | 客户产品贡献维 | 利润 / 效率 |
| TAX_DECLARATION | 税务申报维 | 风险 |
| INVOICE_FUND | 发票资金维 | 风险 |
| SOCIAL_BUSINESS | 社保工商维 | 风险 |
| RECEIVABLE_COLLECTION | 应收回款维 | 现金流 |
| INVENTORY_PAYABLE | 存货付款维 | 现金流 |
| HUMAN_ASSET_EFFICIENCY | 人效资产维 | 效率 |

九维用于：

text 问题归类 资料要求归类 规则归类 风险信号归类 四维评分计算 报告依据展示 服务推荐映射 

---

# 4. 本轮总目标

完成一次 V2 级别重构，使系统达到以下状态：

text 1. 用户进入网站后，不再只是填问卷，而是进入企业经营初诊流程。 2. 用户先选择初诊模式，再上传资料，再补充问卷。 3. 系统基于资料完整度 + 问卷答案 + 九维规则生成四维经营看板。 4. 结果页必须像专业老板看板，而不是普通文字报告。 5. 后台复核页也必须看到完整四维看板和资料上传情况。 6. 所有内容必须足够完整，能作为第一期演示版本给纪姐看。 

---

# 5. 严格禁止

本轮不要做以下事情：

text 1. 不修改 /Users/a1234/cpp/junce-miniprogram/ 2. 不把 AI 初诊功能塞进小程序项目 3. 不接真实短信服务 4. 不接真实 OCR 5. 不声称已经自动解析所有上传资料 6. 不声称基于真实大数据精准判断 7. 不写最终税务结论 8. 不写最终法律结论 9. 不写最终审计结论 10. 不写“违法了” 11. 不写“必须补税” 12. 不写“一定会被罚” 13. 不写“保证解决” 14. 不写“保证合规” 15. 不写“100% 避免风险” 16. 不写“税局不会查” 17. 不写“包注销” 18. 不做假短信验证码 19. 不伪造真实财务数据 20. 不隐藏失败 

所有表述必须保持：

text 初步筛查 建议进一步核查 基于当前填写和上传资料 资料完整度影响判断可信度 由君册专业人员复核 不构成最终税务、法律、审计意见 

---

# 6. 开始前必须检查

执行：

bash pwd git status 

确认当前目录是：

bash /Users/a1234/Desktop/junce-aiproject/ 

确认不是：

bash /Users/a1234/cpp/junce-miniprogram/ 

然后阅读项目已有资料：

bash CLAUDE.md AI-docs/ ai-diagnosis-server/prisma/schema.prisma ai-diagnosis-server/prisma/seed.ts ai-diagnosis-client/src/router/index.ts ai-diagnosis-client/src/pages/ 

先理解现有项目，不要盲目推翻。

---

# 7. 建议新建工作分支

执行：

bash git checkout -b feature/v2-business-diagnosis 

如果当前已有未提交内容，先说明，不要强行覆盖。

---

# 8. 第一部分：建立 V2 产品模型文档

新增文档：

bash AI-docs/V2_BUSINESS_DIAGNOSIS_MODEL.md 

内容必须包括：

text 1. V2 产品定位 2. 四维看板定义 3. 九维规则定义 4. 资料上传体系 5. 问卷补充体系 6. 资料完整度评分 7. 四维评分计算逻辑 8. 报告展示结构 9. 后台复核结构 10. 合规边界 

这份文档是 V2 的产品根文档。

---

# 9. 第二部分：新增资料上传体系

## 9.1 资料上传的定位

资料上传不是装饰。

资料上传的作用是：

text 1. 提升诊断可信度 2. 支撑四维看板 3. 告诉客户哪些资料缺失 4. 告诉君册后续需要客户补哪些材料 5. 让系统不像普通问卷，而像专业初诊流程 

第一期不要求真实 OCR 或自动解析全部文件。  
但必须做到：

text 客户能上传资料 系统能记录资料类型 系统能计算资料完整度 报告能显示依据与缺失资料 后台能查看上传资料清单 

---

## 9.2 资料分档

新增三档初诊模式：

### 快速初诊

适合第一次体验。

资料要求：

text 营业执照或企业基本信息 近 3-6 个月利润表 近 3-6 个月资产负债表 近 3-6 个月纳税申报表 

### 标准初诊

适合正式演示和一期主流程。

资料要求：

text 营业执照 近 12 个月利润表 近 12 个月资产负债表 近 12 个月现金流量表 科目余额表 增值税申报表 企业所得税申报表 开票/收票汇总 银行流水 工资表 / 社保记录 / 个税申报 

### 深度经营出诊

适合后续收费服务。

资料要求：

text 产品/项目收入成本表 客户收入贡献表 应收账款明细及账龄 应付账款明细 存货明细及库龄 固定资产/设备清单 费用明细 合同样本 员工花名册 历史税务异常/处罚/提醒记录 

---

## 9.3 资料类型代码

定义资料类型：

| code | name | affects |
|---|---|---|
| BUSINESS_LICENSE | 营业执照 | 风险 / 生命周期 |
| INCOME_STATEMENT | 利润表 | 利润 |
| BALANCE_SHEET | 资产负债表 | 现金流 / 效率 |
| CASH_FLOW_STATEMENT | 现金流量表 | 现金流 |
| ACCOUNT_BALANCE | 科目余额表 | 利润 / 风险 |
| VAT_DECLARATION | 增值税申报表 | 风险 |
| CIT_DECLARATION | 企业所得税申报表 | 风险 / 利润 |
| INVOICE_SUMMARY | 开票/收票汇总 | 风险 |
| BANK_STATEMENT | 银行流水 | 现金流 / 风险 |
| PAYROLL_SOCIAL_SECURITY | 工资社保个税资料 | 风险 / 效率 |
| CUSTOMER_REVENUE | 客户收入贡献表 | 利润 / 效率 |
| PRODUCT_MARGIN | 产品/项目毛利表 | 利润 |
| AR_AGING | 应收账款账龄表 | 现金流 |
| AP_AGING | 应付账款明细 | 现金流 |
| INVENTORY_DETAIL | 存货明细 | 现金流 / 效率 |
| FIXED_ASSET | 固定资产/设备清单 | 效率 |
| EXPENSE_DETAIL | 费用明细 | 利润 / 效率 |
| CONTRACT_SAMPLE | 合同样本 | 风险 |
| TAX_ABNORMAL_RECORD | 税务异常/处罚/提醒记录 | 风险 |

---

## 9.4 后端数据模型

检查现有 Prisma schema。  
如果没有资料上传模型，则新增。

建议新增模型：

prisma model UploadedDocument {   id              Int      @id @default(autoincrement())   publicId        String   @unique   submissionId    Int?   submission      Submission? @relation(fields: [submissionId], references: [id])   docType         String   docName         String   originalName    String   mimeType        String   sizeBytes       Int   storagePath     String   uploadStatus    String   @default("UPLOADED")   createdAt       DateTime @default(now())   updatedAt       DateTime @updatedAt } 

如果当前 schema 命名不同，请按现有风格适配。

建议新增：

prisma model DocumentRequirement {   id              Int      @id @default(autoincrement())   code            String   @unique   name            String   category        String   requiredForQuick Boolean @default(false)   requiredForStandard Boolean @default(false)   requiredForDeep Boolean @default(false)   affectsDimensions Json?   description     String?   sortOrder       Int      @default(0)   isActive        Boolean  @default(true)   createdAt       DateTime @default(now())   updatedAt       DateTime @updatedAt } 

如果不想新增 DocumentRequirement 表，也可以先在 seed/config 中维护。  
但推荐建表，后续后台可编辑。

---

## 9.5 后端文件上传接口

新增模块：

bash src/document/ 

接口：

http GET /api/document-requirements?mode=quick|standard|deep POST /api/submissions/:submissionPublicId/documents GET /api/submissions/:submissionPublicId/documents DELETE /api/submissions/:submissionPublicId/documents/:documentPublicId 

要求：

text 支持 PDF 支持 Excel 支持 Word 支持图片 限制文件大小 保存到本地 uploads 目录 uploads 目录加入 .gitignore 不把真实上传文件提交到 git 

第一期可以使用本地文件存储，不接对象存储。

---

## 9.6 资料完整度评分

生成资料完整度：

text documentCompletenessScore: 0 - 100 

计算逻辑：

text 按所选初诊模式要求的资料类型计算 已上传 required 文档越多，分数越高 可选资料加分 关键资料缺失影响对应维度可信度 

输出：

json {   "mode": "standard",   "completenessScore": 68,   "uploadedCount": 7,   "requiredCount": 10,   "missingDocuments": [     "银行流水",     "应收账款账龄表",     "工资社保个税资料"   ],   "dimensionConfidence": {     "PROFIT": 72,     "RISK": 65,     "CASH_FLOW": 48,     "EFFICIENCY": 55   } } 

---

# 10. 第三部分：重构客户流程

当前流程不要再是：

text 进入问卷 填写 提交 

改成：

text 手机号入口 → 选择初诊模式 → 上传资料 → 补充问卷 → 生成四维看板 → 人工复核 

---

## 10.1 前端路由建议

新增或调整客户侧路由：

text /diagnosis/start /diagnosis/upload /questionnaire /questionnaire/success /report/:publicId 

如果为了减少改动，也可以继续使用 /questionnaire，但内部步骤必须变成：

text 资料上传 + 问卷补充 

---

## 10.2 Start 页面

内容：

text 选择初诊模式 快速初诊 标准初诊 深度经营出诊 

标准初诊默认推荐。

每个模式说明：

text 快速初诊：少量资料 + 基础问卷，适合初步了解 标准初诊：推荐上传 10 类资料，生成完整四维看板 深度经营出诊：适合后续顾问深度服务 

---

## 10.3 Upload 页面

做成非常专业的资料清单页面。

布局：

text 左侧：资料上传清单 右侧：资料完整度面板 

每个资料项显示：

text 资料名称 用途说明 影响维度 是否必传 上传状态 上传按钮 

示例：

text 近 12 个月利润表 用于判断收入、毛利和费用变化情况 影响维度：利润 状态：未上传 

右侧面板：

text 资料完整度：68% 利润维度可信度：72% 风险维度可信度：65% 现金流维度可信度：48% 效率维度可信度：55% 

允许用户跳过资料上传，但必须提示：

text 资料越完整，初诊结果参考价值越高。缺失资料可能导致部分维度仅能做初步判断。 

---

## 10.4 Questionnaire 页面

问卷不是主角，而是资料补充。

标题改为：

text 补充经营情况 

副标题：

text 请补充资料中无法体现的经营情况，系统将结合资料完整度和问卷答案生成初诊看板。 

问卷体验必须是自然滚动式，不要一组一页切换。

要求：

text 问题卡片 选项卡片 选择后平滑滚动 右侧 sticky 进度面板 移动端底部进度 

---

# 11. 第四部分：重建问卷题库

问卷题库不再只有 30 道。

建立：

text 总题库：60 - 80 道 用户实际填写：25 - 45 道 

第一期不一定全部复杂跳题，但题库必须完整。

---

## 11.1 问卷分组

按照九维分组：

text 1. 收入与毛利 2. 成本费用 3. 客户产品贡献 4. 税务申报 5. 发票资金 6. 社保工商 7. 应收回款 8. 存货付款 9. 人效资产 

每个维度 5-8 道题。

---

## 11.2 收入与毛利维

示例题：

text 近一年营业收入变化情况？ 主要产品或服务毛利水平如何？ 是否存在低毛利或亏损产品？ 是否能区分不同产品/项目毛利？ 是否存在收入增长但利润没有增长？ 是否有季节性收入波动？ 

---

## 11.3 成本费用维

示例题：

text 近一年成本是否明显上涨？ 销售费用是否明显增长？ 人工成本是否明显增长？ 房租、物流、平台费等固定费用是否有压力？ 是否定期核算费用投入产出比？ 是否存在老板个人支出与公司费用混用？ 

---

## 11.4 客户产品贡献维

示例题：

text 收入是否依赖少数大客户？ 是否知道前五大客户毛利贡献？ 是否存在低毛利大客户？ 是否有客户长期拖欠款项？ 是否有产品/服务长期不赚钱但仍在做？ 是否定期淘汰低效产品或客户？ 

---

## 11.5 税务申报维

示例题：

text 是否按期申报？ 是否长期零申报？ 零申报期间是否仍有经营？ 是否出现过税务提醒、异常或处罚？ 纳税人身份是否清楚？ 是否存在申报数据与实际经营不一致的担忧？ 

---

## 11.6 发票资金维

示例题：

text 发票与实际业务是否匹配？ 进项与销项结构是否合理？ 银行流水是否能对应合同、发票和业务？ 是否存在频繁公转私？ 是否存在大额无说明往来？ 是否存在私人账户收款？ 

---

## 11.7 社保工商维

示例题：

text 是否有员工？ 社保是否正常缴纳？ 工资、个税和社保人数是否一致？ 是否有较多兼职、劳务或外包人员？ 工商状态是否正常？ 是否频繁变更法人、股东或地址？ 

---

## 11.8 应收回款维

示例题：

text 客户回款是否及时？ 是否存在逾期 90 天以上应收账款？ 是否有专人跟进应收款？ 是否对高风险客户停止发货或服务？ 是否知道平均回款周期？ 是否有坏账或长期挂账？ 

---

## 11.9 存货付款维

示例题：

text 是否存在存货积压？ 是否知道存货周转天数？ 是否有呆滞库存？ 供应商账期是否稳定？ 是否经常先付款后回款？ 是否存在采购占用大量现金？ 

---

## 11.10 人效资产维

示例题：

text 人员配置是否与业务量匹配？ 是否知道人均产出？ 是否存在明显人员冗余？ 是否存在设备、仓库、车辆闲置？ 是否有流程重复、人工录入、效率低的问题？ 是否定期复盘经营效率？ 

---

# 12. 第五部分：规则体系

建立不少于：

text 50 条风险规则 20 条服务推荐规则 10 条资料完整度规则 

规则必须全部挂到九维。

---

## 12.1 风险等级

使用：

text LOW MEDIUM HIGH UNKNOWN 

规则：

text HIGH：强制人工复核 MEDIUM：可根据数量升级 LOW：无明显高风险信号 UNKNOWN：关键信息缺失，需补充资料或人工确认 

---

## 12.2 规则示例

### 长期零申报但有经营

维度：

text TAX_DECLARATION 

触发：

text 长期零申报 且 有经营/流水/开票/人员 

结果：

text HIGH forcedReview = true 

---

### 频繁公转私

维度：

text INVOICE_FUND 

触发：

text 频繁公转私 或 大额私人账户往来 

结果：

text HIGH forcedReview = true 

---

### 回款周期过长

维度：

text RECEIVABLE_COLLECTION 

触发：

text 经常拖延 或 存在较多长期未回款 

结果：

text MEDIUM / HIGH 

---

### 存货积压严重

维度：

text INVENTORY_PAYABLE 

触发：

text 存货积压明显 或 呆滞库存较多 

结果：

text MEDIUM 

---

### 低毛利大客户依赖

维度：

text CUSTOMER_PRODUCT 

触发：

text 收入高度依赖少数客户 且 存在低毛利客户 

结果：

text MEDIUM / HIGH 

---

# 13. 第六部分：四维经营看板计算

新增后端服务：

text business-dashboard.service.ts 

职责：

text 根据问卷答案 + 资料完整度 + 风险规则命中情况 计算四维评分和综合健康度 

---

## 13.1 四维评分

评分范围：

text 1.0 - 5.0 

分值含义：

text 4.0 - 5.0：较好 3.0 - 3.9：一般 2.0 - 2.9：需关注 1.0 - 1.9：压力较大 / 风险较高 

---

## 13.2 利润评分

依据：

text 收入变化 毛利水平 费用增长 客户/产品贡献 资料完整度 

---

## 13.3 风险评分

依据：

text 税务申报 发票资金 社保工商 税务异常 规则命中情况 

注意：

text 风险评分越高 = 越安全 风险评分越低 = 风险越高 

---

## 13.4 现金流评分

依据：

text 应收回款 存货积压 应付账期 现金紧张程度 银行流水资料完整度 

---

## 13.5 效率评分

依据：

text 人员效率 资产利用 客户集中度 流程效率 库存周转 

---

## 13.6 综合健康度

计算：

text 综合健康度 = 利润 * 0.25 + 风险 * 0.35 + 现金流 * 0.25 + 效率 * 0.15 

生成：

json {   "overallScore": 3.2,   "overallLabel": "需重点关注",   "profitScore": 2.8,   "riskScore": 2.0,   "cashFlowScore": 2.2,   "efficiencyScore": 3.0,   "documentCompletenessScore": 68,   "confidenceLevel": "MEDIUM" } 

---

# 14. 第七部分：四维经营看板展示

报告页顶部必须新增：

text 君册企业经营初诊看板 

它是整个系统的核心门面。

---

## 14.1 看板布局

桌面端：

text 左侧： - 综合经营健康度卡片 - 雷达图  右侧： - 四维状态卡 - 一句话结论 - TOP3 优先行动 

移动端：

text 综合健康度 雷达图 四维卡片 一句话结论 TOP3 行动 资料完整度 

---

## 14.2 必须展示的内容

text 综合经营健康度 利润评分 风险评分 现金流评分 效率评分 资料完整度 报告可信度 一句话结论 TOP3 行动建议 缺失资料提醒 服务建议 人工复核状态 

---

## 14.3 雷达图

建议使用：

bash pnpm add echarts vue-echarts 

如果引入失败，可以先用 CSS 替代。  
但最终效果建议用 ECharts 雷达图。

雷达图维度：

text 利润 风险 现金流 效率 综合 

不要做得像普通后台图表。  
要像高端咨询看板。

---

## 14.4 四维卡片

每张卡片包含：

text 维度名称 分数 状态 核心问题 建议动作 依据资料 可信度 

示例：

text 现金流 2.2 / 5 状态：压力较大 问题：回款周期偏长，存货或项目周期可能占用资金 建议：优先梳理应收账款和资金周转周期 依据：银行流水未上传，应收账款明细缺失，可信度中等 

---

## 14.5 一句话结论

生成老板能看懂的结论。

示例：

text 根据当前填写和上传资料，企业盈利能力一般，风险项需重点关注，现金流存在一定压力。建议优先核查税务申报、发票流水和回款周期，并由君册人员进一步复核。 

---

## 14.6 TOP3 行动建议

每条包含：

text 优先级 行动标题 建议时间 原因 对应服务 

示例：

text 1. 优先核查税务申报与账务资料 时间：1个月内 原因：当前存在申报或账务资料相关风险信号 对应服务：税务合规检查 / 补账清账 

---

# 15. 第八部分：报告结构升级

报告结构必须变成：

text 一、经营初诊总览 二、四维经营看板 三、资料完整度说明 四、九维规则分析 五、命中风险场景 六、TOP3 行动建议 七、君册服务建议 八、人工复核提示 九、免责声明 

不要再只是风险列表。

---

# 16. 第九部分：后台复核升级

后台报告详情页必须展示：

text 客户资料上传情况 资料完整度 四维看板 九维命中规则 风险清单 TOP3 行动 服务建议 复核操作 复核记录 

后台人员需要看到比客户更多的信息。

客户侧中高风险不可见时，后台仍可见完整看板。

---

# 17. 第十部分：前端视觉要求

所有客户侧页面都要重做成企业级。

重点页面：

text /diagnosis/start /diagnosis/upload /questionnaire /questionnaire/success /report/:publicId 

视觉标准：

text 高级 专业 有咨询公司质感 有 SaaS 产品感 不卡通 不廉价 不政务 不大学生作业 

---

## 17.1 问卷页

必须是自然滚动式。

不要：

text 下一组 上一组 一页一页切换 普通 radio 表单 

要：

text 问题卡片 选项卡片 自动平滑滚动 右侧 sticky 进度 移动端底部进度 四维九维进度提示 资料完整度提示 

---

## 17.2 上传页

必须漂亮。

风格：

text 资料清单 上传状态 资料完整度 维度影响 缺失提醒 

每个上传项像专业 checklist，不要像普通 input file。

---

## 17.3 报告页

必须是全项目最漂亮的页面。

参考四维看板 PPT，但不能 1:1 复刻。  
必须做得更强：

text 更现代 更动态 更像网页产品 更像老板看板 

---

# 18. 第十一部分：演示案例

新增：

bash AI-docs/DEMO_CASES_V2.md 

必须包含 3 个完整案例。

---

## Case A：低风险健康企业

特征：

text 资料较完整 申报正常 账务完整 发票流水基本匹配 回款正常 社保正常 无明显工商异常 

预期：

text 综合健康度 4.0+ LOW customerVisible = true 资料完整度 80%+ 

---

## Case B：中风险经营需关注企业

特征：

text 部分资料缺失 偶尔逾期 费用增长较快 回款周期偏长 部分社保不完整 

预期：

text 综合健康度 2.8 - 3.5 MEDIUM needReview = true 或 待复核 资料完整度 50%-75% 

---

## Case C：高风险待复核企业

特征：

text 长期零申报但仍有经营 账务长期缺失 频繁公转私 回款拖延 准备注销但资料不完整 社保基本未缴 

预期：

text 综合健康度 2.0 - 2.8 HIGH NEED_REVIEW customerVisible = false 资料完整度偏低 后台可见完整看板 

---

# 19. 第十二部分：合规文案

全系统统一使用：

text 本系统生成内容仅作为企业经营与财税风险初步筛查参考，不构成最终税务、法律、审计或行政结论。具体事项建议结合完整资料由君册专业人员进一步复核。 

禁止任何确定性判断。

---

# 20. 第十三部分：技术实现建议

## 20.1 后端

新增或扩展模块：

text document/ business-dashboard/ 

可能涉及：

text document.module.ts document.controller.ts document.service.ts business-dashboard.service.ts 

ReportService 生成报告时调用 BusinessDashboardService。

---

## 20.2 前端

建议新增组件：

text components/diagnosis/ModeSelector.vue components/diagnosis/DocumentUploadChecklist.vue components/diagnosis/DocumentCompletenessPanel.vue components/questionnaire/QuestionCard.vue components/questionnaire/ChoiceCard.vue components/questionnaire/ProgressPanel.vue components/report/BusinessDashboard.vue components/report/RadarChart.vue components/report/DimensionCard.vue components/report/TopActions.vue components/report/DocumentEvidencePanel.vue 

---

## 20.3 动效

可以使用：

bash pnpm add @formkit/auto-animate @vueuse/motion 

用于：

text 问题卡片进入 选项选择 上传清单状态变化 报告看板入场 

不要做花哨动画。

---

## 20.4 图表

建议：

bash pnpm add echarts vue-echarts 

用于雷达图。

---

# 21. 测试要求

必须跑通：

bash cd ai-diagnosis-server && pnpm build cd ai-diagnosis-client && pnpm build 

然后测试：

text 快速初诊流程 标准初诊流程 资料上传 问卷补充 LOW 案例 MEDIUM 案例 HIGH 案例 报告页四维看板 后台复核页 APPROVE 后客户可见 REJECT 后客户不可见 

---

# 22. 验收标准

完成后必须满足：

text 1. 系统不再像普通问卷。 2. 有资料上传流程。 3. 有资料完整度评分。 4. 有九维规则模型。 5. 有 50+ 风险规则。 6. 有四维经营看板。 7. 报告页比原 PPT 更高级。 8. 后台可看完整诊断依据。 9. 客户侧中高风险仍需复核。 10. 有三套演示案例。 11. 页面视觉明显升级。 12. 问卷自然滚动，不再翻页。 13. 提交和报告 token 流程不丢。 14. 前端 build 通过。 15. 后端 build 通过。 16. 未修改小程序项目。 

---

# 23. 最终完成报告要求

完成后输出：

text 1. 修改了哪些文件 2. 新增了哪些文件 3. 是否新增资料上传 4. 资料类型清单 5. 初诊模式说明 6. 四维看板模型 7. 九维规则模型 8. 问卷题库数量 9. 风险规则数量 10. 服务推荐数量 11. 资料完整度计算逻辑 12. 四维评分计算逻辑 13. dashboard JSON 示例 14. 报告页效果说明 15. 后台复核页效果说明 16. LOW 案例测试结果 17. MEDIUM 案例测试结果 18. HIGH 案例测试结果 19. 前端 build 结果 20. 后端 build 结果 21. git commit hash 22. 是否触碰小程序项目 

最后一项必须明确回答：

text 未修改 /Users/a1234/cpp/junce-miniprogram/ 

---

# 24. 最重要的产品要求

这次不要做“能跑就行”。

这次目标是：

text 让纪姐看到后觉得： 这比我想的完整很多。 

最终产品必须呈现出：

text 资料驱动 规则支撑 四维看板 九维诊断 人工复核 服务转化 

不要再做大学生期末作业级别的页面。

如果某个功能短时间无法完全实现，不要假装完成。  
必须说明：

text 已完成什么 暂时无法完成什么 为什么 下一步怎么补 

但整体目标不变：

text 做一个完整、漂亮、专业、能演示的一期 V2。 
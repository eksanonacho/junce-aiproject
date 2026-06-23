import { PrismaClient } from '../../generated/prisma/client';

export async function seedV2RiskScenarios(prisma: PrismaClient) {
  console.log('  ⚠️  V2 Risk Scenarios...');

  const scenarios = [
    { scenarioName: '长期零申报持续经营', scenarioCode: 'V2_SC_001', description: '企业长期零申报但实际存在经营活动，属于高风险税务违规行为。', riskLevel: 'HIGH' as const, triggerRules: ['V2_TAX_002C'], safeExplanation: '长期零申报但实际有经营活动，是税务部门重点关注的情形，可能面临补税、滞纳金和行政处罚。', forbiddenPhrases: ['肯定会被查', '一定会被罚', '可以继续零申报'], suggestion: '建议立即委托专业人员规范账务，如实申报经营情况。君册可提供代理记账和补账清账服务。', recommendServices: ['代理记账', '补账清账', '税务合规检查'], needManualReview: true, isActive: true },
    { scenarioName: '公私账户混用', scenarioCode: 'V2_SC_002', description: '企业资金通过个人账户流转，包括私人账户收公司款、频繁公转私，存在严重财税合规风险。', riskLevel: 'HIGH' as const, triggerRules: ['V2_FUND_002', 'V2_FUND_003'], safeExplanation: '公私账户混用可能导致财产混同、难以区分经营收支，也是税务稽查的重点关注事项。', forbiddenPhrases: ['违法了', '一定会被罚', '包解决'], suggestion: '建议尽快规范资金账户管理，开设对公账户，所有经营收支通过公司账户。', recommendServices: ['开户指导', '财务外包', '税务合规检查'], needManualReview: true, isActive: true },
    { scenarioName: '回款大面积逾期', scenarioCode: 'V2_SC_003', description: '客户回款严重延迟，存在大额逾期账款，企业现金流面临较大压力。', riskLevel: 'MEDIUM' as const, triggerRules: ['V2_AR_001', 'V2_AR_002', 'V2_AR_005C'], safeExplanation: '应收账款回款周期过长会影响企业日常经营所需现金流，建议建立规范的账款管理制度。', forbiddenPhrases: ['肯定收不回来', '一定会坏账'], suggestion: '建议建立应收账款台账和催收流程，对高风险客户收紧信用政策。', recommendServices: ['经营分析'], needManualReview: false, isActive: true },
    { scenarioName: '发票业务不匹配', scenarioCode: 'V2_SC_004', description: '发票与实际业务不匹配，进销项结构异常，存在虚开发票或账外经营风险。', riskLevel: 'HIGH' as const, triggerRules: ['V2_FUND_001', 'V2_FUND_006'], safeExplanation: '发票与业务不匹配可能涉及虚开发票、账外经营等问题，是税务稽查的重点领域。', forbiddenPhrases: ['违法了', '肯定会查', '一定会处罚'], suggestion: '建议规范发票管理，确保票货款三流一致，由专业人员核查发票合规性。', recommendServices: ['税务合规检查', '代理记账'], needManualReview: true, isActive: true },
    { scenarioName: '全员未缴社保', scenarioCode: 'V2_SC_005', description: '有员工但全员未缴纳社保，属于严重劳动用工合规问题。', riskLevel: 'HIGH' as const, triggerRules: ['V2_SB_001', 'V2_SB_005C'], safeExplanation: '有员工未缴纳社保违反劳动法和社保法规定，可能面临劳动监察、补缴和罚款。', forbiddenPhrases: ['违法了', '一定会被查', '可以不交'], suggestion: '建议立即为员工办理社保登记和缴纳，规范用工关系，君册可提供社保用工咨询服务。', recommendServices: ['社保用工咨询'], needManualReview: true, isActive: true },
    { scenarioName: '收入高度依赖大客户', scenarioCode: 'V2_SC_006', description: '收入高度依赖少数大客户，经营风险集中，一旦客户流失将造成重大影响。', riskLevel: 'MEDIUM' as const, triggerRules: ['V2_CP_001', 'V2_CP_005C'], safeExplanation: '客户集中度偏高是常见的经营风险，建议主动分散客户结构，降低单一客户依赖。', forbiddenPhrases: ['一定会破产', '肯定不行'], suggestion: '建议积极开拓新客户和市场，逐步降低大客户收入占比至30%以下。', recommendServices: ['经营分析'], needManualReview: false, isActive: true },
    { scenarioName: '收入持续下降', scenarioCode: 'V2_SC_007', description: '近一年营业收入持续下降，可能反映市场竞争力减弱或行业下行。', riskLevel: 'MEDIUM' as const, triggerRules: ['V2_REV_001', 'V2_REV_005C'], safeExplanation: '收入持续下降需要重点关注业务结构和市场竞争策略，建议深入分析原因。', forbiddenPhrases: ['公司不行了', '肯定倒闭'], suggestion: '建议全面分析收入下降原因，评估产品/客户/渠道结构，制定应对方案。', recommendServices: ['经营分析'], needManualReview: false, isActive: true },
    { scenarioName: '费用失控利润承压', scenarioCode: 'V2_SC_008', description: '成本费用快速增长，利润空间不断压缩，企业经营效益下降。', riskLevel: 'MEDIUM' as const, triggerRules: ['V2_COST_001', 'V2_COST_006C'], safeExplanation: '成本费用增速超过收入增速会导致利润持续下降，需关注费用控制。', forbiddenPhrases: ['肯定亏损', '一定会倒闭'], suggestion: '建议全面审计费用结构，建立费用预算和控制机制。', recommendServices: ['经营分析', '财务外包'], needManualReview: false, isActive: true },
    { scenarioName: '存货积压+现金流紧张', scenarioCode: 'V2_SC_009', description: '存货严重积压同时付款压力大，资金周转困难。', riskLevel: 'MEDIUM' as const, triggerRules: ['V2_IP_001', 'V2_IP_005C'], safeExplanation: '存货积压占用大量资金，叠加付款压力可能导致现金流断裂。', forbiddenPhrases: ['肯定破产', '资金链断了一定完蛋'], suggestion: '建议加快存货变现，优化采购和库存管理，缓解现金流压力。', recommendServices: ['经营分析'], needManualReview: false, isActive: true },
    { scenarioName: '未按期申报+无专业会计', scenarioCode: 'V2_SC_010', description: '未按期纳税申报且无专业会计人员，税务合规风险极高。', riskLevel: 'HIGH' as const, triggerRules: ['V2_TAX_001', 'V2_TAX_005'], safeExplanation: '未按期申报且没有专业人员处理账务，随时可能触发税务风险。', forbiddenPhrases: ['违法了', '可以不申报', '不会被发现'], suggestion: '建议立即委托代理记账，由专业人员补申报和规范后续账务。', recommendServices: ['代理记账', '补账清账', '税务合规检查'], needManualReview: true, isActive: true },
    { scenarioName: '先付后收资金倒挂', scenarioCode: 'V2_SC_011', description: '经常先向供应商付款再向客户收款，企业长期垫付资金，现金流压力持续。', riskLevel: 'MEDIUM' as const, triggerRules: ['V2_IP_004'], safeExplanation: '先付款后收款模式占用大量运营资金，建议争取改善付款条款或采用预收模式。', forbiddenPhrases: ['肯定缺钱', '一定会周转不开'], suggestion: '建议优化采购付款条件，争取客户预付款或缩短回款周期。', recommendServices: ['经营分析'], needManualReview: false, isActive: true },
    { scenarioName: '人员冗余+人效低下', scenarioCode: 'V2_SC_012', description: '人员配置冗余且缺乏人效管理，人工成本浪费严重。', riskLevel: 'MEDIUM' as const, triggerRules: ['V2_HAE_001', 'V2_HAE_005C'], safeExplanation: '人员冗余和低效管理会持续消耗企业利润，建议定期评估人效指标。', forbiddenPhrases: ['肯定要裁员', '养了一堆闲人'], suggestion: '建议建立人效考核体系，优化人员配置，提升整体运营效率。', recommendServices: ['经营分析', '社保用工咨询'], needManualReview: false, isActive: true },
  ];

  for (const sc of scenarios) {
    await prisma.riskScenario.upsert({
      where: { scenarioCode: sc.scenarioCode },
      update: sc,
      create: sc,
    });
  }

  console.log(`  ✅ V2 Risk Scenarios: ${scenarios.length} seeded`);
}

import { PrismaClient } from '../../generated/prisma/client';

// skipLogic tag:
//   'QS' = hidden in QUICK and STANDARD (deep only)
//   'Q'  = hidden in QUICK only
//   ''   = visible in all modes
// Target: QUICK=24, STANDARD=40, DEEP=65

export async function seedV2Questionnaire(prisma: PrismaClient) {
  console.log('  📋 V2 Questionnaire...');

  const q = await prisma.questionnaire.upsert({
    where: { id: 2 },
    update: {},
    create: {
      version: 'v2',
      title: '君册财税·企业经营初诊（V2）',
      description: '请补充资料中无法体现的经营情况，系统将结合资料完整度和问卷答案生成四维经营初诊看板。',
      isActive: true,
    },
  });
  console.log(`  ✅ V2 Questionnaire: ${q.title}`);

  // Tag legend: ''=all modes visible, 'Q'=hideInModes:['QUICK'], 'QS'=hideInModes:['QUICK','STANDARD']
  const defs: { groupLabel: string; groupOrder: number; orderInGroup: number; questionText: string; questionType: 'SINGLE_CHOICE'|'MULTI_CHOICE'|'RANGE'|'YES_NO'; options: unknown; isRequired: boolean; riskDimension: string; tag: ''|'Q'|'QS' }[] = [
    // ============================================================
    // 1. REVENUE_MARGIN (7题): 核心3+Q1+QS3 → QUICK=4 STANDARD=4
    // ============================================================
    { groupLabel: '收入与毛利', groupOrder: 1, orderInGroup: 1, questionText: '近一年营业收入变化情况？', questionType: 'SINGLE_CHOICE', options: ['增长超过20%', '增长10%-20%', '基本持平', '下降10%-20%', '下降超过20%'], isRequired: true, riskDimension: 'REVENUE_MARGIN', tag: '' },
    { groupLabel: '收入与毛利', groupOrder: 1, orderInGroup: 2, questionText: '主要产品或服务毛利水平如何？', questionType: 'SINGLE_CHOICE', options: ['毛利30%以上', '毛利15%-30%', '毛利5%-15%', '毛利低于5%', '不清楚毛利情况'], isRequired: true, riskDimension: 'REVENUE_MARGIN', tag: '' },
    { groupLabel: '收入与毛利', groupOrder: 1, orderInGroup: 3, questionText: '是否存在低毛利或亏损产品？', questionType: 'YES_NO', options: ['是', '否', '不清楚'], isRequired: true, riskDimension: 'REVENUE_MARGIN', tag: '' },
    { groupLabel: '收入与毛利', groupOrder: 1, orderInGroup: 4, questionText: '是否能区分不同产品/项目毛利？', questionType: 'YES_NO', options: ['是，有明确核算', '部分可以', '无法区分'], isRequired: true, riskDimension: 'REVENUE_MARGIN', tag: 'Q' },
    { groupLabel: '收入与毛利', groupOrder: 1, orderInGroup: 5, questionText: '是否存在收入增长但利润没有增长？', questionType: 'YES_NO', options: ['是', '否', '收入未增长'], isRequired: true, riskDimension: 'REVENUE_MARGIN', tag: 'QS' },
    { groupLabel: '收入与毛利', groupOrder: 1, orderInGroup: 6, questionText: '是否有季节性收入波动？', questionType: 'SINGLE_CHOICE', options: ['有明显季节性', '波动较小', '比较稳定'], isRequired: false, riskDimension: 'REVENUE_MARGIN', tag: 'QS' },
    { groupLabel: '收入与毛利', groupOrder: 1, orderInGroup: 7, questionText: '近一年是否有关键客户流失或业务线收缩？', questionType: 'YES_NO', options: ['是', '否'], isRequired: false, riskDimension: 'REVENUE_MARGIN', tag: 'QS' },

    // ============================================================
    // 2. COST_EXPENSE (7题): 核心3+Q1+QS3 → QUICK=4 STANDARD=4
    // ============================================================
    { groupLabel: '成本费用', groupOrder: 2, orderInGroup: 1, questionText: '近一年成本是否明显上涨？', questionType: 'SINGLE_CHOICE', options: ['上涨超过30%', '上涨10%-30%', '基本持平', '下降'], isRequired: true, riskDimension: 'COST_EXPENSE', tag: '' },
    { groupLabel: '成本费用', groupOrder: 2, orderInGroup: 2, questionText: '人工成本是否明显增长？', questionType: 'SINGLE_CHOICE', options: ['大幅增长', '小幅增长', '基本持平', '下降'], isRequired: true, riskDimension: 'COST_EXPENSE', tag: '' },
    { groupLabel: '成本费用', groupOrder: 2, orderInGroup: 3, questionText: '房租、物流、平台费等固定费用是否有压力？', questionType: 'YES_NO', options: ['是，压力较大', '有一定压力', '无压力'], isRequired: true, riskDimension: 'COST_EXPENSE', tag: '' },
    { groupLabel: '成本费用', groupOrder: 2, orderInGroup: 4, questionText: '销售费用是否明显增长？', questionType: 'SINGLE_CHOICE', options: ['大幅增长', '小幅增长', '基本持平', '下降'], isRequired: true, riskDimension: 'COST_EXPENSE', tag: 'Q' },
    { groupLabel: '成本费用', groupOrder: 2, orderInGroup: 5, questionText: '是否定期核算费用投入产出比？', questionType: 'YES_NO', options: ['是，定期核算', '偶尔核算', '不清楚'], isRequired: false, riskDimension: 'COST_EXPENSE', tag: 'QS' },
    { groupLabel: '成本费用', groupOrder: 2, orderInGroup: 6, questionText: '是否存在老板个人支出与公司费用混用？', questionType: 'YES_NO', options: ['是', '否', '不确定'], isRequired: true, riskDimension: 'COST_EXPENSE', tag: '' },
    { groupLabel: '成本费用', groupOrder: 2, orderInGroup: 7, questionText: '近一年是否有大额非经常性支出？', questionType: 'YES_NO', options: ['是', '否'], isRequired: false, riskDimension: 'COST_EXPENSE', tag: 'QS' },

    // ============================================================
    // 3. CUSTOMER_PRODUCT (7题): 核心2+Q2+QS3 → QUICK=4 STANDARD=4
    // ============================================================
    { groupLabel: '客户产品贡献', groupOrder: 3, orderInGroup: 1, questionText: '收入是否依赖少数大客户？', questionType: 'SINGLE_CHOICE', options: ['前1-2个客户占50%以上', '前3-5个客户占50%以上', '客户较分散', '不清楚'], isRequired: true, riskDimension: 'CUSTOMER_PRODUCT', tag: '' },
    { groupLabel: '客户产品贡献', groupOrder: 3, orderInGroup: 2, questionText: '是否存在低毛利大客户？', questionType: 'YES_NO', options: ['是', '否', '不清楚'], isRequired: true, riskDimension: 'CUSTOMER_PRODUCT', tag: '' },
    { groupLabel: '客户产品贡献', groupOrder: 3, orderInGroup: 3, questionText: '是否有客户长期拖欠款项？', questionType: 'YES_NO', options: ['是，较严重', '有少量', '没有'], isRequired: true, riskDimension: 'CUSTOMER_PRODUCT', tag: 'Q' },
    { groupLabel: '客户产品贡献', groupOrder: 3, orderInGroup: 4, questionText: '是否知道前五大客户毛利贡献？', questionType: 'YES_NO', options: ['是，清楚核算', '大致了解', '不清楚'], isRequired: true, riskDimension: 'CUSTOMER_PRODUCT', tag: 'Q' },
    { groupLabel: '客户产品贡献', groupOrder: 3, orderInGroup: 5, questionText: '是否有产品/服务长期不赚钱但仍在做？', questionType: 'YES_NO', options: ['是', '否', '不确定'], isRequired: false, riskDimension: 'CUSTOMER_PRODUCT', tag: 'Q' },
    { groupLabel: '客户产品贡献', groupOrder: 3, orderInGroup: 6, questionText: '是否定期淘汰低效产品或客户？', questionType: 'YES_NO', options: ['是，定期评估', '偶尔', '从未'], isRequired: false, riskDimension: 'CUSTOMER_PRODUCT', tag: 'QS' },
    { groupLabel: '客户产品贡献', groupOrder: 3, orderInGroup: 7, questionText: '近一年是否开拓了新客户或新产品线？', questionType: 'YES_NO', options: ['是', '否'], isRequired: false, riskDimension: 'CUSTOMER_PRODUCT', tag: 'QS' },

    // ============================================================
    // 4. TAX_DECLARATION (8题): 核心5+Q1+QS2 → QUICK=6 STANDARD=6
    // ============================================================
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 1, questionText: '目前是否按期进行纳税申报？', questionType: 'YES_NO', options: ['是', '否'], isRequired: true, riskDimension: 'TAX_DECLARATION', tag: '' },
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 2, questionText: '是否长期零申报？', questionType: 'YES_NO', options: ['是', '否'], isRequired: true, riskDimension: 'TAX_DECLARATION', tag: '' },
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 3, questionText: '零申报期间是否仍有实际经营？', questionType: 'YES_NO', options: ['是', '否', '未零申报'], isRequired: false, riskDimension: 'TAX_DECLARATION', tag: '' },
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 4, questionText: '是否出现过税务提醒、异常或处罚？', questionType: 'YES_NO', options: ['是', '否', '不清楚'], isRequired: true, riskDimension: 'TAX_DECLARATION', tag: '' },
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 5, questionText: '纳税人身份是否清楚？', questionType: 'SINGLE_CHOICE', options: ['一般纳税人', '小规模纳税人', '不清楚'], isRequired: true, riskDimension: 'TAX_DECLARATION', tag: '' },
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 6, questionText: '是否存在申报数据与实际经营不一致的担忧？', questionType: 'YES_NO', options: ['是，有担忧', '否，基本一致', '不确定'], isRequired: true, riskDimension: 'TAX_DECLARATION', tag: 'Q' },
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 7, questionText: '是否有专业会计或代理记账？', questionType: 'YES_NO', options: ['有专职会计', '委托代理记账', '自己做账', '无专人负责'], isRequired: true, riskDimension: 'TAX_DECLARATION', tag: 'Q' },
    { groupLabel: '税务申报', groupOrder: 4, orderInGroup: 8, questionText: '是否了解最新税收优惠政策？', questionType: 'YES_NO', options: ['了解并已享受', '了解但未享受', '不了解'], isRequired: false, riskDimension: 'TAX_DECLARATION', tag: 'QS' },

    // ============================================================
    // 5. INVOICE_FUND (8题): 核心3+Q2+QS3 → QUICK=5 STANDARD=5
    // ============================================================
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 1, questionText: '发票与实际业务是否匹配？', questionType: 'YES_NO', options: ['是', '否', '部分不匹配'], isRequired: true, riskDimension: 'INVOICE_FUND', tag: '' },
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 2, questionText: '是否存在频繁公转私或大额无说明往来？', questionType: 'YES_NO', options: ['是', '否', '不清楚'], isRequired: true, riskDimension: 'INVOICE_FUND', tag: '' },
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 3, questionText: '是否存在私人账户收取公司款项的情况？', questionType: 'YES_NO', options: ['是', '否'], isRequired: true, riskDimension: 'INVOICE_FUND', tag: '' },
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 4, questionText: '是否已开设对公账户？', questionType: 'YES_NO', options: ['是', '否'], isRequired: true, riskDimension: 'INVOICE_FUND', tag: 'Q' },
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 5, questionText: '进项与销项结构是否合理？', questionType: 'SINGLE_CHOICE', options: ['基本合理', '进项偏少', '销项偏少', '不清楚'], isRequired: true, riskDimension: 'INVOICE_FUND', tag: 'Q' },
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 6, questionText: '银行流水是否能对应合同、发票和业务？', questionType: 'SINGLE_CHOICE', options: ['基本对应', '部分不对应', '差异较大', '未核对过'], isRequired: true, riskDimension: 'INVOICE_FUND', tag: 'QS' },
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 7, questionText: '是否存在大额现金收款？', questionType: 'YES_NO', options: ['是', '否'], isRequired: false, riskDimension: 'INVOICE_FUND', tag: 'QS' },
    { groupLabel: '发票资金', groupOrder: 5, orderInGroup: 8, questionText: '是否有未开票收入？', questionType: 'YES_NO', options: ['是，占比较大', '是，少量', '全部开票'], isRequired: false, riskDimension: 'INVOICE_FUND', tag: 'QS' },

    // ============================================================
    // 6. SOCIAL_BUSINESS (7题): 核心1+Q2+QS4 → QUICK=3 STANDARD=3
    // ============================================================
    { groupLabel: '社保工商', groupOrder: 6, orderInGroup: 1, questionText: '是否有员工？', questionType: 'SINGLE_CHOICE', options: ['0人（无员工）', '1-5人', '5-10人', '10-50人', '50人以上'], isRequired: true, riskDimension: 'SOCIAL_BUSINESS', tag: '' },
    { groupLabel: '社保工商', groupOrder: 6, orderInGroup: 2, questionText: '社保是否正常缴纳？', questionType: 'SINGLE_CHOICE', options: ['全员正常缴纳', '部分缴纳', '未缴纳', '无员工无需缴纳'], isRequired: true, riskDimension: 'SOCIAL_BUSINESS', tag: 'Q' },
    { groupLabel: '社保工商', groupOrder: 6, orderInGroup: 3, questionText: '工资、个税和社保人数是否一致？', questionType: 'YES_NO', options: ['基本一致', '存在差异', '不清楚'], isRequired: true, riskDimension: 'SOCIAL_BUSINESS', tag: 'Q' },
    { groupLabel: '社保工商', groupOrder: 6, orderInGroup: 4, questionText: '是否有较多兼职、劳务或外包人员？', questionType: 'YES_NO', options: ['是', '否'], isRequired: true, riskDimension: 'SOCIAL_BUSINESS', tag: 'Q' },
    { groupLabel: '社保工商', groupOrder: 6, orderInGroup: 5, questionText: '工商状态是否正常？', questionType: 'SINGLE_CHOICE', options: ['正常经营', '存在异常', '不清楚'], isRequired: true, riskDimension: 'SOCIAL_BUSINESS', tag: 'QS' },
    { groupLabel: '社保工商', groupOrder: 6, orderInGroup: 6, questionText: '是否频繁变更法人、股东或地址？', questionType: 'YES_NO', options: ['近一年有变更', '近3年有变更', '无变更'], isRequired: false, riskDimension: 'SOCIAL_BUSINESS', tag: 'QS' },
    { groupLabel: '社保工商', groupOrder: 6, orderInGroup: 7, questionText: '是否考虑注销或股权转让？', questionType: 'YES_NO', options: ['正在考虑', '有计划', '无计划'], isRequired: false, riskDimension: 'SOCIAL_BUSINESS', tag: 'QS' },

    // ============================================================
    // 7. RECEIVABLE_COLLECTION (7题): 核心1+Q2+QS4 → QUICK=3 STANDARD=3
    // ============================================================
    { groupLabel: '应收回款', groupOrder: 7, orderInGroup: 1, questionText: '客户回款是否及时？', questionType: 'SINGLE_CHOICE', options: ['及时', '偶尔逾期', '经常拖延', '严重逾期'], isRequired: true, riskDimension: 'RECEIVABLE_COLLECTION', tag: '' },
    { groupLabel: '应收回款', groupOrder: 7, orderInGroup: 2, questionText: '是否存在逾期90天以上的应收账款？', questionType: 'YES_NO', options: ['是', '否', '不清楚'], isRequired: true, riskDimension: 'RECEIVABLE_COLLECTION', tag: 'Q' },
    { groupLabel: '应收回款', groupOrder: 7, orderInGroup: 3, questionText: '是否有专人跟进应收款？', questionType: 'YES_NO', options: ['是', '否'], isRequired: false, riskDimension: 'RECEIVABLE_COLLECTION', tag: 'Q' },
    { groupLabel: '应收回款', groupOrder: 7, orderInGroup: 4, questionText: '是否对高风险客户停止发货或服务？', questionType: 'YES_NO', options: ['是', '否', '无高风险客户'], isRequired: false, riskDimension: 'RECEIVABLE_COLLECTION', tag: 'QS' },
    { groupLabel: '应收回款', groupOrder: 7, orderInGroup: 5, questionText: '是否知道平均回款周期？', questionType: 'SINGLE_CHOICE', options: ['30天以内', '30-60天', '60-90天', '90天以上', '不清楚'], isRequired: true, riskDimension: 'RECEIVABLE_COLLECTION', tag: 'QS' },
    { groupLabel: '应收回款', groupOrder: 7, orderInGroup: 6, questionText: '是否有坏账或长期挂账？', questionType: 'YES_NO', options: ['是', '否', '不清楚'], isRequired: true, riskDimension: 'RECEIVABLE_COLLECTION', tag: '' },
    { groupLabel: '应收回款', groupOrder: 7, orderInGroup: 7, questionText: '是否使用预收款或定金模式？', questionType: 'YES_NO', options: ['是', '否'], isRequired: false, riskDimension: 'RECEIVABLE_COLLECTION', tag: 'QS' },

    // ============================================================
    // 8. INVENTORY_PAYABLE (7题): 核心1+Q2+QS4 → QUICK=3 STANDARD=3
    // ============================================================
    { groupLabel: '存货付款', groupOrder: 8, orderInGroup: 1, questionText: '是否存在存货积压？', questionType: 'SINGLE_CHOICE', options: ['积压严重', '有一定积压', '基本正常', '无存货/服务业'], isRequired: true, riskDimension: 'INVENTORY_PAYABLE', tag: '' },
    { groupLabel: '存货付款', groupOrder: 8, orderInGroup: 2, questionText: '是否知道存货周转天数？', questionType: 'SINGLE_CHOICE', options: ['30天以内', '30-60天', '60-90天', '90天以上', '不清楚', '无存货/服务业'], isRequired: true, riskDimension: 'INVENTORY_PAYABLE', tag: 'Q' },
    { groupLabel: '存货付款', groupOrder: 8, orderInGroup: 3, questionText: '是否有呆滞库存？', questionType: 'YES_NO', options: ['是', '否', '无存货/服务业'], isRequired: false, riskDimension: 'INVENTORY_PAYABLE', tag: 'Q' },
    { groupLabel: '存货付款', groupOrder: 8, orderInGroup: 4, questionText: '供应商账期是否稳定？', questionType: 'SINGLE_CHOICE', options: ['稳定', '偶尔变动', '经常变动', '无供应商/服务业'], isRequired: true, riskDimension: 'INVENTORY_PAYABLE', tag: 'QS' },
    { groupLabel: '存货付款', groupOrder: 8, orderInGroup: 5, questionText: '是否经常先付款后回款？', questionType: 'YES_NO', options: ['是', '否'], isRequired: true, riskDimension: 'INVENTORY_PAYABLE', tag: 'QS' },
    { groupLabel: '存货付款', groupOrder: 8, orderInGroup: 6, questionText: '是否存在采购占用大量现金？', questionType: 'YES_NO', options: ['是', '否', '不确定'], isRequired: false, riskDimension: 'INVENTORY_PAYABLE', tag: 'QS' },
    { groupLabel: '存货付款', groupOrder: 8, orderInGroup: 7, questionText: '是否有紧急采购或断货风险？', questionType: 'YES_NO', options: ['是', '否'], isRequired: false, riskDimension: 'INVENTORY_PAYABLE', tag: 'QS' },

    // ============================================================
    // 9. HUMAN_ASSET_EFFICIENCY (7题): 核心1+Q2+QS4 → QUICK=3 STANDARD=3
    // ============================================================
    { groupLabel: '人效资产', groupOrder: 9, orderInGroup: 1, questionText: '人员配置是否与业务量匹配？', questionType: 'SINGLE_CHOICE', options: ['匹配', '人员偏多/业务不足', '人员不足/业务量大', '不确定'], isRequired: true, riskDimension: 'HUMAN_ASSET_EFFICIENCY', tag: '' },
    { groupLabel: '人效资产', groupOrder: 9, orderInGroup: 2, questionText: '是否知道人均产出？', questionType: 'SINGLE_CHOICE', options: ['有明确指标', '大致了解', '不清楚'], isRequired: true, riskDimension: 'HUMAN_ASSET_EFFICIENCY', tag: 'Q' },
    { groupLabel: '人效资产', groupOrder: 9, orderInGroup: 3, questionText: '是否有流程重复、人工录入、效率低的问题？', questionType: 'YES_NO', options: ['是，较严重', '有一些', '基本没有'], isRequired: true, riskDimension: 'HUMAN_ASSET_EFFICIENCY', tag: 'Q' },
    { groupLabel: '人效资产', groupOrder: 9, orderInGroup: 4, questionText: '是否存在明显人员冗余？', questionType: 'YES_NO', options: ['是', '否', '不确定'], isRequired: false, riskDimension: 'HUMAN_ASSET_EFFICIENCY', tag: 'QS' },
    { groupLabel: '人效资产', groupOrder: 9, orderInGroup: 5, questionText: '是否存在设备、仓库、车辆闲置？', questionType: 'YES_NO', options: ['是', '否', '无相关资产'], isRequired: false, riskDimension: 'HUMAN_ASSET_EFFICIENCY', tag: 'QS' },
    { groupLabel: '人效资产', groupOrder: 9, orderInGroup: 6, questionText: '是否定期复盘经营效率？', questionType: 'YES_NO', options: ['是，定期复盘', '偶尔', '从未'], isRequired: false, riskDimension: 'HUMAN_ASSET_EFFICIENCY', tag: 'QS' },
    { groupLabel: '人效资产', groupOrder: 9, orderInGroup: 7, questionText: '是否使用ERP或管理系统？', questionType: 'YES_NO', options: ['是，使用成熟系统', '使用简单工具', '基本手工'], isRequired: false, riskDimension: 'HUMAN_ASSET_EFFICIENCY', tag: 'QS' },
  ];

  // Tag count validation
  const taggedQS = defs.filter(d => d.tag === 'QS').length;
  const taggedQ = defs.filter(d => d.tag === 'Q').length;
  const taggedNone = defs.filter(d => d.tag === '').length;
  console.log(`  📊 Tag distribution: QS=${taggedQS}, Q=${taggedQ}, none=${taggedNone} → QUICK=${taggedNone}, STANDARD=${taggedNone + taggedQ}, DEEP=${defs.length}`);

  function toSkipLogic(tag: ''|'Q'|'QS'): any {
    if (tag === 'Q') return { hideInModes: ['QUICK'] };
    if (tag === 'QS') return { hideInModes: ['QUICK', 'STANDARD'] };
    return {};
  }

  const questions = [];
  for (const def of defs) {
    const { tag, ...qDef } = def;
    const created = await prisma.question.create({
      data: { questionnaireId: q.id, ...qDef, skipLogic: toSkipLogic(tag) },
    });
    questions.push(created);
  }
  console.log(`  ✅ V2 Questions: ${questions.length} created`);
  return { questionnaire: q, questions };
}

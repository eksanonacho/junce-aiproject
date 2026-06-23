import { PrismaClient } from '../../generated/prisma/client';

export async function seedV2DocumentRequirements(prisma: PrismaClient) {
  console.log('  📄 V2 Document Requirements...');

  const requirements = [
    { code: 'BUSINESS_LICENSE', name: '营业执照', category: '工商证照', requiredForQuick: true, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['RISK'], description: '用于确认企业主体信息、经营范围与存续状态', sortOrder: 1 },
    { code: 'INCOME_STATEMENT', name: '利润表', category: '财务报表', requiredForQuick: true, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['PROFIT'], description: '用于判断收入、毛利和费用变化情况（快速：近3-6月；标准/深度：近12月）', sortOrder: 2 },
    { code: 'BALANCE_SHEET', name: '资产负债表', category: '财务报表', requiredForQuick: true, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['CASH_FLOW', 'EFFICIENCY'], description: '用于判断资产结构、负债水平和运营效率（快速：近3-6月；标准/深度：近12月）', sortOrder: 3 },
    { code: 'CASH_FLOW_STATEMENT', name: '现金流量表', category: '财务报表', requiredForQuick: false, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['CASH_FLOW'], description: '用于判断经营/投资/筹资现金流是否健康（近12月）', sortOrder: 4 },
    { code: 'ACCOUNT_BALANCE', name: '科目余额表', category: '财务报表', requiredForQuick: false, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['PROFIT', 'RISK'], description: '用于核对各科目余额，发现账务异常', sortOrder: 5 },
    { code: 'VAT_DECLARATION', name: '增值税申报表', category: '税务资料', requiredForQuick: true, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['RISK'], description: '用于判断增值税申报合规性和税负水平', sortOrder: 6 },
    { code: 'CIT_DECLARATION', name: '企业所得税申报表', category: '税务资料', requiredForQuick: false, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['RISK', 'PROFIT'], description: '用于判断企业所得税申报合规性和利润真实性', sortOrder: 7 },
    { code: 'INVOICE_SUMMARY', name: '开票/收票汇总', category: '税务资料', requiredForQuick: false, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['RISK'], description: '用于判断进销项匹配度和发票合规性', sortOrder: 8 },
    { code: 'BANK_STATEMENT', name: '银行流水', category: '资金资料', requiredForQuick: false, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['CASH_FLOW', 'RISK'], description: '用于核对收入、支出与合同/发票匹配度', sortOrder: 9 },
    { code: 'PAYROLL_SOCIAL_SECURITY', name: '工资/社保/个税资料', category: '人力资料', requiredForQuick: false, requiredForStandard: true, requiredForDeep: true, affectsDimensions: ['RISK', 'EFFICIENCY'], description: '用于判断用工合规性和人效水平', sortOrder: 10 },
    { code: 'CUSTOMER_REVENUE', name: '客户收入贡献表', category: '经营分析', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['PROFIT', 'EFFICIENCY'], description: '用于分析客户集中度和客户毛利贡献', sortOrder: 11 },
    { code: 'PRODUCT_MARGIN', name: '产品/项目毛利表', category: '经营分析', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['PROFIT'], description: '用于分析各产品/项目盈利能力', sortOrder: 12 },
    { code: 'AR_AGING', name: '应收账款账龄表', category: '资金资料', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['CASH_FLOW'], description: '用于判断回款能力和坏账风险', sortOrder: 13 },
    { code: 'AP_AGING', name: '应付账款明细', category: '资金资料', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['CASH_FLOW'], description: '用于判断付款压力和供应商账期', sortOrder: 14 },
    { code: 'INVENTORY_DETAIL', name: '存货明细及库龄', category: '经营分析', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['CASH_FLOW', 'EFFICIENCY'], description: '用于判断存货积压和周转效率', sortOrder: 15 },
    { code: 'FIXED_ASSET', name: '固定资产/设备清单', category: '经营分析', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['EFFICIENCY'], description: '用于判断资产利用率和闲置情况', sortOrder: 16 },
    { code: 'EXPENSE_DETAIL', name: '费用明细', category: '经营分析', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['PROFIT', 'EFFICIENCY'], description: '用于分析费用结构和投入产出比', sortOrder: 17 },
    { code: 'CONTRACT_SAMPLE', name: '合同样本', category: '法务资料', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['RISK'], description: '用于判断合同条款合规性和经营风险', sortOrder: 18 },
    { code: 'TAX_ABNORMAL_RECORD', name: '税务异常/处罚/提醒记录', category: '税务资料', requiredForQuick: false, requiredForStandard: false, requiredForDeep: true, affectsDimensions: ['RISK'], description: '用于判断历史税务合规问题和风险程度', sortOrder: 19 },
  ];

  for (const req of requirements) {
    await prisma.documentRequirement.upsert({
      where: { code: req.code },
      update: req,
      create: req,
    });
  }

  console.log(`  ✅ Document Requirements: ${requirements.length} seeded`);
}

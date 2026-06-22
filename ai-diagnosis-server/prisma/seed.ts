import 'dotenv/config';
import { PrismaClient } from '../generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env['DATABASE_URL'] }),
});

async function main() {
  console.log('🌱 Seeding AI Diagnosis database...');

  // --- 1. AdminUser ---
  const passwordHash = await bcrypt.hash('Admin@123456', 10);
  const admin = await prisma.adminUser.upsert({
    where: { username: 'admin' },
    update: {},
    create: {
      username: 'admin',
      passwordHash,
      realName: '管理员',
      role: 'ADMIN',
    },
  });
  console.log(`  ✅ AdminUser: ${admin.username}`);

  // --- 2. Questionnaire ---
  const q = await prisma.questionnaire.create({
    data: {
      version: 'v1',
      title: '君册财税·企业初诊问卷',
      description: '请如实填写以下信息，我们将为您生成企业财税健康初诊报告。',
      isActive: true,
    },
  });
  console.log(`  ✅ Questionnaire: ${q.title}`);

  // --- 3. Questions (10 个示例，顺序创建保证 ID 可预测) ---
  const questionDefs = [
    { groupLabel: '企业基础信息', groupOrder: 1, orderInGroup: 1, questionText: '贵公司所属行业？', questionType: 'SINGLE_CHOICE' as const, options: ['互联网', '贸易', '餐饮', '建筑', '运输', '制造', '其他'], isRequired: true, riskDimension: '工商维度' },
    { groupLabel: '企业基础信息', groupOrder: 1, orderInGroup: 2, questionText: '公司注册时间？', questionType: 'SINGLE_CHOICE' as const, options: ['不到1年', '1-3年', '3-5年', '5年以上'], isRequired: true, riskDimension: '工商维度' },
    { groupLabel: '企业基础信息', groupOrder: 1, orderInGroup: 3, questionText: '公司类型？', questionType: 'SINGLE_CHOICE' as const, options: ['一人公司', '多股东', '个体户'], isRequired: true, riskDimension: '工商维度' },
    { groupLabel: '经营规模', groupOrder: 2, orderInGroup: 1, questionText: '年流水大约多少？', questionType: 'RANGE' as const, options: { options: ['10万以下', '10-50万', '50-100万', '100-500万', '500万以上'] }, isRequired: true, riskDimension: '税务维度' },
    { groupLabel: '经营规模', groupOrder: 2, orderInGroup: 2, questionText: '公司员工人数？', questionType: 'SINGLE_CHOICE' as const, options: ['0人（无员工）', '1-5人', '5-10人', '10-50人', '50人以上'], isRequired: true, riskDimension: '社保维度' },
    { groupLabel: '税务申报', groupOrder: 3, orderInGroup: 1, questionText: '目前是否正常报税？', questionType: 'YES_NO' as const, options: ['是', '否'], isRequired: true, riskDimension: '税务维度' },
    { groupLabel: '税务申报', groupOrder: 3, orderInGroup: 2, questionText: '是否长期零申报？', questionType: 'YES_NO' as const, options: ['是', '否'], isRequired: false, riskDimension: '税务维度' },
    { groupLabel: '社保/员工', groupOrder: 4, orderInGroup: 1, questionText: '是否给员工缴纳社保？', questionType: 'YES_NO' as const, options: ['是', '否', '无员工'], isRequired: true, riskDimension: '社保维度' },
    { groupLabel: '资金/账户', groupOrder: 5, orderInGroup: 1, questionText: '是否已开设对公账户？', questionType: 'YES_NO' as const, options: ['是', '否'], isRequired: true, riskDimension: '资金维度' },
    { groupLabel: '资金/账户', groupOrder: 5, orderInGroup: 2, questionText: '是否存在老板个人账户收公司款项的情况？', questionType: 'YES_NO' as const, options: ['是', '否', '不清楚'], isRequired: false, riskDimension: '资金维度' },
  ];
  const questions = [];
  for (const def of questionDefs) {
    const created = await prisma.question.create({ data: { questionnaireId: q.id, ...def } });
    questions.push(created);
  }
  console.log(`  ✅ Questions: ${questions.length} created`);

  // --- 4. DiagnosisRules (3 条示例) ---
  await prisma.diagnosisRule.createMany({
    data: [
      {
        ruleCode: 'TAX_001',
        dimension: '税务维度',
        questionId: questions[6].id, // "是否长期零申报？"
        triggerCondition: { operator: 'equals', value: '是' },
        riskLevel: 'MEDIUM',
        riskTitle: '长期零申报',
        riskDescription: '长期零申报可能引起税务关注，尤其是存在实际经营的情况下。',
        suggestion: '建议规范账务处理，确保每期申报真实准确反映经营状况。',
        needReview: false,
        recommendServices: ['代理记账', '合规项目'],
      },
      {
        ruleCode: 'TAX_002',
        dimension: '税务维度',
        questionId: questions[5].id, // "目前是否正常报税？"
        triggerCondition: { operator: 'equals', value: '否' },
        riskLevel: 'HIGH',
        riskTitle: '未正常报税',
        riskDescription: '未正常报税属于严重税务合规问题，可能面临罚款和滞纳金。',
        suggestion: '建议立即联系专业人员，核查申报状态并补报。',
        needReview: true,
        recommendServices: ['代理记账', '合规项目'],
      },
      {
        ruleCode: 'FUND_001',
        dimension: '资金维度',
        questionId: questions[9].id, // "个人账户收公司款项"
        triggerCondition: { operator: 'equals', value: '是' },
        riskLevel: 'HIGH',
        riskTitle: '公私账户混用',
        riskDescription: '公司款项通过个人账户收取可能导致税务风险和管理混乱。',
        suggestion: '建议尽快开立对公账户，所有经营收入通过公司账户管理。',
        needReview: true,
        recommendServices: ['开户', '财务外包', '合规项目'],
      },
      // TODO: 测试占位规则，用于验证 "3 MEDIUM → HIGH" 叠加升级场景，待纪姐确认后替换
      {
        ruleCode: 'TEST_M001',
        dimension: '工商维度',
        questionId: questions[1].id, // "公司注册时间？"
        triggerCondition: { operator: 'equals', value: '不到1年' },
        riskLevel: 'MEDIUM',
        riskTitle: '[测试]新注册公司',
        riskDescription: '新注册公司需要关注初期合规建设。',
        suggestion: '建议尽快开立对公账户并建立账务体系。',
        needReview: false,
        recommendServices: ['开户', '代理记账'],
      },
      {
        ruleCode: 'TEST_M002',
        dimension: '社保维度',
        questionId: questions[8].id, // "是否给员工缴纳社保？"
        triggerCondition: { operator: 'equals', value: '否' },
        riskLevel: 'MEDIUM',
        riskTitle: '[测试]未缴纳社保',
        riskDescription: '有员工但未依法缴纳社保可能存在用工合规风险。',
        suggestion: '建议依法为员工缴纳社保，规范用工管理。',
        needReview: false,
        recommendServices: ['社保', '合规项目'],
      },
    ],
  });
  console.log('  ✅ DiagnosisRules: 5 created (3 business + 2 test placeholders)');

  // --- 5. RiskScenarios (3 条示例) ---
  await prisma.riskScenario.createMany({
    data: [
      {
        scenarioName: '长期零申报',
        scenarioCode: 'LONG_ZERO_DECLARATION',
        description: '连续多个月零申报，但客户可能仍有实际经营',
        riskLevel: 'MEDIUM',
        triggerRules: { answerField: '长期零申报', value: '是' },
        safeExplanation: '长期零申报可能引起税务关注，建议核查申报情况',
        forbiddenPhrases: ['违法了', '必须补税', '一定会被罚款'],
        suggestion: '建议规范账务处理，确保申报真实准确',
        recommendServices: ['代理记账', '合规项目'],
        needManualReview: false,
      },
      {
        scenarioName: '公私账户混用',
        scenarioCode: 'MIXED_ACCOUNTS',
        description: '公司经营款项通过老板个人账户收取',
        riskLevel: 'HIGH',
        triggerRules: { answerField: '个人账户收款', value: '是' },
        safeExplanation: '通过个人账户收取公司款项可能存在合规风险，建议规范资金管理',
        forbiddenPhrases: ['违法了', '走私人账户没问题', '可以避税'],
        suggestion: '建议开立对公账户并通过公司账户管理经营收入',
        recommendServices: ['开户', '财务外包', '合规项目'],
        needManualReview: true,
      },
      {
        scenarioName: '未缴纳社保',
        scenarioCode: 'NO_SOCIAL_INSURANCE',
        description: '有员工但未依法缴纳社保',
        riskLevel: 'HIGH',
        triggerRules: { answerField: '缴纳社保', value: '否' },
        safeExplanation: '有员工但未缴纳社保可能存在用工合规风险，建议尽快规范',
        forbiddenPhrases: ['违法了', '不用交', '不交没关系'],
        suggestion: '建议依法为员工缴纳社保，规范用工管理',
        recommendServices: ['社保', '合规项目'],
        needManualReview: true,
      },
    ],
  });
  console.log('  ✅ RiskScenarios: 3 created');

  // --- 6. ForbiddenPhrases (15 条) ---
  await prisma.forbiddenPhrase.createMany({
    data: [
      { phrase: '违法了', safeAlternative: '可能存在合规风险', category: '法律定性' },
      { phrase: '必须补税', safeAlternative: '建议核查申报情况并及时处理', category: '税务指令' },
      { phrase: '一定会被罚款', safeAlternative: '可能面临税务处理', category: '承诺结果' },
      { phrase: '保证帮您解决', safeAlternative: '君册可以为您提供专业解决方案', category: '承诺结果' },
      { phrase: '保证通过税务检查', safeAlternative: '君册可以帮助您做好合规准备', category: '承诺结果' },
      { phrase: '一定没有风险', safeAlternative: '根据目前信息，暂未发现明显高风险项', category: '承诺结果' },
      { phrase: '这个不用管', safeAlternative: '该项暂不构成紧迫风险，但建议持续关注', category: '忽视问题' },
      { phrase: '可以避税', safeAlternative: '可以通过合法合规的税务筹划优化税负', category: '避税教唆' },
      { phrase: '不用开发票', safeAlternative: '开票是企业法定义务，君册可帮助规范开票流程', category: '避税教唆' },
      { phrase: '可以走私人账户', safeAlternative: '建议将经营收入通过公司账户管理', category: '公私混用' },
      { phrase: '保证多久办完', safeAlternative: '根据以往经验，办理周期大约需要一定时间', category: '承诺结果' },
      { phrase: '税局不会查', safeAlternative: '经营合规、申报规范可以降低被稽查可能性', category: '承诺结果' },
      { phrase: '这个操作没问题', safeAlternative: '该操作需由专业人员结合完整资料确认', category: '打包票' },
      { phrase: '肯定能注销成功', safeAlternative: '君册可以协助准备完整注销材料推进流程', category: '承诺结果' },
      { phrase: '一定能省钱', safeAlternative: '合规的税务筹划通常可以合理优化税负', category: '承诺结果' },
    ],
  });
  console.log('  ✅ ForbiddenPhrases: 15 created');

  // --- 7. Disclaimer (1 条) ---
  await prisma.disclaimer.create({
    data: {
      version: 'v1',
      content: '本报告基于您提供的有限信息自动生成，仅作为初步风险筛查参考，不构成任何税务、法律或财务处理意见。企业的具体风险状况需由君册专业人员结合完整资料进行复核和确认。君册不对因依赖本报告而采取的任何行动承担责任。如需专业建议，请联系君册财税顾问。',
      isActive: true,
    },
  });
  console.log('  ✅ Disclaimer: 1 created');

  console.log('\n🎉 Seed complete!');
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });

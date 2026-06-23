import { PrismaClient } from '../../generated/prisma/client';

export async function seedV2Disclaimers(prisma: PrismaClient) {
  console.log('  📜 V2 Disclaimers...');

  const disclaimer = await prisma.disclaimer.upsert({
    where: { id: 2 },
    update: {},
    create: {
      version: 'v2',
      content: `本系统生成内容仅作为企业经营与财税风险初步筛查参考，基于当前填写和上传资料计算，不构成最终税务、法律、审计或行政结论。

报告中的四维经营评分和风险分析系根据您提供的信息由系统自动生成，具体事项建议结合完整资料由君册专业人员进一步复核。

本报告不替代专业会计师、税务师或律师的正式意见。如涉及重大经营决策，请咨询君册专业顾问。

君册财税保留对报告内容的最终解释权。`,
      isActive: true,
    },
  });

  console.log(`  ✅ V2 Disclaimer: v${disclaimer.version}`);
}

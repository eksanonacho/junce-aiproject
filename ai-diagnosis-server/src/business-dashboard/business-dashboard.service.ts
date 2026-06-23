import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { BusinessDashboardResult, DimensionDetail, TopAction } from './interfaces/dashboard.interface';

/** Nine-dimension → Four-dimension mapping */
const DIMENSION_MAP: Record<string, string[]> = {
  REVENUE_MARGIN: ['PROFIT'],
  COST_EXPENSE: ['PROFIT'],
  CUSTOMER_PRODUCT: ['PROFIT', 'EFFICIENCY'],
  TAX_DECLARATION: ['RISK'],
  INVOICE_FUND: ['RISK'],
  SOCIAL_BUSINESS: ['RISK'],
  RECEIVABLE_COLLECTION: ['CASH_FLOW'],
  INVENTORY_PAYABLE: ['CASH_FLOW'],
  HUMAN_ASSET_EFFICIENCY: ['EFFICIENCY'],
};

const FOUR_DIMENSIONS = ['PROFIT', 'RISK', 'CASH_FLOW', 'EFFICIENCY'] as const;

const DIMENSION_LABELS: Record<string, string> = {
  PROFIT: '利润',
  RISK: '风险',
  CASH_FLOW: '现金流',
  EFFICIENCY: '效率',
};

const SCORE_LABELS: { min: number; max: number; label: string }[] = [
  { min: 4.0, max: 5.0, label: '经营状态较好' },
  { min: 3.0, max: 3.9, label: '经营总体一般' },
  { min: 2.0, max: 2.9, label: '需重点关注' },
  { min: 1.0, max: 1.9, label: '经营压力较大' },
];

@Injectable()
export class BusinessDashboardService {
  private readonly logger = new Logger(BusinessDashboardService.name);

  constructor(private readonly prisma: PrismaService) {}

  async compute(submissionPublicId: string): Promise<BusinessDashboardResult> {
    // 1. Load submission + diagnosis result + findings + document completeness
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
      include: {
        diagnosisResult: {
          include: {
            findings: { include: { rule: true } },
          },
        },
      },
    });

    if (!submission?.diagnosisResult) {
      throw new Error('Diagnosis result not found');
    }

    const dr = submission.diagnosisResult;
    const findings = dr.findings;
    const docScore = submission.documentCompletenessScore ?? 0;
    const docDetail = (submission.documentCompletenessDetail as any) || {};
    const dimConfidence = (docDetail.dimensionConfidence as Record<string, number>) || {};

    // 2. Count HIGH/MEDIUM findings per 4-dimension
    const dimCounts: Record<string, { high: number; medium: number; low: number; issues: string[]; suggestions: string[] }> = {};
    for (const dim of FOUR_DIMENSIONS) {
      dimCounts[dim] = { high: 0, medium: 0, low: 0, issues: [], suggestions: [] };
    }

    for (const f of findings) {
      const nineDim = f.rule?.dimension || '';
      const targetDims = DIMENSION_MAP[nineDim] || [];
      for (const target of targetDims) {
        if (dimCounts[target]) {
          if (f.riskLevel === 'HIGH') dimCounts[target].high++;
          else if (f.riskLevel === 'MEDIUM') dimCounts[target].medium++;
          else dimCounts[target].low++;
          dimCounts[target].issues.push(f.title);
          if (f.suggestion) dimCounts[target].suggestions.push(f.suggestion);
        }
      }
    }

    // 3. Compute 4-dimension scores
    const scores: Record<string, number> = {};
    const details: DimensionDetail[] = [];

    for (const dim of FOUR_DIMENSIONS) {
      const counts = dimCounts[dim];
      const penalty = counts.high * 1.5 + counts.medium * 0.8;
      const docPenalty = Math.max(0, (100 - (dimConfidence[dim] ?? 100)) / 100 * 0.8);
      let score = Math.max(1.0, Math.min(5.0, 4.0 - penalty - docPenalty));
      score = Math.round(score * 10) / 10;

      scores[dim] = score;
      details.push({
        dimension: dim,
        score,
        label: this.getLabel(score),
        issues: counts.issues.length > 0 ? counts.issues.slice(0, 3) : ['未发现明显问题'],
        suggestions: counts.suggestions.length > 0 ? counts.suggestions.slice(0, 2) : ['建议保持当前经营状态，定期关注财税合规'],
        evidence: dimConfidence[dim] ? `该维度资料可信度 ${dimConfidence[dim]}%` : '暂无上传资料',
        confidence: dimConfidence[dim] ?? 0,
      });
    }

    // 4. Overall score
    const overallScore = Math.round(
      (scores.PROFIT * 0.25 + scores.RISK * 0.35 + scores.CASH_FLOW * 0.25 + scores.EFFICIENCY * 0.15) * 10,
    ) / 10;

    const overallLabel = this.getLabel(overallScore);

    // 5. Confidence level
    let confidenceLevel: 'HIGH' | 'MEDIUM' | 'LOW' = 'MEDIUM';
    if (docScore >= 70) confidenceLevel = 'HIGH';
    else if (docScore < 40) confidenceLevel = 'LOW';

    // 6. Conclusion
    const sortedByScore = [...details].sort((a, b) => b.score - a.score);
    const best = sortedByScore[0];
    const worst = sortedByScore[sortedByScore.length - 1];
    const conclusion = `根据当前填写和上传资料，企业${DIMENSION_LABELS[best.dimension]}方面${best.label}，但${DIMENSION_LABELS[worst.dimension]}方面${worst.label}。建议优先处理${DIMENSION_LABELS[worst.dimension]}相关问题，并由君册人员进一步复核。`;

    // 7. TOP3 actions
    const topActions: TopAction[] = sortedByScore
      .filter((d) => d.score < 4.0)
      .slice(0, 3)
      .map((d, i) => ({
        priority: i + 1,
        title: `优先核查${DIMENSION_LABELS[d.dimension]}相关事项`,
        timeline: i === 0 ? '1个月内' : i === 1 ? '3个月内' : '6个月内',
        reason: d.issues.join('；'),
        serviceType: this.mapServiceType(d.dimension),
      }));

    // If fewer than 3 actions, add generic ones
    while (topActions.length < 3) {
      const i = topActions.length;
      topActions.push({
        priority: i + 1,
        title: '定期关注企业经营健康状况',
        timeline: '持续',
        reason: '保持财税合规，定期自查经营指标',
        serviceType: '经营分析',
      });
    }

    return {
      overallScore,
      overallLabel,
      profitScore: scores.PROFIT,
      riskScore: scores.RISK,
      cashFlowScore: scores.CASH_FLOW,
      efficiencyScore: scores.EFFICIENCY,
      documentCompletenessScore: docScore,
      confidenceLevel,
      conclusion,
      topActions,
      dimensionDetails: details,
    };
  }

  private getLabel(score: number): string {
    const found = SCORE_LABELS.find((s) => score >= s.min && score <= s.max);
    return found?.label || '未知';
  }

  private mapServiceType(dimension: string): string {
    const map: Record<string, string> = {
      PROFIT: '经营分析',
      RISK: '税务合规检查',
      CASH_FLOW: '经营分析',
      EFFICIENCY: '经营分析',
    };
    return map[dimension] || '经营分析';
  }
}

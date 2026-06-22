import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { RuleEngineService } from './rule-engine.service';
import { RiskLevelService } from './risk-level.service';
import { ServiceRecommendationService } from './service-recommendation.service';

@Injectable()
export class DiagnosisService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ruleEngine: RuleEngineService,
    private readonly riskLevel: RiskLevelService,
    private readonly serviceRec: ServiceRecommendationService,
  ) {}

  /**
   * Run diagnosis for a submission by its publicId.
   * If a DiagnosisResult already exists, clean it and regenerate.
   */
  async runDiagnosis(submissionPublicId: string) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
      include: { answers: true },
    });

    if (!submission) {
      throw new NotFoundException({
        code: 'SUBMISSION_NOT_FOUND',
        message: '提交记录不存在',
      });
    }

    // Set status to DIAGNOSING
    await this.prisma.submission.update({
      where: { id: submission.id },
      data: { status: 'DIAGNOSING' },
    });

    try {
      // Delete existing result if present
      await this.cleanExistingResult(submission.id);

      // 1. Match rules
      const answerInput = submission.answers.map((a) => ({
        questionId: a.questionId,
        answerValue: a.answerValue,
      }));
      const { matchedRules, hasActiveRules } = await this.ruleEngine.evaluate(answerInput);

      // 2. Calculate risk level（传入 hasActiveRules 用于区分 LOW / UNKNOWN）
      const findingsInput = matchedRules.map((r) => ({
        riskLevel: r.riskLevel,
        needReview: r.needReview,
      }));
      const riskResult = this.riskLevel.calculate(findingsInput, { hasActiveRules });

      // 3. Build recommendations
      const recs = this.serviceRec.build(matchedRules);

      // 4. Build dimension results
      const dimensionMap = new Map<string, { riskLevel: string; findings: unknown[] }>();
      for (const rule of matchedRules) {
        const dim = rule.dimension || '其他';
        if (!dimensionMap.has(dim)) {
          dimensionMap.set(dim, { riskLevel: 'LOW', findings: [] });
        }
        const entry = dimensionMap.get(dim)!;
        // Upgrade dimension risk
        if (rule.riskLevel === 'HIGH') entry.riskLevel = 'HIGH';
        else if (rule.riskLevel === 'MEDIUM' && entry.riskLevel !== 'HIGH') entry.riskLevel = 'MEDIUM';
        entry.findings.push({
          title: rule.riskTitle,
          riskLevel: rule.riskLevel,
          description: rule.riskDescription,
          suggestion: rule.suggestion,
          recommendServices: rule.recommendServices,
        });
      }

      // 5. Save DiagnosisResult + RiskFindings + ServiceRecommendations in transaction
      let findingCount = 0;
      let recommendationCount = 0;
      let diagnosisResultId = 0;

      await this.prisma.$transaction(async (tx) => {
        const dr = await tx.diagnosisResult.create({
          data: {
            submissionId: submission.id,
            overallRiskLevel: riskResult.overallRiskLevel as any,
            needReview: riskResult.needReview,
            dimensionResults: Array.from(dimensionMap.entries()).map(([dim, val]) => ({
              dimension: dim,
              riskLevel: val.riskLevel,
              findings: val.findings,
            })) as any,
            summary: null,
            findings: {
              create: matchedRules.map((rule) => ({
                ruleId: rule.id,
                riskLevel: rule.riskLevel as any,
                title: rule.riskTitle,
                description: rule.riskDescription,
                suggestion: rule.suggestion,
                recommendServices: rule.recommendServices as any,
              })),
            },
            recommendations: {
              create: recs.map((r) => ({
                serviceType: r.serviceType,
                reason: r.reason,
                priority: r.priority as any,
              })),
            },
          },
        });
        diagnosisResultId = dr.id;
        // Count findings and recommendations
        const findings = await tx.riskFinding.findMany({ where: { diagnosisResultId: dr.id } });
        const recommendations = await tx.serviceRecommendation.findMany({ where: { diagnosisResultId: dr.id } });
        findingCount = findings.length;
        recommendationCount = recommendations.length;
      });

      // Set status to COMPLETED
      await this.prisma.submission.update({
        where: { id: submission.id },
        data: { status: 'COMPLETED' },
      });

      return {
        submissionPublicId: submission.publicId,
        diagnosisResultId,
        overallRiskLevel: riskResult.overallRiskLevel,
        findingCount,
        recommendationCount,
        needReview: riskResult.needReview,
      };
    } catch (error) {
      // Set status to FAILED
      await this.prisma.submission.update({
        where: { id: submission.id },
        data: { status: 'FAILED' },
      });
      throw error;
    }
  }

  /**
   * Get diagnosis result for a submission by publicId.
   */
  async getResult(submissionPublicId: string) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
    });

    if (!submission) {
      throw new NotFoundException({
        code: 'SUBMISSION_NOT_FOUND',
        message: '提交记录不存在',
      });
    }

    const result = await this.prisma.diagnosisResult.findUnique({
      where: { submissionId: submission.id },
      include: {
        findings: true,
        recommendations: true,
      },
    });

    if (!result) {
      throw new NotFoundException({
        code: 'DIAGNOSIS_RESULT_NOT_FOUND',
        message: '该提交尚未生成诊断结果',
      });
    }

    // Build dimension results from findings
    const dimensionMap = new Map<string, { riskLevel: string; findings: unknown[] }>();
    for (const f of result.findings) {
      const rule = f.ruleId
        ? await this.prisma.diagnosisRule.findUnique({ where: { id: f.ruleId } })
        : null;
      const dim = rule?.dimension || '其他';
      if (!dimensionMap.has(dim)) {
        dimensionMap.set(dim, { riskLevel: 'LOW', findings: [] });
      }
      const entry = dimensionMap.get(dim)!;
      if (f.riskLevel === 'HIGH') entry.riskLevel = 'HIGH';
      else if (f.riskLevel === 'MEDIUM' && entry.riskLevel !== 'HIGH') entry.riskLevel = 'MEDIUM';
      entry.findings.push({
        title: f.title,
        riskLevel: f.riskLevel,
        description: f.description,
        suggestion: f.suggestion,
        recommendServices: f.recommendServices,
      });
    }

    return {
      submissionPublicId: submission.publicId,
      overallRiskLevel: result.overallRiskLevel,
      needReview: result.needReview,
      dimensionResults: Array.from(dimensionMap.entries()).map(([dim, val]) => ({
        dimension: dim,
        riskLevel: val.riskLevel,
        findings: val.findings,
      })),
      findings: result.findings.map((f) => ({
        title: f.title,
        riskLevel: f.riskLevel,
        description: f.description,
        suggestion: f.suggestion,
        recommendServices: f.recommendServices,
      })),
      recommendations: result.recommendations.map((r) => ({
        serviceType: r.serviceType,
        reason: r.reason,
        priority: r.priority,
      })),
    };
  }

  /**
   * Clean up existing diagnosis result for a submission.
   */
  private async cleanExistingResult(submissionId: number) {
    const existing = await this.prisma.diagnosisResult.findUnique({
      where: { submissionId },
    });
    if (existing) {
      // Delete children first, then parent
      await this.prisma.riskFinding.deleteMany({ where: { diagnosisResultId: existing.id } });
      await this.prisma.serviceRecommendation.deleteMany({ where: { diagnosisResultId: existing.id } });
      await this.prisma.diagnosisResult.delete({ where: { id: existing.id } });
    }
  }
}

import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ForbiddenPhraseCheckerService } from '../report/forbidden-phrase-checker.service';

@Injectable()
export class AdminService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly phraseChecker: ForbiddenPhraseCheckerService,
  ) {}

  async listSubmissions(query: {
    page?: number; pageSize?: number; riskLevel?: string;
    reviewStatus?: string; keyword?: string;
  }) {
    const page = query.page || 1;
    const pageSize = query.pageSize || 20;
    const where: any = {};

    const reports = await this.prisma.report.findMany({
      where: {
        ...(query.riskLevel ? { riskLevel: query.riskLevel as any } : {}),
        ...(query.reviewStatus ? { reviewStatus: query.reviewStatus as any } : {}),
      },
      include: {
        diagnosisResult: {
          include: {
            submission: { select: { publicId: true, phone: true, submittedAt: true } },
            findings: { select: { id: true } },
            recommendations: { select: { id: true } },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    });

    const total = await this.prisma.report.count({ where });

    const items = reports.map((r) => {
      const phone = r.diagnosisResult?.submission?.phone || '';
      const masked = phone.length === 11
        ? `${phone.slice(0, 3)}****${phone.slice(7)}`
        : phone;
      return {
        submissionPublicId: r.diagnosisResult?.submission?.publicId || '',
        reportPublicId: r.publicId,
        submittedAt: r.diagnosisResult?.submission?.submittedAt?.toISOString() || null,
        phoneMasked: masked,
        overallRiskLevel: r.riskLevel,
        reviewStatus: r.reviewStatus,
        customerVisible: r.customerVisible,
        findingCount: r.diagnosisResult?.findings?.length || 0,
        recommendationCount: r.diagnosisResult?.recommendations?.length || 0,
      };
    });

    return { items, page, pageSize, total };
  }

  async getReportDetail(publicId: string) {
    const report = await this.prisma.report.findUnique({
      where: { publicId },
      include: {
        diagnosisResult: {
          include: {
            submission: {
              select: {
                publicId: true, phone: true, submittedAt: true,
                mode: true, documentCompletenessScore: true, documentCompletenessDetail: true,
                uploadedDocuments: true,
              },
            },
            findings: { include: { rule: { select: { dimension: true, ruleCode: true } } } },
            recommendations: true,
          },
        },
        reviewRecords: {
          include: { reviewer: { select: { realName: true } } },
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!report) throw new NotFoundException({ code: 'REPORT_NOT_FOUND', message: '报告不存在' });

    const submission = report.diagnosisResult?.submission;

    // Build uploaded documents list (without storagePath)
    const uploadedDocuments = (submission?.uploadedDocuments || []).map((d) => ({
      publicId: d.publicId,
      docType: d.docType,
      originalName: d.originalName,
      mimeType: d.mimeType,
      sizeBytes: d.sizeBytes,
      createdAt: d.createdAt,
    }));

    // Build dimensionRuleHits from findings
    const findings = report.diagnosisResult?.findings || [];
    const dimensionRuleHits: Record<string, { totalRules: number; hitRules: number; findings: unknown[] }> = {};
    const dimensionSet = new Set<string>();
    for (const f of findings) {
      const dim = f.rule?.dimension || '其他';
      dimensionSet.add(dim);
      if (!dimensionRuleHits[dim]) {
        dimensionRuleHits[dim] = { totalRules: 0, hitRules: 0, findings: [] };
      }
      dimensionRuleHits[dim].hitRules++;
      dimensionRuleHits[dim].findings.push({
        title: f.title,
        riskLevel: f.riskLevel,
        description: f.description,
        suggestion: f.suggestion,
      });
    }

    // Count total active rules per dimension
    const allActiveRules = await this.prisma.diagnosisRule.findMany({
      where: { isActive: true },
      select: { dimension: true },
    });
    for (const rule of allActiveRules) {
      const dim = rule.dimension || '其他';
      if (!dimensionRuleHits[dim]) {
        dimensionRuleHits[dim] = { totalRules: 0, hitRules: 0, findings: [] };
      }
      dimensionRuleHits[dim].totalRules++;
    }

    return {
      reportPublicId: report.publicId,
      submissionPublicId: submission?.publicId || '',
      reportNumber: report.reportNumber,
      riskLevel: report.riskLevel,
      reviewStatus: report.reviewStatus,
      customerVisible: report.customerVisible,
      htmlContent: report.htmlContent,
      diagnosisResult: report.diagnosisResult ? {
        overallRiskLevel: report.diagnosisResult.overallRiskLevel,
        dimensionResults: report.diagnosisResult.dimensionResults,
      } : null,
      findings: findings.map((f) => ({
        riskLevel: f.riskLevel,
        title: f.title,
        description: f.description,
        suggestion: f.suggestion,
        recommendServices: f.recommendServices,
        dimension: f.rule?.dimension || null,
      })),
      recommendations: report.diagnosisResult?.recommendations || [],
      reviewRecords: report.reviewRecords.map((rr) => ({
        id: rr.id,
        action: rr.action,
        comment: rr.comment,
        changes: rr.changes,
        reviewerName: rr.reviewer?.realName || '未知',
        createdAt: rr.createdAt.toISOString(),
      })),
      // V2 additions
      dashboard: report.diagnosisResult?.dashboardData || null,
      documentCompleteness: submission?.documentCompletenessDetail || null,
      uploadedDocuments,
      dimensionRuleHits,
    };
  }

  async review(publicId: string, userId: number, action: 'APPROVE' | 'REJECT', comment?: string) {
    const report = await this.prisma.report.findUnique({ where: { publicId } });
    if (!report) throw new NotFoundException({ code: 'REPORT_NOT_FOUND', message: '报告不存在' });

    const result = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.report.update({
        where: { id: report.id },
        data: {
          reviewStatus: action === 'APPROVE' ? 'REVIEWED' : 'REJECTED',
          customerVisible: action === 'APPROVE',
          reviewedById: userId,
          reviewedAt: new Date(),
        },
      });

      await tx.reviewRecord.create({
        data: {
          reportId: report.id,
          reviewerId: userId,
          action: action as any,
          comment: comment || null,
        },
      });

      return updated;
    });

    return {
      reportPublicId: result.publicId,
      reviewStatus: result.reviewStatus,
      customerVisible: result.customerVisible,
    };
  }

  async updateReport(
    publicId: string, userId: number, userRole: string,
    body: {
      htmlContent?: string; customerVisible?: boolean;
      riskLevel?: string; reviewStatus?: string; comment?: string;
    },
  ) {
    const report = await this.prisma.report.findUnique({ where: { publicId } });
    if (!report) throw new NotFoundException({ code: 'REPORT_NOT_FOUND', message: '报告不存在' });

    // Only ADMIN can change riskLevel or reviewStatus
    if ((body.riskLevel || body.reviewStatus) && userRole !== 'ADMIN') {
      throw new ForbiddenException({ code: 'FORBIDDEN', message: '仅管理员可修改风险等级和复核状态' });
    }

    // Forbidden phrase check on htmlContent
    if (body.htmlContent) {
      const { cleaned, replacements } = await this.phraseChecker.check(body.htmlContent);
      if (replacements > 0) {
        console.log(`[Admin] ${replacements} forbidden phrases replaced during report update`);
      }
      body.htmlContent = cleaned;
    }

    const changes: Record<string, string> = {};
    if (body.htmlContent && body.htmlContent !== report.htmlContent) changes['htmlContent'] = 'modified';
    if (body.customerVisible !== undefined && body.customerVisible !== report.customerVisible) changes['customerVisible'] = `${report.customerVisible}→${body.customerVisible}`;
    if (body.riskLevel && body.riskLevel !== report.riskLevel) changes['riskLevel'] = `${report.riskLevel}→${body.riskLevel}`;
    if (body.reviewStatus && body.reviewStatus !== report.reviewStatus) changes['reviewStatus'] = `${report.reviewStatus}→${body.reviewStatus}`;

    const result = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.report.update({
        where: { id: report.id },
        data: {
          ...(body.htmlContent ? { htmlContent: body.htmlContent } : {}),
          ...(body.customerVisible !== undefined ? { customerVisible: body.customerVisible } : {}),
          ...(body.riskLevel ? { riskLevel: body.riskLevel as any } : {}),
          ...(body.reviewStatus ? { reviewStatus: body.reviewStatus as any } : {}),
        },
      });

      await tx.reviewRecord.create({
        data: {
          reportId: report.id,
          reviewerId: userId,
          action: 'MODIFY',
          changes: Object.keys(changes).length > 0 ? changes : undefined,
          comment: body.comment || null,
        },
      });

      return updated;
    });

    return {
      reportPublicId: result.publicId,
      reviewStatus: result.reviewStatus,
      customerVisible: result.customerVisible,
      riskLevel: result.riskLevel,
      changes: Object.keys(changes).length > 0 ? changes : null,
    };
  }
}

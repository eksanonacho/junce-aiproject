import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ReportTemplateService } from './report-template.service';
import { ReportAccessTokenService } from './report-access-token.service';
import { ForbiddenPhraseCheckerService } from './forbidden-phrase-checker.service';

@Injectable()
export class ReportService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly template: ReportTemplateService,
    private readonly accessToken: ReportAccessTokenService,
    private readonly phraseChecker: ForbiddenPhraseCheckerService,
  ) {}

  /**
   * Generate (or regenerate) a Report for a submission.
   * Returns public info + plaintext token.
   */
  async generateReport(submissionPublicId: string) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId: submissionPublicId },
      include: { answers: true, diagnosisResult: true },
    });

    if (!submission) {
      throw new NotFoundException({ code: 'SUBMISSION_NOT_FOUND', message: '提交记录不存在' });
    }
    if (!submission.diagnosisResult) {
      throw new BadRequestException({ code: 'NO_DIAGNOSIS_RESULT', message: '该提交尚未完成诊断，无法生成报告' });
    }

    const dr = submission.diagnosisResult;

    // Fetch full diagnosis result with findings + recommendations
    const fullDr = await this.prisma.diagnosisResult.findUnique({
      where: { id: dr.id },
      include: { findings: true, recommendations: true },
    });
    if (!fullDr) {
      throw new NotFoundException({ code: 'DIAGNOSIS_RESULT_NOT_FOUND', message: '诊断结果不存在' });
    }

    // Get active disclaimer
    const disclaimer = await this.prisma.disclaimer.findFirst({
      where: { isActive: true },
    });
    if (!disclaimer) {
      throw new BadRequestException({ code: 'NO_ACTIVE_DISCLAIMER', message: '系统中没有活跃的免责声明，无法生成报告' });
    }

    // Determine review status: only LOW + !needReview → AUTO_RELEASED
    const needReview = fullDr.needReview;
    const overallRiskLevel = fullDr.overallRiskLevel;
    const reviewStatus = (overallRiskLevel === 'LOW' && !needReview) ? 'AUTO_RELEASED' : 'NEED_REVIEW';
    const customerVisible = (overallRiskLevel === 'LOW' && !needReview);

    // Build report JSON
    const reportJson = await this.template.buildReportJson(
      fullDr as any,
      submission,
      disclaimer.content,
    );

    // Generate report number
    const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
    const count = await this.prisma.report.count({
      where: { reportNumber: { startsWith: `JC-AI-${today}` } },
    });
    const reportNumber = `JC-AI-${today}-${String(count + 1).padStart(4, '0')}`;

    // Render HTML
    const htmlContent = this.template.renderHtml({
      ...reportJson,
      reportNumber,
      generatedAt: new Date().toISOString(),
    });

    // Forbidden phrase check
    const { cleaned, replacements } = await this.phraseChecker.check(htmlContent);
    if (replacements > 0) {
      console.log(`[Report] ${replacements} forbidden phrases replaced in report ${reportNumber}`);
    }

    // Delete old report if exists
    const existingReport = await this.prisma.report.findUnique({
      where: { diagnosisResultId: fullDr.id },
    });
    if (existingReport) {
      await this.prisma.reportAccessToken.deleteMany({ where: { reportId: existingReport.id } });
      await this.prisma.report.delete({ where: { id: existingReport.id } });
    }

    // Save report
    const report = await this.prisma.report.create({
      data: {
        diagnosisResultId: fullDr.id,
        reportNumber,
        title: '君册财税·企业初诊报告',
        riskLevel: overallRiskLevel as any,
        reviewStatus: reviewStatus as any,
        customerVisible,
        htmlContent: cleaned,
        disclaimerText: disclaimer.content,
      },
    });

    // Generate access token
    const plainToken = await this.accessToken.generateToken(report.id);

    return {
      submissionPublicId: submission.publicId,
      reportPublicId: report.publicId,
      reportNumber: report.reportNumber,
      riskLevel: report.riskLevel,
      reviewStatus: report.reviewStatus,
      customerVisible: report.customerVisible,
      reportAccessToken: plainToken,
    };
  }

  /**
   * Get report status (public, no token required, no sensitive content).
   */
  async getReportStatus(publicId: string) {
    const report = await this.prisma.report.findUnique({
      where: { publicId },
    });

    if (!report) {
      throw new NotFoundException({ code: 'REPORT_NOT_FOUND', message: '报告不存在' });
    }

    return {
      reportPublicId: report.publicId,
      reportNumber: report.reportNumber,
      title: report.title,
      riskLevel: report.riskLevel,
      reviewStatus: report.reviewStatus,
      customerVisible: report.customerVisible,
      generatedAt: report.createdAt.toISOString(),
    };
  }

  /**
   * Get report detail (customer-facing, requires token).
   */
  async getReportDetail(publicId: string, token: string) {
    // Validate token
    await this.accessToken.validateToken(publicId, token);

    const report = await this.prisma.report.findUnique({
      where: { publicId },
      include: {
        diagnosisResult: {
          include: {
            findings: true,
            recommendations: true,
            submission: {
              include: { answers: true },
            },
          },
        },
      },
    });

    if (!report) {
      throw new NotFoundException({ code: 'REPORT_NOT_FOUND', message: '报告不存在' });
    }

    // If not customer visible, return limited info
    if (!report.customerVisible) {
      return {
        reportPublicId: report.publicId,
        reportNumber: report.reportNumber,
        title: report.title,
        riskLevel: report.riskLevel,
        reviewStatus: report.reviewStatus,
        customerVisible: false,
        message: report.reviewStatus === 'NEED_REVIEW'
          ? '您的初诊结果包含需要专业人员进一步确认的内容。君册工作人员将结合完整资料进行复核后，再向您说明具体情况。'
          : '该报告暂时无法查看',
      };
    }

    // Full report
    const dr = report.diagnosisResult;
    const submission = dr?.submission;
    if (!dr || !submission) {
      throw new NotFoundException({ code: 'REPORT_DATA_INCOMPLETE', message: '报告数据不完整' });
    }

    const companyProfile = await this.template.buildCompanyProfile(submission);

    return {
      reportPublicId: report.publicId,
      reportNumber: report.reportNumber,
      title: report.title,
      riskLevel: report.riskLevel,
      reviewStatus: report.reviewStatus,
      customerVisible: true,
      generatedAt: report.createdAt.toISOString(),
      companyProfile,
      summary: dr.summary || (dr.findings.length === 0
        ? '根据您目前填写的信息，系统暂未发现明显高风险项。'
        : `系统检测到 ${dr.findings.filter(f=>f.riskLevel==='HIGH').length} 个高风险项、${dr.findings.filter(f=>f.riskLevel==='MEDIUM').length} 个中风险项。`),
      dimensionResults: dr.dimensionResults,
      findings: dr.findings.map((f) => ({
        riskLevel: f.riskLevel,
        title: f.title,
        description: f.description,
        suggestion: f.suggestion,
        recommendServices: f.recommendServices,
      })),
      recommendations: dr.recommendations.map((r) => ({
        serviceType: r.serviceType,
        reason: r.reason,
        priority: r.priority,
      })),
      disclaimer: report.disclaimerText,
      htmlContent: report.htmlContent,
    };
  }
}

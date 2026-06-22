import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

interface DiagnosisResultWithRelations {
  id: number;
  overallRiskLevel: string;
  needReview: boolean;
  dimensionResults: unknown;
  summary: string | null;
  findings: Array<{
    riskLevel: string;
    title: string;
    description: string;
    suggestion: string;
    recommendServices: unknown;
  }>;
  recommendations: Array<{
    serviceType: string;
    reason: string;
    priority: string;
  }>;
}

interface SubmissionInfo {
  answers: Array<{ questionId: number; answerValue: unknown }>;
}

@Injectable()
export class ReportTemplateService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Build the company profile from submission answers.
   */
  async buildCompanyProfile(submission: SubmissionInfo) {
    const questionIds = submission.answers.map((a) => a.questionId);
    const questions = await this.prisma.question.findMany({
      where: { id: { in: questionIds } },
    });
    const questionMap = new Map(questions.map((q) => [q.id, q.questionText]));

    const profile: Record<string, string> = {};
    for (const a of submission.answers) {
      const text = questionMap.get(a.questionId) || `题目${a.questionId}`;
      profile[text] = typeof a.answerValue === 'string' ? a.answerValue : JSON.stringify(a.answerValue);
    }
    return profile;
  }

  /**
   * Build report JSON from diagnosis result.
   */
  async buildReportJson(
    dr: DiagnosisResultWithRelations,
    submission: SubmissionInfo,
    disclaimerText: string,
  ) {
    const companyProfile = await this.buildCompanyProfile(submission);

    // Summary text based on risk level
    let summary: string;
    if (dr.findings.length === 0) {
      summary = '根据您目前填写的信息，系统暂未发现明显高风险项。由于本报告仅基于有限信息生成，仍建议后续结合完整账务、申报、发票和工商资料进行人工确认。';
    } else {
      const highCount = dr.findings.filter((f) => f.riskLevel === 'HIGH').length;
      const mediumCount = dr.findings.filter((f) => f.riskLevel === 'MEDIUM').length;
      const parts: string[] = [];
      if (highCount > 0) parts.push(`${highCount} 个高风险项`);
      if (mediumCount > 0) parts.push(`${mediumCount} 个中风险项`);
      summary = `系统检测到 ${parts.join('、')}，建议您关注以下内容。`;
    }

    // Map priority labels
    const priorityLabel = (p: string) => {
      switch (p) {
        case 'STRONG': return '建议优先了解';
        case 'SUGGEST': return '建议关注';
        case 'INFO': return '可作为后续优化方向';
        default: return '建议关注';
      }
    };

    return {
      riskLevel: dr.overallRiskLevel,
      summary,
      companyProfile,
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
        priorityLabel: priorityLabel(r.priority),
      })),
      disclaimer: disclaimerText,
    };
  }

  /**
   * Render report JSON to HTML.
   */
  renderHtml(reportJson: Record<string, unknown>): string {
    const r = reportJson as any;
    const levelColor = r.riskLevel === 'HIGH' ? 'red' : r.riskLevel === 'MEDIUM' ? '#e67e22' : r.riskLevel === 'LOW' ? '#27ae60' : '#888';
    const levelLabel = r.riskLevel === 'HIGH' ? '高风险' : r.riskLevel === 'MEDIUM' ? '中风险' : r.riskLevel === 'LOW' ? '低风险' : '无法判断';

    const findingsHtml = (r.findings || []).map((f: any) => `
      <div style="border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:10px">
        <span style="display:inline-block;background:${f.riskLevel==='HIGH'?'#e74c3c':f.riskLevel==='MEDIUM'?'#e67e22':'#888'};color:#fff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:8px">${f.riskLevel==='HIGH'?'高风险':f.riskLevel==='MEDIUM'?'中风险':'低风险'}</span>
        <strong>${this.escapeHtml(f.title)}</strong>
        <p style="color:#555;margin:6px 0">${this.escapeHtml(f.description)}</p>
        <p style="color:#888;font-size:14px">💡 ${this.escapeHtml(f.suggestion)}</p>
      </div>
    `).join('');

    const recsHtml = (r.recommendations || []).map((rec: any) => `
      <div style="display:flex;align-items:center;gap:8px;padding:8px 12px;border-left:3px solid #3498db;margin-bottom:6px;background:#f8f9fa;border-radius:0 8px 8px 0">
        <span style="font-size:12px;color:#3498db;white-space:nowrap">${this.escapeHtml(rec.priorityLabel)}</span>
        <strong>${this.escapeHtml(rec.serviceType)}</strong>
        <span style="color:#888;font-size:13px;margin-left:auto">${this.escapeHtml(rec.reason)}</span>
      </div>
    `).join('');

    return `<!DOCTYPE html>
<html lang="zh-CN">
<head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0"><title>君册财税·企业初诊报告</title></head>
<body style="font-family:system-ui,-apple-system,sans-serif;max-width:680px;margin:0 auto;padding:16px;color:#333;line-height:1.6">

<section style="text-align:center;margin-bottom:24px">
  <h1 style="font-size:22px;margin:0 0 4px">君册财税 · 企业初诊报告</h1>
  <p style="color:#888;font-size:13px;margin:0">报告编号：${this.escapeHtml(r.reportNumber)}</p>
  <p style="color:#888;font-size:13px;margin:2px 0">生成时间：${this.escapeHtml(r.generatedAt)}</p>
</section>

<section style="background:#fff3cd;border:1px solid #ffc107;border-radius:8px;padding:12px;margin-bottom:20px;font-size:13px;color:#856404">
  ⚠️ ${this.escapeHtml(r.disclaimer)}
</section>

<section style="background:#f8f9fa;border-radius:8px;padding:16px;margin-bottom:20px">
  <h2 style="font-size:16px;margin:0 0 8px">企业基础画像</h2>
  ${Object.entries(r.companyProfile || {}).map(([k,v]) => `<p style="margin:4px 0;font-size:14px"><span style="color:#888">${this.escapeHtml(k)}：</span>${this.escapeHtml(String(v))}</p>`).join('')}
</section>

<section style="text-align:center;margin-bottom:20px">
  <div style="display:inline-block;background:${levelColor};color:#fff;padding:8px 24px;border-radius:12px;font-size:20px;font-weight:bold">${levelLabel}</div>
  <p style="color:#555;font-size:14px;margin:8px 0 0">${this.escapeHtml(r.summary)}</p>
</section>

${r.findings && r.findings.length > 0 ? `
<section style="margin-bottom:20px">
  <h2 style="font-size:16px;margin:0 0 10px">发现的问题</h2>
  ${findingsHtml}
</section>
` : ''}

${r.recommendations && r.recommendations.length > 0 ? `
<section style="margin-bottom:20px">
  <h2 style="font-size:16px;margin:0 0 10px">推荐服务</h2>
  ${recsHtml}
  <p style="color:#888;font-size:12px;margin-top:8px">* 以上服务建议基于您的填写内容生成，具体方案请联系君册顾问确认。本报告不包含报价。</p>
</section>
` : ''}

<section style="text-align:center;margin-top:24px;padding:16px;background:#f8f9fa;border-radius:8px">
  <p style="margin:0;font-size:14px;color:#555">📞 如需专业建议，请联系君册财税顾问</p>
  <p style="margin:4px 0 0;font-size:12px;color:#888">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>
</section>

</body></html>`;
  }

  private escapeHtml(text: string | undefined | null): string {
    if (!text) return '';
    return text
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }
}

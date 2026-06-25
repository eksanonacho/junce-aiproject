import { Injectable, BadRequestException, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { DiagnosisService } from '../diagnosis/diagnosis.service';
import { ReportService } from '../report/report.service';
import { DocumentService } from '../document/document.service';
import { ReportAccessTokenService } from '../report/report-access-token.service';
import { SubmitQuestionnaireDto, SubmitAnswerDto } from './dto/submit-questionnaire.dto';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';

@Injectable()
export class SubmissionService {
  private readonly logger = new Logger(SubmissionService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly diagnosisService: DiagnosisService,
    private readonly reportService: ReportService,
    private readonly documentService: DocumentService,
    private readonly reportAccessTokenService: ReportAccessTokenService,
  ) {}

  async submit(dto: SubmitQuestionnaireDto) {
    // 1. Validate questionnaire exists and is active
    const questionnaire = await this.prisma.questionnaire.findUnique({
      where: { id: dto.questionnaireId },
      include: { questions: true },
    });

    if (!questionnaire) {
      throw new NotFoundException({
        code: 'QUESTIONNAIRE_NOT_FOUND',
        message: '问卷不存在',
      });
    }

    if (!questionnaire.isActive) {
      throw new BadRequestException({
        code: 'QUESTIONNAIRE_INACTIVE',
        message: '该问卷已下线',
      });
    }

    // 2. Validate answers is non-empty array
    if (!dto.answers || dto.answers.length === 0) {
      throw new BadRequestException({
        code: 'ANSWERS_EMPTY',
        message: '答案不能为空',
      });
    }

    // 3. Build question map for validation
    const questionMap = new Map(questionnaire.questions.map((q) => [q.id, q]));

    // 4. Validate each answer
    const missingRequired: { questionId: number; text: string }[] = [];
    const invalidQuestions: number[] = [];
    const invalidValues: { questionId: number; text: string; reason: string }[] = [];

    for (const answer of dto.answers) {
      const question = questionMap.get(answer.questionId);

      if (!question) {
        invalidQuestions.push(answer.questionId);
        continue;
      }

      // Validate answer value against question type
      this.validateAnswerValue(question, answer, invalidValues);
    }

    // 5. Check required questions are all answered
    const requiredQuestions = questionnaire.questions.filter((q) => q.isRequired);
    const answeredIds = new Set(dto.answers.map((a) => a.questionId));
    for (const q of requiredQuestions) {
      if (!answeredIds.has(q.id)) {
        missingRequired.push({ questionId: q.id, text: q.questionText });
      }
    }

    // 6. Report errors
    if (invalidQuestions.length > 0) {
      throw new BadRequestException({
        code: 'INVALID_QUESTION_ID',
        message: `以下题目不属于该问卷: ${invalidQuestions.join(', ')}`,
      });
    }

    if (missingRequired.length > 0) {
      throw new BadRequestException({
        code: 'REQUIRED_ANSWER_MISSING',
        message: '必填题未填写',
        details: missingRequired,
      });
    }

    if (invalidValues.length > 0) {
      throw new BadRequestException({
        code: 'INVALID_ANSWER_VALUE',
        message: '答案格式不正确',
        details: invalidValues,
      });
    }

    // 7. Create Submission + Answers
    const submission = await this.prisma.submission.create({
      data: {
        questionnaireId: dto.questionnaireId,
        phone: dto.phone || null,
        status: 'SUBMITTED',
        submittedAt: new Date(),
        source: 'WEB',
        answers: {
          create: dto.answers.map((a) => ({
            questionId: a.questionId,
            answerValue: a.value as object,
          })),
        },
      },
    });

    let diagnosisStatus = 'NOT_RUN';
    let reportStatus = 'NOT_RUN';
    let reportPublicId: string | undefined;
    let reportAccessToken: string | undefined;

    // 8. Auto-trigger diagnosis
    try {
      await this.diagnosisService.runDiagnosis(submission.publicId);
      diagnosisStatus = 'COMPLETED';

      // 9. Auto-generate report
      try {
        const reportResult = await this.reportService.generateReport(submission.publicId);
        reportStatus = 'READY';
        reportPublicId = reportResult.reportPublicId;
        reportAccessToken = reportResult.reportAccessToken;
      } catch (reportErr: unknown) {
        this.logger.error(`Report generation failed for ${submission.publicId}: ${(reportErr as Error).message}`);
        reportStatus = 'FAILED';
      }
    } catch (err: unknown) {
      this.logger.error(`Diagnosis failed for ${submission.publicId}: ${(err as Error).message}`);
      diagnosisStatus = 'FAILED';
    }

    return {
      submissionPublicId: submission.publicId,
      status: 'SUBMITTED',
      diagnosisStatus,
      reportStatus,
      reportPublicId,
      reportAccessToken,
      message: diagnosisStatus === 'COMPLETED' && reportStatus === 'READY'
        ? '提交成功，报告已生成'
        : diagnosisStatus === 'COMPLETED'
          ? '提交成功，诊断已完成但报告生成失败'
          : '提交成功',
    };
  }

  private validateAnswerValue(
    question: { id: number; questionText: string; questionType: string; options: unknown },
    answer: SubmitAnswerDto,
    invalidValues: { questionId: number; text: string; reason: string }[],
  ) {
    const options = question.options as Record<string, unknown> | null;
    const optionsList = (options as any)?.options as string[] | undefined;

    switch (question.questionType) {
      case 'SINGLE_CHOICE':
        if (typeof answer.value !== 'string') {
          invalidValues.push({ questionId: question.id, text: question.questionText, reason: '单选答案必须是字符串' });
        } else if (optionsList && !optionsList.includes(answer.value)) {
          invalidValues.push({ questionId: question.id, text: question.questionText, reason: `"${answer.value}"不在选项中` });
        }
        break;

      case 'MULTI_CHOICE':
        if (!Array.isArray(answer.value)) {
          invalidValues.push({ questionId: question.id, text: question.questionText, reason: '多选答案必须是数组' });
        } else if (optionsList) {
          for (const v of answer.value) {
            if (typeof v !== 'string') {
              invalidValues.push({ questionId: question.id, text: question.questionText, reason: '多选数组项必须是字符串' });
              break;
            }
            if (!optionsList.includes(v)) {
              invalidValues.push({ questionId: question.id, text: question.questionText, reason: `"${v}"不在选项中` });
              break;
            }
          }
        }
        break;

      case 'YES_NO':
        if (typeof answer.value !== 'string') {
          invalidValues.push({ questionId: question.id, text: question.questionText, reason: 'YES_NO 答案必须是字符串' });
        } else if (optionsList && !optionsList.includes(answer.value)) {
          invalidValues.push({ questionId: question.id, text: question.questionText, reason: `"${answer.value}"不在选项中` });
        }
        break;

      case 'RANGE':
        // Accept string or object
        if (typeof answer.value !== 'string' && typeof answer.value !== 'object') {
          invalidValues.push({ questionId: question.id, text: question.questionText, reason: 'RANGE 答案格式不正确' });
        }
        break;

      default:
        // TEXT or unknown — accept anything non-empty
        if (answer.value === null || answer.value === undefined || answer.value === '') {
          invalidValues.push({ questionId: question.id, text: question.questionText, reason: '答案不能为空' });
        }
    }
  }

  // ============================================================
  // V2 Methods
  // ============================================================

  async startV2Submission(phone: string | undefined, mode: string) {
    if (!mode || !['QUICK', 'STANDARD', 'DEEP'].includes(mode.toUpperCase())) {
      throw new BadRequestException('Invalid mode. Must be QUICK, STANDARD, or DEEP');
    }

    const diagnosisMode = mode.toUpperCase() as 'QUICK' | 'STANDARD' | 'DEEP';

    // Find V2 questionnaire
    const v2Questionnaire = await this.prisma.questionnaire.findFirst({
      where: { version: 'v2', isActive: true },
    });
    if (!v2Questionnaire) {
      throw new BadRequestException('V2 问卷不存在');
    }

    // Generate access token (plaintext returned once)
    const plainToken = crypto.randomBytes(32).toString('hex');
    const tokenHash = await bcrypt.hash(plainToken, 10);

    const submission = await this.prisma.submission.create({
      data: {
        questionnaireId: v2Questionnaire.id,
        phone: phone || null,
        mode: diagnosisMode,
        status: 'DRAFT',
        accessTokenHash: tokenHash,
        accessTokenCreatedAt: new Date(),
        source: 'WEB',
      },
    });

    this.logger.log(`V2 submission started: ${submission.publicId}, mode=${diagnosisMode}`);

    return {
      submissionPublicId: submission.publicId,
      submissionAccessToken: plainToken,
      mode: diagnosisMode,
      status: 'DRAFT',
      createdAt: submission.createdAt,
    };
  }

  async completeV2Submission(
    publicId: string,
    dto: { questionnaireVersion?: string; answers: { questionPublicId: string; value: unknown }[] },
  ) {
    const submission = await this.prisma.submission.findUnique({
      where: { publicId },
      include: { questionnaire: { include: { questions: true } } },
    });

    if (!submission) {
      throw new NotFoundException({ code: 'SUBMISSION_NOT_FOUND', message: '提交记录不存在' });
    }

    if (!['DRAFT', 'DOCUMENT_UPLOADING'].includes(submission.status)) {
      throw new BadRequestException({
        code: 'INVALID_STATUS',
        message: `当前状态 ${submission.status} 不允许完成提交`,
      });
    }

    if (!dto.answers || dto.answers.length === 0) {
      throw new BadRequestException({ code: 'ANSWERS_EMPTY', message: '答案不能为空' });
    }

    // Build question map by publicId
    const questionMap = new Map(
      submission.questionnaire.questions.map((q) => [q.publicId, q]),
    );

    // Validate and convert answers
    const validAnswers: { questionId: number; value: unknown }[] = [];
    const invalidQuestions: string[] = [];

    for (const answer of dto.answers) {
      const question = questionMap.get(answer.questionPublicId);
      if (!question) {
        invalidQuestions.push(answer.questionPublicId);
        continue;
      }
      validAnswers.push({ questionId: question.id, value: answer.value });
    }

    if (invalidQuestions.length > 0) {
      throw new BadRequestException({
        code: 'INVALID_QUESTION_ID',
        message: `以下题目不属于该问卷: ${invalidQuestions.join(', ')}`,
      });
    }

    // Save answers
    for (const a of validAnswers) {
      await this.prisma.answer.create({
        data: {
          submissionId: submission.id,
          questionId: a.questionId,
          answerValue: a.value as object,
        },
      });
    }

    // Update status
    await this.prisma.submission.update({
      where: { publicId },
      data: {
        status: 'QUESTIONNAIRE_COMPLETED',
        submittedAt: new Date(),
      },
    });

    // Compute document completeness
    let completenessScore = 0;
    if (submission.mode) {
      try {
        const result = await this.documentService.computeAndSaveCompleteness(publicId);
        completenessScore = result.score;
      } catch (err) {
        this.logger.warn(`Document completeness computation skipped: ${(err as Error).message}`);
      }
    }

    // Run diagnosis
    let diagnosisStatus = 'NOT_RUN';
    let reportStatus = 'NOT_RUN';
    let reportPublicId: string | undefined;
    let reportAccessToken: string | undefined;

    try {
      await this.diagnosisService.runDiagnosis(publicId);
      diagnosisStatus = 'COMPLETED';

      // Generate report
      try {
        const reportResult = await this.reportService.generateReport(publicId);
        reportStatus = 'READY';
        reportPublicId = reportResult.reportPublicId;
        reportAccessToken = reportResult.reportAccessToken;
      } catch (reportErr: unknown) {
        this.logger.error(`Report generation failed: ${(reportErr as Error).message}`);
        reportStatus = 'FAILED';
      }
    } catch (diagErr: unknown) {
      this.logger.error(`Diagnosis failed: ${(diagErr as Error).message}`);
      diagnosisStatus = 'FAILED';
    }

    return {
      submissionPublicId: publicId,
      status: diagnosisStatus === 'COMPLETED' ? 'COMPLETED' : 'FAILED',
      diagnosisStatus,
      reportStatus,
      reportPublicId,
      reportAccessToken,
      documentCompletenessScore: completenessScore,
      message: reportStatus === 'READY'
        ? '提交成功，报告已生成'
        : '提交成功，报告生成中',
    };
  }

  async lookupByPhone(phone: string) {
    if (!phone || phone.length < 11) {
      throw new BadRequestException('手机号格式不正确');
    }

    // Find latest V2 submission (mode IS NOT NULL)
    const latest = await this.prisma.submission.findFirst({
      where: { phone, mode: { not: null } },
      orderBy: { createdAt: 'desc' },
      include: {
        diagnosisResult: {
          include: { report: true },
        },
      },
    });

    if (!latest) {
      return {
        hasExisting: false,
        latest: null,
        actions: { canContinue: false, canViewReport: false, canRestart: true },
      };
    }

    const report = latest.diagnosisResult?.report;
    const isDraft = ['DRAFT', 'DOCUMENT_UPLOADING'].includes(latest.status);
    const isQuestionnaireCompleted = latest.status === 'QUESTIONNAIRE_COMPLETED';
    const isInDiagnosis = latest.status === 'DIAGNOSING';
    const isCompleted = latest.status === 'COMPLETED';
    const hasReport = !!report;

    const result: any = {
      hasExisting: true,
      latest: {
        submissionPublicId: latest.publicId,
        status: latest.status,
        mode: latest.mode,
        createdAt: latest.createdAt,
        updatedAt: latest.updatedAt,
        report: null as any,
      },
      actions: {
        canContinue: isDraft || isQuestionnaireCompleted || isInDiagnosis,
        canViewReport: isCompleted && hasReport,
        canRestart: true,
      },
    };

    // If DRAFT, generate a new submissionAccessToken for continuation
    if (isDraft) {
      const newPlainToken = crypto.randomBytes(32).toString('hex');
      const newTokenHash = await bcrypt.hash(newPlainToken, 10);
      await this.prisma.submission.update({
        where: { id: latest.id },
        data: { accessTokenHash: newTokenHash, accessTokenCreatedAt: new Date() },
      });
      result.latest.submissionAccessToken = newPlainToken;
    }

    // If has report, generate a fresh reportAccessToken
    if (hasReport && report) {
      try {
        const reportToken = await this.reportAccessTokenService.generateToken(report.id, 7);
        result.latest.report = {
          reportPublicId: report.publicId,
          reportNumber: report.reportNumber,
          riskLevel: report.riskLevel,
          reviewStatus: report.reviewStatus,
          customerVisible: report.customerVisible,
          reportAccessToken: reportToken,
        };
      } catch (err) {
        this.logger.warn(`Failed to generate report token for lookup: ${(err as Error).message}`);
        result.latest.report = {
          reportPublicId: report.publicId,
          reportNumber: report.reportNumber,
          riskLevel: report.riskLevel,
          reviewStatus: report.reviewStatus,
          customerVisible: report.customerVisible,
          reportAccessToken: null,
        };
      }
    }

    return result;
  }
}

import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { SubmitQuestionnaireDto, SubmitAnswerDto } from './dto/submit-questionnaire.dto';

@Injectable()
export class SubmissionService {
  constructor(private readonly prisma: PrismaService) {}

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

    return {
      submissionPublicId: submission.publicId,
      status: 'SUBMITTED',
      message: '提交成功',
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
}

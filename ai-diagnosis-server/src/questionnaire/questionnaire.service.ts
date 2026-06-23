import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class QuestionnaireService {
  constructor(private readonly prisma: PrismaService) {}

  async getActiveQuestionnaire(version: string = 'v1') {
    const q = await this.prisma.questionnaire.findFirst({
      where: { isActive: true, version },
      include: {
        questions: {
          orderBy: [{ groupOrder: 'asc' }, { orderInGroup: 'asc' }],
        },
      },
    });

    if (!q) {
      throw new NotFoundException({
        code: 'NO_ACTIVE_QUESTIONNAIRE',
        message: '暂无可用问卷',
      });
    }

    // Group questions by groupLabel
    const groupMap = new Map<string, { label: string; order: number; questions: typeof q.questions }>();
    for (const question of q.questions) {
      const key = question.groupLabel;
      if (!groupMap.has(key)) {
        groupMap.set(key, { label: key, order: question.groupOrder, questions: [] });
      }
      groupMap.get(key)!.questions.push(question);
    }

    const groups = Array.from(groupMap.values()).sort((a, b) => a.order - b.order);

    return {
      id: q.id,
      version: q.version,
      title: q.title,
      description: q.description,
      groups: groups.map((g) => ({
        label: g.label,
        order: g.order,
        questions: g.questions.map((q) => ({
          id: q.id,
          publicId: q.publicId,
          text: q.questionText,
          type: q.questionType,
          options: q.options,
          required: q.isRequired,
          riskDimension: q.riskDimension,
        })),
      })),
    };
  }
}

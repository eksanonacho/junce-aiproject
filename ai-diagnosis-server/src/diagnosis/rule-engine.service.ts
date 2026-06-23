import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

// -------------------------------------
// Types
// -------------------------------------

interface NormalizedAnswer {
  questionId: number;
  value: unknown;
  /** flattened string array for MULTI_CHOICE; null for other types */
  arrayValue: string[] | null;
  /** numeric value for RANGE/gt/gte/lt/lte; null if not parseable */
  numericValue: number | null;
  stringValue: string | null;
  exists: boolean;
}

interface RuleCondition {
  operator: string;
  value?: unknown;
  questionId?: number;
  questionPublicId?: string;
  min?: number;
  max?: number;
}

interface CompositeConditionBlock {
  logic: 'AND' | 'OR';
  conditions: RuleCondition[];
}

interface RuleRecord {
  id: number;
  ruleCode: string;
  dimension: string;
  questionId: number | null;
  triggerCondition: unknown;
  compositeCondition: unknown;
  conditionMode: string;
  riskLevel: string;
  riskTitle: string;
  riskDescription: string;
  suggestion: string;
  needReview: boolean;
  recommendServices: unknown;
}

interface MatchResult {
  rule: RuleRecord;
  matched: boolean;
}

// -------------------------------------
// Service
// -------------------------------------

@Injectable()
export class RuleEngineService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Main entry: load active rules, match against answers, return matched rules.
   */
  async evaluate(answers: { questionId: number; answerValue: unknown }[]): Promise<{
    matchedRules: RuleRecord[];
    hasActiveRules: boolean;
  }> {
    // 1. Load active rules
    const rules = await this.prisma.diagnosisRule.findMany({
      where: { isActive: true },
    });

    // 2. Load all questions and build publicId → id map (for composite condition resolution)
    const allQuestions = await this.prisma.question.findMany({
      select: { id: true, publicId: true },
    });
    const qPublicIdToId = new Map<string, number>();
    for (const q of allQuestions) {
      if (q.publicId) qPublicIdToId.set(q.publicId, q.id);
    }

    // 3. Normalize all answers
    const normalizedAnswers = answers.map((a) => this.normalizeAnswer(a));

    // 4. Match each rule
    const matched: RuleRecord[] = [];

    for (const rule of rules) {
      if (this.matchRule(rule, normalizedAnswers, qPublicIdToId)) {
        matched.push(rule);
      }
    }

    return { matchedRules: matched, hasActiveRules: rules.length > 0 };
  }

  // -------------------------------------
  // Answer normalization
  // -------------------------------------

  private normalizeAnswer(raw: { questionId: number; answerValue: unknown }): NormalizedAnswer {
    const v = raw.answerValue;

    let arrayValue: string[] | null = null;
    let numericValue: number | null = null;
    let stringValue: string | null = null;
    let exists = true;

    if (v === null || v === undefined) {
      exists = false;
    } else if (Array.isArray(v)) {
      arrayValue = v.map(String);
      stringValue = arrayValue.join(',');
    } else if (typeof v === 'number') {
      numericValue = v;
      stringValue = String(v);
    } else if (typeof v === 'string') {
      stringValue = v;
      const n = parseFloat(v);
      if (!isNaN(n)) numericValue = n;
    } else if (typeof v === 'boolean') {
      stringValue = String(v);
      numericValue = v ? 1 : 0;
    } else if (typeof v === 'object') {
      stringValue = JSON.stringify(v);
      const obj = v as Record<string, unknown>;
      if (typeof obj.from === 'number') numericValue = obj.from as number;
      if (typeof obj.value === 'number') numericValue = obj.value as number;
      if (obj.from !== undefined && obj.to !== undefined) {
        exists = true;
      }
    }

    return {
      questionId: raw.questionId,
      value: v,
      arrayValue,
      numericValue,
      stringValue,
      exists,
    };
  }

  // -------------------------------------
  // Rule matching
  // -------------------------------------

  private matchRule(rule: RuleRecord, answers: NormalizedAnswer[], qPublicIdToId?: Map<string, number>): boolean {
    // V2 COMPOSITE mode: structured { logic, conditions[] }
    if (rule.conditionMode === 'COMPOSITE' && rule.compositeCondition) {
      const block = rule.compositeCondition as CompositeConditionBlock;
      if (!block.conditions || !Array.isArray(block.conditions) || block.conditions.length === 0) return false;
      const resolvedConditions = block.conditions.map((c) => this.resolveCondition(c, qPublicIdToId));
      if (block.logic === 'OR') {
        return resolvedConditions.some((cond) => this.evaluateCondition(cond, answers));
      }
      return resolvedConditions.every((cond) => this.evaluateCondition(cond, answers));
    }

    // Legacy array composite condition (AND only)
    if (rule.compositeCondition && Array.isArray(rule.compositeCondition)) {
      const conditions = rule.compositeCondition as RuleCondition[];
      if (conditions.length === 0) return false;
      return conditions.every((cond) => this.evaluateCondition(cond, answers));
    }

    // SIMPLE: single triggerCondition
    if (rule.triggerCondition) {
      const cond = rule.triggerCondition as RuleCondition;
      if (rule.questionId && !cond.questionId) {
        cond.questionId = rule.questionId;
      }
      return this.evaluateCondition(cond, answers);
    }

    return false;
  }

  /** Resolve questionPublicId → questionId if needed */
  private resolveCondition(cond: RuleCondition, qPublicIdToId?: Map<string, number>): RuleCondition {
    if (cond.questionPublicId && qPublicIdToId) {
      const id = qPublicIdToId.get(cond.questionPublicId);
      if (id !== undefined) {
        return { ...cond, questionId: id };
      }
    }
    return cond;
  }

  private evaluateCondition(cond: RuleCondition, answers: NormalizedAnswer[]): boolean {
    const qId = cond.questionId;
    if (!qId) return false;

    const answer = answers.find((a) => a.questionId === qId);
    if (!answer) return false;

    const op = cond.operator;

    switch (op) {
      case 'exists':
        return answer.exists;

      case 'equals':
        return answer.stringValue === String(cond.value);

      case 'not_equals':
        return answer.stringValue !== String(cond.value);

      case 'includes':
        if (!answer.arrayValue) return false;
        return answer.arrayValue.includes(String(cond.value));

      case 'in':
        if (!Array.isArray(cond.value)) return false;
        return (cond.value as unknown[]).map(String).includes(answer.stringValue ?? '');

      case 'gt':
        return answer.numericValue !== null && answer.numericValue > Number(cond.value);

      case 'gte':
        return answer.numericValue !== null && answer.numericValue >= Number(cond.value);

      case 'lt':
        return answer.numericValue !== null && answer.numericValue < Number(cond.value);

      case 'lte':
        return answer.numericValue !== null && answer.numericValue <= Number(cond.value);

      case 'range': {
        if (answer.numericValue === null) return false;
        const range = cond.value as { min?: number; max?: number } | undefined;
        if (!range) return false;
        if (range.min !== undefined && answer.numericValue < range.min) return false;
        if (range.max !== undefined && answer.numericValue > range.max) return false;
        return true;
      }

      default:
        return false;
    }
  }
}

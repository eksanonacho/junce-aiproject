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
  min?: number;
  max?: number;
}

interface RuleRecord {
  id: number;
  ruleCode: string;
  dimension: string;
  questionId: number | null;
  triggerCondition: unknown;
  compositeCondition: unknown;
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
  async evaluate(answers: { questionId: number; answerValue: unknown }[]) {
    // 1. Load active rules
    const rules = await this.prisma.diagnosisRule.findMany({
      where: { isActive: true },
    });

    // 2. Normalize all answers
    const normalizedAnswers = answers.map((a) => this.normalizeAnswer(a));

    // 3. Match each rule
    const matched: RuleRecord[] = [];

    for (const rule of rules) {
      if (this.matchRule(rule, normalizedAnswers)) {
        matched.push(rule);
      }
    }

    return matched;
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
      // Handle range objects: { from: 100000, to: 500000 }
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

  private matchRule(rule: RuleRecord, answers: NormalizedAnswer[]): boolean {
    // Composite condition: all sub-conditions must match (AND)
    if (rule.compositeCondition) {
      const conditions = rule.compositeCondition as RuleCondition[];
      if (!Array.isArray(conditions) || conditions.length === 0) return false;
      return conditions.every((cond) => this.evaluateCondition(cond, answers));
    }

    // Single condition
    if (rule.triggerCondition) {
      const cond = rule.triggerCondition as RuleCondition;
      // If the rule has questionId at the top level, inject it into the condition
      if (rule.questionId && !cond.questionId) {
        cond.questionId = rule.questionId;
      }
      return this.evaluateCondition(cond, answers);
    }

    return false;
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

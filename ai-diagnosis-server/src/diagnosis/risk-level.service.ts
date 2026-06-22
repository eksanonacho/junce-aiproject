import { Injectable } from '@nestjs/common';

interface RiskFindingInput {
  riskLevel: string;
  needReview?: boolean;
}

interface RiskCalcResult {
  overallRiskLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'UNKNOWN';
  needReview: boolean;
  reviewReason: string | null;
}

@Injectable()
export class RiskLevelService {
  /**
   * Calculate overall risk level from a list of findings.
   *
   * Rules:
   * 1. Any HIGH finding → overall = HIGH, needReview = true
   * 2. 3+ MEDIUM findings → overall = HIGH, needReview = true
   * 3. Any MEDIUM → overall = MEDIUM
   * 4. Only LOW findings → overall = LOW
   * 5. No findings + rules loaded successfully → LOW（系统正常评估，未发现风险）
   * 6. No findings + no active rules → UNKNOWN（系统无法判断）
   * 7. Answers incomplete/contradictory → UNKNOWN（信息不足）
   */
  calculate(findings: RiskFindingInput[], context?: { hasActiveRules?: boolean }): RiskCalcResult {
    if (!findings || findings.length === 0) {
      // ★ P0 修正：规则引擎正常执行但未命中规则 → LOW，不是 UNKNOWN
      if (context?.hasActiveRules === false) {
        // 没有 active 规则，系统无法判断
        return {
          overallRiskLevel: 'UNKNOWN',
          needReview: true,
          reviewReason: '系统中没有活跃的诊断规则，无法执行判断',
        };
      }
      // 规则正常加载，所有答案通过了检查，未发现风险
      return {
        overallRiskLevel: 'LOW',
        needReview: false,
        reviewReason: null,
      };
    }

    const highFindings = findings.filter((f) => f.riskLevel === 'HIGH');
    const mediumFindings = findings.filter((f) => f.riskLevel === 'MEDIUM');
    const lowFindings = findings.filter((f) => f.riskLevel === 'LOW');
    const forcedReview = findings.some((f) => f.needReview === true);

    // Rule 1: Any HIGH → HIGH
    if (highFindings.length > 0) {
      return {
        overallRiskLevel: 'HIGH',
        needReview: true,
        reviewReason: `命中 ${highFindings.length} 个高风险项`,
      };
    }

    // Rule 2: 3+ MEDIUM → HIGH
    if (mediumFindings.length >= 3) {
      return {
        overallRiskLevel: 'HIGH',
        needReview: true,
        reviewReason: `命中 ${mediumFindings.length} 个中风险项，叠加升级为高风险`,
      };
    }

    // Rule 3: Any MEDIUM → MEDIUM（1-2 MEDIUM, 3+ already handled above）
    if (mediumFindings.length > 0) {
      // needReview only if rule explicitly requires it
      return {
        overallRiskLevel: 'MEDIUM',
        needReview: forcedReview,
        reviewReason: forcedReview ? '规则要求人工复核' : null,
      };
    }

    // Rule 4: Only LOW → LOW
    if (lowFindings.length > 0) {
      return {
        overallRiskLevel: 'LOW',
        needReview: forcedReview,
        reviewReason: forcedReview ? '规则要求人工复核' : null,
      };
    }

    // Fallback
    return {
      overallRiskLevel: 'UNKNOWN',
      needReview: true,
      reviewReason: '无法确定风险等级',
    };
  }

  /**
   * Determine Report.reviewStatus based on needReview.
   */
  getReviewStatus(needReview: boolean): 'AUTO_RELEASED' | 'NEED_REVIEW' {
    return needReview ? 'NEED_REVIEW' : 'AUTO_RELEASED';
  }
}

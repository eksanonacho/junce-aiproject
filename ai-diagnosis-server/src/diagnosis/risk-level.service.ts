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
   * 4. Only LOW or no findings → overall = LOW
   * 5. No findings → UNKNOWN (placeholder)
   */
  calculate(findings: RiskFindingInput[]): RiskCalcResult {
    if (!findings || findings.length === 0) {
      return {
        overallRiskLevel: 'UNKNOWN',
        needReview: true,
        reviewReason: '未命中任何规则，无法判断风险',
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

    // Rule 3: Any MEDIUM → MEDIUM
    if (mediumFindings.length > 0) {
      const needReview = forcedReview || mediumFindings.length >= 2;
      return {
        overallRiskLevel: 'MEDIUM',
        needReview,
        reviewReason: needReview && !forcedReview
          ? `命中 ${mediumFindings.length} 个中风险项`
          : forcedReview ? '规则要求人工复核' : null,
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

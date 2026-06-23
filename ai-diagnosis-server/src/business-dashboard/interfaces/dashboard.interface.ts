export interface TopAction {
  priority: number;
  title: string;
  timeline: string;
  reason: string;
  serviceType: string;
}

export interface DimensionDetail {
  dimension: string;
  score: number;
  label: string;
  issues: string[];
  suggestions: string[];
  evidence: string;
  confidence: number;
}

export interface BusinessDashboardResult {
  overallScore: number;
  overallLabel: string;
  profitScore: number;
  riskScore: number;
  cashFlowScore: number;
  efficiencyScore: number;
  documentCompletenessScore: number;
  confidenceLevel: 'HIGH' | 'MEDIUM' | 'LOW';
  conclusion: string;
  topActions: TopAction[];
  dimensionDetails: DimensionDetail[];
}

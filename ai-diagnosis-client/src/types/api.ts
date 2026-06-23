// 问卷相关类型

export interface QuestionDto {
  id: number;
  publicId: string | null;
  text: string;
  type: 'SINGLE_CHOICE' | 'MULTI_CHOICE' | 'RANGE' | 'YES_NO';
  options: unknown;
  required: boolean;
  riskDimension: string | null;
}

export interface QuestionGroupDto {
  label: string;
  order: number;
  questions: QuestionDto[];
}

export interface QuestionnaireResponse {
  id: number;
  version: string;
  title: string;
  description: string | null;
  groups: QuestionGroupDto[];
}

// 提交相关类型

export interface SubmitAnswer {
  questionId: number;
  value: unknown;
}

export interface SubmitPayload {
  questionnaireId: number;
  phone?: string;
  answers: SubmitAnswer[];
}

export interface SubmitResponse {
  submissionPublicId: string;
  status: string;
  diagnosisStatus?: string;
  reportStatus?: string;
  reportPublicId?: string;
  reportAccessToken?: string;
  message: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: { questionId: number; text: string; reason?: string }[];
}

// 报告相关类型

export interface ReportStatus {
  reportPublicId: string;
  reportNumber?: string;
  title?: string;
  riskLevel: string;
  reviewStatus: string;
  customerVisible: boolean;
  generatedAt?: string;
}

export interface ReportDetail {
  reportPublicId: string;
  reportNumber?: string;
  title?: string;
  riskLevel: string;
  reviewStatus: string;
  customerVisible: boolean;
  generatedAt?: string;
  companyProfile?: Record<string, string>;
  summary?: string;
  findings?: Array<{
    riskLevel: string;
    title: string;
    description: string;
    suggestion: string;
    recommendServices?: unknown;
  }>;
  recommendations?: Array<{
    serviceType: string;
    reason: string;
    priority: string;
  }>;
  disclaimer?: string;
  htmlContent?: string;
  message?: string;
  // V2 additions
  dashboard?: BusinessDashboard | null;
  documentCompleteness?: DocumentCompletenessDto | null;
}

// ============================================================
// V2 Types
// ============================================================

// Document upload
export interface DocumentRequirementDto {
  code: string;
  name: string;
  category: string;
  description: string | null;
  required: boolean;
  affectsDimensions: string[];
  uploaded: boolean;
  uploadedDocument: {
    publicId: string;
    originalName: string;
    mimeType: string;
    sizeBytes: number;
    createdAt: string;
  } | null;
}

export interface DocumentCompletenessDto {
  mode: string;
  completenessScore: number;
  uploadedCount: number;
  requiredCount: number;
  missingDocuments: string[];
  dimensionConfidence: Record<string, number>;
}

export interface DocumentChecklistResponse extends DocumentCompletenessDto {
  requirements: DocumentRequirementDto[];
}

export interface UploadedDocumentDto {
  publicId: string;
  docType: string;
  originalName: string;
  mimeType: string;
  sizeBytes: number;
  uploadStatus?: string;
  createdAt: string;
}

// V2 Submission
export interface StartDiagnosisResponse {
  submissionPublicId: string;
  submissionAccessToken: string;
  mode: string;
  status: string;
  createdAt: string;
}

export interface CompleteDiagnosisResponse {
  submissionPublicId: string;
  status: string;
  diagnosisStatus: string;
  reportStatus: string;
  reportPublicId?: string;
  reportAccessToken?: string;
  documentCompletenessScore: number;
  message: string;
}

// Dashboard
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

export interface BusinessDashboard {
  overallScore: number;
  overallLabel: string;
  profitScore: number;
  riskScore: number;
  cashFlowScore: number;
  efficiencyScore: number;
  documentCompletenessScore: number;
  confidenceLevel: string;
  conclusion: string;
  topActions: TopAction[];
  dimensionDetails: DimensionDetail[];
}

// Admin V2
export interface AdminReportDetail {
  reportPublicId: string;
  submissionPublicId: string;
  reportNumber: string;
  riskLevel: string;
  reviewStatus: string;
  customerVisible: boolean;
  htmlContent: string | null;
  diagnosisResult: {
    overallRiskLevel: string;
    dimensionResults: unknown;
  } | null;
  findings: Array<{
    riskLevel: string;
    title: string;
    description: string;
    suggestion: string;
    recommendServices?: unknown;
    dimension?: string | null;
  }>;
  recommendations: Array<{
    serviceType: string;
    reason: string;
    priority: string;
  }>;
  reviewRecords: Array<{
    id: number;
    action: string;
    comment: string | null;
    changes: unknown;
    reviewerName: string;
    createdAt: string;
  }>;
  dashboard: BusinessDashboard | null;
  documentCompleteness: DocumentCompletenessDto | null;
  uploadedDocuments: UploadedDocumentDto[];
  dimensionRuleHits: Record<string, {
    totalRules: number;
    hitRules: number;
    findings: unknown[];
  }>;
}

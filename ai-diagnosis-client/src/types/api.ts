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
}

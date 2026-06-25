import { apiPost } from './client';
import type { StartDiagnosisResponse, CompleteDiagnosisResponse } from '../types/api';

const BASE = '/submissions';

export interface LookupResponse {
  hasExisting: boolean;
  latest: null | {
    submissionPublicId: string;
    status: string;
    mode: string;
    createdAt: string;
    updatedAt: string;
    submissionAccessToken?: string;
    report: null | {
      reportPublicId: string;
      reportNumber: string;
      riskLevel: string;
      reviewStatus: string;
      customerVisible: boolean;
      reportAccessToken: string | null;
    };
  };
  actions: { canContinue: boolean; canViewReport: boolean; canRestart: boolean };
}

export function lookupByPhone(phone: string): Promise<LookupResponse> {
  return apiPost<LookupResponse>(`${BASE}/lookup`, { phone });
}

export function startDiagnosis(phone: string, mode: string): Promise<StartDiagnosisResponse> {
  return apiPost<StartDiagnosisResponse>(`${BASE}/start`, { phone, mode });
}

export function completeDiagnosis(
  publicId: string,
  token: string,
  answers: { questionPublicId: string; value: unknown }[],
): Promise<CompleteDiagnosisResponse> {
  return apiPost<CompleteDiagnosisResponse>(
    `${BASE}/${publicId}/complete`,
    { questionnaireVersion: 'v2', answers },
    { 'X-Submission-Token': token },
  );
}

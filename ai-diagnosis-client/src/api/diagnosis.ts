import { apiPost } from './client';
import type { StartDiagnosisResponse, CompleteDiagnosisResponse } from '../types/api';

const BASE = '/api/submissions';

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

import { apiPost } from './client';
import type { SubmitPayload, SubmitResponse } from '../types/api';

export function submitQuestionnaire(payload: SubmitPayload): Promise<SubmitResponse> {
  return apiPost<SubmitResponse>('/submissions', payload);
}

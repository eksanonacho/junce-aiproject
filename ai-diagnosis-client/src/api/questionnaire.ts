import { apiGet } from './client';
import type { QuestionnaireResponse } from '../types/api';

export function fetchQuestionnaire(): Promise<QuestionnaireResponse> {
  return apiGet<QuestionnaireResponse>('/questionnaire');
}

import { apiGet } from './client';
import type { QuestionnaireResponse } from '../types/api';

export function fetchQuestionnaire(version?: string): Promise<QuestionnaireResponse> {
  const query = version ? `?version=${version}` : '';
  return apiGet<QuestionnaireResponse>(`/questionnaire${query}`);
}

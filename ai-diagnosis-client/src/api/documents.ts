import { apiGet, apiPost, apiDelete } from './client';
import type { DocumentChecklistResponse, UploadedDocumentDto } from '../types/api';

const BASE = '';

export function fetchDocumentChecklist(submissionPublicId: string, token: string): Promise<DocumentChecklistResponse> {
  return apiGet<DocumentChecklistResponse>(
    `${BASE}/submissions/${submissionPublicId}/document-checklist`,
    { 'X-Submission-Token': token },
  );
}

export function uploadDocument(
  submissionPublicId: string,
  token: string,
  docType: string,
  file: File,
): Promise<UploadedDocumentDto> {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('docType', docType);
  return apiPost<UploadedDocumentDto>(
    `${BASE}/submissions/${submissionPublicId}/documents`,
    formData,
    { 'X-Submission-Token': token },
    true, // isFormData
  );
}

export function fetchDocuments(submissionPublicId: string, token: string): Promise<UploadedDocumentDto[]> {
  return apiGet<UploadedDocumentDto[]>(
    `${BASE}/submissions/${submissionPublicId}/documents`,
    { 'X-Submission-Token': token },
  );
}

export function deleteDocument(submissionPublicId: string, token: string, documentPublicId: string): Promise<{ success: boolean }> {
  return apiDelete<{ success: boolean }>(
    `${BASE}/submissions/${submissionPublicId}/documents/${documentPublicId}`,
    { 'X-Submission-Token': token },
  );
}

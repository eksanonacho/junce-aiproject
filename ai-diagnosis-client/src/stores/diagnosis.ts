import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { startDiagnosis as apiStartDiagnosis, completeDiagnosis as apiCompleteDiagnosis, lookupByPhone as apiLookupByPhone, type LookupResponse } from '../api/diagnosis';
import { fetchDocumentChecklist, uploadDocument, deleteDocument } from '../api/documents';
import type { DocumentChecklistResponse, UploadedDocumentDto } from '../types/api';

export const useDiagnosisStore = defineStore('diagnosis', () => {
  // State
  const mode = ref<string>('STANDARD');
  const phone = ref<string>('');
  const submissionPublicId = ref<string>('');
  const submissionAccessToken = ref<string>('');
  const step = ref<'start' | 'upload' | 'questionnaire' | 'complete'>('start');
  const checklist = ref<DocumentChecklistResponse | null>(null);
  const documents = ref<UploadedDocumentDto[]>([]);
  const completenessScore = ref<number>(0);
  const reportPublicId = ref<string>('');
  const reportAccessToken = ref<string>('');
  const diagnosisStatus = ref<string>('');
  const reportStatus = ref<string>('');
  const error = ref<string>('');
  const lookupResult = ref<LookupResponse | null>(null);

  // Getters
  const hasSubmission = computed(() => !!submissionPublicId.value);
  const isQuickMode = computed(() => mode.value === 'QUICK');
  const isStandardMode = computed(() => mode.value === 'STANDARD');
  const missingDocuments = computed(() => checklist.value?.missingDocuments || []);

  // Actions
  async function startDiagnosis(p: string, m: string) {
    error.value = '';
    try {
      phone.value = p;
      mode.value = m;
      const result = await apiStartDiagnosis(p, m);
      submissionPublicId.value = result.submissionPublicId;
      submissionAccessToken.value = result.submissionAccessToken;
      step.value = 'upload';
      // Persist token in sessionStorage
      sessionStorage.setItem('v2_submission_token', result.submissionAccessToken);
      sessionStorage.setItem('v2_submission_id', result.submissionPublicId);
      return result;
    } catch (e: any) {
      error.value = e.message || '创建诊断失败';
      throw e;
    }
  }

  async function loadChecklist() {
    if (!submissionPublicId.value || !submissionAccessToken.value) return;
    try {
      checklist.value = await fetchDocumentChecklist(submissionPublicId.value, submissionAccessToken.value);
      completenessScore.value = checklist.value.completenessScore;
    } catch (e: any) {
      error.value = e.message || '加载资料清单失败';
    }
  }

  async function uploadDoc(docType: string, file: File) {
    if (!submissionPublicId.value || !submissionAccessToken.value) return;
    try {
      const doc = await uploadDocument(submissionPublicId.value, submissionAccessToken.value, docType, file);
      documents.value.push(doc);
      await loadChecklist(); // Refresh checklist after upload
      return doc;
    } catch (e: any) {
      error.value = e.message || '上传失败';
      throw e;
    }
  }

  async function removeDoc(documentPublicId: string) {
    if (!submissionPublicId.value || !submissionAccessToken.value) return;
    try {
      await deleteDocument(submissionPublicId.value, submissionAccessToken.value, documentPublicId);
      documents.value = documents.value.filter((d) => d.publicId !== documentPublicId);
      await loadChecklist();
    } catch (e: any) {
      error.value = e.message || '删除失败';
      throw e;
    }
  }

  async function completeDiagnosis(answers: { questionPublicId: string; value: unknown }[]) {
    error.value = '';
    try {
      const result = await apiCompleteDiagnosis(submissionPublicId.value, submissionAccessToken.value, answers);
      diagnosisStatus.value = result.diagnosisStatus;
      reportStatus.value = result.reportStatus;
      reportPublicId.value = result.reportPublicId || '';
      reportAccessToken.value = result.reportAccessToken || '';
      step.value = 'complete';
      return result;
    } catch (e: any) {
      error.value = e.message || '提交失败';
      throw e;
    }
  }

  async function lookup(p: string) {
    error.value = '';
    phone.value = p;
    try {
      lookupResult.value = await apiLookupByPhone(p);
      return lookupResult.value;
    } catch (e: any) {
      error.value = e.message || '查询失败';
      throw e;
    }
  }

  function continueExisting(sid: string, token: string, m: string) {
    submissionPublicId.value = sid;
    submissionAccessToken.value = token;
    mode.value = m || 'STANDARD';
    step.value = 'upload';
    sessionStorage.setItem('v2_submission_token', token);
    sessionStorage.setItem('v2_submission_id', sid);
    lookupResult.value = null;
  }

  function viewExistingReport(rpid: string, reportToken: string) {
    reportPublicId.value = rpid;
    reportAccessToken.value = reportToken;
  }

  function resetLookup() {
    lookupResult.value = null;
    error.value = '';
  }

  function restoreFromSession() {
    const token = sessionStorage.getItem('v2_submission_token');
    const sid = sessionStorage.getItem('v2_submission_id');
    if (token && sid) {
      submissionAccessToken.value = token;
      submissionPublicId.value = sid;
    }
  }

  return {
    mode, phone, submissionPublicId, submissionAccessToken, step,
    checklist, documents, completenessScore,
    reportPublicId, reportAccessToken, diagnosisStatus, reportStatus, error, lookupResult,
    hasSubmission, isQuickMode, isStandardMode, missingDocuments,
    startDiagnosis, loadChecklist, uploadDoc, removeDoc, completeDiagnosis, restoreFromSession,
    lookup, continueExisting, viewExistingReport, resetLookup,
  };
});

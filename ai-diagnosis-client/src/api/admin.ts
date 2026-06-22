const BASE = '/api/admin';

function getToken(): string {
  return localStorage.getItem('admin_token') || '';
}

function authHeaders(): Record<string, string> {
  return { Authorization: `Bearer ${getToken()}`, 'Content-Type': 'application/json' };
}

async function apiGet<T>(path: string): Promise<T> {
  const res = await fetch(`${BASE}${path}`, { headers: authHeaders() });
  if (res.status === 401) { localStorage.removeItem('admin_token'); window.location.href = '/admin/login'; throw new Error('Unauthorized'); }
  if (!res.ok) { const err = await res.json().catch(() => ({ message: res.statusText })); throw err; }
  return res.json();
}

async function apiPost<T>(path: string, body?: unknown): Promise<T> {
  const res = await fetch(`${BASE}${path}`, { method: 'POST', headers: authHeaders(), body: body ? JSON.stringify(body) : undefined });
  if (res.status === 401) { localStorage.removeItem('admin_token'); window.location.href = '/admin/login'; throw new Error('Unauthorized'); }
  if (!res.ok) { const err = await res.json().catch(() => ({ message: res.statusText })); throw err; }
  return res.json();
}

async function apiPatch<T>(path: string, body: unknown): Promise<T> {
  const res = await fetch(`${BASE}${path}`, { method: 'PATCH', headers: authHeaders(), body: JSON.stringify(body) });
  if (res.status === 401) { localStorage.removeItem('admin_token'); window.location.href = '/admin/login'; throw new Error('Unauthorized'); }
  if (!res.ok) { const err = await res.json().catch(() => ({ message: res.statusText })); throw err; }
  return res.json();
}

export interface LoginResult { accessToken: string; user: { id: number; username: string; realName: string; role: string }; }
export interface SubmissionItem { submissionPublicId: string; reportPublicId: string; submittedAt: string | null; phoneMasked: string; overallRiskLevel: string; reviewStatus: string; customerVisible: boolean; findingCount: number; recommendationCount: number; }
export interface ListResult { items: SubmissionItem[]; page: number; pageSize: number; total: number; }
export interface ReportDetail { reportPublicId: string; submissionPublicId: string; reportNumber: string; riskLevel: string; reviewStatus: string; customerVisible: boolean; htmlContent: string | null; findings: unknown[]; recommendations: unknown[]; reviewRecords: unknown[]; }

export function login(username: string, password: string) {
  return fetch(`${BASE}/auth/login`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ username, password }) })
    .then(r => r.ok ? r.json() : r.json().then(e => { throw e; }));
}

export function getSubmissions(params?: Record<string, string>) {
  const qs = params ? '?' + new URLSearchParams(params).toString() : '';
  return apiGet<ListResult>(`/submissions${qs}`);
}

export function getReportDetail(publicId: string) {
  return apiGet<ReportDetail>(`/reports/${publicId}`);
}

export function reviewReport(publicId: string, action: string, comment?: string) {
  return apiPost(`/reports/${publicId}/review`, { action, comment });
}

export function updateReport(publicId: string, body: Record<string, unknown>) {
  return apiPatch(`/reports/${publicId}`, body);
}

export function getUser() {
  try { return JSON.parse(localStorage.getItem('admin_user') || 'null'); } catch { return null; }
}
export function saveAuth(token: string, user: unknown) {
  localStorage.setItem('admin_token', token);
  localStorage.setItem('admin_user', JSON.stringify(user));
}
export function clearAuth() {
  localStorage.removeItem('admin_token');
  localStorage.removeItem('admin_user');
}

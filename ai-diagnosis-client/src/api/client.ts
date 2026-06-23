const BASE_URL = '/api';

export async function apiGet<T>(path: string, extraHeaders?: Record<string, string>): Promise<T> {
  const headers: Record<string, string> = { ...extraHeaders };
  const res = await fetch(`${BASE_URL}${path}`, { headers });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ code: 'UNKNOWN', message: res.statusText }));
    throw err;
  }
  return res.json();
}

export async function apiPost<T>(
  path: string,
  body: unknown,
  extraHeaders?: Record<string, string>,
  isFormData?: boolean,
): Promise<T> {
  const headers: Record<string, string> = { ...extraHeaders };
  const options: RequestInit = { method: 'POST', headers };

  if (isFormData) {
    // FormData — let browser set Content-Type with boundary
    delete headers['Content-Type'];
    (options as any).body = body as FormData;
  } else {
    headers['Content-Type'] = 'application/json';
    (options as any).body = JSON.stringify(body);
  }

  const res = await fetch(`${BASE_URL}${path}`, options);
  if (!res.ok) {
    const err = await res.json().catch(() => ({ code: 'UNKNOWN', message: res.statusText }));
    throw err;
  }
  return res.json();
}

export async function apiDelete<T>(path: string, extraHeaders?: Record<string, string>): Promise<T> {
  const headers: Record<string, string> = { ...extraHeaders };
  const res = await fetch(`${BASE_URL}${path}`, { method: 'DELETE', headers });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ code: 'UNKNOWN', message: res.statusText }));
    throw err;
  }
  return res.json();
}

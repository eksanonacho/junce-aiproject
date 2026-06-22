import { apiGet } from './client';
import type { ReportStatus, ReportDetail } from '../types/api';

export function getReportStatus(publicId: string): Promise<ReportStatus> {
  return apiGet<ReportStatus>(`/reports/${publicId}/status`);
}

export function getReport(publicId: string, token: string): Promise<ReportDetail> {
  return apiGet<ReportDetail>(`/reports/${publicId}?token=${encodeURIComponent(token)}`);
}

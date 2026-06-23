import { defineStore } from 'pinia';
import { ref } from 'vue';
import { getReport } from '../api/reports';
import type { ReportDetail, BusinessDashboard } from '../types/api';

export const useReportStore = defineStore('report', () => {
  const report = ref<ReportDetail | null>(null);
  const dashboard = ref<BusinessDashboard | null>(null);
  const loading = ref(false);
  const error = ref('');

  async function fetchReport(publicId: string, token: string) {
    loading.value = true;
    error.value = '';
    try {
      report.value = await getReport(publicId, token);
      dashboard.value = report.value?.dashboard || null;
      return report.value;
    } catch (e: any) {
      error.value = e.message || '加载报告失败';
      throw e;
    } finally {
      loading.value = false;
    }
  }

  return { report, dashboard, loading, error, fetchReport };
});

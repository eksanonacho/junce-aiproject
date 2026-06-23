<template>
  <div class="min-h-screen bg-[#F2F5FC] print:bg-white">
    <!-- Loading -->
    <div v-if="loading" class="flex items-center justify-center min-h-screen text-slate-500">
      加载报告中...
    </div>

    <!-- Error -->
    <div v-else-if="error" class="flex flex-col items-center justify-center min-h-screen gap-4">
      <p class="text-red-500">{{ error }}</p>
      <router-link to="/" class="text-[#1E3A8A] hover:underline">返回首页</router-link>
    </div>

    <!-- PENDING_REVIEW -->
    <div v-else-if="isPendingReview" class="flex items-center justify-center min-h-screen">
      <div class="max-w-md mx-4 bg-white rounded-2xl p-8 border border-amber-200 shadow-lg text-center">
        <div class="text-4xl mb-4">⏳</div>
        <h2 class="text-xl font-bold text-slate-900 mb-2">报告待复核</h2>
        <p class="text-slate-600 mb-4">{{ pendingMessage }}</p>
        <p class="text-xs text-slate-400">如有疑问请联系君册财税顾问</p>
      </div>
    </div>

    <!-- Full Report -->
    <div v-else-if="report" class="max-w-4xl mx-auto px-4 py-6">
      <!-- Print button -->
      <div class="flex justify-end mb-4 no-print">
        <button @click="printReport" class="px-4 py-2 rounded-xl bg-[#1E3A8A] text-white text-sm hover:bg-[#1E40AF] transition">
          🖨 打印 / 保存PDF
        </button>
      </div>

      <!-- Section 1: Overview -->
      <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm mb-4">
        <h1 class="text-xl font-bold text-slate-900">{{ report.title || '君册财税·企业初诊报告' }}</h1>
        <div class="flex flex-wrap gap-2 mt-2 text-sm text-slate-500">
          <span>报告编号：{{ report.reportNumber }}</span>
          <span class="px-2 py-0.5 rounded text-xs font-medium" :class="riskBadgeClass(report.riskLevel)">{{ riskLabel(report.riskLevel) }}</span>
          <span>{{ report.generatedAt?.slice(0, 10) }}</span>
        </div>
      </div>

      <!-- Section 2: Four-Dimension Dashboard -->
      <div class="mb-4" v-if="report.dashboard">
        <h2 class="text-lg font-bold text-slate-900 mb-3">📊 四维经营看板</h2>
        <BusinessDashboard :dashboard="report.dashboard" />
      </div>

      <!-- Section 3: Document Completeness -->
      <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm mb-4" v-if="report.documentCompleteness">
        <h3 class="font-semibold text-slate-900 mb-3">📄 资料完整度</h3>
        <div class="flex items-center gap-4">
          <div class="text-3xl font-bold text-[#1E3A8A]">{{ report.documentCompleteness.completenessScore }}%</div>
          <div class="text-sm text-slate-500">
            <p>已上传 {{ report.documentCompleteness.uploadedCount }} / {{ report.documentCompleteness.requiredCount }} 类必传资料</p>
            <p v-if="report.documentCompleteness.missingDocuments.length" class="text-amber-600">
              缺失：{{ report.documentCompleteness.missingDocuments.join('、') }}
            </p>
          </div>
        </div>
      </div>

      <!-- Section 4: Company Profile -->
      <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm mb-4">
        <h3 class="font-semibold text-slate-900 mb-3">📋 企业信息摘要</h3>
        <div class="grid grid-cols-2 gap-2 text-sm" v-if="report.companyProfile">
          <div v-for="(val, key) in report.companyProfile" :key="key" class="flex gap-1">
            <span class="text-slate-400 shrink-0">{{ key }}：</span>
            <span class="text-slate-700">{{ val }}</span>
          </div>
        </div>
        <p class="text-sm text-slate-600 mt-2" v-if="report.summary">{{ report.summary }}</p>
      </div>

      <!-- Section 5: Risk Findings -->
      <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm mb-4" v-if="report.findings?.length">
        <h3 class="font-semibold text-slate-900 mb-3">⚠️ 风险发现 ({{ report.findings.length }})</h3>
        <div class="space-y-3">
          <div v-for="(f, i) in report.findings" :key="i" class="p-3 rounded-xl border-l-4" :class="findingBorder(f.riskLevel)">
            <div class="flex items-center gap-2 mb-1">
              <span class="px-2 py-0.5 rounded text-xs font-medium" :class="riskBadgeClass(f.riskLevel)">{{ riskLabel(f.riskLevel) }}</span>
              <span class="font-medium text-slate-900">{{ f.title }}</span>
            </div>
            <p class="text-sm text-slate-600">{{ f.description }}</p>
            <p class="text-sm text-blue-700 mt-1" v-if="f.suggestion">💡 {{ f.suggestion }}</p>
          </div>
        </div>
      </div>

      <!-- Section 6: TOP3 Actions -->
      <div class="mb-4" v-if="report.dashboard?.topActions?.length">
        <TopActions :actions="report.dashboard.topActions" />
      </div>

      <!-- Section 7: Service Recommendations -->
      <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm mb-4" v-if="report.recommendations?.length">
        <h3 class="font-semibold text-slate-900 mb-3">💼 君册服务建议</h3>
        <div class="space-y-2">
          <div v-for="(r, i) in report.recommendations" :key="i" class="flex items-center gap-3 p-2 rounded-lg bg-slate-50">
            <span class="text-xs px-2 py-0.5 rounded-full font-medium" :class="priorityBadge(r.priority)">{{ priorityLabel(r.priority) }}</span>
            <span class="font-medium text-slate-900">{{ r.serviceType }}</span>
            <span class="text-sm text-slate-500">— {{ r.reason }}</span>
          </div>
        </div>
      </div>

      <!-- Section 8: Review Status -->
      <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm mb-4">
        <h3 class="font-semibold text-slate-900 mb-2">🔍 复核状态</h3>
        <p class="text-sm text-slate-600">{{ reviewLabel }}</p>
      </div>

      <!-- Section 9: Disclaimer -->
      <div class="bg-amber-50 rounded-2xl p-5 border border-amber-200 mb-4">
        <p class="text-xs text-amber-800 whitespace-pre-wrap">{{ report.disclaimer }}</p>
      </div>

      <p class="text-xs text-slate-400 text-center pb-8">君册财税 · 企业经营初诊系统 · 咨询请联系君册顾问</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { getReport } from '../api/reports';
import type { ReportDetail } from '../types/api';
import BusinessDashboard from '../components/report/BusinessDashboard.vue';
import TopActions from '../components/report/TopActions.vue';

const route = useRoute();
const report = ref<ReportDetail | null>(null);
const loading = ref(true);
const error = ref('');

const publicId = route.params.publicId as string;
const token = route.query.token as string;

const isPendingReview = computed(() => {
  return report.value && (report.value as any).status === 'PENDING_REVIEW';
});

const pendingMessage = computed(() => {
  return (report.value as any)?.message || '您的初诊结果正在由君册专业人员复核，复核完成后将展示完整报告。';
});

const reviewLabel = computed(() => {
  const s = report.value?.reviewStatus;
  const map: Record<string, string> = {
    AUTO_RELEASED: '系统自动发布（低风险）',
    NEED_REVIEW: '待专业人员复核',
    REVIEWED: '已复核通过',
    REJECTED: '已驳回',
  };
  return map[s || ''] || s || '未知';
});

function riskBadgeClass(level: string): string {
  const map: Record<string, string> = {
    HIGH: 'bg-red-100 text-red-700',
    MEDIUM: 'bg-amber-100 text-amber-700',
    LOW: 'bg-green-100 text-green-700',
    UNKNOWN: 'bg-slate-100 text-slate-600',
  };
  return map[level] || '';
}

function riskLabel(level: string): string {
  const map: Record<string, string> = {
    HIGH: '高风险', MEDIUM: '中风险', LOW: '低风险', UNKNOWN: '未知',
  };
  return map[level] || level;
}

function findingBorder(level: string): string {
  const map: Record<string, string> = {
    HIGH: 'border-red-400 bg-red-50/30',
    MEDIUM: 'border-amber-400 bg-amber-50/30',
    LOW: 'border-green-400 bg-green-50/30',
  };
  return map[level] || 'border-slate-300 bg-slate-50';
}

function priorityBadge(p: string): string {
  const map: Record<string, string> = {
    STRONG: 'bg-red-100 text-red-700',
    SUGGEST: 'bg-blue-100 text-blue-700',
    INFO: 'bg-slate-100 text-slate-600',
  };
  return map[p] || '';
}

function priorityLabel(p: string): string {
  const map: Record<string, string> = {
    STRONG: '强烈推荐', SUGGEST: '建议关注', INFO: '可了解',
  };
  return map[p] || p;
}

function printReport() {
  window.print();
}

onMounted(async () => {
  if (!token) {
    error.value = '缺少访问令牌';
    loading.value = false;
    return;
  }
  try {
    report.value = await getReport(publicId, token);
  } catch (e: any) {
    error.value = e.message || '加载报告失败';
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
@media print {
  .no-print { display: none !important; }
}
</style>

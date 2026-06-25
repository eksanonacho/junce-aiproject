<template>
  <div class="min-h-screen" style="background: linear-gradient(180deg, #F1F5F9 0%, #F8FAFC 100%);">
    <div class="max-w-lg mx-auto px-4 py-12 md:py-20">
      <!-- Success header -->
      <div class="text-center mb-8">
        <div class="w-16 h-16 rounded-2xl bg-green-100 flex items-center justify-center mx-auto mb-4">
          <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7"/></svg>
        </div>
        <h1 class="text-[22px] font-extrabold text-[#0F172A] tracking-tight">提交成功</h1>
        <p v-if="isV2 && v2Mode" class="text-[14px] text-slate-500 mt-1">{{ modeLabel }}</p>
      </div>

      <!-- V2: Process Flow -->
      <div v-if="isV2" class="bg-white rounded-2xl border border-[#E2E8F0] shadow-sm px-5 py-4 mb-6">
        <div class="flex items-center justify-between">
          <div v-for="(step, i) in progressSteps" :key="i" class="flex flex-col items-center flex-1">
            <div class="w-7 h-7 rounded-full flex items-center justify-center text-[11px] font-bold"
              :class="step.done ? 'bg-green-500 text-white' : step.active ? 'bg-[#1E3A8A] text-white' : 'bg-slate-100 text-slate-400'">
              {{ step.done ? '&#10003;' : i + 1 }}
            </div>
            <span class="text-[10px] mt-1 text-center leading-tight"
              :class="step.done ? 'text-green-600 font-medium' : step.active ? 'text-[#0F172A] font-semibold' : 'text-slate-400'">
              {{ step.label }}
            </span>
          </div>
        </div>
      </div>

      <!-- Status cards -->
      <div class="space-y-3 mb-6">
        <!-- V2 doc completeness -->
        <div v-if="isV2 && docCompletenessScore" class="bg-white rounded-2xl border border-[#E2E8F0] px-4 py-3 flex items-center justify-between">
          <span class="text-[13px] text-slate-600">资料完整度</span>
          <span class="text-[14px] font-bold" :class="docScoreColor">{{ docCompletenessScore }}%</span>
        </div>

        <!-- Diagnosis status -->
        <div class="bg-white rounded-2xl border border-[#E2E8F0] px-4 py-3 flex items-center justify-between">
          <span class="text-[13px] text-slate-600">系统初筛</span>
          <span class="text-[13px] font-semibold" :class="statusColor.replace('bg-','text-').replace('-50','-600').replace('border-','')">{{ statusLabel }}</span>
        </div>

        <!-- Report status -->
        <div v-if="reportStatus === 'READY'" class="bg-white rounded-2xl border border-green-200 px-4 py-3 flex items-center justify-between">
          <span class="text-[13px] text-slate-600">报告生成</span>
          <span class="text-[13px] font-semibold text-green-600">已完成</span>
        </div>

        <!-- PENDING_REVIEW hint -->
        <div v-if="isV2 && !showReportButton && reportStatus === 'READY'" class="bg-amber-50 border border-amber-200 rounded-2xl px-4 py-4">
          <p class="text-[14px] font-semibold text-amber-800 mb-1">初诊已完成，报告进入专业复核</p>
          <p class="text-[12px] text-amber-700 leading-relaxed">涉及高风险或资料不完整时，君册人员将复核后展示完整报告。复核通常需要1个工作日。</p>
        </div>
      </div>

      <!-- Submission ID -->
      <div class="bg-slate-50 rounded-xl px-4 py-3 mb-6">
        <p class="text-[11px] text-slate-400 mb-0.5">提交编号</p>
        <p class="text-[12px] text-slate-600 font-mono break-all">{{ submissionPublicId }}</p>
      </div>

      <!-- CTA -->
      <router-link
        v-if="showReportButton"
        :to="reportUrl"
        class="block w-full text-center py-3.5 rounded-xl bg-[#0F172A] text-white font-semibold text-[15px] hover:bg-[#1E293B] transition shadow-lg shadow-slate-900/10 mb-3"
      >查看企业经营初诊报告</router-link>

      <p v-if="showReportButton" class="text-[11px] text-slate-400 text-center mb-6 leading-relaxed">
        本报告为初步筛查参考，不构成最终专业意见。
      </p>

      <router-link to="/" class="block text-center py-3 rounded-xl border border-slate-300 text-[14px] text-slate-600 hover:bg-slate-50 transition font-medium">
        返回首页
      </router-link>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const submissionPublicId = (route.query.submissionPublicId as string) || '';
const diagnosisStatus = (route.query.diagnosisStatus as string) || '';
const reportStatus = (route.query.reportStatus as string) || '';
const reportPublicId = (route.query.reportPublicId as string) || '';
const reportAccessToken = (route.query.reportAccessToken as string) || '';

const isV2 = route.query.v2 === 'true';
const v2Mode = (route.query.mode as string) || '';
const docCompletenessScore = (route.query.documentCompletenessScore as string) || '';

const modeLabel = computed(() => {
  const map: Record<string, string> = { QUICK: '快速初诊', STANDARD: '标准初诊', DEEP: '深度经营出诊' };
  return map[v2Mode] || v2Mode;
});

const statusLabel = computed(() => {
  switch (diagnosisStatus) {
    case 'COMPLETED': return '已完成';
    case 'FAILED': return '未通过';
    default: return '处理中';
  }
});
const statusColor = computed(() => {
  switch (diagnosisStatus) {
    case 'COMPLETED': return 'text-green-600 bg-green-50 border-green-200';
    case 'FAILED': return 'text-red-600 bg-red-50 border-red-200';
    default: return 'text-amber-600 bg-amber-50 border-amber-200';
  }
});

const showReportButton = computed(() => reportStatus === 'READY' && reportPublicId && reportAccessToken);
const reportUrl = computed(() => `/report/${reportPublicId}?token=${encodeURIComponent(reportAccessToken || '')}`);

const docScoreColor = computed(() => {
  const s = parseInt(docCompletenessScore) || 0;
  return s >= 70 ? 'text-green-600' : s >= 40 ? 'text-amber-600' : 'text-red-600';
});

const progressSteps = computed(() => [
  { label: '资料提交', done: true, active: false },
  { label: '问卷完成', done: true, active: false },
  { label: '系统初筛', done: diagnosisStatus === 'COMPLETED', active: diagnosisStatus !== 'COMPLETED' && diagnosisStatus !== 'FAILED' },
  { label: '专业复核', done: reportStatus === 'READY' && !!reportPublicId, active: false },
  { label: '报告开放', done: !!showReportButton.value, active: false },
]);
</script>

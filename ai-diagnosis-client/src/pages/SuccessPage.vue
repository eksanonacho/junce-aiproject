<template>
  <div class="success-shell min-h-screen overflow-x-hidden text-[#1A1A1A] flex flex-col">
    <header class="fixed top-0 left-0 w-full z-50 h-20 bg-[#FFF8F3]/86 backdrop-blur-xl border-b border-[#D8C5A8]/35 shadow-[0_8px_28px_rgba(53,48,39,0.05)]">
      <div class="max-w-[1280px] mx-auto px-5 md:px-10 h-full flex items-center justify-between">
        <JcBrand />
        <div class="hidden md:flex items-center gap-8">
          <span class="text-[13px] font-semibold text-[#817563]">提交编号: {{ shortSubmissionId }}</span>
          <router-link to="/" class="text-[13px] font-bold text-[#5E5548] hover:text-[#785600] transition">返回首页</router-link>
        </div>
      </div>
    </header>

    <main class="flex-grow max-w-[1180px] mx-auto w-full px-5 md:px-10 pt-32 pb-20">
      <section class="text-center mb-14">
        <div class="relative inline-flex mb-7">
          <div class="absolute inset-0 rounded-full bg-[#785600]/18 success-pulse"></div>
          <div class="relative w-24 h-24 rounded-full bg-[#785600] text-white flex items-center justify-center shadow-[0_24px_60px_rgba(120,86,0,0.24)]">
            <JcIcon name="success" :size="52" color="#fff" />
          </div>
        </div>
        <h1 class="text-[42px] md:text-[58px] font-extrabold tracking-tight text-[#785600] mb-4">诊断已提交</h1>
        <p class="text-[15px] md:text-[18px] leading-8 text-[#5E5548] max-w-2xl mx-auto">
          您的企业经营信息已提交。系统已完成初步处理，后续将根据风险等级和复核策略展示报告状态。
        </p>
      </section>

      <section v-if="isV2" class="max-w-4xl mx-auto mb-14 px-3">
        <div class="relative flex justify-between items-start">
          <div class="absolute top-5 left-0 w-full h-px bg-[#D8C5A8]/55"></div>
          <div class="absolute top-5 left-0 h-px bg-[#785600] transition-all duration-700" :style="{ width: progressLineWidth }"></div>
          <div v-for="step in progressSteps" :key="step.label" class="relative z-[1] flex flex-col items-center gap-3 flex-1">
            <div class="progress-dot" :class="step.done ? 'done' : step.active ? 'active' : ''">
              <JcIcon :name="step.icon" :size="18" :color="step.done || step.active ? '#fff' : '#9A8C7A'" />
            </div>
            <span class="text-[12px] font-bold" :class="step.done || step.active ? 'text-[#785600]' : 'text-[#9A8C7A]'">{{ step.label }}</span>
          </div>
        </div>
      </section>

      <section class="grid grid-cols-1 md:grid-cols-12 gap-6 max-w-6xl mx-auto">
        <article class="md:col-span-6 success-card">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-[24px] font-extrabold">数据完整性</h2>
            <span class="status-pill green">{{ docCompletenessScore ? '已记录' : '已提交' }}</span>
          </div>
          <div class="flex items-end gap-4 mb-6">
            <div class="text-[52px] leading-none font-extrabold text-[#785600]">{{ docCompletenessScore || '--' }}<span v-if="docCompletenessScore" class="text-[26px]">%</span></div>
            <div class="text-[13px] font-semibold text-[#817563] pb-2">{{ docCompletenessScore ? '资料完整度' : '等待评估' }}</div>
          </div>
          <div class="h-2 rounded-full bg-[#ECE1D4] overflow-hidden mb-7">
            <div class="h-full rounded-full bg-[#785600]" :style="{ width: docCompletenessScore ? `${docCompletenessScore}%` : '36%' }"></div>
          </div>
          <div class="space-y-3 text-[14px] text-[#5E5548]">
            <p class="flex items-center gap-3"><JcIcon name="success" :size="17" color="#2F6B48" />资料与问卷信息已进入初筛流程。</p>
            <p class="flex items-center gap-3"><JcIcon name="secure" :size="17" color="#2F6B48" />报告展示将遵守复核与客户可见门控。</p>
          </div>
        </article>

        <article class="md:col-span-6 success-card">
          <div class="flex items-center justify-between mb-6">
            <h2 class="text-[24px] font-extrabold">初筛矩阵</h2>
            <span class="status-pill" :class="diagnosisStatus === 'COMPLETED' ? 'green' : diagnosisStatus === 'FAILED' ? 'red' : 'amber'">{{ statusLabel }}</span>
          </div>
          <div class="grid grid-cols-2 gap-4 mb-6">
            <div class="metric-box">
              <div class="text-[11px] font-bold text-[#817563] uppercase mb-1">系统初筛</div>
              <div class="text-[24px] font-extrabold" :class="diagnosisStatus === 'FAILED' ? 'text-[#9F1D1D]' : 'text-[#785600]'">{{ statusLabel }}</div>
            </div>
            <div class="metric-box">
              <div class="text-[11px] font-bold text-[#817563] uppercase mb-1">报告状态</div>
              <div class="text-[24px] font-extrabold" :class="showReportButton ? 'text-[#2F6B48]' : 'text-[#B8860B]'">{{ reportStatus === 'READY' ? '已生成' : '处理中' }}</div>
            </div>
          </div>
          <p class="text-[14px] leading-7 text-[#5E5548] mb-5">
            {{ showReportButton ? '报告已完成并开放查看。' : '如涉及高风险或资料需要进一步确认，君册专业人员将复核后展示完整报告。' }}
          </p>
          <div class="flex items-center gap-2 text-[#785600] font-bold text-[13px]">
            <span class="w-2 h-2 rounded-full bg-[#785600]"></span>
            <span>{{ showReportButton ? '报告已开放' : '正在确认风险计算与复核状态' }}</span>
          </div>
        </article>

        <article class="md:col-span-12 action-card">
          <div class="max-w-2xl">
            <h2 class="text-[28px] font-extrabold text-[#785600] mb-3">下一步操作</h2>
            <p class="text-[14px] md:text-[15px] leading-8 text-[#5E5548]">
              {{ showReportButton ? '您可以查看本次企业经营初诊报告。报告仅用于初步筛查参考，具体事项仍建议结合完整资料复核。' : '自动化初筛已提交，等待报告开放或专业复核完成。复核状态可通过报告页查看。' }}
            </p>
            <div v-if="isV2 && !showReportButton && reportStatus === 'READY'" class="review-box">
              <strong>专业复核中</strong>
              <span>完整报告将在复核通过后展示。</span>
            </div>
          </div>
          <div class="flex flex-col gap-3 w-full md:w-auto">
            <router-link v-if="showReportButton" :to="reportUrl" class="action-primary">查看企业经营初诊报告</router-link>
            <router-link to="/" class="action-secondary">返回首页</router-link>
          </div>
        </article>
      </section>

      <section class="mt-8 max-w-6xl mx-auto rounded-2xl bg-[#FFF8F3]/62 border border-[#D8C5A8]/55 px-5 py-4">
        <p class="text-[11px] text-[#817563] leading-6 break-all">提交编号：{{ submissionPublicId || '-' }}</p>
      </section>
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import JcBrand from '../components/common/JcBrand.vue';
import JcIcon from '../components/ui/JcIcon.vue';

const route = useRoute();
const submissionPublicId = (route.query.submissionPublicId as string) || '';
const diagnosisStatus = (route.query.diagnosisStatus as string) || '';
const reportStatus = (route.query.reportStatus as string) || '';
const reportPublicId = (route.query.reportPublicId as string) || '';
const reportAccessToken = (route.query.reportAccessToken as string) || '';

const isV2 = route.query.v2 === 'true';
const docCompletenessScore = (route.query.documentCompletenessScore as string) || '';

const shortSubmissionId = computed(() => submissionPublicId ? `${submissionPublicId.slice(0, 8)}...` : '-');

const statusLabel = computed(() => {
  switch (diagnosisStatus) {
    case 'COMPLETED': return '已完成';
    case 'FAILED': return '未通过';
    default: return '处理中';
  }
});

const showReportButton = computed(() => reportStatus === 'READY' && reportPublicId && reportAccessToken);
const reportUrl = computed(() => `/report/${reportPublicId}?token=${encodeURIComponent(reportAccessToken || '')}`);

const progressSteps = computed(() => [
  { label: '数据', icon: 'report', done: true, active: false },
  { label: '问卷', icon: 'process', done: true, active: false },
  { label: '初筛', icon: 'search', done: diagnosisStatus === 'COMPLETED', active: diagnosisStatus !== 'COMPLETED' && diagnosisStatus !== 'FAILED' },
  { label: '审核', icon: 'review', done: reportStatus === 'READY' && !!reportPublicId, active: reportStatus === 'READY' && !showReportButton.value },
  { label: '开放', icon: 'success', done: !!showReportButton.value, active: false },
]);

const progressLineWidth = computed(() => {
  const doneCount = progressSteps.value.filter(s => s.done).length;
  return `${Math.max(0, (doneCount - 1) / 4 * 100)}%`;
});
</script>

<style scoped>
.success-shell {
  background:
    radial-gradient(circle at 50% 8%, rgba(184, 134, 11, 0.10), transparent 32%),
    linear-gradient(180deg, #fff8f3 0%, #faf8f4 55%, #f3ede3 100%);
}

.success-pulse {
  animation: success-pulse 2.2s ease-in-out infinite;
}

@keyframes success-pulse {
  0%, 100% { transform: scale(1); opacity: 0.55; }
  50% { transform: scale(1.35); opacity: 0.12; }
}

.progress-dot {
  width: 42px;
  height: 42px;
  border-radius: 999px;
  background: #ece1d4;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 4px solid #fff8f3;
}

.progress-dot.done,
.progress-dot.active {
  background: #785600;
  box-shadow: 0 14px 30px rgba(120, 86, 0, 0.20);
}

.progress-dot.active {
  transform: scale(1.12);
}

.success-card,
.action-card {
  border: 1px solid rgba(216, 197, 168, 0.56);
  border-radius: 24px;
  background: rgba(255, 253, 250, 0.80);
  box-shadow: 0 20px 55px rgba(53, 48, 39, 0.07);
  backdrop-filter: blur(18px);
  padding: 32px;
}

.status-pill {
  border-radius: 999px;
  padding: 5px 11px;
  font-size: 11px;
  font-weight: 800;
}

.status-pill.green {
  background: rgba(47, 107, 72, 0.12);
  color: #2f6b48;
}

.status-pill.amber {
  background: rgba(184, 134, 11, 0.12);
  color: #785600;
}

.status-pill.red {
  background: rgba(159, 29, 29, 0.10);
  color: #9f1d1d;
}

.metric-box {
  border-radius: 16px;
  background: rgba(243, 230, 200, 0.42);
  padding: 16px;
}

.action-card {
  display: flex;
  flex-direction: column;
  gap: 28px;
  align-items: stretch;
  justify-content: space-between;
  background: rgba(243, 230, 200, 0.36);
}

@media (min-width: 768px) {
  .action-card {
    flex-direction: row;
    align-items: center;
  }
}

.review-box {
  margin-top: 20px;
  border: 1px solid rgba(216, 197, 168, 0.62);
  border-radius: 16px;
  background: rgba(255, 253, 250, 0.62);
  padding: 14px 16px;
  display: grid;
  gap: 4px;
  color: #5e5548;
  font-size: 13px;
}

.review-box strong {
  color: #1a1a1a;
}

.action-primary,
.action-secondary {
  min-width: 220px;
  border-radius: 14px;
  padding: 15px 24px;
  font-size: 14px;
  font-weight: 800;
  text-align: center;
}

.action-primary {
  background: #785600;
  color: white;
  box-shadow: 0 18px 34px rgba(120, 86, 0, 0.20);
}

.action-secondary {
  border: 1px solid #d8c5a8;
  color: #1a1a1a;
  background: rgba(255, 253, 250, 0.72);
}
</style>

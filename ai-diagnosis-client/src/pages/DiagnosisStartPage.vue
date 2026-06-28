<template>
  <div class="start-shell min-h-screen overflow-x-hidden text-[#1A1A1A]">
    <header class="fixed top-0 left-0 w-full z-50 h-20 bg-[#FFF8F3]/86 backdrop-blur-xl border-b border-[#D8C5A8]/35 shadow-[0_8px_28px_rgba(53,48,39,0.05)]">
      <div class="max-w-[1280px] mx-auto px-5 md:px-10 h-full flex items-center justify-between">
        <JcBrand />
        <nav class="hidden md:flex items-center gap-10 text-[13px] font-semibold text-[#5E5548]">
          <router-link to="/" class="hover:text-[#785600] transition">覆盖场景</router-link>
          <router-link to="/" class="hover:text-[#785600] transition">初诊流程</router-link>
          <router-link to="/" class="hover:text-[#785600] transition">衔接服务</router-link>
        </nav>
        <router-link to="/diagnosis/start" class="bg-[#785600] text-white px-5 py-2.5 rounded-xl text-[13px] font-semibold shadow-[0_12px_26px_rgba(120,86,0,0.18)]">
          开始初诊
        </router-link>
      </div>
    </header>

    <main class="max-w-[1280px] mx-auto px-5 md:px-10 pt-32 pb-24">
      <section class="mb-14">
        <div class="max-w-3xl">
          <h1 class="text-[44px] md:text-[64px] leading-tight font-extrabold tracking-tight mb-7">开始企业经营初诊</h1>
          <p class="text-[16px] md:text-[18px] leading-9 text-[#4F4535] mb-8">
            通过君册企业经营初诊系统，深度透视企业健康。基于四个核心维度——<span class="text-[#785600] font-bold">盈利能力、风险管理、现金流效率、经营效率</span>，为后续诊断和专业复核提供依据。
          </p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div v-for="dim in dimensionCards" :key="dim.label" class="dimension-card">
              <JcIcon :name="dim.icon" :size="22" color="#785600" />
              <span>{{ dim.label }}</span>
            </div>
          </div>
        </div>
      </section>

      <section v-if="!store.lookupResult && !showModeSelector" class="mb-16">
        <div class="lookup-card">
          <div>
            <p class="text-[12px] font-semibold text-[#785600] tracking-[0.16em] uppercase mb-3">Start Diagnosis</p>
            <h2 class="text-[26px] md:text-[34px] font-extrabold tracking-tight mb-3">先确认手机号</h2>
            <p class="text-[14px] leading-7 text-[#5E5548] max-w-xl">
              手机号用于查找未完成流程、已有报告或复核状态；若没有历史记录，将进入初诊模式选择。
            </p>
          </div>
          <div class="w-full md:w-[360px]">
            <label class="block text-[12px] font-semibold text-[#5E5548] mb-2">手机号</label>
            <input v-model="phone" type="tel" maxlength="11" placeholder="输入手机号开始初诊" class="start-input mb-3" />
            <p v-if="lookupError" class="text-[13px] text-red-600 mb-3">{{ lookupError }}</p>
            <button @click="handleLookup" :disabled="looking || !phone || phone.length < 11" class="start-primary w-full h-12" :class="(!phone || phone.length < 11) ? 'is-disabled' : ''">
              {{ looking ? '查询中...' : '开始初诊' }}
            </button>
          </div>
        </div>
      </section>

      <section v-if="showModeSelector" class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-20">
        <article
          v-for="m in modes"
          :key="m.code"
          @click="selectedMode = m.code"
          class="mode-card"
          :class="[m.recommended ? 'is-recommended' : '', selectedMode === m.code ? 'is-selected' : '']"
        >
          <div>
            <div class="flex items-start justify-between mb-7">
              <span class="mode-icon"><JcIcon :name="modeIcon(m.code)" :size="22" color="#785600" /></span>
              <span class="mode-badge" :class="m.recommended ? 'gold' : ''">{{ m.recommended ? '推荐' : modeTag(m.code) }}</span>
            </div>
            <h3 class="text-[28px] font-extrabold tracking-tight mb-5">{{ m.name }}</h3>
            <p class="text-[14px] leading-7 text-[#4F4535] mb-8">{{ m.desc }}</p>
            <div class="space-y-4 mb-10">
              <div class="mode-row"><span>文件需求</span><strong>{{ m.docCount }} 类{{ m.code === 'DEEP' ? '详细' : m.code === 'QUICK' ? '基础' : '' }}资料</strong></div>
              <div class="mode-row"><span>核心问题</span><strong>约 {{ String(m.questionCount).replace('~', '') }} 题</strong></div>
              <div class="pt-4 border-t border-[#D8C5A8]/45">
                <span class="text-[11px] uppercase tracking-wider text-[#9A8C7A]">输出：{{ m.output }}</span>
              </div>
            </div>
          </div>
          <button @click.stop="selectAndStart(m.code)" :disabled="starting" class="w-full rounded-xl font-bold transition-all" :class="m.recommended ? 'start-primary h-14' : 'start-secondary h-14'">
            {{ starting && selectedMode === m.code ? '创建中...' : modeAction(m.code) }}
          </button>
        </article>
      </section>

      <section v-if="showIncomplete || showVisibleReport || showPendingReview" class="mb-20">
        <div class="state-card">
          <div v-if="showIncomplete">
            <p class="state-kicker">Continue</p>
            <h2>检测到未完成的初诊流程</h2>
            <p>该手机号已有一份尚未完成的企业经营初诊，您可以继续填写，也可以重新开始。</p>
            <div class="state-actions">
              <button @click="handleContinue" class="start-primary h-12 flex-1">继续填写</button>
              <button @click="handleRestart" class="start-secondary h-12 flex-1">重新开始</button>
            </div>
          </div>
          <div v-if="showVisibleReport">
            <p class="state-kicker">Existing Report</p>
            <h2>检测到已有初诊报告</h2>
            <p>该手机号已有一份企业经营初诊报告。</p>
            <div class="report-mini">
              <div><span>初诊模式</span><strong>{{ modeLabel(reportData?.mode) }}</strong></div>
              <div><span>风险等级</span><strong :class="riskCls(reportData?.report?.riskLevel)">{{ riskLabel(reportData?.report?.riskLevel) }}</strong></div>
              <div><span>生成时间</span><strong>{{ (reportData?.createdAt || '').slice(0, 10) }}</strong></div>
            </div>
            <div class="state-actions">
              <button @click="handleViewReport" class="start-primary h-12 flex-1">查看已有报告</button>
              <button @click="handleRestart" class="start-secondary h-12 flex-1">重新发起初诊</button>
            </div>
          </div>
          <div v-if="showPendingReview">
            <p class="state-kicker">Review</p>
            <h2>初诊报告正在复核</h2>
            <p>您的初诊结果已进入君册专业人员复核流程。复核完成后将展示完整报告。</p>
            <div class="review-note">涉及高风险或资料需进一步确认时，完整报告将在复核后展示。</div>
            <div class="state-actions">
              <button @click="handleViewReport" class="start-primary h-12 flex-1">查看复核状态</button>
              <button @click="handleRestart" class="start-secondary h-12 flex-1">重新发起初诊</button>
            </div>
          </div>
          <button @click="goBack()" class="mt-6 text-[12px] text-[#817563] hover:text-[#785600]">返回修改手机号</button>
        </div>
      </section>

      <section class="security-card">
        <div class="overflow-hidden rounded-2xl bg-[#121212]">
          <img src="/brand/start-security-dashboard.png" alt="经营数据看板" class="w-full h-full object-cover" />
        </div>
        <div class="space-y-6">
          <h2 class="text-[28px] md:text-[34px] font-extrabold tracking-tight">数据安全与隐私保障</h2>
          <p class="text-[15px] leading-8 text-[#4F4535]">
            上传资料仅用于企业经营初诊和后续人工复核。系统结论作为初步筛查参考，不构成最终税务、法律或审计意见。
          </p>
          <div class="flex flex-wrap gap-5 text-[13px] font-bold text-[#785600]">
            <span class="inline-flex items-center gap-2"><JcIcon name="secure" :size="16" color="#785600" />合规脱敏</span>
            <span class="inline-flex items-center gap-2"><JcIcon name="review" :size="16" color="#785600" />人工复核</span>
          </div>
        </div>
      </section>
    </main>

    <footer class="border-t border-[#D8C5A8]/35 px-5 md:px-10 py-10">
      <div class="max-w-[1280px] mx-auto flex flex-col md:flex-row items-start md:items-center justify-between gap-5">
        <JcBrand compact />
        <p class="text-[12px] text-[#817563] text-center md:text-left">© 2024 君册财税 AI. 版权所有。高风险财务智能免责声明适用。</p>
        <div class="flex gap-7 text-[12px] font-semibold text-[#5E5548]">
          <span>隐私政策</span>
          <span>服务条款</span>
          <span>安全保障</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import JcBrand from '../components/common/JcBrand.vue';
import JcIcon from '../components/ui/JcIcon.vue';
import { useDiagnosisStore } from '../stores/diagnosis';

const router = useRouter();
const store = useDiagnosisStore();
const phone = ref('');
const looking = ref(false);
const starting = ref(false);
const lookupError = ref('');
const selectedMode = ref('STANDARD');
const showModeSelector = ref(false);

const dimensionCards = [
  { icon: 'analysis', label: '盈利能力' },
  { icon: 'secure', label: '风险水平' },
  { icon: 'invoice', label: '现金流状态' },
  { icon: 'risk', label: '运营效率' },
];

const modes = [
  { code: 'QUICK', name: '快速初诊', desc: '适合日常健康监测，快速获取企业的财务概览。', docCount: 4, questionCount: '~22', output: '基础概览', recommended: false },
  { code: 'STANDARD', name: '标准初诊', desc: '生成完整四维经营看板与 TOP3 优先行动建议。', docCount: 10, questionCount: '~40', output: '四维看板 + TOP3 行动', recommended: true },
  { code: 'DEEP', name: '深度经营初诊', desc: '适合顾问深度服务场景，提供深度财务与经营分析。', docCount: 18, questionCount: '~65', output: '完整诊断 + 定制建议', recommended: false },
];

const reportData = computed(() => store.lookupResult?.latest);
const isIncomplete = computed(() => store.lookupResult?.actions.canContinue && !store.lookupResult?.actions.canViewReport);
const isVisibleReport = computed(() => store.lookupResult?.actions.canViewReport && reportData.value?.report?.customerVisible);
const isPendingReview = computed(() => store.lookupResult?.actions.canViewReport && reportData.value?.report && !reportData.value.report.customerVisible);

const showIncomplete = computed(() => store.lookupResult && isIncomplete.value);
const showVisibleReport = computed(() => store.lookupResult && isVisibleReport.value);
const showPendingReview = computed(() => store.lookupResult && isPendingReview.value);

function modeLabel(m?: string) {
  const labels: Record<string, string> = { QUICK: '快速初诊', STANDARD: '标准初诊', DEEP: '深度初诊' };
  return labels[m || ''] || m || '-';
}

function riskCls(l?: string) {
  const labels: Record<string, string> = { HIGH: 'text-red-700', MEDIUM: 'text-[#D97706]', LOW: 'text-green-700' };
  return labels[l || ''] || '';
}

function riskLabel(l?: string) {
  const labels: Record<string, string> = { HIGH: '高风险', MEDIUM: '中风险', LOW: '低风险', UNKNOWN: '未知' };
  return labels[l || ''] || l || '-';
}

function modeIcon(code: string) {
  return ({ QUICK: 'process', STANDARD: 'analysis', DEEP: 'search' } as Record<string, string>)[code] || 'analysis';
}

function modeTag(code: string) {
  return ({ QUICK: '快速模式', DEEP: '顾问级' } as Record<string, string>)[code] || '';
}

function modeAction(code: string) {
  return ({ QUICK: '开始体验', STANDARD: '进入标准诊断', DEEP: '开启深度分析' } as Record<string, string>)[code] || '开始初诊';
}

async function handleLookup() {
  if (!phone.value || phone.value.length < 11) return;
  looking.value = true;
  lookupError.value = '';
  try {
    const result = await store.lookup(phone.value);
    if (!result.hasExisting) {
      showModeSelector.value = true;
    }
  } catch (e: any) {
    lookupError.value = e.message || '查询失败';
  } finally {
    looking.value = false;
  }
}

async function selectAndStart(mode: string) {
  selectedMode.value = mode;
  await handleStartWithMode();
}

async function handleContinue() {
  const r = reportData.value;
  if (!r) return;
  store.continueExisting(r.submissionPublicId, r.submissionAccessToken || '', r.mode || 'STANDARD');
  router.push('/diagnosis/upload');
}

async function handleStartWithMode() {
  starting.value = true;
  lookupError.value = '';
  try {
    await store.startDiagnosis(phone.value, selectedMode.value);
    router.push('/diagnosis/upload');
  } catch (e: any) {
    lookupError.value = e.message || '创建失败';
  } finally {
    starting.value = false;
  }
}

async function handleRestart() {
  goBack();
  showModeSelector.value = true;
}

function goBack() {
  store.resetLookup();
  showModeSelector.value = false;
}

function handleViewReport() {
  const r = reportData.value?.report;
  if (!r?.reportPublicId || !r?.reportAccessToken) return;
  store.viewExistingReport(r.reportPublicId, r.reportAccessToken);
  router.push(`/report/${r.reportPublicId}?token=${encodeURIComponent(r.reportAccessToken)}`);
}
</script>

<style scoped>
.start-shell {
  background:
    radial-gradient(circle at 88% 8%, rgba(184, 134, 11, 0.10), transparent 30%),
    linear-gradient(180deg, #fff8f3 0%, #faf8f4 52%, #f3ede3 100%);
}

.dimension-card {
  border: 1px solid rgba(216, 197, 168, 0.62);
  border-radius: 12px;
  background: rgba(255, 248, 243, 0.72);
  min-height: 76px;
  padding: 18px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  color: #785600;
  font-size: 13px;
  font-weight: 800;
  box-shadow: 0 10px 24px rgba(53, 48, 39, 0.035);
}

.lookup-card,
.state-card {
  border: 1px solid rgba(216, 197, 168, 0.58);
  border-radius: 28px;
  background: rgba(255, 253, 250, 0.78);
  box-shadow: 0 24px 70px rgba(53, 48, 39, 0.08);
  backdrop-filter: blur(18px);
}

.lookup-card {
  display: flex;
  flex-direction: column;
  gap: 28px;
  padding: 28px;
}

@media (min-width: 768px) {
  .lookup-card {
    flex-direction: row;
    align-items: end;
    justify-content: space-between;
    padding: 34px;
  }
}

.start-input {
  width: 100%;
  height: 48px;
  border-radius: 12px;
  border: 1px solid rgba(216, 197, 168, 0.85);
  background: rgba(255, 248, 243, 0.78);
  padding: 0 14px;
  color: #1a1a1a;
  font-size: 14px;
  outline: none;
}

.start-input:focus {
  border-color: #785600;
  box-shadow: 0 0 0 3px rgba(120, 86, 0, 0.10);
}

.start-primary,
.start-secondary {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 12px;
  font-weight: 800;
  transition: transform 0.2s ease, background 0.2s ease, box-shadow 0.2s ease;
}

.start-primary {
  background: #785600;
  color: white;
  box-shadow: 0 18px 34px rgba(120, 86, 0, 0.20);
}

.start-primary:hover {
  background: #5d4200;
  transform: translateY(-1px);
}

.start-primary.is-disabled {
  background: #e1d8c9;
  color: #9a8c7a;
  box-shadow: none;
  cursor: not-allowed;
}

.start-secondary {
  border: 1px solid #1a1a1a;
  color: #1a1a1a;
  background: transparent;
}

.start-secondary:hover {
  background: rgba(120, 86, 0, 0.08);
  border-color: #785600;
  color: #785600;
}

.mode-card {
  min-height: 496px;
  border: 1px solid rgba(216, 197, 168, 0.52);
  border-radius: 24px;
  background: rgba(255, 253, 250, 0.86);
  padding: 32px;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  box-shadow: 0 18px 55px rgba(53, 48, 39, 0.08);
  cursor: pointer;
  transition: transform 0.22s ease, border-color 0.22s ease, box-shadow 0.22s ease, background 0.22s ease;
}

.mode-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 28px 70px rgba(53, 48, 39, 0.12);
}

.mode-card.is-recommended {
  background: #f7eddc;
  border: 2px solid rgba(184, 134, 11, 0.42);
  transform: translateY(-14px);
  box-shadow: 0 32px 85px rgba(120, 86, 0, 0.16);
}

.mode-card.is-selected {
  border-color: #785600;
}

.mode-icon {
  width: 56px;
  height: 56px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  background: #e5d8bd;
}

.mode-badge {
  border-radius: 999px;
  background: rgba(26, 26, 26, 0.06);
  color: rgba(26, 26, 26, 0.34);
  padding: 6px 12px;
  font-size: 11px;
  font-weight: 800;
}

.mode-badge.gold {
  background: #785600;
  color: white;
}

.mode-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  font-size: 13px;
}

.mode-row span {
  color: #5e5548;
}

.mode-row strong {
  color: #1a1a1a;
}

.state-card {
  max-width: 720px;
  margin: 0 auto;
  padding: 34px;
  text-align: center;
}

.state-card h2 {
  font-size: 28px;
  font-weight: 800;
  margin-bottom: 10px;
}

.state-card p {
  color: #5e5548;
  line-height: 1.8;
}

.state-kicker {
  color: #785600 !important;
  font-size: 12px;
  font-weight: 800;
  letter-spacing: 0.16em;
  text-transform: uppercase;
  margin-bottom: 10px;
}

.state-actions {
  display: flex;
  gap: 12px;
  margin-top: 24px;
}

.report-mini,
.review-note {
  border-radius: 16px;
  background: rgba(253, 242, 229, 0.82);
  border: 1px solid rgba(216, 197, 168, 0.58);
  margin-top: 20px;
  padding: 16px;
}

.report-mini {
  display: grid;
  gap: 10px;
  text-align: left;
  font-size: 13px;
}

.report-mini div {
  display: flex;
  justify-content: space-between;
}

.report-mini span {
  color: #817563;
}

.security-card {
  border: 1px solid rgba(216, 197, 168, 0.42);
  border-radius: 32px;
  background: rgba(255, 248, 243, 0.64);
  padding: 28px;
  display: grid;
  grid-template-columns: 1fr;
  gap: 36px;
  align-items: center;
}

@media (min-width: 900px) {
  .security-card {
    grid-template-columns: 1fr 1fr;
    padding: 40px;
  }
}

@media (max-width: 768px) {
  .mode-card.is-recommended {
    transform: none;
  }

  .state-actions {
    flex-direction: column;
  }
}
</style>

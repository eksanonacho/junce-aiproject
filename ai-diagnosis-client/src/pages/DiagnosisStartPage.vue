<template>
  <div class="min-h-screen" style="background: linear-gradient(180deg, #F1F5F9 0%, #F8FAFC 100%);">
    <nav class="border-b border-slate-200 bg-white/90 backdrop-blur sticky top-0 z-50">
      <div class="max-w-4xl mx-auto px-4 h-14 flex items-center justify-between">
        <router-link to="/" class="font-bold text-lg text-[#0F172A] tracking-tight">君册财税 <span class="text-[#1E3A8A] font-normal text-sm ml-1">企业经营初诊</span></router-link>
      </div>
    </nav>

    <div class="max-w-lg mx-auto px-4 py-8 md:py-14">
      <!-- Hero -->
      <div class="text-center mb-10">
        <h1 class="text-[28px] md:text-[32px] font-extrabold text-[#0F172A] tracking-tight leading-tight">开始企业经营初诊</h1>
        <p class="mt-3 text-[14px] text-slate-500 leading-relaxed">上传经营资料并补充关键信息，系统将生成<span class="text-[#0F172A] font-semibold">利润、风险、现金流、效率</span>四维经营看板。</p>
      </div>

      <!-- Phone input + CTA (shown when no lookup result) -->
      <div v-if="!store.lookupResult" class="space-y-6">
        <div>
          <label class="block text-[13px] font-medium text-slate-700 mb-1.5">手机号</label>
          <input v-model="phone" type="tel" maxlength="11" placeholder="输入手机号开始初诊"
            class="w-full px-4 py-3 rounded-xl border border-slate-300 bg-white text-[15px] placeholder-slate-400 focus:border-[#1E3A8A] focus:ring-2 focus:ring-[#1E3A8A]/10 outline-none transition"/>
        </div>
        <p v-if="lookupError" class="text-[13px] text-red-600 text-center">{{ lookupError }}</p>
        <button @click="handleLookup" :disabled="looking || !phone || phone.length<11"
          class="w-full py-3.5 rounded-xl font-semibold text-[15px] transition-all"
          :class="(phone&&phone.length>=11)?'bg-[#0F172A] text-white hover:bg-[#1E293B] shadow-lg shadow-slate-900/10':'bg-slate-200 text-slate-400 cursor-not-allowed'">
          {{ looking ? '查询中...' : '开始初诊' }}
        </button>
      </div>

      <!-- Case 1: No history → show mode selector -->
      <div v-if="showModeSelector" class="space-y-4">
        <p class="text-[14px] text-slate-600 text-center mb-2">手机号 {{ phone }}，请选择初诊模式</p>
        <div v-for="m in modes" :key="m.code"
          @click="selectedMode = m.code"
          class="cursor-pointer rounded-2xl px-5 py-4 border-2 transition-all duration-200"
          :class="selectedMode === m.code ? 'border-[#1E3A8A] bg-[#EEF2FF] ring-1 ring-[#1E3A8A]/20' : 'border-[#E2E8F0] bg-white hover:border-slate-300 hover:shadow-sm'">
          <div class="flex items-start gap-4">
            <div class="shrink-0 mt-0.5 w-5 h-5 rounded-full border-2 flex items-center justify-center"
              :class="selectedMode === m.code ? 'border-[#1E3A8A]' : 'border-slate-300'">
              <div v-if="selectedMode === m.code" class="w-2.5 h-2.5 rounded-full bg-[#1E3A8A]"/>
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-0.5">
                <span class="font-semibold text-[15px] text-[#0F172A]">{{ m.name }}</span>
                <span v-if="m.recommended" class="text-[11px] px-1.5 py-0.5 rounded font-medium bg-[#1E3A8A]/10 text-[#1E3A8A]">推荐</span>
              </div>
              <p class="text-[13px] text-slate-500 leading-relaxed">{{ m.desc }}</p>
              <div class="flex flex-wrap gap-2 mt-2">
                <span class="text-[11px] px-2 py-0.5 rounded-md bg-slate-100 text-slate-600">{{ m.docCount }} 类资料</span>
                <span class="text-[11px] px-2 py-0.5 rounded-md bg-slate-100 text-slate-600">{{ m.questionCount }} 题问卷</span>
                <span class="text-[11px] px-2 py-0.5 rounded-md bg-slate-100 text-slate-600">{{ m.output }}</span>
              </div>
            </div>
          </div>
        </div>
        <button @click="handleStartWithMode" :disabled="starting"
          class="w-full py-3.5 rounded-xl bg-[#0F172A] text-white font-semibold text-[15px] hover:bg-[#1E293B] transition shadow-lg shadow-slate-900/10">
          {{ starting ? '创建中...' : '开始初诊' }}
        </button>
        <button @click="goBack" class="block mx-auto text-[12px] text-slate-400 hover:text-slate-600">返回修改手机号</button>
      </div>

      <!-- Case 2: Incomplete DRAFT/uploading -->
      <div v-if="showIncomplete" class="space-y-5">
        <div class="bg-white rounded-2xl border border-amber-200 shadow-sm px-5 py-5">
          <p class="text-[15px] font-semibold text-[#0F172A] mb-1">检测到未完成的初诊流程</p>
          <p class="text-[13px] text-slate-500 leading-relaxed mb-4">该手机号已有一份尚未完成的企业经营初诊，您可以继续填写，也可以重新开始。</p>
          <div class="flex gap-3">
            <button @click="handleContinue" class="flex-1 py-3 rounded-xl bg-[#0F172A] text-white text-[14px] font-semibold hover:bg-[#1E293B] transition">继续填写</button>
            <button @click="handleRestart" class="flex-1 py-3 rounded-xl border border-slate-300 text-slate-600 text-[14px] font-medium hover:bg-slate-50 transition">重新开始</button>
          </div>
        </div>
        <button @click="goBack()" class="block mx-auto text-[12px] text-slate-400 hover:text-slate-600">返回</button>
      </div>

      <!-- Case 3: Visible report -->
      <div v-if="showVisibleReport" class="space-y-5">
        <div class="bg-white rounded-2xl border border-green-200 shadow-sm px-5 py-5">
          <p class="text-[15px] font-semibold text-[#0F172A] mb-1">检测到已有初诊报告</p>
          <p class="text-[13px] text-slate-500 leading-relaxed mb-4">该手机号已有一份企业经营初诊报告。</p>
          <div class="bg-slate-50 rounded-xl px-4 py-3 mb-4 space-y-1 text-[12px]">
            <div class="flex justify-between"><span class="text-slate-400">初诊模式</span><span class="font-medium">{{ modeLabel(reportData?.mode) }}</span></div>
            <div class="flex justify-between"><span class="text-slate-400">风险等级</span><span class="font-semibold" :class="riskCls(reportData?.report?.riskLevel)">{{ riskLabel(reportData?.report?.riskLevel) }}</span></div>
            <div class="flex justify-between"><span class="text-slate-400">生成时间</span><span>{{ (reportData?.createdAt||'').slice(0,10) }}</span></div>
          </div>
          <div class="flex gap-3">
            <button @click="handleViewReport" class="flex-1 py-3 rounded-xl bg-[#0F172A] text-white text-[14px] font-semibold hover:bg-[#1E293B] transition">查看已有报告</button>
            <button @click="handleRestart" class="flex-1 py-3 rounded-xl border border-slate-300 text-slate-600 text-[14px] font-medium hover:bg-slate-50 transition">重新发起初诊</button>
          </div>
        </div>
        <button @click="goBack()" class="block mx-auto text-[12px] text-slate-400 hover:text-slate-600">返回</button>
      </div>

      <!-- Case 4: Pending review / invisible report -->
      <div v-if="showPendingReview" class="space-y-5">
        <div class="bg-white rounded-2xl border border-amber-200 shadow-sm px-5 py-5">
          <p class="text-[15px] font-semibold text-[#0F172A] mb-1">初诊报告正在复核</p>
          <p class="text-[13px] text-slate-500 leading-relaxed mb-4">您的初诊结果已进入君册专业人员复核流程。复核完成后将展示完整报告。</p>
          <div class="bg-amber-50 rounded-xl px-4 py-3 mb-4 text-[12px] text-amber-700 leading-relaxed">涉及高风险或资料需进一步确认时，完整报告将在复核后展示。</div>
          <div class="flex gap-3">
            <button @click="handleViewReport" class="flex-1 py-3 rounded-xl bg-[#0F172A] text-white text-[14px] font-semibold hover:bg-[#1E293B] transition">查看复核状态</button>
            <button @click="handleRestart" class="flex-1 py-3 rounded-xl border border-slate-300 text-slate-600 text-[14px] font-medium hover:bg-slate-50 transition">重新发起初诊</button>
          </div>
        </div>
        <button @click="goBack()" class="block mx-auto text-[12px] text-slate-400 hover:text-slate-600">返回</button>
      </div>

      <p class="text-[12px] text-slate-400 text-center mt-8 leading-relaxed">本系统仅作为企业经营与财税风险初步筛查参考，不构成最终税务、法律或审计结论。</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';
import { useDiagnosisStore } from '../stores/diagnosis';

const router = useRouter();
const store = useDiagnosisStore();
const phone = ref('');
const looking = ref(false);
const starting = ref(false);
const lookupError = ref('');
const selectedMode = ref('STANDARD');
const showModeSelector = ref(false);

const modes = [
  { code: 'QUICK', name: '快速初诊', desc: '4类基础资料 + 约22题，适合初步了解企业经营健康概况。', docCount: 4, questionCount: '~22', output: '基础概览', recommended: false },
  { code: 'STANDARD', name: '标准初诊', desc: '10类资料 + 约40题，生成完整四维经营看板与TOP3优先行动建议。', docCount: 10, questionCount: '~40', output: '四维看板 + TOP3行动', recommended: true },
  { code: 'DEEP', name: '深度经营出诊', desc: '18类详细资料 + 完整题库，适合顾问深度服务场景。', docCount: 18, questionCount: '~65', output: '完整诊断 + 定制建议', recommended: false },
];

const reportData = computed(() => store.lookupResult?.latest);
const isIncomplete = computed(() => store.lookupResult?.actions.canContinue && !store.lookupResult?.actions.canViewReport);
const isVisibleReport = computed(() => store.lookupResult?.actions.canViewReport && reportData.value?.report?.customerVisible);
const isPendingReview = computed(() => store.lookupResult?.actions.canViewReport && reportData.value?.report && !reportData.value.report.customerVisible);

const showIncomplete = computed(() => store.lookupResult && isIncomplete.value);
const showVisibleReport = computed(() => store.lookupResult && isVisibleReport.value);
const showPendingReview = computed(() => store.lookupResult && isPendingReview.value);

function modeLabel(m?: string) { const m2: Record<string,string>={QUICK:'快速初诊',STANDARD:'标准初诊',DEEP:'深度出诊'}; return m2[m||'']||m||'-'; }
function riskCls(l?: string) { const m: Record<string,string>={HIGH:'text-red-600',MEDIUM:'text-amber-600',LOW:'text-green-600'}; return m[l||'']||''; }
function riskLabel(l?: string) { const m: Record<string,string>={HIGH:'高风险',MEDIUM:'中风险',LOW:'低风险',UNKNOWN:'未知'}; return m[l||'']||l||'-'; }

async function handleLookup() {
  if (!phone.value || phone.value.length < 11) return;
  looking.value = true; lookupError.value = '';
  try {
    const result = await store.lookup(phone.value);
    if (!result.hasExisting) {
      // Case 1: No history → show mode selector
      showModeSelector.value = true;
    }
    // Cases 2-4: handled by template reactivity
  } catch (e: any) { lookupError.value = e.message || '查询失败'; }
  finally { looking.value = false; }
}

async function handleContinue() {
  const r = reportData.value;
  if (!r) return;
  store.continueExisting(r.submissionPublicId, r.submissionAccessToken || '', r.mode || 'STANDARD');
  router.push('/diagnosis/upload');
}

async function handleStartWithMode() {
  starting.value = true; lookupError.value = '';
  try {
    await store.startDiagnosis(phone.value, selectedMode.value);
    router.push('/diagnosis/upload');
  } catch (e: any) { lookupError.value = e.message || '创建失败'; }
  finally { starting.value = false; }
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

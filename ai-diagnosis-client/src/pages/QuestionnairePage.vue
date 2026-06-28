<script setup lang="ts">
import { ref, computed, reactive, onMounted, nextTick } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { fetchQuestionnaire } from '../api/questionnaire';
import { submitQuestionnaire } from '../api/submissions';
import JcBrand from '../components/common/JcBrand.vue';
import { useDiagnosisStore } from '../stores/diagnosis';
import type { QuestionnaireResponse, QuestionDto } from '../types/api';

const router = useRouter();
const route = useRoute();
const diagnosisStore = useDiagnosisStore();
const isV2Mode = computed(() => !!diagnosisStore.submissionPublicId || !!route.query.v2);
function reloadPage() { location.reload(); }
const loading = ref(true);
const error = ref('');
const questionnaire = ref<QuestionnaireResponse | null>(null);
const answers = reactive<Record<number, unknown>>({});
const phone = ref('');
const submitting = ref(false);
const submitError = ref('');
const questionRefs = ref<Record<string, HTMLElement>>({});

interface FlatQ extends QuestionDto { groupLabel: string; index: number; skipLogic?: unknown }
const flatQuestions = computed<FlatQ[]>(() => {
  if (!questionnaire.value) return [];
  let idx = 0;
  return questionnaire.value.groups.flatMap(g =>
    g.questions.map(q => ({ ...q, groupLabel: g.label, index: ++idx, skipLogic: (q as any).skipLogic }))
  );
});

// V2: filter by mode using skipLogic.hideInModes, then re-index
const visibleQuestions = computed<FlatQ[]>(() => {
  if (!isV2Mode.value) return flatQuestions.value;
  const mode = diagnosisStore.mode || 'STANDARD';
  const filtered = flatQuestions.value.filter(q => {
    if (!q.skipLogic) return true;
    const sl = q.skipLogic as { hideInModes?: string[] };
    if (!sl.hideInModes || !Array.isArray(sl.hideInModes)) return true;
    return !sl.hideInModes.includes(mode);
  });
  // Re-index so numbers are 1..N for visible questions only
  return filtered.map((q, i) => ({ ...q, index: i + 1 }));
});

const totalQuestions = computed(() => visibleQuestions.value.length);
const answeredCount = computed(() => visibleQuestions.value.filter(q => {
  const v = answers[q.id];
  if (q.type === 'MULTI_CHOICE') return Array.isArray(v) && v.length > 0;
  return v !== undefined && v !== null && v !== '';
}).length);
const allRequiredDone = computed(() => {
  return visibleQuestions.value.filter(q => q.required).every(q => {
    const v = answers[q.id];
    if (q.type === 'MULTI_CHOICE') return Array.isArray(v) && v.length > 0;
    return v !== undefined && v !== null && v !== '';
  });
});

const sectionLabels = computed(() => {
  const seen = new Set<string>();
  return visibleQuestions.value.map(q => {
    if (seen.has(q.groupLabel)) return null;
    seen.add(q.groupLabel);
    return q.groupLabel;
  });
});

const currentGroup = computed(() => {
  const firstUnanswered = visibleQuestions.value.find(q => !isAnswered(q as any));
  return firstUnanswered?.groupLabel || null;
});

function groupStatus(g: { label: string; questions: any[] }) {
  const visibleInGroup = g.questions.filter((q: any) => visibleQuestions.value.some(vq => vq.id === q.id));
  if (visibleInGroup.length === 0) return { done: false, started: false };
  const answeredInGroup = visibleInGroup.filter((q: any) => isAnswered({ ...q, groupLabel: g.label, index: 0 } as any));
  return { done: answeredInGroup.length === visibleInGroup.length, started: answeredInGroup.length > 0 };
}

onMounted(async () => {
  // Restore diagnosis store from session if navigating directly
  diagnosisStore.restoreFromSession();
  try {
    const version = isV2Mode.value ? 'v2' : undefined;
    questionnaire.value = await fetchQuestionnaire(version);
  } catch (e: unknown) {
    console.error('Questionnaire load error:', e);
    error.value = (e as { message?: string }).message || '加载问卷失败';
  } finally {
    loading.value = false;
  }
});

function setAnswer(qId: number, value: unknown) {
  answers[qId] = value;
  nextTick(() => {
    setTimeout(() => {
      const nextUnanswered = visibleQuestions.value.find(q => {
        const v = answers[q.id];
        if (q.type === 'MULTI_CHOICE') return !Array.isArray(v) || v.length === 0;
        return v === undefined || v === null || v === '';
      });
      if (nextUnanswered) {
        questionRefs.value[`q-${nextUnanswered.id}`]?.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
    }, 350);
  });
}
function getAnswer(qId: number): unknown { return answers[qId]; }
function getOptionsList(q: QuestionDto): string[] {
  const opts = q.options as Record<string, unknown> | null;
  if (opts && Array.isArray(opts)) return opts as string[];
  if (opts && Array.isArray((opts as any).options)) return (opts as any).options as string[];
  return [];
}
function isAnswered(q: FlatQ) {
  const v = answers[q.id];
  if (q.type === 'MULTI_CHOICE') return Array.isArray(v) && v.length > 0;
  return v !== undefined && v !== null && v !== '';
}

async function handleSubmit() {
  if (!questionnaire.value) return;
  const required = visibleQuestions.value.filter(q => q.required);
  const missing = required.filter(q => !isAnswered(q as any));
  if (missing.length > 0) {
    submitError.value = `还有 ${missing.length} 个必填问题未完成`;
    questionRefs.value[`q-${missing[0].id}`]?.scrollIntoView({ behavior: 'smooth', block: 'center' });
    return;
  }
  submitting.value = true; submitError.value = '';
  try {
    let result: any;

    if (isV2Mode.value && diagnosisStore.submissionPublicId) {
      // V2 flow: use diagnosis store complete
      const answersList = Object.entries(answers).map(([qId, value]) => {
        const q = visibleQuestions.value.find((fq) => fq.id === Number(qId));
        return { questionPublicId: q?.publicId || '', value };
      }).filter((a) => a.questionPublicId);
      result = await diagnosisStore.completeDiagnosis(answersList);
    } else {
      // V1 flow: original submit
      result = await submitQuestionnaire({
        questionnaireId: questionnaire.value!.id,
        phone: phone.value || undefined,
        answers: Object.entries(answers).map(([qId, value]) => ({ questionId: Number(qId), value })),
      });
    }

    const params = new URLSearchParams({
      submissionPublicId: result.submissionPublicId,
      diagnosisStatus: result.diagnosisStatus || 'NOT_RUN',
      reportStatus: result.reportStatus || 'NOT_RUN',
    });
    if (result.reportPublicId) params.set('reportPublicId', result.reportPublicId);
    if (result.reportAccessToken) params.set('reportAccessToken', result.reportAccessToken);
    if (isV2Mode.value) {
      params.set('v2', 'true');
      params.set('mode', diagnosisStore.mode);
      if (result.documentCompletenessScore) params.set('documentCompletenessScore', String(result.documentCompletenessScore));
    }
    router.push(`/questionnaire/success?${params.toString()}`);
  } catch (e: unknown) {
    submitError.value = (e as { message?: string }).message || '提交失败，请重试';
  } finally { submitting.value = false; }
}
</script>

<template>
<div class="questionnaire-shell relative min-h-screen overflow-x-hidden text-[#1A1A1A]">
  <header class="fixed top-0 left-0 w-full z-50 h-20 bg-[#FFF8F3]/86 backdrop-blur-xl border-b border-[#D8C5A8]/35 shadow-[0_8px_28px_rgba(53,48,39,0.05)]">
    <div class="max-w-[1440px] mx-auto px-5 md:px-10 h-full flex items-center justify-between">
      <div class="flex items-center gap-6">
        <JcBrand />
        <span class="hidden md:block h-6 w-px bg-[#D8C5A8]"></span>
        <span class="hidden md:block text-[12px] font-bold tracking-[0.14em] uppercase text-[#817563]">经营诊断引擎</span>
      </div>
      <router-link to="/" class="rounded-xl bg-[#785600] px-5 py-2.5 text-[13px] font-bold text-white shadow-[0_12px_26px_rgba(120,86,0,0.18)]">保存并退出</router-link>
    </div>
  </header>

  <div v-if="loading" class="relative z-[1] flex items-center justify-center h-screen">
    <div class="text-center"><div class="w-8 h-8 border-2 border-[#785600] border-t-transparent rounded-full animate-spin mx-auto mb-3"></div><p class="text-[#817563]">加载初诊问卷...</p></div>
  </div>

  <div v-else-if="error" class="relative z-[1] flex items-center justify-center h-screen">
    <div class="text-center"><p class="text-red-500 text-lg mb-4">{{ error }}</p><button @click="reloadPage" class="bg-[#785600] text-white px-5 py-2.5 rounded-xl">重试</button></div>
  </div>

  <div v-else-if="questionnaire" class="relative z-[1] max-w-[1440px] mx-auto px-5 md:px-10 pt-28">
    <div class="flex gap-8">

      <!-- 左侧 -->
      <div class="flex-1 min-w-0 max-w-[820px] mx-auto md:mx-0 pb-32">
        <div class="mb-8">
          <div class="flex items-center gap-3 mb-3">
            <span class="rounded-full bg-[#785600]/10 px-3 py-1 text-[12px] font-bold tracking-[0.14em] uppercase text-[#785600]">阶段 03</span>
            <span class="h-1 w-1 rounded-full bg-[#D8C5A8]"></span>
            <span class="text-[13px] font-semibold text-[#817563]">第 {{ answeredCount + 1 > totalQuestions ? totalQuestions : answeredCount + 1 }} 题，共 {{ totalQuestions }} 题</span>
          </div>
          <h1 class="text-[32px] md:text-[42px] font-extrabold tracking-tight text-[#1A1A1A] mb-2">{{ isV2Mode ? '补充经营诊断信息' : questionnaire.title }}</h1>
          <p class="text-[#5E5548] text-[15px] leading-7">{{ isV2Mode ? '请补充资料中无法体现的经营情况，系统将结合资料完整度和问卷答案生成四维经营初诊看板。' : '通过多个维度完成企业财税基础筛查。' }}</p>
        </div>

        <!-- Questions -->
        <template v-for="(q, qi) in visibleQuestions" :key="q.id">
          <div v-if="sectionLabels[qi]" class="flex items-center gap-3 mt-9 mb-4 first:mt-0">
            <div class="h-px flex-1 bg-[#D8C5A8]/55"></div>
            <span class="text-xs font-bold text-[#817563] uppercase tracking-wider whitespace-nowrap">{{ sectionLabels[qi] }}</span>
            <div class="h-px flex-1 bg-[#D8C5A8]/55"></div>
          </div>

          <div :ref="(el: any) => { if (el) questionRefs[`q-${q.id}`] = el }"
            class="question-card mb-5 rounded-[24px] p-6 md:p-9 transition-all duration-500"
            :class="isAnswered(q as any) ? 'is-answered' : 'is-active'">
            <div class="flex items-center gap-2 mb-3 flex-wrap">
              <span class="q-chip">{{ q.index }} / {{ totalQuestions }}</span>
              <span class="q-chip">{{ q.groupLabel }}</span>
              <span v-if="q.required" class="q-chip required">必填</span>
              <span v-if="isAnswered(q as any)" class="q-chip done ml-auto">已回答</span>
            </div>
            <h3 class="text-[19px] md:text-[24px] font-bold text-[#1A1A1A] leading-snug mb-2">{{ q.text }}</h3>
            <p v-if="q.type === 'SINGLE_CHOICE'" class="text-[#817563] text-sm mb-5">选择最接近的一项</p>
            <p v-else-if="q.type === 'MULTI_CHOICE'" class="text-[#817563] text-sm mb-5">可多选</p>

            <!-- Options: SINGLE_CHOICE / YES_NO -->
            <div v-if="q.type === 'SINGLE_CHOICE' || q.type === 'YES_NO'" class="grid grid-cols-1 md:grid-cols-2 gap-3">
              <button v-for="opt in getOptionsList(q)" :key="opt" @click="setAnswer(q.id, opt)"
                class="option-card"
                :class="getAnswer(q.id) === opt ? 'selected' : ''">
                {{ opt }}
              </button>
            </div>

            <!-- Options: MULTI_CHOICE -->
            <div v-else-if="q.type === 'MULTI_CHOICE'" class="grid grid-cols-1 md:grid-cols-2 gap-3">
              <button v-for="opt in getOptionsList(q)" :key="opt"
                @click="() => { const cur = (getAnswer(q.id) as string[]) || []; setAnswer(q.id, cur.includes(opt) ? cur.filter(v => v !== opt) : [...cur, opt]); }"
                class="option-card"
                :class="Array.isArray(getAnswer(q.id)) && (getAnswer(q.id) as string[]).includes(opt) ? 'selected' : ''">
                {{ opt }}
              </button>
            </div>

            <!-- TEXT / RANGE -->
            <input v-else type="text" :value="getAnswer(q.id) || ''"
              @input="(e: Event) => setAnswer(q.id, (e.target as HTMLInputElement).value)"
              placeholder="请输入" class="start-text-input" />
          </div>
        </template>

        <!-- Submit -->
        <div class="submit-card rounded-[24px] p-6 md:p-8 mt-7">
          <h3 class="font-bold text-[#1A1A1A] text-xl mb-1">即将完成</h3>
          <p class="text-[#5E5548] text-sm leading-7 mb-4">提交后，系统将生成初步筛查结果。涉及高风险内容时，将由君册专业人员复核后再展示。</p>
          <div class="mb-4">
            <label class="block text-sm font-semibold text-[#5E5548] mb-1.5">手机号（用于查看报告）</label>
            <input type="tel" v-model="phone" maxlength="11" placeholder="请输入手机号" class="start-text-input" />
          </div>
          <button @click="handleSubmit" :disabled="submitting || !allRequiredDone"
            class="w-full h-[50px] rounded-xl font-semibold text-base transition shadow-sm flex items-center justify-center gap-2"
            :class="allRequiredDone ? 'bg-[#785600] text-white hover:bg-[#5D4200]' : 'bg-[#E1D8C9] text-[#9A8C7A] cursor-not-allowed'">
            {{ submitting ? '提交中...' : allRequiredDone ? '提交并生成初诊结果' : `还有 ${totalQuestions - answeredCount} 个问题未完成` }}
          </button>
          <div v-if="submitError" class="bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-xl mt-4">{{ submitError }}</div>
        </div>
      </div>

      <!-- 右侧进度面板 -->
      <div class="hidden lg:block w-[360px] flex-shrink-0">
        <div class="sticky top-[80px] space-y-4">
          <!-- Progress card -->
          <div class="side-card overflow-hidden">
            <div class="bg-[#121212] text-white px-5 py-3 text-[13px] font-semibold">
              {{ isV2Mode ? '九维诊断进度' : '初诊进度' }}
            </div>
            <div class="p-5 space-y-3">
              <div class="flex items-center gap-3">
                <span class="text-[36px] font-extrabold text-[#785600]">{{ answeredCount }}</span>
                <span class="text-[13px] text-[#817563]">/ {{ totalQuestions }} 题已完成</span>
              </div>
              <div class="w-full h-2 bg-[#ECE1D4] rounded-full overflow-hidden">
                <div class="h-full bg-[#785600] rounded-full transition-all duration-500"
                  :style="{ width: (totalQuestions > 0 ? answeredCount / totalQuestions * 100 : 0) + '%' }"/>
              </div>
              <div v-if="currentGroup" class="text-[11px] text-[#817563] mt-1">
                当前：<span class="font-medium text-[#5E5548]">{{ currentGroup }}</span>
              </div>
            </div>
          </div>
          <!-- Dimension progress -->
          <div v-if="isV2Mode" class="side-card p-5">
            <div class="space-y-1.5">
              <div v-for="g in questionnaire.groups" :key="g.label" class="flex items-center gap-2 text-[11px]">
                <div class="w-1.5 h-1.5 rounded-full shrink-0"
                  :class="groupStatus(g).done ? 'bg-green-500' : groupStatus(g).started ? 'bg-amber-400' : 'bg-[#CBD5E1]'"/>
                <span class="flex-1 truncate"
                  :class="groupStatus(g).done ? 'text-slate-700 font-medium' : groupStatus(g).started ? 'text-slate-500' : 'text-slate-400'">
                  {{ g.label }}
                </span>
                <span v-if="groupStatus(g).done" class="text-green-500 text-[10px]">完成</span>
                <span v-else-if="groupStatus(g).started" class="text-amber-500 text-[10px]">进行中</span>
              </div>
            </div>
          </div>
          <div v-else class="side-card p-5">
            <p class="text-[12px] text-[#5E5548] leading-relaxed">完成全部问题后，系统将生成初步筛查结果；涉及高风险内容时，将由君册专业人员复核。</p>
          </div>
        </div>
      </div>

    </div>

    <!-- 移动端底部进度条 -->
    <div class="lg:hidden fixed bottom-0 left-0 right-0 bg-[#FFF8F3]/94 backdrop-blur-xl border-t border-[#D8C5A8] px-4 py-3 z-40 shadow-lg">
      <div class="flex items-center justify-between mb-1.5">
        <span class="text-xs font-medium text-[#5E5548]">已完成 {{ answeredCount }} / {{ totalQuestions }}</span>
        <span class="text-xs text-[#785600] font-semibold">{{ totalQuestions > 0 ? Math.round(answeredCount/totalQuestions*100) : 0 }}%</span>
      </div>
      <div class="w-full h-1.5 bg-[#ECE1D4] rounded-full overflow-hidden">
        <div class="h-full bg-[#785600] rounded-full transition-all duration-500" :style="{width:(totalQuestions>0?answeredCount/totalQuestions*100:0)+'%'}"></div>
      </div>
    </div>
  </div>

</div>
</template>

<style scoped>
.questionnaire-shell {
  background:
    radial-gradient(circle at 86% 8%, rgba(184, 134, 11, 0.10), transparent 30%),
    linear-gradient(180deg, #fff8f3 0%, #faf8f4 58%, #f3ede3 100%);
}

.question-card,
.submit-card,
.side-card {
  border: 1px solid rgba(216, 197, 168, 0.56);
  background: rgba(255, 253, 250, 0.80);
  box-shadow: 0 20px 55px rgba(53, 48, 39, 0.07);
  backdrop-filter: blur(18px);
}

.question-card {
  position: relative;
  overflow: hidden;
}

.question-card::before {
  content: "";
  position: absolute;
  inset: 0 auto 0 0;
  width: 5px;
  background: #785600;
  opacity: 0;
}

.question-card.is-active::before {
  opacity: 1;
}

.question-card.is-answered {
  background: rgba(255, 248, 243, 0.58);
}

.q-chip {
  border-radius: 8px;
  background: rgba(243, 230, 200, 0.58);
  color: #817563;
  padding: 4px 8px;
  font-size: 11px;
  font-weight: 800;
}

.q-chip.required {
  background: rgba(184, 134, 11, 0.14);
  color: #785600;
}

.q-chip.done {
  background: rgba(47, 107, 72, 0.12);
  color: #2f6b48;
}

.option-card {
  min-height: 58px;
  border-radius: 16px;
  border: 1px solid rgba(216, 197, 168, 0.58);
  background: rgba(255, 255, 255, 0.52);
  color: #1a1a1a;
  padding: 16px 18px;
  text-align: left;
  font-size: 15px;
  font-weight: 600;
  line-height: 1.5;
  transition: transform 0.2s ease, border-color 0.2s ease, background 0.2s ease, box-shadow 0.2s ease;
}

.option-card:hover {
  transform: translateY(-2px);
  border-color: rgba(120, 86, 0, 0.50);
  background: #fffdfa;
  box-shadow: 0 12px 28px rgba(53, 48, 39, 0.06);
}

.option-card.selected {
  border-color: #785600;
  background: #f3e6c8;
  color: #5d4200;
  box-shadow: 0 14px 32px rgba(120, 86, 0, 0.12);
}

.start-text-input {
  width: 100%;
  height: 48px;
  border-radius: 14px;
  border: 1px solid rgba(216, 197, 168, 0.85);
  background: rgba(255, 248, 243, 0.76);
  padding: 0 14px;
  color: #1a1a1a;
  font-size: 14px;
  outline: none;
}

.start-text-input:focus {
  border-color: #785600;
  box-shadow: 0 0 0 3px rgba(120, 86, 0, 0.10);
}

.side-card {
  border-radius: 24px;
}
</style>

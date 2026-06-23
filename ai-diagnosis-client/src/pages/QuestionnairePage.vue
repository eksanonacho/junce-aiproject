<script setup lang="ts">
import { ref, computed, reactive, onMounted, nextTick } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { fetchQuestionnaire } from '../api/questionnaire';
import { submitQuestionnaire } from '../api/submissions';
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

// V2: filter by mode using skipLogic.hideInModes
const visibleQuestions = computed<FlatQ[]>(() => {
  if (!isV2Mode.value) return flatQuestions.value;
  const mode = diagnosisStore.mode || 'STANDARD';
  return flatQuestions.value.filter(q => {
    if (!q.skipLogic) return true;
    const sl = q.skipLogic as { hideInModes?: string[] };
    if (!sl.hideInModes || !Array.isArray(sl.hideInModes)) return true;
    return !sl.hideInModes.includes(mode);
  });
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
<div class="min-h-screen bg-[#F2F5FC] text-[#1E293B]">

  <div v-if="loading" class="flex items-center justify-center h-screen">
    <div class="text-center"><div class="w-8 h-8 border-2 border-[#2563EB] border-t-transparent rounded-full animate-spin mx-auto mb-3"></div><p class="text-[#64748B]">加载初诊问卷...</p></div>
  </div>

  <div v-else-if="error" class="flex items-center justify-center h-screen">
    <div class="text-center"><p class="text-red-500 text-lg mb-4">{{ error }}</p><button @click="reloadPage" class="bg-[#1E3A8A] text-white px-5 py-2.5 rounded-xl">重试</button></div>
  </div>

  <div v-else-if="questionnaire" class="max-w-[1180px] mx-auto px-4 md:px-6">
    <div class="flex gap-8">

      <!-- 左侧 -->
      <div class="flex-1 min-w-0 max-w-[720px] mx-auto md:mx-0 pt-8 pb-24 md:pb-32">
        <router-link to="/" class="text-[#64748B] text-sm hover:text-[#1E3A8A] inline-flex items-center gap-1 mb-4">&larr; 返回首页</router-link>
        <h1 class="text-2xl md:text-3xl font-bold text-[#0F172A] mb-2">{{ questionnaire.title }}</h1>
        <p class="text-[#64748B] text-sm mb-4">通过 5 个维度完成企业财税基础筛查</p>

        <!-- Questions -->
        <template v-for="(q, qi) in visibleQuestions" :key="q.id">
          <div v-if="sectionLabels[qi]" class="flex items-center gap-3 mt-8 mb-4 first:mt-0">
            <div class="h-px flex-1 bg-[#E2E8F0]"></div>
            <span class="text-xs font-semibold text-[#94A3B8] uppercase tracking-wider whitespace-nowrap">{{ sectionLabels[qi] }}</span>
            <div class="h-px flex-1 bg-[#E2E8F0]"></div>
          </div>

          <div :ref="(el: any) => { if (el) questionRefs[`q-${q.id}`] = el }"
            class="mb-4 rounded-2xl p-5 md:p-6 transition-all duration-500"
            :class="isAnswered(q as any) ? 'bg-[#F8FAFC] border border-[#E2E8F0]/60' : 'bg-white border border-[#CBD5E1] shadow-md shadow-slate-100/50'">
            <div class="flex items-center gap-2 mb-3 flex-wrap">
              <span class="text-[11px] font-bold text-[#94A3B8] bg-[#F1F5F9] px-2 py-0.5 rounded-md">{{ q.index }} / {{ totalQuestions }}</span>
              <span class="text-[11px] text-[#94A3B8] bg-[#F1F5F9] px-2 py-0.5 rounded-md">{{ q.groupLabel }}</span>
              <span v-if="q.required" class="text-[11px] text-[#D97706] bg-[#FEF3C7] px-2 py-0.5 rounded-md">必填</span>
              <span v-if="isAnswered(q as any)" class="text-[11px] text-green-600 bg-green-50 px-2 py-0.5 rounded-md ml-auto">✓ 已回答</span>
            </div>
            <h3 class="text-base md:text-lg font-semibold text-[#0F172A] mb-1.5">{{ q.text }}</h3>
            <p v-if="q.type === 'SINGLE_CHOICE'" class="text-[#94A3B8] text-xs mb-4">选择最接近的一项</p>
            <p v-else-if="q.type === 'MULTI_CHOICE'" class="text-[#94A3B8] text-xs mb-4">可多选</p>

            <!-- Options: SINGLE_CHOICE / YES_NO -->
            <div v-if="q.type === 'SINGLE_CHOICE' || q.type === 'YES_NO'" class="grid grid-cols-2 md:grid-cols-3 gap-2.5">
              <button v-for="opt in getOptionsList(q)" :key="opt" @click="setAnswer(q.id, opt)"
                class="text-left px-4 py-3 rounded-xl border-2 transition-all duration-200 text-sm font-medium"
                :class="getAnswer(q.id) === opt ? 'border-[#2563EB] bg-[#EFF6FF] text-[#1E3A8A] shadow-sm' : 'border-[#E2E8F0] bg-white text-[#475569] hover:border-[#93C5FD] hover:bg-[#F8FAFC]'">
                {{ opt }}
              </button>
            </div>

            <!-- Options: MULTI_CHOICE -->
            <div v-else-if="q.type === 'MULTI_CHOICE'" class="grid grid-cols-2 md:grid-cols-3 gap-2.5">
              <button v-for="opt in getOptionsList(q)" :key="opt"
                @click="() => { const cur = (getAnswer(q.id) as string[]) || []; setAnswer(q.id, cur.includes(opt) ? cur.filter(v => v !== opt) : [...cur, opt]); }"
                class="text-left px-4 py-3 rounded-xl border-2 transition-all duration-200 text-sm font-medium"
                :class="Array.isArray(getAnswer(q.id)) && (getAnswer(q.id) as string[]).includes(opt) ? 'border-[#2563EB] bg-[#EFF6FF] text-[#1E3A8A] shadow-sm' : 'border-[#E2E8F0] bg-white text-[#475569] hover:border-[#93C5FD] hover:bg-[#F8FAFC]'">
                {{ opt }}
              </button>
            </div>

            <!-- TEXT / RANGE -->
            <input v-else type="text" :value="getAnswer(q.id) || ''"
              @input="(e: Event) => setAnswer(q.id, (e.target as HTMLInputElement).value)"
              placeholder="请输入" class="w-full h-[48px] px-4 border border-[#CBD5E1] rounded-xl text-sm focus:border-[#2563EB] focus:ring-2 focus:ring-blue-100 outline-none" />
          </div>
        </template>

        <!-- Submit -->
        <div class="bg-white rounded-2xl border border-[#E2E8F0] shadow-sm p-6 mt-6">
          <h3 class="font-semibold text-[#0F172A] text-lg mb-1">即将完成</h3>
          <p class="text-[#64748B] text-sm mb-4">提交后，系统将生成初步筛查结果。涉及高风险内容时，将由君册专业人员复核后再展示。</p>
          <div class="mb-4">
            <label class="block text-sm font-medium text-[#0F172A] mb-1.5">手机号（用于查看报告）</label>
            <input type="tel" v-model="phone" maxlength="11" placeholder="请输入手机号" class="w-full h-[48px] px-4 border border-[#CBD5E1] rounded-xl text-sm focus:border-[#2563EB] focus:ring-2 focus:ring-blue-100 outline-none" />
          </div>
          <button @click="handleSubmit" :disabled="submitting || !allRequiredDone"
            class="w-full h-[50px] rounded-xl font-semibold text-base transition shadow-sm flex items-center justify-center gap-2"
            :class="allRequiredDone ? 'bg-[#1E3A8A] text-white hover:bg-[#1E40AF]' : 'bg-[#E2E8F0] text-[#94A3B8] cursor-not-allowed'">
            {{ submitting ? '提交中...' : allRequiredDone ? '提交并生成初诊结果' : `还有 ${totalQuestions - answeredCount} 个问题未完成` }}
          </button>
          <div v-if="submitError" class="bg-red-50 border border-red-200 text-red-700 text-sm px-4 py-3 rounded-xl mt-4">{{ submitError }}</div>
        </div>
      </div>

      <!-- 右侧 sticky 进度面板 -->
      <div class="hidden lg:block w-[300px] flex-shrink-0 pt-8">
        <div class="sticky top-[80px]">
          <div class="bg-white rounded-2xl shadow-sm border border-[#E2E8F0] overflow-hidden">
            <div class="bg-[#0F172A] text-white px-5 py-3 text-sm font-semibold">初诊进度</div>
            <div class="p-5 space-y-4">
              <div class="flex items-center gap-4">
                <div class="relative w-16 h-16 flex-shrink-0">
                  <svg class="w-16 h-16 -rotate-90" viewBox="0 0 64 64">
                    <circle cx="32" cy="32" r="28" fill="none" stroke="#E2E8F0" stroke-width="5"/>
                    <circle cx="32" cy="32" r="28" fill="none" stroke="#2563EB" stroke-width="5"
                      :stroke-dasharray="175.9" :stroke-dashoffset="175.9 - (175.9 * answeredCount / totalQuestions)"
                      stroke-linecap="round" class="transition-all duration-700"/>
                  </svg>
                  <span class="absolute inset-0 flex items-center justify-center text-sm font-bold text-[#0F172A]">{{ answeredCount }}/{{ totalQuestions }}</span>
                </div>
                <div><p class="text-xs text-[#94A3B8]">已完成</p><p class="text-sm font-medium text-[#0F172A]">{{ Math.round(answeredCount/totalQuestions*100) }}%</p></div>
              </div>
              <div>
                <p class="text-xs text-[#94A3B8] font-medium mb-2 uppercase tracking-wide">覆盖维度</p>
                <div class="space-y-1.5">
                  <div v-for="g in questionnaire.groups" :key="g.label" class="flex items-center gap-2 text-xs">
                    <div class="w-1.5 h-1.5 rounded-full" :class="g.questions.every(q => isAnswered(q as any)) ? 'bg-[#2563EB]' : 'bg-[#CBD5E1]'"></div>
                    <span :class="g.questions.every(q => isAnswered(q as any)) ? 'text-[#475569]' : 'text-[#94A3B8]'">{{ g.label }}</span>
                    <span v-if="g.questions.every(q => isAnswered(q as any))" class="text-green-500 ml-auto">✓</span>
                  </div>
                </div>
              </div>
              <p class="text-[#94A3B8] text-[11px] leading-relaxed pt-2 border-t border-[#F1F5F9]">完成全部问题后，系统将生成初步筛查结果；涉及高风险内容时，将由君册专业人员复核。</p>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- 移动端底部进度条 -->
    <div class="lg:hidden fixed bottom-0 left-0 right-0 bg-white border-t border-[#E2E8F0] px-4 py-3 z-40 shadow-lg">
      <div class="flex items-center justify-between mb-1.5">
        <span class="text-xs font-medium text-[#64748B]">已完成 {{ answeredCount }} / {{ totalQuestions }}</span>
        <span class="text-xs text-[#2563EB] font-semibold">{{ totalQuestions > 0 ? Math.round(answeredCount/totalQuestions*100) : 0 }}%</span>
      </div>
      <div class="w-full h-1.5 bg-[#E2E8F0] rounded-full overflow-hidden">
        <div class="h-full bg-[#2563EB] rounded-full transition-all duration-500" :style="{width:(totalQuestions>0?answeredCount/totalQuestions*100:0)+'%'}"></div>
      </div>
    </div>
  </div>

</div>
</template>

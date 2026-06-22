<script setup lang="ts">
import { ref, computed, reactive, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { fetchQuestionnaire } from '../api/questionnaire';
import { submitQuestionnaire } from '../api/submissions';
import type { QuestionnaireResponse, QuestionDto } from '../types/api';

const router = useRouter();

// State
const loading = ref(true);
const error = ref('');
const questionnaire = ref<QuestionnaireResponse | null>(null);
const currentGroupIndex = ref(0);
const answers = reactive<Record<number, unknown>>({});
const phone = ref('');
const submitting = ref(false);
const submitError = ref('');

// Computed
const groups = computed(() => questionnaire.value?.groups ?? []);
const currentGroup = computed(() => groups.value[currentGroupIndex.value]);
const totalGroups = computed(() => groups.value.length);
const isFirstGroup = computed(() => currentGroupIndex.value === 0);
const isLastGroup = computed(() => currentGroupIndex.value === totalGroups.value - 1);

onMounted(async () => {
  try {
    questionnaire.value = await fetchQuestionnaire();
  } catch (e: unknown) {
    error.value = (e as { message?: string }).message || '加载问卷失败';
  } finally {
    loading.value = false;
  }
});

// Navigation
function goNext() {
  if (currentGroupIndex.value < totalGroups.value - 1) {
    currentGroupIndex.value++;
    window.scrollTo(0, 0);
  }
}

function goPrev() {
  if (currentGroupIndex.value > 0) {
    currentGroupIndex.value--;
    window.scrollTo(0, 0);
  }
}

// Answer handling
function setAnswer(questionId: number, value: unknown) {
  answers[questionId] = value;
}

function getAnswer(questionId: number): unknown {
  return answers[questionId];
}

// Check if current group has all required fields filled
const canProceed = computed(() => {
  if (!currentGroup.value) return false;
  return currentGroup.value.questions
    .filter((q) => q.required)
    .every((q) => {
      const v = answers[q.id];
      if (q.type === 'MULTI_CHOICE') return Array.isArray(v) && v.length > 0;
      return v !== undefined && v !== null && v !== '';
    });
});

// Submit
async function handleSubmit() {
  if (!questionnaire.value) return [];

  // Collect all answers for all groups
  const allAnswers = Object.entries(answers).map(([qId, value]) => ({
    questionId: Number(qId),
    value,
  }));

  // Also check all required questions
  const allQuestions = questionnaire.value.groups.flatMap((g) => g.questions);
  const missingRequired = allQuestions
    .filter((q) => q.required)
    .filter((q) => {
      const v = answers[q.id];
      if (q.type === 'MULTI_CHOICE') return !Array.isArray(v) || v.length === 0;
      return v === undefined || v === null || v === '';
    });

  if (missingRequired.length > 0) {
    submitError.value = `请完成所有必填题（共 ${missingRequired.length} 题未答）`;
    return;
  }

  submitting.value = true;
  submitError.value = '';

  try {
    const result = await submitQuestionnaire({
      questionnaireId: questionnaire.value.id,
      phone: phone.value || undefined,
      answers: allAnswers,
    });
    const params = new URLSearchParams({
      submissionPublicId: result.submissionPublicId,
      diagnosisStatus: result.diagnosisStatus || 'NOT_RUN',
      reportStatus: result.reportStatus || 'NOT_RUN',
    });
    if (result.reportPublicId) params.set('reportPublicId', result.reportPublicId);
    if (result.reportAccessToken) params.set('reportAccessToken', result.reportAccessToken);
    router.push(`/questionnaire/success?${params.toString()}`);
  } catch (e: unknown) {
    submitError.value = (e as { message?: string }).message || '提交失败，请重试';
  } finally {
    submitting.value = false;
  }
}

// Get options list for a question
function getOptionsList(q: QuestionDto): string[] {
  const opts = q.options as Record<string, unknown> | null;
  if (opts && Array.isArray(opts)) return opts as string[];
  if (opts && Array.isArray((opts as any).options)) return (opts as any).options as string[];
  return [];
}
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading -->
    <div v-if="loading" class="flex items-center justify-center h-screen">
      <p class="text-gray-500 text-lg">加载问卷中...</p>
    </div>

    <!-- Error -->
    <div v-else-if="error" class="flex items-center justify-center h-screen">
      <div class="text-center">
        <p class="text-red-500 text-lg mb-4">{{ error }}</p>
        <button @click="() => window.location.reload()" class="bg-blue-600 text-white px-4 py-2 rounded">
          重试
        </button>
      </div>
    </div>

    <!-- Questionnaire -->
    <div v-else-if="questionnaire" class="max-w-lg mx-auto px-4 py-6">
      <!-- Header -->
      <h1 class="text-2xl font-bold text-gray-800 mb-1">{{ questionnaire.title }}</h1>
      <p v-if="questionnaire.description" class="text-gray-400 text-sm mb-6">{{ questionnaire.description }}</p>

      <!-- Progress -->
      <div class="mb-6">
        <div class="flex justify-between text-sm text-gray-500 mb-1">
          <span>第 {{ currentGroupIndex + 1 }} / {{ totalGroups }} 组</span>
          <span>{{ currentGroup?.label }}</span>
        </div>
        <div class="w-full bg-gray-200 rounded-full h-2">
          <div
            class="bg-blue-600 h-2 rounded-full transition-all duration-300"
            :style="{ width: ((currentGroupIndex + 1) / totalGroups) * 100 + '%' }"
          ></div>
        </div>
      </div>

      <!-- Current Group Questions -->
      <div v-if="currentGroup" class="bg-white rounded-lg shadow-sm p-5 mb-6">
        <h2 class="text-lg font-semibold text-gray-700 mb-4">{{ currentGroup.label }}</h2>

        <div v-for="q in currentGroup.questions" :key="q.id" class="mb-5 last:mb-0">
          <label class="block text-gray-700 font-medium mb-2">
            {{ q.text }}
            <span v-if="q.required" class="text-red-500">*</span>
          </label>

          <!-- SINGLE_CHOICE -->
          <div v-if="q.type === 'SINGLE_CHOICE'" class="space-y-2">
            <label
              v-for="opt in getOptionsList(q)"
              :key="opt"
              class="flex items-center gap-2 p-2 rounded border border-gray-200 hover:border-blue-400 cursor-pointer transition"
              :class="{ 'border-blue-500 bg-blue-50': getAnswer(q.id) === opt }"
            >
              <input
                type="radio"
                :name="'q-' + q.id"
                :value="opt"
                :checked="getAnswer(q.id) === opt"
                @change="setAnswer(q.id, opt)"
                class="hidden"
              />
              <div
                class="w-5 h-5 rounded-full border-2 flex-shrink-0"
                :class="getAnswer(q.id) === opt ? 'border-blue-500 bg-blue-500' : 'border-gray-300'"
              >
                <div v-if="getAnswer(q.id) === opt" class="w-full h-full flex items-center justify-center">
                  <div class="w-2 h-2 bg-white rounded-full"></div>
                </div>
              </div>
              <span class="text-gray-700">{{ opt }}</span>
            </label>
          </div>

          <!-- MULTI_CHOICE -->
          <div v-else-if="q.type === 'MULTI_CHOICE'" class="space-y-2">
            <label
              v-for="opt in getOptionsList(q)"
              :key="opt"
              class="flex items-center gap-2 p-2 rounded border border-gray-200 hover:border-blue-400 cursor-pointer transition"
              :class="{ 'border-blue-500 bg-blue-50': Array.isArray(getAnswer(q.id)) && (getAnswer(q.id) as string[]).includes(opt) }"
            >
              <input
                type="checkbox"
                :value="opt"
                :checked="Array.isArray(getAnswer(q.id)) && (getAnswer(q.id) as string[]).includes(opt)"
                @change="(e: Event) => {
                  const t = e.target as HTMLInputElement;
                  const cur = (getAnswer(q.id) as string[]) || [];
                  setAnswer(q.id, t.checked ? [...cur, opt] : cur.filter(v => v !== opt));
                }"
                class="w-4 h-4 text-blue-600 rounded border-gray-300"
              />
              <span class="text-gray-700">{{ opt }}</span>
            </label>
          </div>

          <!-- YES_NO -->
          <div v-else-if="q.type === 'YES_NO'" class="flex gap-3">
            <button
              v-for="opt in getOptionsList(q)"
              :key="opt"
              @click="setAnswer(q.id, opt)"
              class="px-4 py-2 rounded border transition"
              :class="getAnswer(q.id) === opt
                ? 'border-blue-500 bg-blue-500 text-white'
                : 'border-gray-300 text-gray-600 hover:border-blue-400'"
            >
              {{ opt }}
            </button>
          </div>

          <!-- RANGE / TEXT -->
          <input
            v-else
            type="text"
            :value="getAnswer(q.id) || ''"
            @input="(e: Event) => setAnswer(q.id, (e.target as HTMLInputElement).value)"
            placeholder="请输入"
            class="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 focus:border-blue-500 focus:outline-none"
          />
        </div>
      </div>

      <!-- Navigation -->
      <div class="flex gap-3 mb-6">
        <button
          v-if="!isFirstGroup"
          @click="goPrev"
          class="flex-1 px-4 py-3 rounded-lg border border-gray-300 text-gray-600 hover:bg-gray-100 transition"
        >
          上一组
        </button>
        <button
          v-if="!isLastGroup"
          @click="goNext"
          :disabled="!canProceed"
          class="flex-1 px-4 py-3 rounded-lg bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-40 disabled:cursor-not-allowed transition"
        >
          下一组
        </button>
        <button
          v-if="isLastGroup"
          @click="handleSubmit"
          :disabled="submitting"
          class="flex-1 px-4 py-3 rounded-lg bg-green-600 text-white hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition font-semibold"
        >
          {{ submitting ? '提交中...' : '提交问卷' }}
        </button>
      </div>

      <!-- Phone input on last group -->
      <div v-if="isLastGroup" class="bg-white rounded-lg shadow-sm p-5 mb-6">
        <label class="block text-gray-700 font-medium mb-2">
          手机号（用于查看报告）
        </label>
        <input
          type="tel"
          v-model="phone"
          placeholder="请输入手机号"
          maxlength="11"
          class="w-full border border-gray-300 rounded px-3 py-2 text-gray-700 focus:border-blue-500 focus:outline-none"
        />
      </div>

      <!-- Submit Error -->
      <div v-if="submitError" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">
        {{ submitError }}
      </div>
    </div>
  </div>
</template>

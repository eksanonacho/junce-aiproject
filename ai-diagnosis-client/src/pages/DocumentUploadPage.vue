<template>
  <div class="min-h-screen bg-[#F2F5FC]">
    <!-- Nav -->
    <nav class="sticky top-0 z-50 bg-white/80 backdrop-blur border-b border-slate-200 px-4 py-3 flex items-center justify-between">
      <router-link to="/" class="text-xl font-bold text-[#1E3A8A]">君册财税</router-link>
      <span class="text-sm text-slate-500">{{ modeLabel }} · 资料上传</span>
    </nav>

    <div class="max-w-6xl mx-auto px-4 py-6">
      <!-- Header -->
      <div class="mb-6 text-center md:text-left">
        <h1 class="text-xl font-bold text-slate-900">上传经营资料</h1>
        <p class="text-sm text-slate-500 mt-1">资料越完整，初诊结果参考价值越高。可跳过直接填写问卷。</p>
      </div>

      <div v-if="store.checklist" class="flex flex-col lg:flex-row gap-6">
        <!-- Left: Checklist -->
        <div class="flex-1 space-y-3">
          <div
            v-for="req in categorizedRequirements"
            :key="req.code"
            class="bg-white rounded-xl p-4 border border-slate-200 hover:border-slate-300 transition cursor-pointer"
            @click="triggerUpload(req)"
          >
            <div class="flex items-start justify-between">
              <div class="flex-1">
                <div class="flex items-center gap-2 mb-1">
                  <span class="font-medium text-slate-900">{{ req.name }}</span>
                  <span v-if="req.required" class="text-xs px-1.5 py-0.5 bg-red-50 text-red-600 rounded">必传</span>
                  <span v-else class="text-xs px-1.5 py-0.5 bg-slate-100 text-slate-500 rounded">可选</span>
                </div>
                <p class="text-xs text-slate-500 mb-2">{{ req.description }}</p>
                <div class="flex flex-wrap gap-1">
                  <span
                    v-for="dim in (req.affectsDimensions as string[])"
                    :key="dim"
                    class="text-xs px-1.5 py-0.5 bg-blue-50 text-blue-600 rounded"
                  >{{ dimLabel(dim) }}</span>
                </div>
              </div>
              <div class="ml-4 shrink-0">
                <span v-if="req.uploaded" class="text-green-600 text-sm font-medium">✓ 已上传</span>
                <span v-else class="text-blue-600 text-sm">+ 上传</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Right: Completeness Panel -->
        <div class="lg:w-80 shrink-0">
          <div class="sticky top-20 bg-white rounded-xl p-5 border border-slate-200 shadow-sm">
            <h3 class="font-semibold text-slate-900 mb-4">资料完整度</h3>
            <div class="flex items-center justify-center mb-4">
              <svg class="w-24 h-24" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="42" fill="none" stroke="#E2E8F0" stroke-width="8" />
                <circle
                  cx="50" cy="50" r="42" fill="none"
                  :stroke="scoreColor"
                  stroke-width="8"
                  stroke-linecap="round"
                  :stroke-dasharray="2 * Math.PI * 42"
                  :stroke-dashoffset="2 * Math.PI * 42 * (1 - store.checklist.completenessScore / 100)"
                  transform="rotate(-90 50 50)"
                  class="transition-all duration-700"
                />
                <text x="50" y="48" text-anchor="middle" class="text-2xl font-bold" :fill="scoreColor">
                  {{ store.checklist.completenessScore }}%
                </text>
              </svg>
            </div>

            <div class="space-y-2 mb-4">
              <div v-for="dim in dimensions" :key="dim.key" class="flex items-center justify-between text-sm">
                <span class="text-slate-600">{{ dim.label }}</span>
                <div class="flex items-center gap-2">
                  <div class="w-20 h-2 bg-slate-100 rounded-full overflow-hidden">
                    <div
                      class="h-full rounded-full transition-all duration-500"
                      :class="dim.barClass"
                      :style="{ width: (store.checklist.dimensionConfidence[dim.key] || 0) + '%' }"
                    />
                  </div>
                  <span class="text-xs text-slate-500 w-8 text-right">{{ store.checklist.dimensionConfidence[dim.key] || 0 }}%</span>
                </div>
              </div>
            </div>

            <div v-if="store.checklist.missingDocuments.length" class="text-xs text-slate-500">
              <p class="font-medium text-amber-600 mb-1">缺失资料：</p>
              <ul class="list-disc list-inside space-y-0.5">
                <li v-for="m in store.checklist.missingDocuments" :key="m">{{ m }}</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div v-else class="text-center py-20 text-slate-400">加载资料清单中...</div>

      <!-- Actions -->
      <div class="flex gap-3 mt-8 justify-center">
        <router-link
          to="/questionnaire"
          class="px-6 py-3 rounded-xl border border-slate-300 text-slate-600 hover:bg-slate-50 transition"
        >
          跳过，直接填写问卷
        </router-link>
        <router-link
          to="/questionnaire"
          class="px-8 py-3 rounded-xl bg-[#1E3A8A] text-white font-medium hover:bg-[#1E40AF] shadow-lg transition"
        >
          继续填写问卷
        </router-link>
      </div>

      <!-- Hidden file input -->
      <input ref="fileInput" type="file" class="hidden" accept=".pdf,.xlsx,.xls,.docx,.doc,.jpg,.jpeg,.png" @change="onFileSelected" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useDiagnosisStore } from '../stores/diagnosis';

const store = useDiagnosisStore();
const fileInput = ref<HTMLInputElement>();
const pendingDocType = ref('');

const modeLabel = computed(() => {
  const map: Record<string, string> = { QUICK: '快速初诊', STANDARD: '标准初诊', DEEP: '深度出诊' };
  return map[store.mode] || store.mode;
});

const scoreColor = computed(() => {
  const s = store.checklist?.completenessScore || 0;
  if (s >= 70) return '#22C55E';
  if (s >= 40) return '#F59E0B';
  return '#EF4444';
});

const dimensions = [
  { key: 'PROFIT', label: '利润', barClass: 'bg-blue-500' },
  { key: 'RISK', label: '风险', barClass: 'bg-red-500' },
  { key: 'CASH_FLOW', label: '现金流', barClass: 'bg-green-500' },
  { key: 'EFFICIENCY', label: '效率', barClass: 'bg-purple-500' },
];

function dimLabel(dim: string): string {
  const map: Record<string, string> = {
    PROFIT: '利润', RISK: '风险', CASH_FLOW: '现金流', EFFICIENCY: '效率',
  };
  return map[dim] || dim;
}

const categorizedRequirements = computed(() => {
  if (!store.checklist) return [];
  return store.checklist.requirements;
});

function triggerUpload(req: any) {
  pendingDocType.value = req.code;
  fileInput.value?.click();
}

async function onFileSelected(e: Event) {
  const target = e.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file || !pendingDocType.value) return;
  try {
    await store.uploadDoc(pendingDocType.value, file);
  } catch {
    // error handled in store
  }
  target.value = '';
  pendingDocType.value = '';
}

onMounted(() => {
  store.loadChecklist();
});
</script>

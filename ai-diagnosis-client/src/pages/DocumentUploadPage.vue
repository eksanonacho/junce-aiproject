<template>
  <div class="min-h-screen" style="background: linear-gradient(180deg, #F1F5F9 0%, #F8FAFC 100%);">
    <nav class="border-b border-slate-200 bg-white/90 backdrop-blur sticky top-0 z-50">
      <div class="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
        <router-link to="/" class="font-bold text-lg text-[#0F172A] tracking-tight">君册财税</router-link>
        <span class="text-[13px] text-slate-500 font-medium">{{ modeLabel }}</span>
      </div>
    </nav>

    <div class="max-w-6xl mx-auto px-4 py-6 md:py-10">
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-[22px] md:text-[26px] font-extrabold text-[#0F172A] tracking-tight">上传经营诊断资料</h1>
        <p class="mt-1.5 text-[14px] text-slate-500 max-w-xl">
          资料越完整，四维经营看板的参考价值越高。您也可以先跳过，后续由君册顾问补充确认。
        </p>
      </div>

      <div v-if="store.checklist" class="flex flex-col lg:flex-row gap-6">
        <!-- Left: Checklist -->
        <div class="flex-1 space-y-2.5">
          <div
            v-for="req in store.checklist.requirements"
            :key="req.code"
            @click="triggerUpload(req)"
            class="bg-white rounded-2xl px-4 py-3.5 border transition-all duration-200 cursor-pointer"
            :class="req.uploaded ? 'border-green-200 bg-green-50/30' : 'border-[#E2E8F0] hover:border-slate-300 hover:shadow-sm'"
          >
            <div class="flex items-start gap-3">
              <!-- Status icon -->
              <div class="shrink-0 mt-0.5 w-5 h-5 rounded-full border-2 flex items-center justify-center"
                :class="req.uploaded ? 'border-green-500 bg-green-500' : 'border-slate-300'">
                <span v-if="req.uploaded" class="text-white text-[10px] font-bold leading-none">&#10003;</span>
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center gap-2 flex-wrap">
                  <span class="font-semibold text-[14px] text-[#0F172A]">{{ req.name }}</span>
                  <span v-if="req.required" class="text-[10px] px-1.5 py-0.5 rounded font-medium bg-red-50 text-red-600">必传</span>
                  <span v-else class="text-[10px] px-1.5 py-0.5 rounded font-medium bg-slate-100 text-slate-500">建议</span>
                </div>
                <p class="text-[12px] text-slate-500 mt-0.5 leading-relaxed">{{ req.description }}</p>
                <div class="flex flex-wrap gap-1 mt-1.5">
                  <span v-for="dim in (req.affectsDimensions as string[])" :key="dim"
                    class="text-[10px] px-1.5 py-0.5 rounded font-medium"
                    :class="dimColor(dim)">{{ dimLabel(dim) }}</span>
                </div>
                <!-- Uploaded file info -->
                <div v-if="req.uploaded && req.uploadedDocument" class="mt-2 flex items-center gap-2 text-[12px] text-slate-500">
                  <span class="text-green-600 font-medium">已上传</span>
                  <span class="text-slate-400">{{ req.uploadedDocument.originalName }}</span>
                  <button @click.stop="removeFile(req)" class="text-red-500 hover:text-red-700 text-[11px]">删除</button>
                </div>
              </div>
              <div class="shrink-0 text-[12px] font-medium" :class="req.uploaded ? 'text-green-600' : 'text-[#1E3A8A]'">
                {{ req.uploaded ? '已传' : '上传' }}
              </div>
            </div>
          </div>
        </div>

        <!-- Right: Completeness Panel -->
        <div class="lg:w-80 shrink-0">
          <div class="sticky top-20 bg-white rounded-2xl border border-[#E2E8F0] shadow-sm overflow-hidden">
            <div class="px-5 py-4 border-b border-slate-100">
              <h3 class="font-semibold text-[15px] text-[#0F172A]">资料完整度评估</h3>
            </div>
            <div class="px-5 py-4 space-y-4">
              <!-- Score ring -->
              <div class="flex items-center gap-4">
                <svg class="w-20 h-20 shrink-0" viewBox="0 0 100 100">
                  <circle cx="50" cy="50" r="40" fill="none" stroke="#F1F5F9" stroke-width="8"/>
                  <circle cx="50" cy="50" r="40" fill="none" :stroke="scoreColor" stroke-width="8"
                    stroke-linecap="round" transform="rotate(-90 50 50)"
                    :stroke-dasharray="2 * Math.PI * 40"
                    :stroke-dashoffset="2 * Math.PI * 40 * (1 - (store.checklist.completenessScore || 0) / 100)"
                    class="transition-all duration-700"/>
                  <text x="50" y="46" text-anchor="middle" class="text-[20px] font-extrabold" :fill="scoreColor">
                    {{ store.checklist.completenessScore || 0 }}%
                  </text>
                  <text x="50" y="62" text-anchor="middle" class="text-[10px]" fill="#94A3B8">完整度</text>
                </svg>
                <div class="text-[12px] text-slate-500 leading-relaxed">
                  <p v-if="(store.checklist.completenessScore || 0) >= 50">资料较为完整，看板可信度较高。</p>
                  <p v-else-if="(store.checklist.completenessScore || 0) >= 20">可补充更多资料以提升看板可信度。</p>
                  <p v-else>当前资料较少，系统将主要基于问卷生成初步判断。建议补充利润表、银行流水等核心资料。</p>
                </div>
              </div>

              <!-- Dimension confidence bars -->
              <div class="space-y-2">
                <div v-for="dim in dimensions" :key="dim.key" class="flex items-center gap-2">
                  <span class="text-[11px] text-slate-500 w-12 shrink-0">{{ dim.label }}</span>
                  <div class="flex-1 h-1.5 bg-slate-100 rounded-full overflow-hidden">
                    <div class="h-full rounded-full transition-all duration-500" :class="dim.barClass"
                      :style="{ width: (store.checklist.dimensionConfidence[dim.key] || 0) + '%' }"/>
                  </div>
                  <span class="text-[11px] text-slate-400 w-8 text-right">{{ store.checklist.dimensionConfidence[dim.key] || 0 }}%</span>
                </div>
              </div>

              <!-- Missing -->
              <div v-if="store.checklist.missingDocuments.length" class="pt-2 border-t border-slate-100">
                <p class="text-[11px] font-medium text-slate-500 mb-1.5">建议优先补充</p>
                <div class="flex flex-wrap gap-1">
                  <span v-for="m in store.checklist.missingDocuments.slice(0,5)" :key="m"
                    class="text-[10px] px-2 py-0.5 rounded-full bg-amber-50 text-amber-700 border border-amber-100">{{ m }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-20 text-slate-400 text-[14px]">加载资料清单中...</div>

      <!-- Bottom actions -->
      <div class="flex items-center justify-center gap-4 mt-10 pt-6 border-t border-slate-200">
        <button @click="router.push('/questionnaire')"
          class="px-6 py-2.5 rounded-xl border border-slate-300 text-[14px] text-slate-600 hover:bg-slate-50 transition font-medium">
          跳过，直接填写问卷
        </button>
        <button @click="router.push('/questionnaire')"
          class="px-8 py-2.5 rounded-xl bg-[#0F172A] text-white text-[14px] font-semibold hover:bg-[#1E293B] transition shadow-lg shadow-slate-900/10">
          继续填写问卷
        </button>
      </div>

      <input ref="fileInput" type="file" class="hidden" accept=".pdf,.xlsx,.xls,.docx,.doc,.jpg,.jpeg,.png" @change="onFileSelected"/>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useDiagnosisStore } from '../stores/diagnosis';

const router = useRouter();
const store = useDiagnosisStore();
const fileInput = ref<HTMLInputElement>();
const pendingDocType = ref('');

const modeLabel = computed(() => {
  const map: Record<string, string> = { QUICK: '快速初诊', STANDARD: '标准初诊', DEEP: '深度经营出诊' };
  return map[store.mode] || '标准初诊';
});

const scoreColor = computed(() => {
  const s = store.checklist?.completenessScore || 0;
  if (s >= 70) return '#16A34A'; if (s >= 40) return '#D97706'; return '#DC2626';
});

const dimensions = [
  { key: 'PROFIT', label: '利润', barClass: 'bg-blue-500' },
  { key: 'RISK', label: '风险', barClass: 'bg-red-500' },
  { key: 'CASH_FLOW', label: '现金流', barClass: 'bg-emerald-500' },
  { key: 'EFFICIENCY', label: '效率', barClass: 'bg-violet-500' },
];

function dimLabel(dim: string): string {
  const map: Record<string, string> = { PROFIT: '利润', RISK: '风险', CASH_FLOW: '现金流', EFFICIENCY: '效率' };
  return map[dim] || dim;
}

function dimColor(dim: string): string {
  const map: Record<string, string> = { PROFIT: 'bg-blue-50 text-blue-700', RISK: 'bg-red-50 text-red-700', CASH_FLOW: 'bg-emerald-50 text-emerald-700', EFFICIENCY: 'bg-violet-50 text-violet-700' };
  return map[dim] || 'bg-slate-50 text-slate-600';
}

function triggerUpload(req: any) { pendingDocType.value = req.code; fileInput.value?.click(); }

async function onFileSelected(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file || !pendingDocType.value) return;
  try { await store.uploadDoc(pendingDocType.value, file); } catch { /* store handles error */ }
  (e.target as HTMLInputElement).value = ''; pendingDocType.value = '';
}

async function removeFile(req: any) {
  if (!req.uploadedDocument?.publicId) return;
  try { await store.removeDoc(req.uploadedDocument.publicId); } catch { /* store handles error */ }
}

onMounted(() => { store.loadChecklist(); });
</script>

<template>
  <div class="min-h-screen" style="background: linear-gradient(180deg, #F1F5F9 0%, #F8FAFC 100%);">
    <!-- Brand Nav -->
    <nav class="border-b border-slate-200 bg-white/90 backdrop-blur sticky top-0 z-50">
      <div class="max-w-4xl mx-auto px-4 h-14 flex items-center justify-between">
        <router-link to="/" class="font-bold text-lg text-[#0F172A] tracking-tight">君册财税 <span class="text-[#1E3A8A] font-normal text-sm ml-1">企业经营初诊</span></router-link>
      </div>
    </nav>

    <div class="max-w-3xl mx-auto px-4 py-8 md:py-14">
      <!-- Hero -->
      <div class="text-center mb-10">
        <h1 class="text-[28px] md:text-[36px] font-extrabold text-[#0F172A] tracking-tight leading-tight">
          开始企业经营初诊
        </h1>
        <p class="mt-3 text-[15px] text-slate-500 max-w-lg mx-auto leading-relaxed">
          上传经营资料并补充关键信息，系统将生成<span class="text-[#0F172A] font-semibold">利润、风险、现金流、效率</span>四维经营看板。
        </p>
      </div>

      <!-- Dashboard Preview Strip -->
      <div class="grid grid-cols-4 gap-2 md:gap-3 mb-10 px-2">
        <div v-for="d in previewDims" :key="d.key" class="bg-white rounded-xl border border-slate-200 px-3 py-3 text-center shadow-sm">
          <div class="text-[10px] text-slate-400 uppercase tracking-wide mb-1">{{ d.label }}</div>
          <div class="text-lg font-bold text-[#0F172A]">—</div>
          <div class="text-[10px] text-slate-400">/ 5.0</div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 px-3 py-3 text-center shadow-sm">
          <div class="text-[10px] text-slate-400 uppercase tracking-wide mb-1">资料完整</div>
          <div class="text-lg font-bold text-[#0F172A]">—</div>
          <div class="text-[10px] text-slate-400">%</div>
        </div>
        <div class="bg-white rounded-xl border border-slate-200 px-3 py-3 text-center shadow-sm">
          <div class="text-[10px] text-slate-400 uppercase tracking-wide mb-1">人工复核</div>
          <div class="text-xs text-slate-400 mt-0.5">专业人员</div>
          <div class="text-[10px] text-slate-400">确认</div>
        </div>
      </div>

      <!-- Phone -->
      <div class="max-w-sm mx-auto mb-10">
        <label class="block text-sm font-medium text-slate-700 mb-1.5">手机号</label>
        <input
          v-model="phone"
          type="tel" maxlength="11"
          placeholder="输入手机号开始初诊"
          class="w-full px-4 py-3 rounded-xl border border-slate-300 bg-white text-[15px] placeholder-slate-400 focus:border-[#1E3A8A] focus:ring-2 focus:ring-[#1E3A8A]/10 outline-none transition"
        />
      </div>

      <!-- Mode Cards -->
      <div class="space-y-3 mb-10">
        <div
          v-for="m in modes"
          :key="m.code"
          @click="selectedMode = m.code"
          class="cursor-pointer rounded-2xl px-5 py-4 border-2 transition-all duration-200"
          :class="selectedMode === m.code
            ? 'border-[#1E3A8A] bg-[#EEF2FF] ring-1 ring-[#1E3A8A]/20'
            : 'border-[#E2E8F0] bg-white hover:border-slate-300 hover:shadow-sm'"
        >
          <div class="flex items-start gap-4">
            <!-- Radio indicator -->
            <div class="shrink-0 mt-0.5 w-5 h-5 rounded-full border-2 flex items-center justify-center"
              :class="selectedMode === m.code ? 'border-[#1E3A8A]' : 'border-slate-300'">
              <div v-if="selectedMode === m.code" class="w-2.5 h-2.5 rounded-full bg-[#1E3A8A]" />
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
      </div>

      <!-- Error -->
      <p v-if="error" class="text-red-600 text-[13px] text-center mb-4">{{ error }}</p>

      <!-- CTA -->
      <div class="max-w-sm mx-auto">
        <button
          @click="handleStart"
          :disabled="loading || !phone || phone.length < 11"
          class="w-full py-3.5 rounded-xl font-semibold text-[15px] transition-all duration-200"
          :class="(phone && phone.length >= 11)
            ? 'bg-[#0F172A] text-white hover:bg-[#1E293B] shadow-lg shadow-slate-900/10'
            : 'bg-slate-200 text-slate-400 cursor-not-allowed'"
        >
          {{ loading ? '创建中...' : '开始企业初诊' }}
        </button>
        <p class="text-[12px] text-slate-400 text-center mt-4 leading-relaxed">
          本系统仅作为企业经营与财税风险初步筛查参考，不构成最终税务、法律或审计结论。
        </p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { useDiagnosisStore } from '../stores/diagnosis';

const router = useRouter();
const store = useDiagnosisStore();

const phone = ref('');
const selectedMode = ref('STANDARD');
const loading = ref(false);
const error = ref('');

const previewDims = [
  { key: 'PROFIT', label: '利润' },
  { key: 'RISK', label: '风险' },
  { key: 'CASH_FLOW', label: '现金流' },
  { key: 'EFFICIENCY', label: '效率' },
];

const modes = [
  { code: 'QUICK', name: '快速初诊', desc: '4类基础资料 + 约22题，适合初步了解企业经营健康概况。', docCount: 4, questionCount: '~22', output: '基础概览', recommended: false },
  { code: 'STANDARD', name: '标准初诊', desc: '10类资料 + 约40题，生成完整四维经营看板与TOP3优先行动建议。', docCount: 10, questionCount: '~40', output: '四维看板 + TOP3行动', recommended: true },
  { code: 'DEEP', name: '深度经营出诊', desc: '18类详细资料 + 完整题库，适合顾问深度服务场景。', docCount: 18, questionCount: '~65', output: '完整诊断 + 定制建议', recommended: false },
];

async function handleStart() {
  if (!phone.value || phone.value.length < 11) return;
  loading.value = true;
  error.value = '';
  try {
    await store.startDiagnosis(phone.value, selectedMode.value);
    router.push('/diagnosis/upload');
  } catch (e: any) {
    error.value = e.message || '创建失败，请重试';
  } finally {
    loading.value = false;
  }
}
</script>

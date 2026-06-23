<template>
  <div class="min-h-screen bg-[#F2F5FC]">
    <!-- Nav -->
    <nav class="sticky top-0 z-50 bg-white/80 backdrop-blur border-b border-slate-200 px-4 py-3 flex items-center justify-between">
      <router-link to="/" class="text-xl font-bold text-[#1E3A8A]">君册财税</router-link>
      <span class="text-sm text-slate-500">企业经营初诊</span>
    </nav>

    <div class="max-w-2xl mx-auto px-4 py-12">
      <!-- Phone Input -->
      <div class="mb-10 text-center">
        <h1 class="text-2xl font-bold text-slate-900 mb-2">开始企业经营初诊</h1>
        <p class="text-slate-500 mb-6">输入手机号，选择初诊模式，获取专属经营看板</p>
        <div class="max-w-sm mx-auto">
          <label class="block text-sm text-slate-600 mb-1 text-left">手机号</label>
          <input
            v-model="phone"
            type="tel"
            maxlength="11"
            placeholder="请输入手机号"
            class="w-full px-4 py-3 rounded-xl border border-slate-300 focus:border-[#1E3A8A] focus:ring-2 focus:ring-[#1E3A8A]/20 outline-none text-lg transition"
          />
        </div>
      </div>

      <!-- Mode Selector -->
      <div class="space-y-4">
        <div
          v-for="m in modes"
          :key="m.code"
          @click="selectedMode = m.code"
          class="cursor-pointer rounded-2xl p-5 border-2 transition-all duration-200"
          :class="selectedMode === m.code
            ? 'border-[#1E3A8A] bg-[#1E3A8A]/5 shadow-md'
            : 'border-slate-200 bg-white hover:border-slate-300 hover:shadow-sm'"
        >
          <div class="flex items-start justify-between mb-2">
            <div>
              <h3 class="text-lg font-semibold text-slate-900">{{ m.name }}</h3>
              <p class="text-sm text-slate-500">{{ m.subtitle }}</p>
            </div>
            <span
              v-if="m.recommended"
              class="shrink-0 ml-3 px-2 py-0.5 bg-amber-100 text-amber-700 text-xs font-medium rounded-full"
            >推荐</span>
          </div>
          <p class="text-sm text-slate-600 mb-2">{{ m.desc }}</p>
          <div class="flex flex-wrap gap-2 text-xs text-slate-500">
            <span class="px-2 py-1 bg-slate-100 rounded">{{ m.docCount }} 类资料</span>
            <span class="px-2 py-1 bg-slate-100 rounded">{{ m.questionCount }} 题问卷</span>
          </div>
        </div>
      </div>

      <!-- Error -->
      <p v-if="error" class="text-red-500 text-sm mt-4 text-center">{{ error }}</p>

      <!-- CTA -->
      <button
        @click="handleStart"
        :disabled="loading || !phone || phone.length < 11"
        class="mt-8 w-full py-4 rounded-xl text-white font-semibold text-lg transition-all duration-200"
        :class="(phone && phone.length >= 11)
          ? 'bg-[#1E3A8A] hover:bg-[#1E40AF] shadow-lg'
          : 'bg-slate-300 cursor-not-allowed'"
      >
        {{ loading ? '正在创建...' : '开始初诊' }}
      </button>

      <p class="text-xs text-slate-400 text-center mt-4">
        本系统仅作为企业经营与财税风险初步筛查参考
      </p>
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

const modes = [
  {
    code: 'QUICK',
    name: '快速初诊',
    subtitle: '适合第一次体验',
    desc: '仅需上传4类基础资料，填写20-25题，快速了解企业经营健康概览。',
    docCount: 4,
    questionCount: '20-25',
    recommended: false,
  },
  {
    code: 'STANDARD',
    name: '标准初诊',
    subtitle: '正式演示 · 一期主流程',
    desc: '推荐上传10类资料，填写35-45题，生成完整四维经营看板和TOP3行动建议。',
    docCount: 10,
    questionCount: '35-45',
    recommended: true,
  },
  {
    code: 'DEEP',
    name: '深度经营出诊',
    subtitle: '适合后续顾问深度服务',
    desc: '上传18类详细资料，填写50-65题，获取全面经营诊断和定制化建议。',
    docCount: 18,
    questionCount: '50-65',
    recommended: false,
  },
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

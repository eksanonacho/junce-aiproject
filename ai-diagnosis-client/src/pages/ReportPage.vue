<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { getReport } from '../api/reports';
import type { ReportDetail } from '../types/api';

const route = useRoute();
const publicId = route.params.publicId as string;
const token = route.query.token as string;

function printReport() { window.print(); }

const loading = ref(true);
const error = ref('');
const report = ref<ReportDetail | null>(null);

onMounted(async () => {
  if (!token) {
    error.value = '缺少报告访问凭证';
    loading.value = false;
    return;
  }
  try {
    report.value = await getReport(publicId, token);
  } catch (e: unknown) {
    error.value = (e as { message?: string }).message || '获取报告失败';
  } finally {
    loading.value = false;
  }
});

function levelLabel(level: string) {
  switch (level) {
    case 'HIGH': return '高风险';
    case 'MEDIUM': return '中风险';
    case 'LOW': return '低风险';
    default: return '无法判断';
  }
}
function levelColor(level: string) {
  switch (level) {
    case 'HIGH': return 'bg-red-500';
    case 'MEDIUM': return 'bg-orange-500';
    case 'LOW': return 'bg-green-500';
    default: return 'bg-gray-400';
  }
}
function priorityLabel(p: string) {
  switch (p) {
    case 'STRONG': return '建议优先了解';
    case 'SUGGEST': return '建议关注';
    case 'INFO': return '可作为后续优化方向';
    default: return '建议关注';
  }
}
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading -->
    <div v-if="loading" class="flex items-center justify-center h-screen">
      <p class="text-gray-500 text-lg">加载报告中...</p>
    </div>

    <!-- Error -->
    <div v-else-if="error" class="flex items-center justify-center h-screen">
      <div class="text-center px-4">
        <p class="text-red-500 text-lg mb-4">{{ error }}</p>
        <router-link to="/" class="text-blue-600 underline">返回首页</router-link>
      </div>
    </div>

    <!-- Pending Review -->
    <div v-else-if="report && !report.customerVisible" class="flex items-center justify-center h-screen px-4">
      <div class="bg-white rounded-lg shadow-sm p-8 max-w-md w-full text-center">
        <div class="w-16 h-16 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
          <svg class="w-8 h-8 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m0 0v2m0-2h2m-2 0H10m9.364-7.364A9 9 0 1112 3a9 9 0 017.364 4.636z" />
          </svg>
        </div>
        <h1 class="text-xl font-bold text-gray-800 mb-2">报告待复核</h1>
        <p class="text-gray-500 mb-4">{{ report.message || '该报告需要专业人员复核后展示' }}</p>
        <router-link to="/" class="text-blue-600 underline">返回首页</router-link>
      </div>
    </div>

    <!-- Report Content -->
    <div v-else-if="report" class="max-w-2xl mx-auto px-4 py-6">
      <!-- Print Button (customerVisible only) -->
      <div v-if="report.customerVisible" class="no-print text-center mb-4">
        <button @click="printReport" class="px-5 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 text-sm font-medium">
          🖨️ 打印 / 保存 PDF
        </button>
        <p class="text-gray-400 text-xs mt-1">点击后可在浏览器打印窗口中选择"保存为 PDF"</p>
      </div>

      <!-- Header -->
      <div class="text-center mb-6 print-section">
        <h1 class="text-xl font-bold text-gray-800">{{ report.title }}</h1>
        <p class="text-gray-400 text-sm mt-1">报告编号：{{ report.reportNumber }}</p>
        <p class="text-gray-400 text-sm">生成时间：{{ report.generatedAt?.slice(0, 10) }}</p>
      </div>

      <!-- Disclaimer -->
      <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mb-5 text-sm text-yellow-700 print-section">
        ⚠️ {{ report.disclaimer }}
      </div>

      <!-- Company Profile -->
      <div v-if="report.companyProfile" class="bg-white rounded-lg shadow-sm p-4 mb-5 print-section">
        <h2 class="font-semibold text-gray-700 mb-2">企业基础画像</h2>
        <div v-for="(v, k) in report.companyProfile" :key="k" class="flex text-sm py-1 border-b border-gray-100 last:border-0">
          <span class="text-gray-400 w-24 flex-shrink-0">{{ k }}</span>
          <span class="text-gray-700">{{ v }}</span>
        </div>
      </div>

      <!-- Risk Level -->
      <div class="text-center mb-5 print-section">
        <span :class="`inline-block ${levelColor(report.riskLevel)} text-white px-5 py-2 rounded-xl text-lg font-bold`">
          {{ levelLabel(report.riskLevel) }}
        </span>
        <p v-if="report.summary" class="text-gray-600 text-sm mt-2">{{ report.summary }}</p>
      </div>

      <!-- Findings -->
      <div v-if="report.findings && report.findings.length > 0" class="mb-5">
        <h2 class="font-semibold text-gray-700 mb-2">发现的问题</h2>
        <div v-for="(f, i) in report.findings" :key="i" class="bg-white rounded-lg shadow-sm p-4 mb-2 border-l-4" :class="f.riskLevel === 'HIGH' ? 'border-red-500' : f.riskLevel === 'MEDIUM' ? 'border-orange-400' : 'border-gray-300'">
          <div class="flex items-center gap-2 mb-1">
            <span :class="`text-xs px-2 py-0.5 rounded text-white ${levelColor(f.riskLevel)}`">{{ levelLabel(f.riskLevel) }}</span>
            <strong class="text-gray-800">{{ f.title }}</strong>
          </div>
          <p class="text-gray-500 text-sm mb-1">{{ f.description }}</p>
          <p class="text-gray-400 text-xs">💡 {{ f.suggestion }}</p>
        </div>
      </div>

      <!-- Recommendations -->
      <div v-if="report.recommendations && report.recommendations.length > 0" class="mb-5">
        <h2 class="font-semibold text-gray-700 mb-2">推荐服务</h2>
        <div v-for="(r, i) in report.recommendations" :key="i" class="bg-white rounded-lg shadow-sm p-3 mb-2 flex items-center gap-3">
          <span class="text-xs text-blue-500 whitespace-nowrap">{{ priorityLabel(r.priority) }}</span>
          <strong class="text-gray-700 text-sm">{{ r.serviceType }}</strong>
          <span class="text-gray-400 text-xs ml-auto">{{ r.reason }}</span>
        </div>
        <p class="text-gray-400 text-xs">* 以上服务建议基于您填写的内容生成，具体方案请联系君册顾问确认。</p>
      </div>

      <!-- Footer -->
      <div class="text-center bg-white rounded-lg shadow-sm p-4 mt-6">
        <p class="text-gray-600 text-sm">📞 如需专业建议，请联系君册财税顾问</p>
        <p class="text-gray-400 text-xs mt-1">本报告仅作为初步风险筛查参考，不构成最终税务、法律或财务处理意见</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute();
const submissionPublicId = route.query.submissionPublicId as string;
const diagnosisStatus = route.query.diagnosisStatus as string;

const statusLabel = computed(() => {
  switch (diagnosisStatus) {
    case 'COMPLETED': return '诊断已完成';
    case 'NOT_RUN': return '诊断未运行';
    case 'FAILED': return '诊断失败';
    default: return '诊断状态未知';
  }
});

const statusColor = computed(() => {
  switch (diagnosisStatus) {
    case 'COMPLETED': return 'text-green-600 bg-green-50 border-green-200';
    case 'FAILED': return 'text-red-600 bg-red-50 border-red-200';
    default: return 'text-yellow-600 bg-yellow-50 border-yellow-200';
  }
});
</script>

<template>
  <div class="min-h-screen bg-gray-50 flex flex-col items-center justify-center px-4">
    <div class="bg-white rounded-lg shadow-sm p-8 max-w-md w-full text-center">
      <!-- Check icon -->
      <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <svg class="w-8 h-8 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
        </svg>
      </div>

      <h1 class="text-2xl font-bold text-gray-800 mb-2">提交成功</h1>
      <p class="text-gray-500 mb-4">感谢您的填写！</p>

      <!-- Diagnosis Status -->
      <div :class="`inline-block px-4 py-2 rounded-lg border text-sm font-medium mb-6 ${statusColor}`">
        {{ statusLabel }}
      </div>

      <div class="bg-gray-50 rounded p-3 mb-6 text-left">
        <p class="text-xs text-gray-400 mb-1">提交编号</p>
        <p class="text-sm text-gray-700 font-mono break-all">{{ submissionPublicId }}</p>
      </div>

      <p class="text-sm text-gray-400 mb-8">
        系统已根据您的填写内容完成初步诊断。<br />
        报告生成功能将在后续版本开放。
      </p>

      <router-link
        to="/"
        class="inline-block px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
      >
        返回首页
      </router-link>
    </div>
  </div>
</template>

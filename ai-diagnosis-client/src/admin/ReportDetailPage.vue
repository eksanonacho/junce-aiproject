<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { getReportDetail, reviewReport, updateReport, getUser, clearAuth } from '../api/admin';
import type { ReportDetail } from '../api/admin';

const route = useRoute();
const router = useRouter();
const publicId = route.params.publicId as string;
const report = ref<ReportDetail | null>(null);
const loading = ref(true);
const comment = ref('');
const actionMsg = ref('');
const user = getUser();

onMounted(async () => {
  try { report.value = await getReportDetail(publicId); } catch { clearAuth(); router.push('/admin/login'); }
  finally { loading.value = false; }
});

async function handleReview(action: string) {
  try { await reviewReport(publicId, action, comment.value); actionMsg.value = `${action} 成功`; location.reload(); }
  catch (e: unknown) { actionMsg.value = (e as { message?: string }).message || '操作失败'; }
}

async function handleUpdate(body: Record<string, unknown>) {
  try { await updateReport(publicId, { ...body, comment: comment.value }); actionMsg.value = '修改成功'; location.reload(); }
  catch (e: unknown) { actionMsg.value = (e as { message?: string }).message || '修改失败'; }
}

function levelLabel(l: string) { return l === 'HIGH' ? '高风险' : l === 'MEDIUM' ? '中风险' : l === 'LOW' ? '低风险' : l; }

function back() { router.push('/admin/submissions'); }
</script>

<template>
  <div class="min-h-screen bg-gray-100 p-4">
    <div class="max-w-4xl mx-auto">
      <button @click="back" class="text-blue-600 text-sm mb-4">&larr; 返回列表</button>
      <div v-if="loading" class="text-gray-500 text-center py-8">加载中...</div>
      <div v-else-if="report" class="space-y-4">
        <!-- Info -->
        <div class="bg-white rounded-lg shadow-sm p-4">
          <div class="flex justify-between items-start">
            <div>
              <h1 class="font-bold text-lg">{{ report.reportNumber }}</h1>
              <p class="text-gray-500 text-sm">风险: {{ levelLabel(report.riskLevel) }} | 复核: {{ report.reviewStatus }} | 客户可见: {{ report.customerVisible ? '是' : '否' }}</p>
            </div>
          </div>
        </div>
        <!-- Actions -->
        <div class="bg-white rounded-lg shadow-sm p-4">
          <h2 class="font-semibold mb-2">复核操作</h2>
          <div class="flex gap-2 mb-2">
            <button @click="handleReview('APPROVE')" class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 text-sm">通过</button>
            <button @click="handleReview('REJECT')" class="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 text-sm">驳回</button>
          </div>
          <input v-model="comment" placeholder="复核备注" class="w-full border px-2 py-1 rounded text-sm mb-2" />
          <div v-if="actionMsg" class="text-sm text-gray-600">{{ actionMsg }}</div>
        </div>
        <!-- HTML Content (editable for MANAGER+) -->
        <div v-if="report.htmlContent" class="bg-white rounded-lg shadow-sm p-4">
          <h2 class="font-semibold mb-2">报告内容</h2>
          <div v-if="user?.role === 'MANAGER' || user?.role === 'ADMIN'" class="mb-2">
            <textarea v-model="report.htmlContent" class="w-full border px-2 py-1 rounded text-xs h-64 font-mono"></textarea>
            <button @click="handleUpdate({ htmlContent: report.htmlContent })" class="mt-1 px-3 py-1 bg-blue-600 text-white rounded text-sm">保存修改</button>
          </div>
          <div v-html="report.htmlContent" class="border rounded p-3 mt-2 max-h-96 overflow-auto text-sm"></div>
        </div>
        <!-- Findings -->
        <div v-if="report.findings.length" class="bg-white rounded-lg shadow-sm p-4">
          <h2 class="font-semibold mb-2">发现的问题 ({{ report.findings.length }})</h2>
          <div v-for="(f, i) in report.findings" :key="i" class="border-b py-1 text-sm">
            <span class="font-medium">{{ (f as any).title }}</span>
            <span class="text-gray-500"> — {{ (f as any).suggestion }}</span>
          </div>
        </div>
        <!-- Review Records -->
        <div class="bg-white rounded-lg shadow-sm p-4">
          <h2 class="font-semibold mb-2">复核记录</h2>
          <div v-if="!report.reviewRecords.length" class="text-gray-400 text-sm">暂无记录</div>
          <div v-for="(r, i) in report.reviewRecords" :key="i" class="border-b py-1 text-sm text-gray-600">
            [{{ (r as any).createdAt?.slice(0,16) }}] {{ (r as any).reviewerName }}: {{ (r as any).action }}
            <span v-if="(r as any).comment"> — {{ (r as any).comment }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

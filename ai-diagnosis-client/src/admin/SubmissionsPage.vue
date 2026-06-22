<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { getSubmissions, clearAuth } from '../api/admin';
import type { SubmissionItem } from '../api/admin';

const router = useRouter();
const items = ref<SubmissionItem[]>([]);
const total = ref(0);
const loading = ref(true);
const filterRisk = ref('');
const filterReview = ref('');

async function load() {
  loading.value = true;
  try {
    const params: Record<string, string> = {};
    if (filterRisk.value) params.riskLevel = filterRisk.value;
    if (filterReview.value) params.reviewStatus = filterReview.value;
    const res = await getSubmissions(params);
    items.value = res.items;
    total.value = res.total;
  } catch { clearAuth(); router.push('/admin/login'); }
  finally { loading.value = false; }
}

onMounted(load);

function levelColor(l: string) { return l === 'HIGH' ? 'text-red-600' : l === 'MEDIUM' ? 'text-orange-500' : l === 'LOW' ? 'text-green-600' : 'text-gray-500'; }
function reviewLabel(s: string) { return s === 'NEED_REVIEW' ? '待复核' : s === 'REVIEWED' ? '已复核' : s === 'REJECTED' ? '已驳回' : s === 'AUTO_RELEASED' ? '自动发布' : s; }
function reviewColor(s: string) { return s === 'NEED_REVIEW' ? 'bg-yellow-100 text-yellow-700' : s === 'REVIEWED' ? 'bg-green-100 text-green-700' : s === 'REJECTED' ? 'bg-red-100 text-red-700' : 'bg-gray-100 text-gray-600'; }

function logout() { clearAuth(); router.push('/admin/login'); }
</script>

<template>
  <div class="min-h-screen bg-gray-100 p-4">
    <div class="max-w-5xl mx-auto">
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-xl font-bold text-gray-800">提交记录 ({{ total }})</h1>
        <button @click="logout" class="text-sm text-gray-500 hover:text-red-500">退出</button>
      </div>
      <!-- Filters -->
      <div class="flex gap-2 mb-4">
        <select v-model="filterRisk" @change="load" class="border px-2 py-1 rounded text-sm">
          <option value="">全部风险</option>
          <option value="LOW">低风险</option>
          <option value="MEDIUM">中风险</option>
          <option value="HIGH">高风险</option>
        </select>
        <select v-model="filterReview" @change="load" class="border px-2 py-1 rounded text-sm">
          <option value="">全部状态</option>
          <option value="NEED_REVIEW">待复核</option>
          <option value="REVIEWED">已复核</option>
          <option value="REJECTED">已驳回</option>
          <option value="AUTO_RELEASED">自动发布</option>
        </select>
      </div>
      <!-- Loading -->
      <div v-if="loading" class="text-gray-500 text-center py-8">加载中...</div>
      <!-- Table -->
      <div v-else class="bg-white rounded-lg shadow overflow-x-auto">
        <table class="w-full text-sm">
          <thead class="bg-gray-50 text-gray-600">
            <tr>
              <th class="px-3 py-2 text-left">时间</th>
              <th class="px-3 py-2 text-left">手机号</th>
              <th class="px-3 py-2">风险</th>
              <th class="px-3 py-2">复核</th>
              <th class="px-3 py-2">客户可见</th>
              <th class="px-3 py-2">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in items" :key="item.reportPublicId" class="border-t hover:bg-gray-50">
              <td class="px-3 py-2 text-gray-500">{{ item.submittedAt?.slice(0, 16) || '-' }}</td>
              <td class="px-3 py-2">{{ item.phoneMasked }}</td>
              <td class="px-3 py-2 text-center"><span :class="levelColor(item.overallRiskLevel)">{{ item.overallRiskLevel }}</span></td>
              <td class="px-3 py-2 text-center"><span :class="`px-2 py-0.5 rounded text-xs ${reviewColor(item.reviewStatus)}`">{{ reviewLabel(item.reviewStatus) }}</span></td>
              <td class="px-3 py-2 text-center">{{ item.customerVisible ? '✅' : '❌' }}</td>
              <td class="px-3 py-2 text-center">
                <router-link :to="`/admin/reports/${item.reportPublicId}`" class="text-blue-600 hover:underline text-xs">查看</router-link>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

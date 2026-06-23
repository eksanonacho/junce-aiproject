<template>
  <div v-if="dashboard" class="space-y-6">
    <!-- Overall Health Card + Radar -->
    <div class="grid grid-cols-1 lg:grid-cols-5 gap-4">
      <!-- Health Score -->
      <div class="lg:col-span-2 bg-white rounded-2xl p-6 border border-slate-200 shadow-sm text-center">
        <p class="text-sm text-slate-500 mb-2">综合经营健康度</p>
        <div class="text-5xl font-bold mb-1" :class="scoreColorClass">{{ dashboard.overallScore }}</div>
        <p class="text-sm font-medium" :class="scoreLabelClass">{{ dashboard.overallLabel }}</p>
        <p class="text-xs text-slate-400 mt-2">基于{{ modeLabel }}初诊模式</p>
        <div class="mt-3 inline-block px-3 py-1 rounded-full text-xs font-medium" :class="confidenceClass">
          可信度：{{ confidenceLabel }}
        </div>
      </div>

      <!-- Radar Chart -->
      <div class="lg:col-span-3 bg-white rounded-2xl p-4 border border-slate-200 shadow-sm flex items-center justify-center">
        <div ref="radarRef" class="w-full h-64 lg:h-72" />
      </div>
    </div>

    <!-- 4 Dimension Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <DimensionCard
        v-for="d in dashboard.dimensionDetails"
        :key="d.dimension"
        :detail="d"
        :label="dimLabels[d.dimension] || d.dimension"
      />
    </div>

    <!-- Conclusion -->
    <div class="bg-gradient-to-r from-blue-50 to-slate-50 rounded-2xl p-5 border border-blue-100">
      <p class="text-sm font-medium text-blue-800 mb-1">一句话结论</p>
      <p class="text-slate-700">{{ dashboard.conclusion }}</p>
    </div>

    <!-- TOP3 Actions -->
    <TopActions :actions="dashboard.topActions" />
  </div>
  <div v-else class="text-center py-8 text-slate-400">暂无看板数据</div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import * as echarts from 'echarts';
import type { BusinessDashboard } from '../../types/api';
import DimensionCard from './DimensionCard.vue';
import TopActions from './TopActions.vue';

const props = defineProps<{ dashboard: BusinessDashboard | null; mode?: string }>();

const radarRef = ref<HTMLDivElement>();

const dimLabels: Record<string, string> = {
  PROFIT: '利润', RISK: '风险', CASH_FLOW: '现金流', EFFICIENCY: '效率',
};

const modeLabel = computed(() => {
  const map: Record<string, string> = { QUICK: '快速', STANDARD: '标准', DEEP: '深度' };
  return map[props.mode || ''] || props.mode || '标准';
});

const scoreColorClass = computed(() => {
  const s = props.dashboard?.overallScore || 0;
  if (s >= 4.0) return 'text-green-600';
  if (s >= 3.0) return 'text-amber-600';
  if (s >= 2.0) return 'text-orange-600';
  return 'text-red-600';
});

const scoreLabelClass = computed(() => {
  const s = props.dashboard?.overallScore || 0;
  if (s >= 4.0) return 'text-green-600';
  if (s >= 3.0) return 'text-amber-600';
  return 'text-red-600';
});

const confidenceClass = computed(() => {
  const c = props.dashboard?.confidenceLevel;
  if (c === 'HIGH') return 'bg-green-50 text-green-700';
  if (c === 'MEDIUM') return 'bg-amber-50 text-amber-700';
  return 'bg-red-50 text-red-700';
});

const confidenceLabel = computed(() => {
  const c = props.dashboard?.confidenceLevel;
  if (c === 'HIGH') return '高';
  if (c === 'MEDIUM') return '中';
  return '低';
});

function initRadar() {
  if (!radarRef.value || !props.dashboard) return;
  const chart = echarts.init(radarRef.value);
  const d = props.dashboard;
  const dims = d.dimensionDetails || [];
  const indicators = [
    ...dims.map((dd) => ({ name: dimLabels[dd.dimension] || dd.dimension, max: 5 })),
    { name: '综合', max: 5 },
  ];
  const values = [...dims.map((dd) => dd.score), d.overallScore];

  chart.setOption({
    radar: {
      indicator: indicators,
      shape: 'polygon',
      center: ['50%', '50%'],
      radius: '75%',
      axisName: { color: '#64748B', fontSize: 11, borderRadius: 3, padding: [3, 5] },
    },
    series: [{
      type: 'radar',
      data: [{
        value: values,
        name: '经营评分',
        areaStyle: { color: 'rgba(30, 58, 138, 0.15)' },
        lineStyle: { color: '#1E3A8A', width: 2 },
        itemStyle: { color: '#1E3A8A' },
        symbol: 'circle',
        symbolSize: 5,
      }],
    }],
  });
  window.addEventListener('resize', () => chart.resize());
}

onMounted(() => {
  if (props.dashboard) initRadar();
});

watch(() => props.dashboard, (val) => {
  if (val) setTimeout(initRadar, 100);
});
</script>

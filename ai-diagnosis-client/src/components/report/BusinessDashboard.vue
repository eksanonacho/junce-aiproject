<template>
  <div v-if="dashboard" class="space-y-5">
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-6">
      <div class="lg:col-span-7 grid grid-cols-1 md:grid-cols-2 gap-5">
        <DimensionCard
          v-for="d in orderedDetails"
          :key="d.dimension"
          :detail="d"
        />
      </div>

      <section class="lg:col-span-5 bg-white/82 backdrop-blur-xl rounded-[24px] border border-[#D3C4AF]/70 shadow-[0_18px_55px_rgba(53,48,39,0.08)] p-6 md:p-8 print-card">
        <div class="w-full text-center mb-4">
          <div>
            <p class="text-[20px] md:text-[24px] font-semibold text-[#201B13]">战略平衡看板</p>
            <p class="text-[11px] text-[#817563] mt-1">分值越高，代表该维度当前状态越稳健</p>
          </div>
        </div>
        <div ref="radarRef" class="w-full h-72 lg:h-80"></div>
      </section>
    </div>
  </div>
  <div v-else class="text-center py-10 text-[#817563] text-sm bg-white rounded-2xl border border-[#D3C4AF]">暂无看板数据</div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick } from 'vue';
import * as echarts from 'echarts';
import type { BusinessDashboard, DimensionDetail } from '../../types/api';
import DimensionCard from './DimensionCard.vue';

const props = defineProps<{
  dashboard: BusinessDashboard | null;
  riskLevel?: string;
  reviewStatus?: string;
}>();

const radarRef = ref<HTMLDivElement>();
let chart: echarts.ECharts | null = null;

const dimLabels: Record<string, string> = {
  PROFIT: '利润',
  RISK: '风险',
  CASH_FLOW: '现金流',
  EFFICIENCY: '效率',
};

const dimOrder = ['PROFIT', 'RISK', 'CASH_FLOW', 'EFFICIENCY'];

const orderedDetails = computed<DimensionDetail[]>(() => {
  const details = props.dashboard?.dimensionDetails || [];
  return [...details].sort((a, b) => dimOrder.indexOf(a.dimension) - dimOrder.indexOf(b.dimension));
});

function initRadar() {
  if (!radarRef.value || !props.dashboard) return;
  if (chart) chart.dispose();

  chart = echarts.init(radarRef.value);
  const details = orderedDetails.value;

  chart.setOption({
    tooltip: {
      trigger: 'item',
      backgroundColor: '#121212',
      borderWidth: 0,
      textStyle: { color: '#fff', fontSize: 12 },
    },
    radar: {
      indicator: details.map((dd) => ({ name: dimLabels[dd.dimension] || dd.dimension, max: 5 })),
      shape: 'polygon',
      center: ['50%', '52%'],
      radius: '68%',
      axisName: { color: '#4F4535', fontSize: 12, fontWeight: 600, padding: [4, 6] },
      splitNumber: 4,
      splitArea: { areaStyle: { color: ['#FFFFFF', '#FFF8F3'] } },
      splitLine: { lineStyle: { color: '#D3C4AF', width: 1 } },
      axisLine: { lineStyle: { color: '#D3C4AF' } },
    },
    series: [
      {
        type: 'radar',
        data: [
          {
            value: details.map((dd) => dd.score),
            name: '四维经营评分',
            areaStyle: { color: 'rgba(120,86,0,0.18)' },
            lineStyle: { color: '#785600', width: 3 },
            itemStyle: { color: '#F7BD48', borderColor: '#785600', borderWidth: 2 },
            symbol: 'circle',
            symbolSize: 6,
          },
        ],
      },
    ],
  });
}

function handleResize() {
  chart?.resize();
}

onMounted(() => {
  nextTick(initRadar);
  window.addEventListener('resize', handleResize);
});

watch(() => props.dashboard, () => nextTick(initRadar), { deep: true });

onBeforeUnmount(() => {
  window.removeEventListener('resize', handleResize);
  chart?.dispose();
  chart = null;
});
</script>

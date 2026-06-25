<template>
  <div v-if="dashboard" class="space-y-4">
    <!-- Top: Score Card + Radar -->
    <div class="grid grid-cols-1 lg:grid-cols-5 gap-4">
      <!-- Score Card -->
      <div class="lg:col-span-2 bg-white rounded-2xl border border-slate-200 shadow-sm p-6 flex flex-col items-center justify-center text-center">
        <p class="text-[12px] text-slate-500 uppercase tracking-wider mb-2">综合经营健康度</p>
        <div class="text-[56px] font-extrabold leading-none mb-1" :class="scoreColor">{{ dashboard.overallScore }}</div>
        <p class="text-[12px] text-slate-400 mb-4">/ 5.0</p>
        <div class="inline-block px-3 py-1 rounded-lg text-[13px] font-semibold mb-3" :class="labelBadge">{{ dashboard.overallLabel }}</div>
        <!-- Temperature bar -->
        <div class="w-full max-w-[200px]">
          <div class="flex justify-between text-[10px] text-slate-400 mb-1"><span>1.0</span><span>压力较大</span><span>5.0</span></div>
          <div class="h-2 rounded-full relative" style="background:linear-gradient(90deg,#DC2626,#F59E0B,#EAB308,#22C55E,#16A34A)">
            <div class="absolute top-1/2 -translate-y-1/2 w-3 h-3 rounded-full bg-white border-2 border-[#0F172A] shadow" :style="{left:((dashboard.overallScore-1)/4*100)+'%'}"/>
          </div>
        </div>
        <div class="mt-3 text-[11px] text-slate-400">{{ confLabel }} · {{ riskLabel }}</div>
      </div>

      <!-- Radar -->
      <div class="lg:col-span-3 bg-white rounded-2xl border border-slate-200 shadow-sm p-4 flex items-center justify-center">
        <div ref="radarRef" class="w-full h-64 lg:h-80"/>
      </div>
    </div>

    <!-- 4 Dimension Cards (2×2 grid) -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <DimensionCard
        v-for="d in dashboard.dimensionDetails"
        :key="d.dimension"
        :detail="d"
        :label="dimLabels[d.dimension] || d.dimension"
      />
    </div>
  </div>
  <div v-else class="text-center py-8 text-slate-400 text-sm">暂无看板数据</div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue';
import * as echarts from 'echarts';
import type { BusinessDashboard } from '../../types/api';
import DimensionCard from './DimensionCard.vue';

const props = defineProps<{ dashboard: BusinessDashboard | null }>();
const radarRef = ref<HTMLDivElement>();

const dimLabels: Record<string,string> = { PROFIT:'利润', RISK:'风险', CASH_FLOW:'现金流', EFFICIENCY:'效率' };

const scoreColor = computed(() => { const s = props.dashboard?.overallScore||0; if(s>=4)return'text-green-600';if(s>=3)return'text-amber-600';if(s>=2)return'text-orange-600';return'text-red-600'; });
const labelBadge = computed(() => { const s = props.dashboard?.overallScore||0; if(s>=4)return'bg-green-50 text-green-700';if(s>=3)return'bg-amber-50 text-amber-700';return'bg-red-50 text-red-700'; });
const confLabel = computed(() => ({HIGH:'可信度较高',MEDIUM:'可信度中等',LOW:'可信度较低'} as any)[props.dashboard?.confidenceLevel||'']||'可信度中等');
const riskLabel = computed(() => ({HIGH:'高风险',MEDIUM:'中风险',LOW:'低风险',UNKNOWN:'未知'} as any)[props.dashboard?.confidenceLevel||'']||'');

function initRadar() {
  if (!radarRef.value || !props.dashboard) return;
  const chart = echarts.init(radarRef.value);
  const d = props.dashboard;
  const dims = d.dimensionDetails || [];
  const indicators = [...dims.map(dd=>({name:dimLabels[dd.dimension]||dd.dimension,max:5})),{name:'综合',max:5}];
  const values = [...dims.map(dd=>dd.score), d.overallScore];

  chart.setOption({
    radar: {
      indicator: indicators,
      shape:'polygon', center:['50%','52%'], radius:'70%',
      axisName:{color:'#475569',fontSize:11,borderRadius:3,padding:[3,5]},
      splitArea:{areaStyle:{color:['#fff','#F8FAFC']}},
      splitLine:{lineStyle:{color:'#E2E8F0'}},
      axisLine:{lineStyle:{color:'#CBD5E1'}},
    },
    series:[{type:'radar',data:[{value:values,name:'经营评分',areaStyle:{color:'rgba(30,58,138,0.12)'},lineStyle:{color:'#1E3A8A',width:2},itemStyle:{color:'#1E3A8A'},symbol:'circle',symbolSize:4}]}],
  });
  window.addEventListener('resize',()=>chart.resize());
}

onMounted(()=>{ if(props.dashboard) initRadar(); });
watch(()=>props.dashboard,(val)=>{ if(val) setTimeout(initRadar,100); });
</script>

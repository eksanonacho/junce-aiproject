<template>
  <div class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5">
    <div class="flex items-center justify-between mb-3">
      <h4 class="text-[14px] font-bold text-[#0F172A]">{{ label }}能力</h4>
      <span class="text-[12px] font-medium" :class="scoreCls">{{ detail.score }} / 5</span>
    </div>
    <div class="text-[11px] font-medium mb-3" :class="labelCls">{{ detail.label }}</div>
    <!-- Core issues -->
    <div class="space-y-1.5 mb-3">
      <p class="text-[10px] text-slate-400 uppercase tracking-wider">核心问题</p>
      <p v-for="(issue,i) in detail.issues" :key="'i'+i" class="text-[12px] text-slate-700 flex items-start gap-1.5">
        <span class="text-[#D97706] mt-0.5 shrink-0">-</span>
        <span class="leading-relaxed">{{ issue }}</span>
      </p>
    </div>
    <!-- Suggestions -->
    <div class="space-y-1 mb-3">
      <p class="text-[10px] text-slate-400 uppercase tracking-wider">建议动作</p>
      <p v-for="(s,i) in detail.suggestions" :key="'s'+i" class="text-[11px] text-[#1E3A8A] flex items-start gap-1.5">
        <span class="shrink-0 mt-0.5">-</span>
        <span class="leading-relaxed">{{ s }}</span>
      </p>
    </div>
    <div class="pt-2 border-t border-slate-100 text-[10px] text-slate-400">可信度 {{ detail.confidence }}%</div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { DimensionDetail } from '../../types/api';

const props = defineProps<{ detail: DimensionDetail; label: string }>();

const scoreCls = computed(() => { const s=props.detail.score; if(s>=4)return'text-green-600';if(s>=3)return'text-amber-600';if(s>=2)return'text-orange-600';return'text-red-600'; });
const labelCls = computed(() => { const s=props.detail.score; if(s>=4)return'text-green-600';if(s>=3)return'text-amber-600';return'text-red-600'; });
</script>

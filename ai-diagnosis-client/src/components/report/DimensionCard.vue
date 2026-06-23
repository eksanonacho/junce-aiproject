<template>
  <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
    <div class="flex items-center justify-between mb-2">
      <h4 class="font-semibold text-slate-900">{{ label }}</h4>
      <span class="text-sm font-medium" :class="scoreColor">{{ scoreText }}</span>
    </div>
    <div class="text-3xl font-bold mb-1" :class="scoreColor">{{ detail.score }}</div>
    <p class="text-xs mb-3" :class="scoreColor">{{ detail.label }}</p>
    <div class="space-y-1.5 text-xs text-slate-600">
      <p v-for="(issue, i) in detail.issues" :key="'i'+i" class="flex items-start gap-1">
        <span class="text-amber-500 shrink-0 mt-0.5">•</span> {{ issue }}
      </p>
    </div>
    <div class="mt-2 pt-2 border-t border-slate-100 text-xs text-slate-400">
      可信度：{{ detail.confidence }}%
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { DimensionDetail } from '../../types/api';

const props = defineProps<{ detail: DimensionDetail; label: string }>();

const scoreColor = computed(() => {
  const s = props.detail.score;
  if (s >= 4.0) return 'text-green-600';
  if (s >= 3.0) return 'text-amber-600';
  if (s >= 2.0) return 'text-orange-600';
  return 'text-red-600';
});

const scoreText = computed(() => props.detail.score + ' / 5');
</script>

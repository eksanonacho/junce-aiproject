<template>
  <div class="bg-white rounded-2xl p-5 border border-slate-200 shadow-sm">
    <h3 class="font-semibold text-slate-900 mb-4">TOP3 优先行动建议</h3>
    <div class="space-y-4">
      <div v-for="a in actions" :key="a.priority" class="flex gap-4 items-start">
        <div class="shrink-0 w-8 h-8 rounded-full flex items-center justify-center text-white text-sm font-bold"
          :class="['bg-[#1E3A8A]', 'bg-blue-600', 'bg-blue-400'][a.priority - 1]"
        >{{ a.priority }}</div>
        <div class="flex-1">
          <p class="font-medium text-slate-900">{{ a.title }}</p>
          <p class="text-sm text-slate-500 mt-0.5">{{ a.reason }}</p>
          <div class="flex items-center gap-2 mt-1.5 text-xs">
            <span class="px-2 py-0.5 bg-amber-50 text-amber-700 rounded">⏱ {{ a.timeline }}</span>
            <span class="px-2 py-0.5 bg-blue-50 text-blue-700 rounded">{{ a.serviceType }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { TopAction } from '../../types/api';
defineProps<{ actions: TopAction[] }>();
</script>

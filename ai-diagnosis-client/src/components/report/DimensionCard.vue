<template>
  <section class="bg-white/82 backdrop-blur-xl rounded-[24px] border border-[#D3C4AF]/70 shadow-[0_14px_45px_rgba(53,48,39,0.07)] p-5 print-card">
    <div class="flex items-start justify-between gap-4 mb-4">
      <div>
        <p class="text-[15px] font-bold text-[#201B13]">{{ title }}</p>
        <p class="text-[11px] text-[#817563] mt-1">{{ subtitle }}</p>
      </div>
      <div class="text-right shrink-0">
        <p class="text-[22px] font-extrabold leading-none" :class="scoreCls">{{ detail.score.toFixed(1) }}</p>
        <p class="text-[10px] text-[#817563] mt-0.5">/ 5</p>
      </div>
    </div>

    <div class="flex flex-wrap items-center gap-2 mb-4">
      <span class="px-2.5 py-1 rounded-lg text-[12px] font-semibold" :class="labelCls">{{ detail.label }}</span>
      <span class="px-2.5 py-1 rounded-lg text-[11px] bg-[#FFF8F3] text-[#4F4535] border border-[#D3C4AF]/70">可信度 {{ detail.confidence }}%</span>
    </div>

    <div class="space-y-3">
      <div>
        <p class="text-[11px] font-semibold text-[#817563] tracking-wide mb-1.5">核心问题</p>
        <p class="text-[13px] text-[#4F4535] leading-relaxed">{{ primaryIssue }}</p>
      </div>
      <div>
        <p class="text-[11px] font-semibold text-[#817563] tracking-wide mb-1.5">建议动作</p>
        <p class="text-[13px] text-[#785600] leading-relaxed">{{ primarySuggestion }}</p>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import type { DimensionDetail } from '../../types/api';

const props = defineProps<{ detail: DimensionDetail }>();

const dimMeta: Record<string, { title: string; subtitle: string; fallback: string }> = {
  PROFIT: {
    title: '利润能力',
    subtitle: '收入质量、毛利水平与费用结构',
    fallback: '建议建立产品、客户与费用维度的经营台账，定期核查利润质量。',
  },
  RISK: {
    title: '风险水平',
    subtitle: '税务申报、发票资金与用工合规',
    fallback: '建议优先核查申报、发票、合同、银行流水和用工资料的一致性。',
  },
  CASH_FLOW: {
    title: '现金流状态',
    subtitle: '回款周期、存货占用与付款节奏',
    fallback: '建议梳理应收账款、供应商账期和资金周转周期，形成现金流复盘表。',
  },
  EFFICIENCY: {
    title: '运营效率',
    subtitle: '人效、资产利用与流程效率',
    fallback: '建议复盘人均产出、闲置资产和重复流程，逐步提升经营效率。',
  },
};

const meta = computed(() => dimMeta[props.detail.dimension] || {
  title: props.detail.dimension,
  subtitle: '经营诊断维度',
  fallback: '建议结合完整资料由专业人员进一步复核。',
});

const title = computed(() => meta.value.title);
const subtitle = computed(() => meta.value.subtitle);

const primaryIssue = computed(() => {
  const issues = props.detail.issues?.filter((item) => item && item !== '未发现明显问题') || [];
  if (issues.length > 0) return issues[0];
  return props.detail.score < 3 ? '当前维度得分偏低，建议结合完整资料进一步核查。' : '当前未发现明显异常信号，仍建议持续跟踪。';
});

const primarySuggestion = computed(() => {
  const suggestions = props.detail.suggestions?.filter((item) => item && !item.includes('保持当前经营状态')) || [];
  if (suggestions.length > 0) return suggestions[0];
  return meta.value.fallback;
});

const scoreCls = computed(() => {
  const s = props.detail.score;
  if (s >= 4) return 'text-[#0F766E]';
  if (s >= 3) return 'text-[#785600]';
  if (s >= 2) return 'text-[#D97706]';
  return 'text-[#B45309]';
});

const labelCls = computed(() => {
  const s = props.detail.score;
  if (s >= 4) return 'bg-emerald-50 text-emerald-700 border border-emerald-100';
  if (s >= 3) return 'bg-[#FDF2E5] text-[#785600] border border-[#D3C4AF]';
  return 'bg-[#FDF2E5] text-[#D97706] border border-[#D3C4AF]';
});
</script>

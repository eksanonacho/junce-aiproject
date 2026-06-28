<template>
  <div class="relative min-h-screen overflow-x-hidden report-shell print:bg-white">
    <JcDynamicBackground variant="executive" intensity="low" />
    <nav class="fixed top-0 left-0 w-full z-50 h-20 px-5 md:px-10 bg-[#FFF8F3]/82 backdrop-blur-xl border-b border-[#D3C4AF]/40 shadow-sm no-print">
      <div class="max-w-[1280px] mx-auto h-full flex items-center justify-between">
        <JcBrand />
        <div class="hidden md:flex items-center gap-8 text-[13px] font-semibold text-[#4F4535]">
          <router-link to="/" class="hover:text-[#785600] transition no-underline">覆盖场景</router-link>
          <router-link to="/" class="hover:text-[#785600] transition no-underline">初诊流程</router-link>
          <router-link to="/" class="hover:text-[#785600] transition no-underline">衔接服务</router-link>
          <router-link to="/diagnosis/start" class="bg-[#785600] text-white px-5 py-2.5 rounded-xl hover:bg-[#5D4200] transition shadow-[0_12px_26px_rgba(120,86,0,0.18)] no-underline">开始初诊</router-link>
        </div>
      </div>
    </nav>
    <div v-if="loading" class="relative z-[1] flex items-center justify-center min-h-screen text-[#817563] text-sm">加载报告中...</div>

    <div v-else-if="error" class="relative z-[1] flex flex-col items-center justify-center min-h-screen gap-4 px-4">
      <p class="text-red-500 text-sm">{{ error }}</p>
      <router-link to="/" class="text-[#785600] text-sm hover:underline">返回首页</router-link>
    </div>

    <div v-else-if="isPendingReview" class="relative z-[1] min-h-screen pending-review-page">
      <div class="relative z-[1] max-w-lg mx-auto px-4 pt-32 pb-16 md:pb-24">
        <section class="bg-white/86 backdrop-blur-xl rounded-[28px] border border-[#D3C4AF]/70 shadow-[0_24px_70px_rgba(53,48,39,0.10)] overflow-hidden print-card">
          <div class="bg-[#121212] text-white px-6 py-6 text-center print-light-header">
            <p class="text-[12px] text-[#F7BD48] mb-1">君册财税</p>
            <h1 class="text-xl font-extrabold tracking-tight">初诊结果已生成</h1>
            <p class="text-[13px] text-[#C8C6C5] mt-1">正在由君册专业人员复核</p>
          </div>
          <div class="px-6 py-6 space-y-5">
            <p class="text-[13px] text-[#4F4535] leading-relaxed">
              为避免资料不完整或高风险事项造成误判，系统已将本次初诊结果提交至君册专业人员复核。复核完成后，将展示完整的四维经营看板和行动建议。
            </p>
            <div class="grid grid-cols-4 gap-2">
              <div v-for="(s, i) in pendingSteps" :key="s.label" class="flex flex-col items-center text-center">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-bold" :class="s.done ? 'bg-[#065F46] text-white' : s.active ? 'bg-[#785600] text-white' : 'bg-[#F7ECDF] text-[#817563]'">
                  {{ s.done ? '已' : i + 1 }}
                </div>
                <span class="text-[10px] mt-1.5 leading-tight" :class="s.done ? 'text-[#065F46] font-medium' : s.active ? 'text-[#201B13] font-semibold' : 'text-[#817563]'">{{ s.label }}</span>
              </div>
            </div>
            <div class="border-t border-[#D3C4AF]/50 pt-4 flex flex-wrap gap-1.5">
              <span v-for="it in ['税务申报', '发票与资金流水', '资料完整度', '四维经营看板', '服务建议']" :key="it" class="text-[11px] px-2.5 py-1 rounded-full bg-[#FDF2E5] text-[#4F4535] border border-[#D3C4AF]/70">{{ it }}</span>
            </div>
          </div>
          <div class="border-t border-[#D3C4AF]/50 px-6 py-4 flex gap-3 no-print">
            <router-link to="/" class="flex-1 text-center py-2.5 rounded-xl border border-[#D3C4AF] text-[13px] text-[#4F4535] hover:bg-[#FDF2E5] transition font-medium">返回首页</router-link>
            <button disabled class="flex-1 py-2.5 rounded-xl bg-[#F1E7D9] text-[#817563] text-[13px] font-medium cursor-not-allowed">等待专业复核</button>
          </div>
        </section>
      </div>
    </div>

    <main v-else-if="report" class="relative z-[1] max-w-[1280px] mx-auto px-4 md:px-10 pt-28 md:pt-32 pb-20 md:pb-24">
      <div class="flex justify-end mb-4 no-print">
        <button @click="printReport" class="px-5 py-2.5 rounded-xl bg-[#785600] text-white text-[13px] font-semibold hover:bg-[#5D4200] transition shadow-[0_14px_30px_rgba(120,86,0,0.18)]">打印 / 保存 PDF</button>
      </div>

      <section class="relative overflow-hidden rounded-[32px] bg-[#121212] text-white shadow-[0_30px_90px_rgba(53,48,39,0.22)] mb-8 print-card">
        <div class="absolute inset-0 opacity-30 pointer-events-none report-hero-sheen"></div>
        <div class="relative z-[1] grid grid-cols-1 lg:grid-cols-[1fr_280px] gap-8 min-h-[260px] px-6 md:px-10 py-8 md:py-10">
          <div class="text-white print-light-header">
            <div class="relative z-[1]">
              <p class="text-[12px] text-[#F7BD48] font-semibold tracking-[0.18em] mb-4">君册财税 · 企业经营初诊报告</p>
              <h1 class="text-[30px] md:text-[46px] font-extrabold tracking-tight leading-tight">君册企业经营初诊报告</h1>
              <p class="text-[13px] md:text-[14px] text-[#C8C6C5] mt-4 max-w-2xl leading-relaxed">基于资料上传、九维规则筛查与四维经营看板生成。报告用于企业经营与财税风险初步筛查，具体事项建议结合完整资料进一步复核。</p>
              <div class="flex flex-wrap gap-2.5 mt-6 text-[11px]">
                <span class="report-chip-dark">报告编号 {{ report.reportNumber || '-' }}</span>
                <span class="report-chip-dark">生成日期 {{ report.generatedAt?.slice(0, 10) || '-' }}</span>
                <span class="report-chip-dark">{{ reviewLabel }}</span>
                <span class="report-chip-dark">资料完整度 {{ completenessText }}</span>
                <span class="report-chip-dark">报告可信度 {{ confidenceLabel }}</span>
              </div>
            </div>
          </div>

          <aside class="rounded-[24px] border border-white/15 bg-white/10 backdrop-blur-md px-6 py-6 flex flex-col justify-between">
            <div class="flex items-start justify-between gap-4">
              <div>
                <p class="text-[12px] text-[#F7BD48] font-semibold">本次初筛风险等级</p>
                <p class="text-[11px] text-[#C8C6C5] mt-1">结合规则命中和复核策略生成</p>
              </div>
              <span class="px-3 py-1.5 rounded-full text-[12px] font-semibold" :class="riskChip(report.riskLevel)">{{ riskLabel(report.riskLevel) }}</span>
            </div>
            <div class="mt-7" v-if="report.dashboard">
              <div class="flex items-end gap-2">
                <span class="text-[58px] font-extrabold leading-none tracking-tight text-[#F7BD48]">{{ report.dashboard.overallScore.toFixed(1) }}</span>
                <span class="text-[#C8C6C5] font-semibold mb-1">/ 5</span>
              </div>
              <p class="text-[13px] font-semibold text-white mt-2">{{ report.dashboard.overallLabel }}</p>
              <p class="text-[12px] text-[#C8C6C5] mt-2 leading-relaxed">{{ scoreProfessionalExplanation }}</p>
            </div>
            <div class="mt-5 grid grid-cols-2 gap-2 text-[11px]">
              <div class="rounded-xl bg-white/10 border border-white/10 px-3 py-2">
                <p class="text-[#C8C6C5]">资料可信度</p>
                <p class="font-semibold text-white mt-0.5">{{ confidenceLabel }}</p>
              </div>
              <div class="rounded-xl bg-white/10 border border-white/10 px-3 py-2">
                <p class="text-[#C8C6C5]">复核状态</p>
                <p class="font-semibold text-white mt-0.5">{{ reviewLabel }}</p>
              </div>
            </div>
          </aside>
        </div>
      </section>

      <section class="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-12 first-screen-summary">
        <div class="lg:col-span-8 executive-card p-6 md:p-10 print-card">
          <SectionTitle eyebrow="Executive Summary" title="老板一分钟速看" />
          <div class="rounded-[20px] bg-[#FFF8F3] border border-[#D3C4AF]/70 px-5 py-4 mb-5">
            <p class="text-[17px] md:text-[20px] font-bold text-[#201B13] leading-relaxed">{{ executiveConclusion }}</p>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-3 gap-3">
            <div v-for="sig in topSignals" :key="sig.label" class="rounded-2xl border border-[#D3C4AF]/60 bg-white/70 px-4 py-3">
              <p class="text-[13px] font-semibold text-[#201B13]">{{ sig.label }}</p>
              <p class="text-[12px] text-[#4F4535] leading-relaxed mt-1">{{ sig.desc }}</p>
            </div>
          </div>
        </div>

        <div class="lg:col-span-4 rounded-[24px] bg-[#121212] text-white border border-white/10 shadow-[0_22px_60px_rgba(53,48,39,0.18)] p-6 md:p-8 print-card">
          <h2 class="text-[20px] md:text-[24px] font-bold mb-6">资料完整度与可信度</h2>
          <div class="space-y-6">
            <div>
              <div class="flex justify-between text-[13px] font-semibold mb-2">
                <span class="text-[#E5E2E1]">资料完整度</span>
                <span class="text-[#F7BD48]">{{ completenessText }}</span>
              </div>
              <div class="h-1.5 w-full bg-white/10 rounded-full overflow-hidden">
                <div class="h-full bg-[#F7BD48] rounded-full" :style="{ width: report.documentCompleteness ? `${report.documentCompleteness.completenessScore || 0}%` : '0%' }"></div>
              </div>
            </div>
            <div>
              <div class="flex justify-between text-[13px] font-semibold mb-2">
                <span class="text-[#E5E2E1]">报告可信度</span>
                <span class="text-[#F7BD48]">{{ confidenceLabel }}</span>
              </div>
              <div class="h-1.5 w-full bg-white/10 rounded-full overflow-hidden">
                <div class="h-full bg-[#F7BD48] rounded-full" :style="{ width: `${confidencePercent}%` }"></div>
              </div>
            </div>
          </div>
          <div class="mt-8 pt-6 border-t border-white/10">
            <p class="text-[12px] text-[#C8C6C5] leading-relaxed">{{ nextStepText }}</p>
          </div>
        </div>
      </section>

      <section v-if="report.dashboard" class="mb-8">
        <SectionTitle eyebrow="Business Dashboard" title="四维经营看板" />
        <BusinessDashboard :dashboard="report.dashboard" :risk-level="report.riskLevel" :review-status="report.reviewStatus" />
      </section>

      <section v-if="report.documentCompleteness" class="mb-8">
        <SectionTitle eyebrow="Evidence Confidence" title="资料完整度与报告可信度" />
        <div class="executive-card p-6 md:p-8 print-card">
          <div class="grid grid-cols-1 lg:grid-cols-[260px_1fr] gap-6 items-center">
            <div>
              <div class="flex items-center gap-4">
                <svg class="w-24 h-24 shrink-0" viewBox="0 0 100 100" aria-label="资料完整度">
                  <circle cx="50" cy="50" r="40" fill="none" stroke="#ECE1D4" stroke-width="9" />
                  <circle cx="50" cy="50" r="40" fill="none" :stroke="completenessColor" stroke-width="9" stroke-linecap="round" transform="rotate(-90 50 50)" stroke-dasharray="251.3" :stroke-dashoffset="251.3 * (1 - (report.documentCompleteness.completenessScore || 0) / 100)" />
                  <text x="50" y="48" text-anchor="middle" :fill="completenessColor" font-size="21" font-weight="800">{{ report.documentCompleteness.completenessScore }}%</text>
                  <text x="50" y="64" text-anchor="middle" fill="#817563" font-size="9">完整度</text>
                </svg>
                <div>
                  <p class="text-[13px] text-[#4F4535]">已上传资料</p>
                  <p class="text-[20px] font-extrabold text-[#201B13]">{{ report.documentCompleteness.uploadedCount }} / {{ report.documentCompleteness.requiredCount }}</p>
                  <p class="text-[11px] text-[#817563] mt-1">按当前初诊模式计算</p>
                </div>
              </div>
            </div>
            <div class="space-y-3">
              <div v-for="dim in dims4" :key="dim.key" class="grid grid-cols-[72px_1fr_42px] gap-2 items-center text-[12px]">
                <span class="text-[#4F4535] font-medium">{{ dim.label }}</span>
                <div class="h-2 bg-[#ECE1D4] rounded-full overflow-hidden">
                  <div class="h-full rounded-full" :class="dim.barClass" :style="{ width: (report.documentCompleteness.dimensionConfidence[dim.key] || 0) + '%' }"></div>
                </div>
                <span class="text-right text-[#4F4535]">{{ report.documentCompleteness.dimensionConfidence[dim.key] || 0 }}%</span>
              </div>
            </div>
          </div>
          <div v-if="report.documentCompleteness.missingDocuments.length" class="mt-5 pt-4 border-t border-[#D3C4AF]/50">
            <p class="text-[12px] font-semibold text-[#4F4535] mb-2">建议补充资料</p>
            <div class="flex flex-wrap gap-2">
              <span v-for="doc in report.documentCompleteness.missingDocuments.slice(0, 8)" :key="doc" class="text-[11px] px-2.5 py-1 rounded-full bg-[#FDF2E5] text-[#785600] border border-[#D3C4AF]">{{ doc }}</span>
            </div>
          </div>
          <p class="text-[12px] text-[#4F4535] leading-relaxed mt-4 pt-4 border-t border-[#D3C4AF]/50">资料完整度会影响四维看板的参考价值。当前结论仅作为初步筛查，不构成最终税务、法律或审计意见。</p>
        </div>
      </section>

      <section class="mb-8">
        <SectionTitle eyebrow="Risk Summary" title="风险摘要" />
        <div class="executive-card p-6 md:p-8 print-card">
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-5">
            <MetricCard label="风险信号总数" :value="String(riskCounts.total)" tone="slate" />
            <MetricCard label="高风险事项" :value="String(riskCounts.high)" tone="red" />
            <MetricCard label="中风险事项" :value="String(riskCounts.medium)" tone="amber" />
            <MetricCard label="建议关注" :value="String(riskCounts.low)" tone="blue" />
          </div>
          <div v-if="topRiskDims.length" class="rounded-2xl bg-[#FFF8F3] border border-[#D3C4AF]/70 px-4 py-3">
            <p class="text-[12px] text-[#4F4535] font-semibold mb-2">TOP 风险领域</p>
            <div class="flex flex-wrap gap-2">
              <span v-for="d in topRiskDims" :key="d.name" class="px-2.5 py-1 rounded-lg text-[11px] font-medium" :class="d.cls">{{ d.name }} {{ d.count }} 项</span>
            </div>
          </div>
          <p v-else class="text-[13px] text-[#4F4535] leading-relaxed">根据目前可见信息，暂未形成明确的风险领域聚类，建议结合完整资料由专业人员继续复核。</p>
        </div>
      </section>

      <section v-if="findingGroups.length" class="mb-8">
        <SectionTitle eyebrow="Risk Findings" title="风险明细分组" />
        <div class="space-y-5">
          <div v-for="group in findingGroups" :key="group.level">
            <div class="flex items-center justify-between mb-2 px-1">
              <h3 class="text-[14px] font-bold" :class="group.titleCls">{{ group.title }}</h3>
              <span class="text-[11px] text-[#817563]">{{ group.items.length }} 项</span>
            </div>
            <div class="space-y-3">
              <article v-for="(f, i) in group.items" :key="`${group.level}-${i}`" class="rounded-2xl border-l-4 border-y border-r px-5 py-4 shadow-sm bg-white/82 backdrop-blur print-card" :class="[group.borderCls, group.bgCls]">
                <div class="flex flex-wrap items-center gap-2 mb-2">
                  <span class="text-[11px] px-2.5 py-1 rounded-lg font-semibold" :class="group.badgeCls">{{ group.badgeLabel }}</span>
                  <span class="text-[14px] font-semibold text-[#201B13]">{{ f.title }}</span>
                  <span class="text-[11px] px-2 py-0.5 rounded bg-white/70 text-[#4F4535] border border-[#D3C4AF]/50 ml-auto">{{ f.displayDimension }}</span>
                </div>
                <p class="text-[12px] text-[#4F4535] leading-relaxed">{{ f.description }}</p>
                <p v-if="f.suggestion" class="text-[12px] text-[#785600] mt-2 leading-relaxed">{{ f.suggestion }}</p>
              </article>
            </div>
          </div>
        </div>
      </section>

      <section v-if="actionPlan.length" class="mb-8">
        <SectionTitle eyebrow="90-Day Action Plan" title="90 天优先行动计划" />
        <div class="space-y-5 border-l border-[#D3C4AF] pl-5 md:pl-8">
          <article v-for="a in actionPlan" :key="a.priority" class="relative executive-card p-5 md:p-6 print-card">
            <span class="absolute -left-[31px] md:-left-[43px] top-6 w-4 h-4 rounded-full bg-[#785600] border-[3px] border-[#FFF8F3] shadow"></span>
            <div class="flex items-center justify-between mb-4">
              <span class="text-[12px] font-semibold text-[#785600]">阶段 {{ String(a.priority).padStart(2, '0') }}</span>
              <span class="text-[11px] px-2.5 py-1 rounded-lg bg-[#FDF2E5] text-[#785600] border border-[#D3C4AF]">{{ a.timeline }}</span>
            </div>
            <h3 class="text-[16px] font-bold text-[#201B13] leading-snug mb-2">{{ a.title }}</h3>
            <p class="text-[12px] text-[#4F4535] leading-relaxed mb-3">{{ a.reason }}</p>
            <p class="text-[11px] text-[#785600] font-medium">对应服务/维度：{{ a.serviceType }}</p>
          </article>
        </div>
      </section>

      <section v-if="serviceSteps.length" class="mb-8">
        <SectionTitle eyebrow="Service Path" title="君册建议服务路径" />
        <div class="rounded-[32px] border border-[#D3C4AF]/70 bg-[#FDF2E5]/80 shadow-[0_18px_55px_rgba(53,48,39,0.08)] p-6 md:p-10 print-card">
          <div class="grid grid-cols-1 lg:grid-cols-[0.9fr_1.1fr] gap-8 items-center">
            <div>
              <h3 class="text-[24px] md:text-[30px] font-extrabold text-[#785600] mb-4">君册建议服务路径</h3>
              <p class="text-[13px] md:text-[14px] text-[#4F4535] leading-relaxed mb-6">基于您的企业初诊得分，我们建议通过以下专业服务路径来辅助后续沟通排序。具体服务内容需由君册人员结合完整资料确认。</p>
              <div class="flex flex-wrap gap-2">
                <span v-for="step in serviceSteps" :key="step.label" class="px-3 py-1.5 rounded-full bg-white text-[#785600] text-[12px] font-semibold border border-[#D3C4AF]/80 shadow-sm">{{ step.label }}</span>
              </div>
            </div>
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <article v-for="step in serviceSteps.slice(0, 4)" :key="step.label" class="rounded-2xl border border-[#D3C4AF]/80 bg-white px-5 py-5 shadow-[0_12px_30px_rgba(53,48,39,0.08)]">
                <p class="text-[12px] font-semibold text-[#785600] mb-1">{{ step.order }}</p>
                <h3 class="text-[15px] font-bold text-[#201B13] mb-2">{{ step.label }}</h3>
                <p class="text-[12px] text-[#4F4535] leading-relaxed mb-3">{{ step.why }}</p>
                <div class="flex flex-wrap gap-2">
                  <span v-for="s in step.services.slice(0, 2)" :key="s.type" class="text-[11px] px-2.5 py-1 rounded-lg bg-[#FFF8F3] text-[#4F4535] border border-[#D3C4AF]/70">{{ s.type }} · {{ s.priorityLabel }}</span>
                </div>
              </article>
            </div>
          </div>
        </div>
      </section>

      <section class="grid grid-cols-1 lg:grid-cols-[0.7fr_1.3fr] gap-4 mb-8">
        <div class="executive-card px-5 py-4 print-card">
          <h3 class="text-[14px] font-semibold text-[#201B13] mb-2">复核状态</h3>
          <p class="text-[12px] text-[#4F4535] leading-relaxed">{{ reviewLabel }}。涉及资料不完整、高风险或敏感事项时，建议由专业人员进一步确认。</p>
        </div>
        <div class="rounded-[22px] border border-[#D3C4AF] bg-[#FDF2E5] px-5 py-4 print-card">
          <h3 class="text-[14px] font-semibold text-[#5D4200] mb-2">免责声明</h3>
          <p class="text-[11px] text-[#4F4535] leading-relaxed whitespace-pre-wrap">{{ report.disclaimer }}</p>
        </div>
      </section>

      <footer class="flex flex-col md:flex-row items-start md:items-center justify-between gap-4 border-t border-[#D3C4AF]/50 pt-8 pb-10 text-[#4F4535]">
        <div>
          <JcBrand compact />
          <p class="text-[11px] max-w-xl leading-relaxed mt-2">本报告为初步 AI 诊断结果，仅供参考，不构成最终专业意见。具体事项需由专业人员结合完整资料复核确认。</p>
        </div>
        <div class="flex gap-6 text-[12px] font-semibold">
          <span>隐私政策</span>
          <span>服务条款</span>
          <span>安全保障</span>
        </div>
      </footer>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, defineComponent, h } from 'vue';
import { useRoute } from 'vue-router';
import { getReport } from '../api/reports';
import type { ReportDetail, TopAction } from '../types/api';
import JcBrand from '../components/common/JcBrand.vue';
import JcDynamicBackground from '../components/common/JcDynamicBackground.vue';
import BusinessDashboard from '../components/report/BusinessDashboard.vue';

type EnhancedFinding = {
  riskLevel: string;
  title: string;
  description: string;
  suggestion: string;
  recommendServices?: unknown;
  displayDimension: string;
};

const SectionTitle = defineComponent({
  props: { eyebrow: { type: String, required: true }, title: { type: String, required: true } },
  setup(props) {
    return () => h('div', { class: 'mb-3' }, [
      h('p', { class: 'text-[11px] font-semibold text-[#785600] tracking-[0.16em] mb-1 uppercase' }, props.eyebrow),
      h('h2', { class: 'text-[20px] md:text-[24px] font-extrabold text-[#201B13] tracking-tight' }, props.title),
    ]);
  },
});

const MetricCard = defineComponent({
  props: { label: { type: String, required: true }, value: { type: String, required: true }, tone: { type: String, required: true } },
  setup(props) {
    const cls: Record<string, string> = {
      red: 'text-[#991B1B]',
      amber: 'text-[#D97706]',
      blue: 'text-[#785600]',
      slate: 'text-[#201B13]',
    };
    return () => h('div', { class: 'rounded-2xl border border-[#D3C4AF]/70 bg-[#FFF8F3]/80 px-4 py-3 text-center' }, [
      h('p', { class: `text-[28px] leading-none font-extrabold ${cls[props.tone] || cls.slate}` }, props.value),
      h('p', { class: 'text-[11px] text-[#4F4535] mt-1.5' }, props.label),
    ]);
  },
});

const route = useRoute();
const report = ref<ReportDetail | null>(null);
const loading = ref(true);
const error = ref('');

const publicId = route.params.publicId as string;
const token = route.query.token as string;

const pendingSteps = [
  { label: '资料提交', done: true, active: false },
  { label: '系统初筛', done: true, active: false },
  { label: '专业复核', done: false, active: true },
  { label: '报告开放', done: false, active: false },
];

const dims4 = [
  { key: 'PROFIT', label: '利润', barClass: 'bg-[#785600]' },
  { key: 'RISK', label: '风险', barClass: 'bg-[#D97706]' },
  { key: 'CASH_FLOW', label: '现金流', barClass: 'bg-[#065F46]' },
  { key: 'EFFICIENCY', label: '效率', barClass: 'bg-[#353027]' },
];

const isPendingReview = computed(() => !!(report.value && (report.value as any).status === 'PENDING_REVIEW'));

const reviewLabel = computed(() => ({
  AUTO_RELEASED: '系统自动发布',
  NEED_REVIEW: '待专业人员复核',
  REVIEWED: '已复核通过',
  REJECTED: '已驳回',
} as Record<string, string>)[report.value?.reviewStatus || ''] || '复核状态待确认');

const confidenceLabel = computed(() => ({
  HIGH: '较高',
  MEDIUM: '中等',
  LOW: '较低',
} as Record<string, string>)[report.value?.dashboard?.confidenceLevel || ''] || '中等');

const confidencePercent = computed(() => ({
  HIGH: 88,
  MEDIUM: 62,
  LOW: 38,
} as Record<string, number>)[report.value?.dashboard?.confidenceLevel || ''] || 62);

const completenessText = computed(() => {
  const score = report.value?.documentCompleteness?.completenessScore;
  return score === undefined || score === null ? '待补充' : `${score}%`;
});

const completenessColor = computed(() => {
  const s = report.value?.documentCompleteness?.completenessScore || 0;
  if (s >= 70) return '#0F766E';
  if (s >= 40) return '#D97706';
  return '#B45309';
});

const scoreProfessionalExplanation = computed(() => {
  const score = report.value?.dashboard?.overallScore || 0;
  const high = enhancedFindings.value.filter((f) => f.riskLevel === 'HIGH').length;
  if (score < 2) {
    return `经营压力较大，本次初筛识别 ${high || '多个'} 个高风险信号，建议由君册专业人员进一步复核。`;
  }
  if (score < 3) return '部分经营指标需要重点关注，建议优先核查低分维度并补充关键资料。';
  return '当前结果可作为经营复盘参考，建议持续关注资料完整度和风险变化。';
});

const executiveConclusion = computed(() => {
  return report.value?.dashboard?.conclusion || report.value?.summary || '根据目前填写和上传资料，系统已生成企业经营与财税风险初步筛查结果。';
});

const enhancedFindings = computed<EnhancedFinding[]>(() => {
  return (report.value?.findings || []).map((f) => ({
    ...f,
    displayDimension: inferFindingDimension(f),
  }));
});

const topSignals = computed(() => {
  const details = report.value?.dashboard?.dimensionDetails || [];
  const byScore = [...details].sort((a, b) => a.score - b.score);
  const signals = byScore.slice(0, 3).map((detail) => {
    const meta: Record<string, string> = {
      PROFIT: '利润质量需核查',
      RISK: '合规风险需关注',
      CASH_FLOW: '现金流周转需跟踪',
      EFFICIENCY: '运营效率有提升空间',
    };
    return {
      label: meta[detail.dimension] || '经营指标需复核',
      desc: detail.score < 2 ? '当前得分偏低，建议优先复核相关资料。' : detail.score < 3.5 ? '存在一定改善空间，建议纳入近期复盘。' : '当前状态相对稳健，建议持续跟踪。',
    };
  });

  while (signals.length < 3) {
    signals.push({
      label: signals.length === 0 ? '资料完整度影响判断' : signals.length === 1 ? '复核状态需关注' : '服务路径可进一步确认',
      desc: signals.length === 0 ? '资料越完整，报告参考价值越高。' : signals.length === 1 ? '敏感或高风险事项需由专业人员复核。' : '建议结合完整资料确认后续服务重点。',
    });
  }
  return signals.slice(0, 3);
});

const nextStepText = computed(() => {
  const first = report.value?.dashboard?.topActions?.[0];
  if (first?.reason) return first.reason;
  if (first?.title) return first.title;
  return '建议先补充关键资料，并由君册专业人员结合申报、发票、账务和资金流水进一步复核。';
});

const findingsByLevel = computed(() => {
  const groups = { HIGH: [] as EnhancedFinding[], MEDIUM: [] as EnhancedFinding[], LOW: [] as EnhancedFinding[] };
  for (const f of enhancedFindings.value) {
    if (f.riskLevel === 'HIGH') groups.HIGH.push(f);
    else if (f.riskLevel === 'MEDIUM') groups.MEDIUM.push(f);
    else groups.LOW.push(f);
  }
  return groups;
});

const riskCounts = computed(() => ({
  total: enhancedFindings.value.length,
  high: findingsByLevel.value.HIGH.length,
  medium: findingsByLevel.value.MEDIUM.length,
  low: findingsByLevel.value.LOW.length,
}));

const topRiskDims = computed(() => {
  const counts: Record<string, number> = {};
  for (const f of [...findingsByLevel.value.HIGH, ...findingsByLevel.value.MEDIUM]) {
    if (f.displayDimension === '待复核确认') continue;
    counts[f.displayDimension] = (counts[f.displayDimension] || 0) + 1;
  }
  return Object.entries(counts)
    .sort((a, b) => b[1] - a[1])
    .slice(0, 3)
    .map(([name, count]) => ({
      name,
      count,
      cls: count >= 3 ? 'bg-red-50 text-[#991B1B] border border-red-100' : 'bg-[#FDF2E5] text-[#785600] border border-[#D3C4AF]',
    }));
});

const findingGroups = computed(() => [
  { level: 'HIGH', title: '高风险事项', items: findingsByLevel.value.HIGH, titleCls: 'text-[#991B1B]', borderCls: 'border-red-300', bgCls: 'border-red-100', badgeCls: 'bg-red-100 text-[#991B1B]', badgeLabel: '高风险' },
  { level: 'MEDIUM', title: '中风险事项', items: findingsByLevel.value.MEDIUM, titleCls: 'text-[#D97706]', borderCls: 'border-[#D97706]', bgCls: 'border-amber-100', badgeCls: 'bg-[#FDF2E5] text-[#785600]', badgeLabel: '中风险' },
  { level: 'LOW', title: '建议关注事项', items: findingsByLevel.value.LOW, titleCls: 'text-[#4F4535]', borderCls: 'border-[#065F46]', bgCls: 'border-[#D3C4AF]/70', badgeCls: 'bg-emerald-50 text-[#065F46]', badgeLabel: '建议关注' },
].filter((g) => g.items.length > 0));

const actionPlan = computed(() => {
  const raw = report.value?.dashboard?.topActions || [];
  const fallback = buildFallbackActions();
  const source = raw.length ? raw : fallback;
  return source.slice(0, 3).map((a, i) => ({
    priority: i + 1,
    timeline: ['30 天内', '60 天内', '90 天内'][i],
    title: strengthenActionTitle(a, i),
    reason: a.reason || fallback[i]?.reason || '建议结合完整资料确认该项的优先级和处理顺序。',
    serviceType: a.serviceType || fallback[i]?.serviceType || '经营复核',
  }));
});

const serviceSteps = computed(() => {
  const recs = report.value?.recommendations || [];
  const used = new Set<number>();

  function take(predicate: (name: string, priority: string) => boolean) {
    return recs
      .map((r, index) => ({ ...r, index }))
      .filter((r) => !used.has(r.index) && predicate(r.serviceType, r.priority))
      .map((r) => {
        used.add(r.index);
        return { type: r.serviceType, priorityLabel: priorityLabel(r.priority) };
      });
  }

  const compliance = take((name) => /税务|合规|社保|异常|工商|开户/.test(name));
  const bookkeeping = take((name) => /代理记账|财务外包|补账|清账|资料|账务/.test(name));
  const optimization = take(() => true);

  return [
    {
      order: '第一步',
      label: '合规核查',
      why: '先核查税务申报、发票资金、社保工商等事项，明确哪些内容需要专业复核。',
      services: compliance.length ? compliance : [{ type: '税务合规检查', priorityLabel: '建议关注' }],
    },
    {
      order: '第二步',
      label: '账务与资料整理',
      why: '补齐账务、申报、合同、发票和银行流水资料，为后续判断提供依据。',
      services: bookkeeping.length ? bookkeeping : [{ type: '代理记账', priorityLabel: '建议关注' }],
    },
    {
      order: '第三步',
      label: '经营数据优化',
      why: '在合规和资料基础清晰后，再复盘利润、现金流和效率指标。',
      services: optimization.length ? optimization : [{ type: '经营分析', priorityLabel: '后续可选' }],
    },
  ];
});

function riskChip(lvl: string) {
  return ({
    HIGH: 'bg-red-50 text-red-700 border border-red-100',
    MEDIUM: 'bg-[#FDF2E5] text-[#785600] border border-[#D3C4AF]',
    LOW: 'bg-emerald-50 text-emerald-700 border border-emerald-100',
    UNKNOWN: 'bg-white/10 text-[#C8C6C5] border border-white/20',
  } as Record<string, string>)[lvl] || 'bg-white/10 text-[#C8C6C5] border border-white/20';
}

function riskLabel(lvl: string) {
  return ({ HIGH: '高风险', MEDIUM: '中风险', LOW: '低风险', UNKNOWN: '待确认' } as Record<string, string>)[lvl] || lvl;
}

function inferFindingDimension(finding: { title: string; description: string; suggestion: string; recommendServices?: unknown }) {
  const services = Array.isArray(finding.recommendServices) ? finding.recommendServices.join(' ') : '';
  const text = `${finding.title || ''} ${finding.description || ''} ${finding.suggestion || ''} ${services}`;
  const matches: Array<{ label: string; regex: RegExp }> = [
    { label: '税务申报', regex: /税务申报|纳税申报|零申报|纳税人|补申报|申报数据/ },
    { label: '发票资金', regex: /发票|开票|进项|销项|银行流水|公转私|私人账户|对公账户|资金|票货款/ },
    { label: '社保工商', regex: /社保|用工|工资|个税|员工|工商|法人|股东|地址|注销/ },
    { label: '利润能力', regex: /收入|毛利|利润|成本|费用|客户|产品|亏损/ },
    { label: '现金流', regex: /现金流|回款|应收|逾期|坏账|存货|付款|账期|周转/ },
    { label: '运营效率', regex: /人效|人员配置|资产|设备|流程|效率|系统|人工录入/ },
  ];
  const hit = matches.find((item) => item.regex.test(text));
  return hit?.label || '待复核确认';
}

function priorityLabel(priority: string) {
  return ({ STRONG: '优先建议', SUGGEST: '建议关注', INFO: '后续可选' } as Record<string, string>)[priority] || '建议关注';
}

function buildFallbackActions(): TopAction[] {
  const details = report.value?.dashboard?.dimensionDetails || [];
  return [...details]
    .sort((a, b) => a.score - b.score)
    .slice(0, 3)
    .map((d, i) => ({
      priority: i + 1,
      title: `核查${dimensionActionName(d.dimension)}相关事项`,
      timeline: ['30 天内', '60 天内', '90 天内'][i],
      reason: d.issues?.[0] || '该维度需要结合完整资料进一步确认。',
      serviceType: dimensionActionName(d.dimension),
    }));
}

function dimensionActionName(dimension: string) {
  return ({ PROFIT: '利润能力', RISK: '合规风险', CASH_FLOW: '现金流', EFFICIENCY: '运营效率' } as Record<string, string>)[dimension] || '经营复核';
}

function strengthenActionTitle(action: TopAction, index: number) {
  const text = `${action.title} ${action.reason} ${action.serviceType}`;
  if (/税务|合规|发票|资金|社保|风险/.test(text)) return '完成税务申报、发票资金与合规资料核查';
  if (/账务|资料|代理记账|财务外包|补账/.test(text)) return '梳理账务资料、合同、发票与银行流水对应关系';
  if (/利润|毛利|客户|产品|经营分析/.test(text)) return '建立低毛利客户与产品复盘机制';
  if (/现金流|回款|应收|存货/.test(text)) return '梳理回款周期、应收账款与资金周转计划';
  if (/效率|人效|资产|流程/.test(text)) return '复盘人均产出、资产利用与关键流程效率';
  return ['完成关键资料补充与初步复核', '梳理风险事项和经营数据口径', '建立后续月度经营复盘机制'][index] || action.title;
}

function printReport() {
  window.print();
}

onMounted(async () => {
  if (!token) {
    error.value = '缺少访问令牌';
    loading.value = false;
    return;
  }
  try {
    report.value = await getReport(publicId, token);
  } catch (e: any) {
    error.value = e.message || '加载失败';
  } finally {
    loading.value = false;
  }
});
</script>

<style scoped>
.report-shell {
  background:
    radial-gradient(circle at 14% 0%, rgba(120, 86, 0, 0.10), transparent 28%),
    linear-gradient(180deg, #FFF8F3 0%, #F9F8F6 42%, #F1E7D9 100%);
  color: #201B13;
}

.pending-review-page {
  background: transparent;
}

.executive-card {
  border: 1px solid rgba(211, 196, 175, 0.70);
  border-radius: 24px;
  background: rgba(255, 255, 255, 0.82);
  box-shadow: 0 18px 55px rgba(53, 48, 39, 0.08);
  backdrop-filter: blur(14px);
}

.report-hero-sheen {
  background:
    radial-gradient(circle at 84% 0%, rgba(247, 189, 72, 0.22), transparent 28%),
    linear-gradient(118deg, transparent 0 46%, rgba(255, 255, 255, 0.10) 46.2% 46.8%, transparent 47%),
    linear-gradient(118deg, transparent 0 66%, rgba(247, 189, 72, 0.12) 66.2% 66.45%, transparent 66.7%);
}

.report-chip-dark {
  border: 1px solid rgba(255, 255, 255, 0.14);
  background: rgba(255, 255, 255, 0.08);
  color: #E5E2E1;
  border-radius: 999px;
  padding: 6px 10px;
  box-shadow: 0 10px 24px rgba(0, 0, 0, 0.08);
}

@media print {
  .no-print {
    display: none !important;
  }

  .report-shell,
  .pending-review-page {
    background: #fff !important;
  }

  .executive-card {
    background: #fff !important;
    border-color: #E2E8F0 !important;
    box-shadow: none !important;
    backdrop-filter: none !important;
  }

  .report-hero-sheen {
    display: none !important;
  }

  .print-card {
    box-shadow: none !important;
    break-inside: avoid;
  }

  :global(.print-card) {
    box-shadow: none !important;
    break-inside: avoid;
  }

  .print-light-header {
    background: #fff !important;
    color: #0F172A !important;
    border-bottom: 1px solid #E2E8F0;
  }

  .print-light-header * {
    color: #0F172A !important;
  }

  .report-chip-dark {
    color: #334155 !important;
    border-color: #CBD5E1 !important;
    background: #F8FAFC !important;
  }

  main {
    max-width: none !important;
    padding: 0 !important;
  }
}
</style>

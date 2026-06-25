<template>
  <div class="min-h-screen print:bg-white" style="background:#F1F5F9">
    <!-- Loading / Error / PENDING_REVIEW — keep existing -->
    <div v-if="loading" class="flex items-center justify-center min-h-screen text-slate-500 text-sm">加载报告中...</div>
    <div v-else-if="error" class="flex flex-col items-center justify-center min-h-screen gap-4"><p class="text-red-500 text-sm">{{ error }}</p><router-link to="/" class="text-[#1E3A8A] text-sm hover:underline">返回首页</router-link></div>

    <!-- PENDING_REVIEW -->
    <div v-else-if="isPendingReview" style="background:linear-gradient(180deg,#F1F5F9,#F8FAFC);min-height:100vh">
      <div class="max-w-lg mx-auto px-4 py-16 md:py-24">
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
          <div class="bg-[#0F172A] text-white px-6 py-5 text-center">
            <h1 class="text-xl font-extrabold tracking-tight">初诊结果已生成</h1>
            <p class="text-[13px] text-slate-300 mt-1">正在由君册专业人员复核</p>
          </div>
          <div class="px-6 py-6 space-y-5">
            <p class="text-[13px] text-slate-600 leading-relaxed">为避免资料不完整或高风险事项造成误判，系统已将本次初诊结果提交至君册专业人员复核。复核完成后，您将看到完整的四维经营看板和行动建议。</p>
            <div class="flex items-center justify-between">
              <div v-for="(s,i) in [{l:'资料提交',d:true,a:false},{l:'系统初筛',d:true,a:false},{l:'专业复核',d:false,a:true},{l:'报告开放',d:false,a:false}]" :key="i" class="flex flex-col items-center flex-1">
                <div class="w-8 h-8 rounded-full flex items-center justify-center text-[11px] font-bold" :class="s.d?'bg-green-500 text-white':s.a?'bg-[#1E3A8A] text-white':'bg-slate-100 text-slate-400'">{{ s.d ? '✓' : i+1 }}</div>
                <span class="text-[10px] mt-1.5" :class="s.d?'text-green-600 font-medium':s.a?'text-slate-900 font-semibold':'text-slate-400'">{{ s.l }}</span>
              </div>
            </div>
            <div class="border-t border-slate-100 pt-4 flex flex-wrap gap-1.5">
              <span v-for="it in ['税务申报','发票与资金流水','资料完整度','四维经营看板','服务建议']" :key="it" class="text-[11px] px-2.5 py-1 rounded-full bg-slate-50 text-slate-600 border border-slate-100">{{ it }}</span>
            </div>
          </div>
          <div class="border-t border-slate-100 px-6 py-4 flex gap-3">
            <router-link to="/" class="flex-1 text-center py-2.5 rounded-xl border border-slate-300 text-[13px] text-slate-600 hover:bg-slate-50 transition font-medium">返回首页</router-link>
            <button disabled class="flex-1 py-2.5 rounded-xl bg-slate-100 text-slate-400 text-[13px] font-medium cursor-not-allowed">联系君册顾问</button>
          </div>
        </div>
      </div>
    </div>

    <!-- === FULL REPORT === -->
    <div v-else-if="report" class="max-w-[1120px] mx-auto px-4 md:px-6 py-6 md:py-10">
      <!-- Print -->
      <div class="flex justify-end mb-4 no-print"><button @click="printReport" class="px-4 py-2 rounded-xl bg-[#0F172A] text-white text-[13px] font-medium hover:bg-[#1E293B] transition">打印 / 保存 PDF</button></div>

      <!-- 1. REPORT HERO -->
      <div class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden mb-6">
        <div class="bg-[#0F172A] px-6 md:px-8 py-6 text-white">
          <p class="text-[12px] text-slate-400 uppercase tracking-wider mb-1">君册财税</p>
          <h1 class="text-[22px] md:text-[26px] font-extrabold tracking-tight leading-tight">企业经营初诊报告</h1>
          <p class="text-[12px] text-slate-400 mt-2 max-w-lg leading-relaxed">基于企业资料上传、九维规则筛查与四维经营看板生成</p>
        </div>
        <div class="px-6 md:px-8 py-4 flex flex-wrap items-center gap-3">
          <div class="flex flex-wrap gap-2.5 text-[11px]">
            <span class="px-2.5 py-1 rounded-md bg-slate-50 text-slate-600 border border-slate-100">编号 {{ report.reportNumber }}</span>
            <span class="px-2.5 py-1 rounded-md bg-slate-50 text-slate-600 border border-slate-100">{{ report.generatedAt?.slice(0,10) || '' }}</span>
            <span class="px-2.5 py-1 rounded-md font-semibold" :class="riskChip(report.riskLevel)">{{ riskLabel(report.riskLevel) }}</span>
            <span class="px-2.5 py-1 rounded-md bg-slate-50 text-slate-600 border border-slate-100">{{ reviewLabel }}</span>
          </div>
          <div class="ml-auto flex gap-2 text-[11px] text-slate-400">
            <span v-if="report.documentCompleteness">资料完整 {{ report.documentCompleteness.completenessScore }}%</span>
            <span v-if="report.dashboard">可信度 {{ confLabel }}</span>
          </div>
        </div>
      </div>

      <!-- 2. EXECUTIVE SUMMARY (老板一分钟速看) -->
      <div class="mb-6" v-if="report.dashboard">
        <h2 class="text-[13px] font-semibold text-slate-500 uppercase tracking-wider mb-3">老板一分钟速看</h2>
        <!-- Conclusion -->
        <div class="bg-gradient-to-r from-[#EEF2FF] to-white rounded-2xl border border-[#C7D2FE] px-5 py-4 mb-4">
          <p class="text-[15px] md:text-[16px] font-semibold text-[#0F172A] leading-relaxed">{{ report.dashboard.conclusion }}</p>
        </div>
        <!-- 3 signals -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 mb-4">
          <div v-for="sig in topSignals" :key="sig.label" class="bg-white rounded-xl border border-slate-200 px-4 py-3 shadow-sm">
            <p class="text-[13px] font-semibold text-[#0F172A] mb-0.5">{{ sig.label }}</p>
            <p class="text-[11px] text-slate-500 leading-relaxed">{{ sig.desc }}</p>
          </div>
        </div>
        <!-- Next step -->
        <div class="bg-white rounded-xl border border-slate-200 px-4 py-3 shadow-sm">
          <p class="text-[12px] font-medium text-slate-500 mb-0.5">下一步建议</p>
          <p class="text-[13px] text-[#0F172A] leading-relaxed">{{ nextStepText }}</p>
        </div>
      </div>

      <!-- 3. FOUR-DIMENSION DASHBOARD -->
      <div class="mb-6" v-if="report.dashboard">
        <h2 class="text-[13px] font-semibold text-slate-500 uppercase tracking-wider mb-3">四维经营看板</h2>
        <BusinessDashboard :dashboard="report.dashboard" />
      </div>

      <!-- 4. EVIDENCE CONFIDENCE -->
      <div class="mb-6" v-if="report.documentCompleteness">
        <h2 class="text-[13px] font-semibold text-slate-500 uppercase tracking-wider mb-3">资料完整度与可信度</h2>
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm px-5 py-5">
          <div class="flex flex-wrap items-center gap-6">
            <div class="flex items-center gap-4">
              <svg class="w-20 h-20" viewBox="0 0 100 100"><circle cx="50" cy="50" r="40" fill="none" stroke="#F1F5F9" stroke-width="8"/><circle cx="50" cy="50" r="40" fill="none" :stroke="completenessColor" stroke-width="8" stroke-linecap="round" transform="rotate(-90 50 50)" :stroke-dasharray="251.3" :stroke-dashoffset="251.3*(1-(report.documentCompleteness.completenessScore||0)/100)"/><text x="50" y="46" text-anchor="middle" :fill="completenessColor" font-size="20" font-weight="800">{{ report.documentCompleteness.completenessScore }}%</text><text x="50" y="62" text-anchor="middle" fill="#94A3B8" font-size="9">完整度</text></svg>
              <div>
                <p class="text-sm text-slate-600">已上传 <span class="font-bold text-[#0F172A]">{{ report.documentCompleteness.uploadedCount }}</span> / <span class="font-bold text-[#0F172A]">{{ report.documentCompleteness.requiredCount }}</span> 类资料</p>
                <p v-if="report.documentCompleteness.missingDocuments.length" class="text-xs text-slate-400 mt-1">缺失：{{ report.documentCompleteness.missingDocuments.slice(0,5).join('、') }}</p>
              </div>
            </div>
            <div class="flex-1 min-w-[200px] space-y-1.5">
              <div v-for="dim in dims4" :key="dim.key" class="flex items-center gap-2 text-[11px]">
                <span class="w-12 text-slate-500 shrink-0">{{ dim.label }}</span>
                <div class="flex-1 h-1.5 bg-slate-100 rounded-full"><div class="h-full rounded-full" :class="dim.barClass" :style="{width:(report.documentCompleteness.dimensionConfidence[dim.key]||0)+'%'}"/></div>
                <span class="w-8 text-right text-slate-400">{{ report.documentCompleteness.dimensionConfidence[dim.key]||0 }}%</span>
              </div>
            </div>
          </div>
          <p class="text-[11px] text-slate-400 mt-4 pt-3 border-t border-slate-50 leading-relaxed">资料完整度影响四维看板的参考价值。缺失资料较多时，相关结论仅作为初步筛查参考，不作为最终判断。</p>
        </div>
      </div>

      <!-- 5. RISK SUMMARY -->
      <div class="mb-6" v-if="findingsByLevel">
        <h2 class="text-[13px] font-semibold text-slate-500 uppercase tracking-wider mb-3">风险摘要</h2>
        <div class="grid grid-cols-3 gap-3 mb-3">
          <div class="bg-white rounded-xl border border-slate-200 px-4 py-3 text-center shadow-sm">
            <div class="text-[22px] font-extrabold text-red-600">{{ findingsByLevel.HIGH.length }}</div>
            <div class="text-[11px] text-slate-500">高风险事项</div>
          </div>
          <div class="bg-white rounded-xl border border-slate-200 px-4 py-3 text-center shadow-sm">
            <div class="text-[22px] font-extrabold text-amber-500">{{ findingsByLevel.MEDIUM.length }}</div>
            <div class="text-[11px] text-slate-500">中风险事项</div>
          </div>
          <div class="bg-white rounded-xl border border-slate-200 px-4 py-3 text-center shadow-sm">
            <div class="text-[22px] font-extrabold text-slate-400">{{ findingsByLevel.LOW.length }}</div>
            <div class="text-[11px] text-slate-500">建议关注</div>
          </div>
        </div>
        <div v-if="topRiskDims.length" class="bg-white rounded-xl border border-slate-200 px-4 py-3 shadow-sm flex flex-wrap items-center gap-2 text-[12px]">
          <span class="text-slate-500">TOP 风险领域：</span>
          <span v-for="d in topRiskDims" :key="d.name" class="px-2 py-0.5 rounded-md text-[11px] font-medium" :class="d.cls">{{ d.name }} ({{ d.count }})</span>
        </div>
      </div>

      <!-- 6. RISK FINDINGS (grouped) -->
      <div class="mb-6" v-if="findingsByLevel">
        <h2 class="text-[13px] font-semibold text-slate-500 uppercase tracking-wider mb-3">风险发现</h2>
        <div v-for="group in findingGroups" :key="group.level" class="mb-4">
          <h3 class="text-[12px] font-semibold mb-2 px-1" :class="group.titleCls">{{ group.title }} ({{ group.items.length }})</h3>
          <div class="space-y-2">
            <div v-for="(f,i) in group.items" :key="i" class="bg-white rounded-xl border-l-4 px-4 py-3 shadow-sm" :class="[group.borderCls, group.bgCls]">
              <div class="flex items-center gap-2 mb-1">
                <span class="text-[11px] px-2 py-0.5 rounded font-semibold" :class="group.badgeCls">{{ group.badgeLabel }}</span>
                <span class="text-[13px] font-semibold text-[#0F172A]">{{ f.title }}</span>
                <span v-if="f.dimension" class="text-[10px] px-1.5 py-0.5 rounded bg-slate-100 text-slate-500 ml-auto">{{ dimNameMap[f.dimension] || f.dimension }}</span>
              </div>
              <p class="text-[12px] text-slate-600 leading-relaxed">{{ f.description }}</p>
              <p v-if="f.suggestion" class="text-[12px] text-[#1E3A8A] mt-1.5 leading-relaxed">{{ f.suggestion }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 7. 90-DAY ACTION PLAN -->
      <div class="mb-6" v-if="actionPlan.length">
        <h2 class="text-[13px] font-semibold text-slate-500 uppercase tracking-wider mb-3">90 天优先行动计划</h2>
        <div class="space-y-3">
          <div v-for="(a,i) in actionPlan" :key="i" class="bg-white rounded-2xl border border-slate-200 shadow-sm px-5 py-4 flex gap-4 items-start">
            <div class="shrink-0 w-9 h-9 rounded-xl flex items-center justify-center text-white text-[13px] font-extrabold" :class="['bg-[#0F172A]','bg-[#334155]','bg-[#64748B]'][i]">{{ a.priority }}</div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 mb-1 flex-wrap">
                <span class="text-[14px] font-semibold text-[#0F172A]">{{ a.title }}</span>
                <span class="text-[11px] px-2 py-0.5 rounded-md bg-amber-50 text-amber-700 font-medium">{{ a.timeline }}</span>
              </div>
              <p class="text-[12px] text-slate-500 leading-relaxed">{{ a.reason }}</p>
              <p class="text-[11px] text-[#1E3A8A] mt-1 font-medium">对应服务：{{ a.serviceType }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 8. SERVICE PATH -->
      <div class="mb-6" v-if="report.recommendations?.length">
        <h2 class="text-[13px] font-semibold text-slate-500 uppercase tracking-wider mb-3">君册建议服务路径</h2>
        <div class="bg-white rounded-2xl border border-slate-200 shadow-sm px-5 py-5">
          <div class="flex flex-col md:flex-row gap-3 md:gap-0">
            <div v-for="(step,i) in serviceSteps" :key="i" class="flex-1 relative">
              <div class="flex items-center gap-2 mb-2">
                <div class="w-7 h-7 rounded-lg flex items-center justify-center text-[11px] font-extrabold text-white" :class="step.cls">{{ i+1 }}</div>
                <span class="text-[13px] font-semibold text-[#0F172A]">{{ step.label }}</span>
              </div>
              <div class="space-y-1">
                <div v-for="s in step.services" :key="s.type" class="text-[12px] text-slate-600 flex items-center gap-1.5">
                  <span class="w-1 h-1 rounded-full shrink-0" :class="step.dotCls"></span>
                  <span>{{ s.type }}</span>
                  <span class="text-[10px] text-slate-400 hidden md:inline">· {{ s.reason }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 9. REVIEW & DISCLAIMER -->
      <div class="bg-white rounded-2xl border border-slate-200 shadow-sm px-5 py-4 mb-6">
        <h3 class="text-[14px] font-semibold text-[#0F172A] mb-2">复核状态</h3>
        <p class="text-[12px] text-slate-600">{{ reviewLabel }}</p>
      </div>
      <div class="bg-amber-50 rounded-2xl border border-amber-200 px-5 py-4 mb-6">
        <p class="text-[11px] text-amber-800 leading-relaxed whitespace-pre-wrap">{{ report.disclaimer }}</p>
      </div>
      <p class="text-[11px] text-slate-400 text-center pb-10">君册财税 · 企业经营初诊系统 · 咨询请联系君册顾问</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRoute } from 'vue-router';
import { getReport } from '../api/reports';
import type { ReportDetail } from '../types/api';
import BusinessDashboard from '../components/report/BusinessDashboard.vue';

const route = useRoute();
const report = ref<ReportDetail | null>(null);
const loading = ref(true);
const error = ref('');

const publicId = route.params.publicId as string;
const token = route.query.token as string;

const isPendingReview = computed(() => !!(report.value && (report.value as any).status === 'PENDING_REVIEW'));

// Compute
const reviewLabel = computed(() => ({ AUTO_RELEASED: '系统自动发布', NEED_REVIEW: '待专业人员复核', REVIEWED: '已复核通过', REJECTED: '已驳回' } as Record<string,string>)[report.value?.reviewStatus||''] || '未知');
const confLabel = computed(() => ({ HIGH: '较高', MEDIUM: '中等', LOW: '较低' } as Record<string,string>)[report.value?.dashboard?.confidenceLevel||''] || '中等');
const completenessColor = computed(() => { const s = report.value?.documentCompleteness?.completenessScore || 0; return s >= 70 ? '#16A34A' : s >= 40 ? '#D97706' : '#DC2626'; });

function riskChip(lvl: string) { return ({ HIGH: 'bg-red-50 text-red-700 border border-red-100', MEDIUM: 'bg-amber-50 text-amber-700 border border-amber-100', LOW: 'bg-green-50 text-green-700 border border-green-100', UNKNOWN: 'bg-slate-50 text-slate-500' } as any)[lvl] || ''; }
function riskLabel(lvl: string) { return ({ HIGH: '高风险', MEDIUM: '中风险', LOW: '低风险', UNKNOWN: '未知' } as any)[lvl] || lvl; }

const dims4 = [{key:'PROFIT',label:'利润',barClass:'bg-blue-500'},{key:'RISK',label:'风险',barClass:'bg-red-500'},{key:'CASH_FLOW',label:'现金流',barClass:'bg-emerald-500'},{key:'EFFICIENCY',label:'效率',barClass:'bg-violet-500'}];

// Top 3 signals from dashboard
const topSignals = computed(() => {
  const d = report.value?.dashboard;
  if (!d) return [];
  const dims = d.dimensionDetails || [];
  const sorted = [...dims].sort((a,b) => a.score - b.score).slice(0,3);
  return sorted.map(dd => ({
    label: ({PROFIT:'利润压力较高',RISK:'风险需要关注',CASH_FLOW:'现金流周转偏紧',EFFICIENCY:'效率有待提升'} as any)[dd.dimension] || dd.dimension,
    desc: dd.score <= 2.5 ? '需重点关注和改善' : dd.score <= 3.5 ? '有一定提升空间' : '状态尚可',
  }));
});

const nextStepText = computed(() => {
  const d = report.value?.dashboard;
  if (!d?.topActions?.length) return '建议定期关注企业经营健康状况，保持财税合规。';
  return d.topActions[0].reason || d.topActions[0].title;
});

// Findings grouped by level
const findingsByLevel = computed(() => {
  const all = report.value?.findings || [];
  const groups = { HIGH: [] as any[], MEDIUM: [] as any[], LOW: [] as any[] };
  for (const f of all) groups[f.riskLevel as keyof typeof groups]?.push(f);
  if (!groups.HIGH.length && !groups.MEDIUM.length && !groups.LOW.length) return null;
  return groups;
});

const dimNameMap: Record<string,string> = {
  REVENUE_MARGIN: '收入与毛利维', COST_EXPENSE: '成本费用维', CUSTOMER_PRODUCT: '客户产品贡献维',
  TAX_DECLARATION: '税务申报维', INVOICE_FUND: '发票资金维', SOCIAL_BUSINESS: '社保工商维',
  RECEIVABLE_COLLECTION: '应收回款维', INVENTORY_PAYABLE: '存货付款维', HUMAN_ASSET_EFFICIENCY: '人效资产维',
};

const topRiskDims = computed(() => {
  if (!findingsByLevel.value) return [];
  const counts: Record<string,number> = {};
  for (const f of [...findingsByLevel.value.HIGH, ...findingsByLevel.value.MEDIUM]) {
    const dim = (f as any).dimension || '其他';
    counts[dim] = (counts[dim]||0) + 1;
  }
  return Object.entries(counts).sort((a,b) => b[1]-a[1]).slice(0,3).map(([name,count]) => ({
    name: dimNameMap[name] || name, count,
    cls: count >= 3 ? 'bg-red-50 text-red-700' : 'bg-amber-50 text-amber-700',
  }));
});

const findingGroups = computed(() => {
  if (!findingsByLevel.value) return [];
  return [
    { level:'HIGH', title:'高风险事项', items:findingsByLevel.value.HIGH, titleCls:'text-red-700', borderCls:'border-red-400', bgCls:'bg-red-50/20', badgeCls:'bg-red-100 text-red-700', badgeLabel:'高风险' },
    { level:'MEDIUM', title:'中风险事项', items:findingsByLevel.value.MEDIUM, titleCls:'text-amber-700', borderCls:'border-amber-400', bgCls:'bg-amber-50/20', badgeCls:'bg-amber-100 text-amber-700', badgeLabel:'中风险' },
    { level:'LOW', title:'建议关注事项', items:findingsByLevel.value.LOW, titleCls:'text-slate-600', borderCls:'border-slate-300', bgCls:'bg-slate-50/30', badgeCls:'bg-slate-100 text-slate-600', badgeLabel:'关注' },
  ].filter(g => g.items.length > 0);
});

// Action plan: enhance titles
const actionPlan = computed(() => {
  const raw = report.value?.dashboard?.topActions || [];
  return raw.map((a,i) => {
    let title = a.title;
    // Replace generic titles with better ones
    if (title.includes('优先核查利润') || title.includes('利润相关')) title = `${i+1}. 建立产品与客户毛利台账，核查费用归集`;
    else if (title.includes('优先核查风险') || title.includes('风险相关')) title = `${i+1}. 完成税务申报与发票流水一致性核查`;
    else if (title.includes('优先核查现金流') || title.includes('现金流相关')) title = `${i+1}. 梳理应收账款与资金周转周期`;
    else if (title.includes('优先核查效率') || title.includes('效率相关')) title = `${i+1}. 复盘人均产出与核心流程效率`;
    else title = `${i+1}. ${title}`;
    return { ...a, title };
  });
});

const serviceSteps = computed(() => {
  const recs = report.value?.recommendations || [];
  const strong = recs.filter(r => r.priority === 'STRONG');
  const suggest = recs.filter(r => r.priority === 'SUGGEST');
  const info = recs.filter(r => r.priority === 'INFO');
  const steps: any[] = [];
  if (strong.length) steps.push({ label: '合规核查', cls: 'bg-red-500', dotCls: 'bg-red-400', services: strong.map(r => ({ type: r.serviceType, reason: r.reason })) });
  if (suggest.length) steps.push({ label: '账务与经营梳理', cls: 'bg-amber-500', dotCls: 'bg-amber-400', services: suggest.map(r => ({ type: r.serviceType, reason: r.reason })) });
  if (info.length) steps.push({ label: '长期优化', cls: 'bg-blue-500', dotCls: 'bg-blue-400', services: info.map(r => ({ type: r.serviceType, reason: r.reason })) });
  return steps;
});

function printReport() { window.print(); }

onMounted(async () => {
  if (!token) { error.value = '缺少访问令牌'; loading.value = false; return; }
  try { report.value = await getReport(publicId, token); } catch (e: any) { error.value = e.message || '加载失败'; } finally { loading.value = false; }
});
</script>

<style scoped>
@media print { .no-print { display: none !important; } }
</style>

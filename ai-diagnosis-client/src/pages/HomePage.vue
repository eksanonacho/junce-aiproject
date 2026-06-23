<script setup lang="ts">
import JcIcon from '../components/ui/JcIcon.vue';

function scrollToFlow() {
  document.getElementById('flow-section')?.scrollIntoView({ behavior: 'smooth' });
}

const iconShell = 'w-14 h-14 rounded-2xl flex items-center justify-center border flex-shrink-0';
const iconShellBlue = `${iconShell} bg-[#EFF6FF] border-[#DBEAFE]`;
const iconShellGold = `${iconShell} bg-[#FEF3C7] border-[#FDE68A]`;

const riskScenes = [
  { name: 'tax', label: '税务申报异常' },
  { name: 'history', label: '长期零申报' },
  { name: 'invoice', label: '发票与流水风险' },
  { name: 'socialSecurity', label: '社保用工问题' },
  { name: 'company', label: '工商变更 / 异常' },
  { name: 'warning', label: '注销前风险' },
];

const flowSteps = [
  { icon: 'company', title: '填写企业信息', desc: '3 分钟完成标准化问卷，覆盖税务、工商、社保等关键维度' },
  { icon: 'analysis', title: '系统初步筛查', desc: '基于规则引擎自动匹配风险场景，生成结构化诊断结果' },
  { icon: 'report', title: '生成初诊报告', desc: '自动生成含风险等级、问题明细和服务建议的初诊报告' },
  { icon: 'review', title: '专业人员复核跟进', desc: '中高风险报告由君册专业人员复核确认后跟进服务', highlight: true },
];
</script>

<template>
<div class="min-h-screen bg-[#F8FAFC] text-[#1E293B] font-sans">

  <!-- ========== 1. 顶部导航栏 ========== -->
  <nav class="sticky top-0 z-50 bg-white/95 backdrop-blur border-b border-[#E2E8F0]">
    <div class="max-w-[1180px] mx-auto px-6 h-14 flex items-center justify-between">
      <router-link to="/" class="flex items-center gap-2.5 no-underline">
        <div class="w-8 h-8 rounded-lg bg-[#1E3A8A] flex items-center justify-center">
          <JcIcon name="company" :size="16" color="#fff" :stroke-width="2.5" />
        </div>
        <span class="font-semibold text-[#0F172A] text-base">君册财税<span class="text-[#475569] font-normal ml-1.5 text-sm hidden sm:inline">企业财税 AI 初诊</span></span>
      </router-link>
      <div class="flex items-center gap-6">
        <a @click="scrollToFlow" class="text-sm text-[#475569] hover:text-[#1E3A8A] cursor-pointer hidden sm:block">初诊流程</a>
        <router-link to="/questionnaire" class="bg-[#1E3A8A] text-white text-sm px-4 py-1.5 rounded-md font-medium hover:bg-[#1E40AF] transition inline-flex items-center gap-1.5">
          开始初诊 <JcIcon name="arrowRight" :size="14" color="#fff" />
        </router-link>
      </div>
    </div>
  </nav>

  <!-- ========== 2. Hero 主视觉区 ========== -->
  <section class="max-w-[1180px] mx-auto px-6 py-16 md:py-24">
    <div class="flex flex-col md:flex-row items-center gap-12 md:gap-16">
      <div class="flex-1 text-center md:text-left">
        <div class="inline-flex items-center gap-1.5 bg-[#FEF3C7] text-[#92400E] text-xs font-medium px-2.5 py-1 rounded-full mb-4">
          <JcIcon name="risk" :size="14" color="#92400E" /> 企业财税风险初筛 · AI 辅助
        </div>
        <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-[#0F172A] leading-tight mb-4">
          君册财税<br class="md:hidden" /><span class="text-[#1E3A8A]">AI 企业初诊</span>
        </h1>
        <p class="text-[#475569] text-base md:text-lg max-w-lg mb-3">
          通过结构化问卷，快速识别企业财税、工商、社保与注销风险，为后续人工复核和服务跟进提供参考。
        </p>
        <p class="text-[#94A3B8] text-sm mb-8">
          <span class="inline-flex items-center gap-1"><JcIcon name="process" :size="14" color="#94A3B8" /> 3 分钟填写</span>
          <span class="mx-2 text-[#CBD5E1]">·</span>
          自动生成初诊结果
          <span class="mx-2 text-[#CBD5E1]">·</span>
          高风险问题由专业人员复核
        </p>
        <div class="flex flex-col sm:flex-row gap-3 justify-center md:justify-start">
          <router-link to="/questionnaire" class="inline-flex items-center gap-2 bg-[#1E3A8A] text-white text-center px-6 py-3 rounded-lg font-medium text-base hover:bg-[#1E40AF] transition shadow-sm">
            开始免费初诊 <JcIcon name="arrowRight" :size="16" color="#fff" />
          </router-link>
          <button @click="scrollToFlow" class="inline-flex items-center gap-2 border border-[#CBD5E1] text-[#475569] text-center px-6 py-3 rounded-lg font-medium text-base hover:border-[#94A3B8] hover:text-[#1E293B] transition">
            查看初诊流程
          </button>
        </div>
      </div>
      <!-- 右侧报告预览卡片 -->
      <div class="flex-shrink-0 w-72 md:w-80">
        <div class="bg-white rounded-xl shadow-md border border-[#E2E8F0] overflow-hidden">
          <div class="bg-[#1E3A8A] text-white px-5 py-3 text-sm font-semibold flex items-center gap-2">
            <JcIcon name="report" :size="16" color="#fff" /> 企业初诊报告预览
          </div>
          <div class="px-5 py-4 space-y-3">
            <div class="flex justify-between items-center">
              <span class="text-[#94A3B8] text-xs">总体风险</span>
              <span class="bg-[#F1F5F9] text-[#475569] text-xs px-2 py-0.5 rounded-full">待评估</span>
            </div>
            <div class="border-t border-[#F1F5F9]"></div>
            <p class="text-xs text-[#475569] font-medium mb-1">覆盖维度</p>
            <div class="flex flex-wrap gap-1.5">
              <span class="bg-[#F1F5F9] text-[#475569] text-xs px-2 py-0.5 rounded flex items-center gap-1"><JcIcon name="tax" :size="12" color="#64748B" />税务申报</span>
              <span class="bg-[#F1F5F9] text-[#475569] text-xs px-2 py-0.5 rounded flex items-center gap-1"><JcIcon name="invoice" :size="12" color="#64748B" />发票与流水</span>
              <span class="bg-[#F1F5F9] text-[#475569] text-xs px-2 py-0.5 rounded flex items-center gap-1"><JcIcon name="company" :size="12" color="#64748B" />工商状态</span>
              <span class="bg-[#F1F5F9] text-[#475569] text-xs px-2 py-0.5 rounded flex items-center gap-1"><JcIcon name="socialSecurity" :size="12" color="#64748B" />社保用工</span>
              <span class="bg-[#F1F5F9] text-[#475569] text-xs px-2 py-0.5 rounded flex items-center gap-1"><JcIcon name="warning" :size="12" color="#64748B" />注销风险</span>
            </div>
            <div class="flex items-center gap-1.5 text-xs text-[#94A3B8] italic pt-1">
              <JcIcon name="secure" :size="12" color="#94A3B8" /> 高风险内容由专业人员复核
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ========== 3. 三个核心价值卡片 ========== -->
  <section class="bg-white border-y border-[#E2E8F0]">
    <div class="max-w-[1180px] mx-auto px-6 py-16">
      <div class="text-center mb-10">
        <h2 class="text-2xl font-bold text-[#0F172A] mb-2">为什么选择 AI 初诊</h2>
        <p class="text-[#64748B] text-sm">不是替代专业判断，而是帮助更高效地完成初步筛查</p>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl p-6 hover:border-[#93C5FD] transition">
          <div :class="iconShellBlue">
            <JcIcon name="company" :size="28" />
          </div>
          <h3 class="font-semibold text-[#0F172A] mt-4 mb-2">结构化收集客户信息</h3>
          <p class="text-[#64748B] text-sm leading-relaxed">通过标准化问题收集企业基础信息、经营情况和当前诉求，减少反复沟通，提升商务判断效率。</p>
        </div>
        <div class="bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl p-6 hover:border-[#93C5FD] transition">
          <div :class="iconShellBlue">
            <JcIcon name="risk" :size="28" />
          </div>
          <h3 class="font-semibold text-[#0F172A] mt-4 mb-2">自动识别初步风险</h3>
          <p class="text-[#64748B] text-sm leading-relaxed">系统根据规则对常见财税、工商、社保问题进行初步筛查，帮助快速分层不同风险等级的客户。</p>
        </div>
        <div class="bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl p-6 hover:border-[#93C5FD] transition">
          <div :class="iconShellGold">
            <JcIcon name="review" :size="28" color="#D97706" />
          </div>
          <h3 class="font-semibold text-[#0F172A] mt-4 mb-2">高风险人工复核</h3>
          <p class="text-[#64748B] text-sm leading-relaxed">涉及高风险或敏感内容时，报告不会直接展示给客户，而是进入内部复核流程，保障合规底线。</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ========== 4. 初诊流程区 ========== -->
  <section id="flow-section" class="max-w-[1180px] mx-auto px-6 py-16">
    <div class="text-center mb-10">
      <h2 class="text-2xl font-bold text-[#0F172A] mb-2">初诊流程</h2>
      <p class="text-[#64748B] text-sm">四步完成企业财税初步筛查</p>
    </div>
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
      <div v-for="(step, i) in flowSteps" :key="i" class="text-center">
        <div :class="step.highlight ? iconShellGold : iconShellBlue" class="mx-auto">
          <JcIcon :name="step.icon" :size="24" :color="step.highlight ? '#D97706' : '#2563EB'" />
        </div>
        <h4 class="font-semibold text-[#0F172A] mt-3 mb-1">{{ step.title }}</h4>
        <p class="text-[#94A3B8] text-sm">{{ step.desc }}</p>
      </div>
    </div>
  </section>

  <!-- ========== 5. 风险覆盖场景区 ========== -->
  <section class="bg-white border-y border-[#E2E8F0]">
    <div class="max-w-[1180px] mx-auto px-6 py-16">
      <div class="text-center mb-10">
        <h2 class="text-2xl font-bold text-[#0F172A] mb-2">覆盖风险场景</h2>
        <p class="text-[#64748B] text-sm">系统可初步关注以下常见财税风险类型，具体判断需结合完整资料</p>
      </div>
      <div class="grid grid-cols-2 md:grid-cols-3 gap-4 max-w-2xl mx-auto">
        <div v-for="scene in riskScenes" :key="scene.name" class="border border-[#E2E8F0] rounded-lg px-4 py-3 flex items-center justify-center gap-2 text-[#475569] text-sm hover:border-[#93C5FD] transition">
          <JcIcon :name="scene.name" :size="16" color="#64748B" />
          {{ scene.label }}
        </div>
      </div>
      <p class="text-center text-[#94A3B8] text-xs mt-4">以上为系统可初步关注的场景类型，不构成最终判断</p>
    </div>
  </section>

  <!-- ========== 6. 底部 CTA + 合规说明 ========== -->
  <section class="bg-[#0F172A] text-white">
    <div class="max-w-[1180px] mx-auto px-6 py-16 text-center">
      <div :class="iconShellGold" class="mx-auto mb-4">
        <JcIcon name="success" :size="28" color="#D97706" />
      </div>
      <h2 class="text-2xl font-bold mb-3">现在开始企业财税初诊</h2>
      <p class="text-[#94A3B8] text-sm max-w-lg mx-auto mb-6">
        填写基础信息后，系统将生成初步筛查结果。涉及高风险内容时，将由君册专业人员进一步复核。
      </p>
      <router-link to="/questionnaire" class="inline-flex items-center gap-2 bg-white text-[#0F172A] px-8 py-3 rounded-lg font-semibold text-base hover:bg-[#F1F5F9] transition shadow-sm">
        开始免费初诊 <JcIcon name="arrowRight" :size="16" color="#0F172A" />
      </router-link>
      <p class="text-[#64748B] text-xs max-w-md mx-auto mt-8 leading-relaxed flex items-start gap-2 justify-center">
        <JcIcon name="secure" :size="14" color="#64748B" class="mt-0.5 flex-shrink-0" />
        <span>本系统生成内容仅作为初步筛查参考，不构成最终税务、法律或审计意见。具体事项建议结合完整资料由专业人员复核。</span>
      </p>
    </div>
  </section>

</div>
</template>

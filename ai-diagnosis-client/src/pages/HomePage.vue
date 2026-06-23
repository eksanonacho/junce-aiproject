<script setup lang="ts">
import JcIcon from '../components/ui/JcIcon.vue';
function scrollTo(id: string) { document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' }); }

const riskScenes = [
  { icon: 'tax', title: '税务申报异常', desc: '关注是否存在逾期申报、申报数据异常或历史处罚记录。' },
  { icon: 'history', title: '长期零申报', desc: '关注企业是否存在持续经营但长期零申报的情况。' },
  { icon: 'invoice', title: '发票与流水风险', desc: '关注发票开具、银行流水和实际经营之间是否需要进一步核查。' },
  { icon: 'socialSecurity', title: '社保用工问题', desc: '关注员工社保缴纳、劳务用工和人员结构是否存在隐患。' },
  { icon: 'company', title: '工商变更 / 异常', desc: '关注法人、股东、地址变更及工商异常状态对后续经营的影响。' },
  { icon: 'warning', title: '注销前风险', desc: '关注注销前账务、税务、发票和工商资料是否完整，避免注销受阻。' },
];

const flows = [
  { num: '01', icon: 'company', title: '填写企业信息', desc: '3 分钟完成标准化问卷，覆盖税务、工商、社保等关键维度' },
  { num: '02', icon: 'analysis', title: '系统初步筛查', desc: '基于规则引擎自动匹配风险场景，生成结构化诊断结果' },
  { num: '03', icon: 'report', title: '生成初诊结果', desc: '自动输出风险等级、问题明细和服务建议，支持打印留存' },
  { num: '04', icon: 'review', title: '专业人员复核跟进', desc: '中高风险报告由君册专业人员复核确认后跟进服务' },
];

const mockLeads = [
  { phone: '138****8000', risk: 'HIGH', status: '待复核' },
  { phone: '186****1122', risk: 'LOW', status: '已生成' },
  { phone: '159****8899', risk: 'MEDIUM', status: '待复核' },
  { phone: '177****6655', risk: 'LOW', status: '已复核' },
];

const services = [
  { icon: 'report', label: '代理记账' },
  { icon: 'tax', label: '税务合规' },
  { icon: 'company', label: '工商变更' },
  { icon: 'warning', label: '注销清算' },
  { icon: 'socialSecurity', label: '社保用工' },
  { icon: 'risk', label: '异常处理' },
];
</script>

<template>
<div class="min-h-screen bg-[#F8FAFC] text-[#1E293B] font-sans overflow-x-hidden">

  <!-- ===== 1. 导航栏 ===== -->
  <nav class="sticky top-0 z-50 bg-white/90 backdrop-blur-xl border-b border-[#E2E8F0]/60" style="height:64px">
    <div class="max-w-[1200px] mx-auto px-6 h-full flex items-center justify-between">
      <router-link to="/" class="flex items-center gap-3 no-underline">
        <img src="/logo.png" alt="君册财税" class="h-9 w-auto" />
        <span class="text-[#475569] font-normal text-sm hidden sm:inline">企业财税 AI 初诊</span>
      </router-link>
      <div class="flex items-center gap-6 text-sm">
        <a @click="scrollTo('scenes')" class="text-[#475569] hover:text-[#1E3A8A] cursor-pointer hidden md:block">覆盖场景</a>
        <a @click="scrollTo('flow')" class="text-[#475569] hover:text-[#1E3A8A] cursor-pointer hidden md:block">初诊流程</a>
        <a @click="scrollTo('services')" class="text-[#475569] hover:text-[#1E3A8A] cursor-pointer hidden md:block">衔接服务</a>
        <router-link to="/questionnaire" class="bg-[#1E3A8A] text-white px-4 py-2 rounded-lg font-medium hover:bg-[#1E40AF] transition inline-flex items-center gap-1.5 shadow-sm">
          开始初诊 <JcIcon name="arrowRight" :size="14" color="#fff" />
        </router-link>
      </div>
    </div>
  </nav>

  <!-- ===== 2. Hero 首屏 ===== -->
  <section class="relative overflow-hidden" style="min-height:620px;background:radial-gradient(circle at 75% 20%,rgba(37,99,235,0.10),transparent 35%),radial-gradient(circle at 25% 80%,rgba(37,99,235,0.04),transparent 30%),linear-gradient(180deg,#F1F5F9 0%,#F8FAFC 40%,#fff 100%)">
    <!-- subtle grid -->
    <div class="absolute inset-0 opacity-[0.03]" style="background-image:linear-gradient(rgba(15,23,42,0.4) 1px,transparent 1px),linear-gradient(90deg,rgba(15,23,42,0.4) 1px,transparent 1px);background-size:40px 40px"></div>
    <div class="relative max-w-[1200px] mx-auto px-6 flex flex-col md:flex-row items-center gap-10 md:gap-6" style="padding-top:88px;padding-bottom:88px">
      <!-- 左侧 -->
      <div class="flex-1 text-center md:text-left max-w-[580px]">
        <div class="inline-flex items-center gap-1.5 bg-[#FEF3C7] text-[#92400E] text-xs font-medium px-3 py-1 rounded-full mb-5">
          <JcIcon name="risk" :size="13" color="#92400E" /> 企业财税风险初筛 · AI 辅助
        </div>
        <h1 class="text-[38px] md:text-[48px] lg:text-[56px] font-extrabold text-[#0F172A] leading-[1.08] tracking-tight mb-5">
          君册财税<br/><span class="text-[#1E3A8A]">AI 企业初诊</span>
        </h1>
        <p class="text-[#475569] text-base md:text-lg max-w-[520px] mb-4 leading-relaxed">
          通过结构化问卷，快速识别企业在税务申报、发票流水、工商状态、社保用工与注销前准备中的常见风险，为后续人工复核和服务跟进提供参考。
        </p>
        <div class="flex flex-wrap items-center gap-3 text-sm text-[#64748B] mb-8">
          <span class="inline-flex items-center gap-1.5 bg-white border border-[#E2E8F0] rounded-full px-3 py-1"><JcIcon name="process" :size="14" color="#64748B"/> 3 分钟填写</span>
          <span class="inline-flex items-center gap-1.5 bg-white border border-[#E2E8F0] rounded-full px-3 py-1"><JcIcon name="analysis" :size="14" color="#64748B"/> 自动生成初诊结果</span>
          <span class="inline-flex items-center gap-1.5 bg-white border border-[#E2E8F0] rounded-full px-3 py-1"><JcIcon name="review" :size="14" color="#64748B"/> 高风险人工复核</span>
          <span class="inline-flex items-center gap-1.5 bg-white border border-[#E2E8F0] rounded-full px-3 py-1"><JcIcon name="report" :size="14" color="#64748B"/> 报告可打印留存</span>
        </div>
        <div class="flex flex-col sm:flex-row gap-3 justify-center md:justify-start">
          <router-link to="/questionnaire" class="inline-flex items-center gap-2 bg-[#1E3A8A] text-white px-7 py-3.5 rounded-xl font-semibold text-base hover:bg-[#1E40AF] transition shadow-lg shadow-blue-500/20">
            开始免费初诊 <JcIcon name="arrowRight" :size="18" color="#fff" />
          </router-link>
          <button @click="scrollTo('flow')" class="inline-flex items-center gap-2 border border-[#CBD5E1] text-[#475569] px-7 py-3.5 rounded-xl font-medium text-base hover:border-[#94A3B8] hover:bg-white transition">
            查看初诊流程
          </button>
        </div>
      </div>
      <!-- 右侧：大型产品预览面板 -->
      <div class="flex-shrink-0 w-full max-w-[480px]">
        <div class="bg-white rounded-2xl shadow-xl shadow-slate-200/60 border border-[#E2E8F0]/60 overflow-hidden" style="background:linear-gradient(180deg,#fff 0%,#F8FAFC 100%)">
          <!-- 面板头部 -->
          <div class="bg-[#0F172A] text-white px-6 py-4 flex items-center justify-between">
            <div class="flex items-center gap-2.5">
              <JcIcon name="report" :size="18" color="#fff" />
              <span class="font-semibold text-sm">企业初诊报告预览</span>
            </div>
            <span class="bg-white/15 text-white text-xs px-2.5 py-0.5 rounded-full">系统生成</span>
          </div>
          <!-- 面板主体 -->
          <div class="p-6 space-y-4">
            <!-- 风险等级 -->
            <div class="flex items-center justify-between bg-[#F1F5F9] rounded-xl px-4 py-3">
              <span class="text-[#64748B] text-sm">总体风险等级</span>
              <span class="bg-white border border-[#E2E8F0] text-[#475569] text-sm font-medium px-3 py-1 rounded-lg">待评估</span>
            </div>
            <!-- 维度 -->
            <div>
              <p class="text-xs text-[#94A3B8] font-medium mb-2.5 uppercase tracking-wide">覆盖维度</p>
              <div class="grid grid-cols-2 gap-2">
                <div class="flex items-center gap-2 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg px-3 py-2.5 text-sm text-[#475569]"><JcIcon name="tax" :size="15" color="#64748B" /> 税务申报</div>
                <div class="flex items-center gap-2 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg px-3 py-2.5 text-sm text-[#475569]"><JcIcon name="invoice" :size="15" color="#64748B" /> 发票与流水</div>
                <div class="flex items-center gap-2 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg px-3 py-2.5 text-sm text-[#475569]"><JcIcon name="company" :size="15" color="#64748B" /> 工商状态</div>
                <div class="flex items-center gap-2 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg px-3 py-2.5 text-sm text-[#475569]"><JcIcon name="socialSecurity" :size="15" color="#64748B" /> 社保用工</div>
                <div class="flex items-center gap-2 bg-[#F8FAFC] border border-[#E2E8F0] rounded-lg px-3 py-2.5 text-sm text-[#475569] col-span-2"><JcIcon name="warning" :size="15" color="#64748B" /> 注销风险</div>
              </div>
            </div>
            <!-- 底部 -->
            <div class="flex items-center justify-between pt-1">
              <div class="flex items-center gap-1.5 text-xs text-[#94A3B8]"><JcIcon name="secure" :size="12" color="#94A3B8" /> 高风险内容由专业人员复核</div>
            </div>
          </div>
        </div>
        <!-- 浮层小卡片 -->
        <div class="relative -mt-6 ml-auto mr-4 w-fit bg-white rounded-xl shadow-lg border border-[#E2E8F0] px-4 py-3 flex items-center gap-3 z-10">
          <div class="w-2 h-2 rounded-full bg-[#D97706] animate-pulse"></div>
          <div>
            <p class="text-xs font-semibold text-[#0F172A]">服务建议</p>
            <p class="text-[11px] text-[#64748B]">税务合规 · 注销前检查 · 社保用工核查</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ===== 3. 信任/能力标签条 ===== -->
  <section class="bg-white border-y border-[#E2E8F0]/60 -mt-1 relative z-10">
    <div class="max-w-[1200px] mx-auto px-6 py-5 flex flex-wrap items-center justify-center gap-6 md:gap-10 text-sm text-[#64748B] font-medium">
      <div class="flex items-center gap-2"><JcIcon name="process" :size="16" color="#64748B"/> 结构化问卷</div>
      <div class="hidden sm:block text-[#CBD5E1]">|</div>
      <div class="flex items-center gap-2"><JcIcon name="analysis" :size="16" color="#64748B"/> 规则初筛</div>
      <div class="hidden sm:block text-[#CBD5E1]">|</div>
      <div class="flex items-center gap-2"><JcIcon name="review" :size="16" color="#64748B"/> 人工复核</div>
      <div class="hidden sm:block text-[#CBD5E1]">|</div>
      <div class="flex items-center gap-2"><JcIcon name="report" :size="16" color="#64748B"/> 报告留存</div>
      <div class="hidden sm:block text-[#CBD5E1]">|</div>
      <div class="flex items-center gap-2"><JcIcon name="service" :size="16" color="#64748B"/> 服务跟进</div>
    </div>
  </section>

  <!-- ===== 4. 为什么选择 AI 初诊 ===== -->
  <section class="max-w-[1200px] mx-auto px-6 py-20">
    <div class="text-center mb-12">
      <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">Why AI Diagnosis</p>
      <h2 class="text-3xl font-bold text-[#0F172A] mb-3">为什么选择 AI 初诊</h2>
      <p class="text-[#64748B] max-w-lg mx-auto">不是替代专业判断，而是帮助更高效地完成初步筛查与客户分层</p>
    </div>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="group rounded-2xl p-7 transition-all duration-300 hover:-translate-y-1" style="background:linear-gradient(180deg,#fff 0%,#F8FAFC 100%);border:1px solid rgba(148,163,184,0.20);box-shadow:0 18px 45px rgba(15,23,42,0.05)">
        <div class="w-12 h-12 rounded-2xl bg-[#EFF6FF] border border-[#DBEAFE] flex items-center justify-center mb-5 group-hover:scale-105 transition">
          <JcIcon name="company" :size="24" />
        </div>
        <div class="text-xs text-[#1E3A8A] font-semibold mb-2 tracking-wide uppercase">Step 1</div>
        <h3 class="font-bold text-[#0F172A] text-lg mb-2">把客户信息问清楚</h3>
        <p class="text-[#64748B] text-sm leading-relaxed">通过标准化问题收集企业基础信息、经营状态和当前诉求，减少反复沟通，让后续服务更高效。</p>
      </div>
      <div class="group rounded-2xl p-7 transition-all duration-300 hover:-translate-y-1" style="background:linear-gradient(180deg,#fff 0%,#F8FAFC 100%);border:1px solid rgba(148,163,184,0.20);box-shadow:0 18px 45px rgba(15,23,42,0.05)">
        <div class="w-12 h-12 rounded-2xl bg-[#EFF6FF] border border-[#DBEAFE] flex items-center justify-center mb-5 group-hover:scale-105 transition">
          <JcIcon name="risk" :size="24" />
        </div>
        <div class="text-xs text-[#1E3A8A] font-semibold mb-2 tracking-wide uppercase">Step 2</div>
        <h3 class="font-bold text-[#0F172A] text-lg mb-2">把常见风险先筛出来</h3>
        <p class="text-[#64748B] text-sm leading-relaxed">围绕申报、发票、工商、社保、注销等场景进行初步筛查，帮助君册快速判断客户情况。</p>
      </div>
      <div class="group rounded-2xl p-7 transition-all duration-300 hover:-translate-y-1" style="background:linear-gradient(180deg,#fff 0%,#F8FAFC 100%);border:1px solid rgba(148,163,184,0.20);box-shadow:0 18px 45px rgba(15,23,42,0.05)">
        <div class="w-12 h-12 rounded-2xl bg-[#FEF3C7] border border-[#FDE68A] flex items-center justify-center mb-5 group-hover:scale-105 transition">
          <JcIcon name="review" :size="24" color="#D97706" />
        </div>
        <div class="text-xs text-[#92400E] font-semibold mb-2 tracking-wide uppercase">Step 3</div>
        <h3 class="font-bold text-[#0F172A] text-lg mb-2">把高风险内容先拦住</h3>
        <p class="text-[#64748B] text-sm leading-relaxed">涉及敏感或高风险内容时，报告不会直接展示给客户，而是进入专业人员复核流程，保障合规底线。</p>
      </div>
    </div>
  </section>

  <!-- ===== 5. 财税风险场景矩阵 ===== -->
  <section id="scenes" class="bg-white border-y border-[#E2E8F0]/60">
    <div class="max-w-[1200px] mx-auto px-6 py-20">
      <div class="text-center mb-12">
        <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">Risk Coverage</p>
        <h2 class="text-3xl font-bold text-[#0F172A] mb-3">覆盖财税风险场景</h2>
        <p class="text-[#64748B] max-w-lg mx-auto">系统可初步关注以下常见财税风险类型，具体判断需结合完整资料</p>
      </div>
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
        <div v-for="s in riskScenes" :key="s.title" class="group rounded-2xl p-6 transition-all duration-300 hover:-translate-y-1 cursor-default" style="background:linear-gradient(180deg,#fff 0%,#F8FAFC 100%);border:1px solid rgba(148,163,184,0.18);box-shadow:0 12px 30px rgba(15,23,42,0.04)">
          <div class="w-10 h-10 rounded-xl bg-[#EFF6FF] border border-[#DBEAFE] flex items-center justify-center mb-4 group-hover:bg-[#DBEAFE] transition">
            <JcIcon :name="s.icon" :size="20" />
          </div>
          <h4 class="font-semibold text-[#0F172A] mb-1.5">{{ s.title }}</h4>
          <p class="text-[#64748B] text-sm leading-relaxed">{{ s.desc }}</p>
        </div>
      </div>
      <p class="text-center text-[#94A3B8] text-xs mt-6">以上为系统可初步关注的场景类型，不构成最终判断</p>
    </div>
  </section>

  <!-- ===== 6. 初诊流程 ===== -->
  <section id="flow" class="max-w-[1200px] mx-auto px-6 py-20">
    <div class="text-center mb-12">
      <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">How It Works</p>
      <h2 class="text-3xl font-bold text-[#0F172A] mb-3">初诊流程</h2>
      <p class="text-[#64748B]">四步完成企业财税初步筛查</p>
    </div>
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6">
      <div v-for="(s, i) in flows" :key="i" class="relative text-center group">
        <!-- connector line (desktop) -->
        <div v-if="i < flows.length - 1" class="hidden md:block absolute top-9 left-[calc(50%+40px)] w-[calc(100%-80px)] h-px bg-[#E2E8F0]"></div>
        <div class="w-[72px] h-[72px] rounded-2xl mx-auto mb-4 flex items-center justify-center group-hover:scale-105 transition" :class="i===3?'bg-[#FEF3C7] border border-[#FDE68A]':'bg-[#EFF6FF] border border-[#DBEAFE]'">
          <JcIcon :name="s.icon" :size="28" :color="i===3?'#D97706':'#2563EB'" />
        </div>
        <div class="text-xs font-bold text-[#94A3B8] mb-1">{{ s.num }}</div>
        <h4 class="font-semibold text-[#0F172A] mb-1">{{ s.title }}</h4>
        <p class="text-[#94A3B8] text-sm">{{ s.desc }}</p>
      </div>
    </div>
  </section>

  <!-- ===== 7. 产品闭环展示 ===== -->
  <section class="bg-white border-y border-[#E2E8F0]/60">
    <div class="max-w-[1200px] mx-auto px-6 py-20">
      <div class="text-center mb-12">
        <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">Closed Loop</p>
        <h2 class="text-3xl font-bold text-[#0F172A] mb-3">从客户初诊到服务跟进，形成完整闭环</h2>
        <p class="text-[#64748B] max-w-lg mx-auto">不是一张问卷，而是一个从收集、筛查、报告到复核跟进的完整工作流</p>
      </div>
      <div class="flex flex-col md:flex-row gap-8 items-center">
        <!-- 左侧流程 -->
        <div class="flex-1 space-y-3 w-full max-w-sm">
          <div class="flex items-center gap-4 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl px-5 py-4"><div class="w-8 h-8 rounded-lg bg-[#DBEAFE] flex items-center justify-center text-sm font-bold text-[#1E3A8A]">1</div><span class="font-medium text-[#0F172A]">客户填写提交</span></div>
          <div class="flex items-center gap-4 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl px-5 py-4"><div class="w-8 h-8 rounded-lg bg-[#DBEAFE] flex items-center justify-center text-sm font-bold text-[#1E3A8A]">2</div><span class="font-medium text-[#0F172A]">系统分层筛查</span></div>
          <div class="flex items-center gap-4 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl px-5 py-4"><div class="w-8 h-8 rounded-lg bg-[#DBEAFE] flex items-center justify-center text-sm font-bold text-[#1E3A8A]">3</div><span class="font-medium text-[#0F172A]">生成初诊报告</span></div>
          <div class="flex items-center gap-4 bg-[#FEF3C7] border border-[#FDE68A] rounded-xl px-5 py-4"><div class="w-8 h-8 rounded-lg bg-[#FDE68A] flex items-center justify-center text-sm font-bold text-[#92400E]">4</div><span class="font-medium text-[#0F172A]">人工复核确认</span></div>
          <div class="flex items-center gap-4 bg-[#F8FAFC] border border-[#E2E8F0] rounded-xl px-5 py-4"><div class="w-8 h-8 rounded-lg bg-[#DBEAFE] flex items-center justify-center text-sm font-bold text-[#1E3A8A]">5</div><span class="font-medium text-[#0F172A]">商务服务跟进</span></div>
        </div>
        <!-- 右侧后台预览 -->
        <div class="flex-1 w-full max-w-md">
          <div class="bg-[#0F172A] rounded-2xl overflow-hidden shadow-xl">
            <div class="px-5 py-3 border-b border-white/10 flex items-center gap-2">
              <div class="flex gap-1.5"><div class="w-2.5 h-2.5 rounded-full bg-red-400"></div><div class="w-2.5 h-2.5 rounded-full bg-yellow-400"></div><div class="w-2.5 h-2.5 rounded-full bg-green-400"></div></div>
              <span class="text-white/60 text-xs ml-2">后台 · 客户线索</span>
            </div>
            <div class="p-3 space-y-1.5">
              <div v-for="(lead, i) in mockLeads" :key="i" class="flex items-center justify-between text-xs py-2 px-3 rounded-lg" :class="i%2===0?'bg-white/5':''">
                <span class="text-white/80 font-mono">{{ lead.phone }}</span>
                <span class="px-2 py-0.5 rounded-full text-[11px] font-medium" :class="lead.risk==='HIGH'?'bg-red-500/20 text-red-300':lead.risk==='MEDIUM'?'bg-yellow-500/20 text-yellow-300':'bg-green-500/20 text-green-300'">{{ lead.risk }}</span>
                <span class="text-white/40">{{ lead.status }}</span>
                <span class="text-blue-400 cursor-pointer hover:underline">查看</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ===== 8. 服务衔接区 ===== -->
  <section id="services" class="max-w-[1200px] mx-auto px-6 py-20">
    <div class="text-center mb-12">
      <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">Professional Services</p>
      <h2 class="text-3xl font-bold text-[#0F172A] mb-3">初诊之后，可以衔接君册专业服务</h2>
      <p class="text-[#64748B] max-w-lg mx-auto">初诊报告仅用于初步筛查，具体服务方案将结合企业完整资料由君册人员进一步确认</p>
    </div>
    <div class="grid grid-cols-3 md:grid-cols-6 gap-3 max-w-3xl mx-auto">
      <div v-for="svc in services" :key="svc.label" class="flex flex-col items-center gap-2 bg-white border border-[#E2E8F0] rounded-2xl p-4 hover:border-[#93C5FD] hover:shadow-sm transition cursor-default">
        <JcIcon :name="svc.icon" :size="22" color="#475569" />
        <span class="text-xs text-[#475569] font-medium">{{ svc.label }}</span>
      </div>
    </div>
  </section>

  <!-- ===== 9. 底部 CTA ===== -->
  <section style="background:linear-gradient(180deg,#0F172A 0%,#1E293B 100%)">
    <div class="max-w-[1200px] mx-auto px-6 py-20 text-center">
      <div class="w-14 h-14 rounded-2xl bg-white/10 border border-white/10 flex items-center justify-center mx-auto mb-5">
        <JcIcon name="success" :size="28" color="#FBBF24" />
      </div>
      <h2 class="text-3xl font-bold text-white mb-3">现在开始企业财税初诊</h2>
      <p class="text-[#94A3B8] max-w-lg mx-auto mb-8">填写基础信息后，系统将生成初步筛查结果。涉及高风险内容时，将由君册专业人员进一步复核。</p>
      <router-link to="/questionnaire" class="inline-flex items-center gap-2 bg-white text-[#0F172A] px-8 py-3.5 rounded-xl font-semibold text-base hover:bg-[#F1F5F9] transition shadow-lg">
        开始免费初诊 <JcIcon name="arrowRight" :size="18" color="#0F172A" />
      </router-link>
      <div class="flex items-start gap-2 justify-center mt-10 max-w-md mx-auto text-[#64748B] text-xs leading-relaxed">
        <JcIcon name="secure" :size="14" color="#64748B" class="mt-0.5 flex-shrink-0" />
        <span>本系统生成内容仅作为初步筛查参考，不构成最终税务、法律或审计意见。具体事项建议结合完整资料由专业人员复核。</span>
      </div>
    </div>
  </section>

</div>
</template>

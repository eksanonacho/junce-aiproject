<script setup lang="ts">
import { ref } from 'vue';
import JcIcon from '../components/ui/JcIcon.vue';
function scrollTo(id: string) { document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' }); }

const phone = ref('');
const code = ref('');
const codeSending = ref(false);

function handleSendCode() {
  if (!phone.value || phone.value.length < 11) {
    alert('请先输入正确的手机号');
    return;
  }
  codeSending.value = true;
  alert('短信验证将在正式接入后启用，当前可直接开始初诊。');
  setTimeout(() => { codeSending.value = false; }, 3000);
}

const riskScenes = [
  { icon: 'tax', title: '税务申报异常', concern: '是否存在逾期申报、申报数据异常、历史处罚或税务状态异常。', signals: '多期未申报 · 申报数据波动异常 · 存在税务处罚记录', advice: '建议结合历史申报表、税务状态和账务资料进一步核查。' },
  { icon: 'history', title: '长期零申报', concern: '企业是否存在持续经营迹象，但长期进行零申报。', signals: '仍有经营流水 · 仍在开票或收款 · 员工或办公成本持续存在', advice: '建议核对实际经营、银行流水和申报口径是否一致。' },
  { icon: 'invoice', title: '发票与流水风险', concern: '发票开具、银行流水和实际业务之间是否需要进一步核查。', signals: '发票金额与流水不匹配 · 大额往来缺少业务说明 · 进销项结构异常', advice: '建议结合合同、发票、流水和账务凭证进行复核。' },
  { icon: 'socialSecurity', title: '社保用工问题', concern: '员工社保、劳务用工和人员结构是否存在潜在隐患。', signals: '有员工但未缴社保 · 劳务人员比例较高 · 工资与个税、社保数据不一致', advice: '建议结合员工花名册、工资表、社保记录和个税申报进一步确认。' },
  { icon: 'company', title: '工商变更 / 异常', concern: '法人、股东、地址变更及工商异常状态是否影响后续经营。', signals: '频繁变更法人或股东 · 注册地址异常 · 工商年报异常', advice: '建议结合工商档案、年报记录和当前经营情况进一步核查。' },
  { icon: 'warning', title: '注销前风险', concern: '企业注销前账务、税务、发票和工商资料是否完整。', signals: '账务资料不完整 · 仍有未处理发票 · 税务状态未清理', advice: '建议在注销前完成税务、账务、工商和发票资料的系统核查。' },
];

const flows = [
  { num: '01', icon: 'company', title: '填写企业信息', input: '企业基础信息、经营情况、财税状态、当前诉求', process: '客户通过结构化问卷提交企业当前情况，减少后续反复沟通。', output: '形成客户初诊档案' },
  { num: '02', icon: 'analysis', title: '系统规则筛查', input: '客户提交的问卷答案', process: '系统根据预设规则识别常见风险场景，并进行初步风险分层。', output: '生成 LOW / MEDIUM / HIGH 初步等级' },
  { num: '03', icon: 'report', title: '生成初诊报告', input: '风险分层、命中场景、服务建议', process: '低风险客户可查看初诊报告；中高风险客户进入待复核状态。', output: '生成客户侧初诊报告' },
  { num: '04', icon: 'review', title: '人工复核确认', input: '中高风险报告、客户提交信息、命中风险点', process: '君册人员在后台查看报告内容，决定通过、驳回或修改报告。', output: '形成复核记录和客户可见状态' },
  { num: '05', icon: 'service', title: '服务跟进转化', input: '客户初诊结果和复核意见', process: '根据客户风险类型和当前诉求，衔接代理记账、税务合规、注销清算、工商变更等服务。', output: '进入后续沟通和服务跟进' },
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
<div class="min-h-screen bg-[#F2F5FC] text-[#1E293B] font-sans overflow-x-hidden">

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
        <router-link to="/diagnosis/start" class="bg-[#1E3A8A] text-white px-4 py-2 rounded-lg font-medium hover:bg-[#1E40AF] transition inline-flex items-center gap-1.5 shadow-sm">
          开始初诊 <JcIcon name="arrowRight" :size="14" color="#fff" />
        </router-link>
      </div>
    </div>
  </nav>

  <!-- ===== 2. Hero 首屏 ===== -->
  <section class="relative overflow-hidden bg-cover bg-center" style="min-height:620px;background-image:url('/hero-bg.png')">
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
          <router-link to="/diagnosis/start" class="inline-flex items-center gap-2 bg-[#1E3A8A] text-white px-7 py-3.5 rounded-xl font-semibold text-base hover:bg-[#1E40AF] transition shadow-lg shadow-blue-500/20">
            开始免费初诊 <JcIcon name="arrowRight" :size="18" color="#fff" />
          </router-link>
          <button @click="scrollTo('flow')" class="inline-flex items-center gap-2 border border-[#CBD5E1] text-[#475569] px-7 py-3.5 rounded-xl font-medium text-base hover:border-[#94A3B8] hover:bg-white transition">
            查看初诊流程
          </button>
        </div>
      </div>
      <!-- 右侧：手机号验证码初诊入口卡 -->
      <div class="flex-shrink-0 w-full max-w-[440px]">
        <div class="bg-white rounded-3xl shadow-2xl shadow-slate-200/60 border border-[#E2E8F0]/50 overflow-hidden">
          <!-- 顶部安全标签栏 -->
          <div class="bg-[#0F172A] text-white px-6 py-3.5 flex items-center justify-between">
            <div class="flex items-center gap-2">
              <JcIcon name="secure" :size="16" color="#FBBF24" />
              <span class="font-semibold text-sm">开始企业财税初诊</span>
            </div>
            <span class="bg-white/10 text-white/80 text-[11px] px-2.5 py-0.5 rounded-full flex items-center gap-1"><JcIcon name="secure" :size="10" color="#FBBF24" /> 安全验证</span>
          </div>
          <!-- 表单主体 -->
          <div class="p-6 space-y-4">
            <p class="text-[#64748B] text-sm leading-relaxed">手机号验证后进入问卷，初诊结果将用于后续报告查看和人工复核联系。</p>
            <!-- 手机号 -->
            <div>
              <label class="block text-sm font-medium text-[#0F172A] mb-1.5">手机号</label>
              <input
                v-model="phone"
                type="tel"
                maxlength="11"
                placeholder="请输入用于接收初诊结果的手机号"
                class="w-full h-[46px] px-4 border border-[#CBD5E1] rounded-xl text-[#0F172A] placeholder-[#94A3B8] focus:border-[#2563EB] focus:ring-2 focus:ring-blue-100 outline-none transition text-sm"
              />
            </div>
            <!-- 验证码 -->
            <div>
              <label class="block text-sm font-medium text-[#0F172A] mb-1.5">验证码</label>
              <div class="flex gap-2">
                <input
                  v-model="code"
                  type="text"
                  maxlength="6"
                  placeholder="请输入验证码"
                  class="flex-1 h-[46px] px-4 border border-[#CBD5E1] rounded-xl text-[#0F172A] placeholder-[#94A3B8] focus:border-[#2563EB] focus:ring-2 focus:ring-blue-100 outline-none transition text-sm"
                />
                <button
                  @click="handleSendCode"
                  :disabled="codeSending"
                  class="flex-shrink-0 h-[46px] px-4 rounded-xl border border-[#CBD5E1] text-[#475569] text-sm font-medium hover:border-[#2563EB] hover:text-[#2563EB] disabled:opacity-50 transition whitespace-nowrap"
                >{{ codeSending ? '已发送' : '获取验证码' }}</button>
              </div>
            </div>
            <!-- TODO: 接入真实短信验证码接口后，在这里调用 sendSmsCode() -->
            <!-- TODO: 验证通过后再进入问卷 -->
            <!-- 主按钮 -->
            <router-link to="/diagnosis/start" class="block w-full h-[48px] bg-[#1E3A8A] text-white rounded-xl font-semibold text-base hover:bg-[#1E40AF] transition shadow-lg shadow-blue-500/20 flex items-center justify-center gap-2">
              开始免费初诊 <JcIcon name="arrowRight" :size="18" color="#fff" />
            </router-link>
            <!-- 合规提示 -->
            <p class="text-[#94A3B8] text-xs leading-relaxed text-center">本系统仅用于企业财税初步筛查，涉及高风险内容时将由君册专业人员复核。</p>
          </div>
        </div>
        <!-- 底部信任标签 -->
        <div class="flex flex-wrap justify-center gap-2 mt-4">
          <span class="bg-white/80 border border-[#E2E8F0] rounded-full px-3 py-1 text-[11px] text-[#64748B] flex items-center gap-1"><JcIcon name="secure" :size="11" color="#64748B"/> 信息仅用于初诊</span>
          <span class="bg-white/80 border border-[#E2E8F0] rounded-full px-3 py-1 text-[11px] text-[#64748B] flex items-center gap-1"><JcIcon name="review" :size="11" color="#64748B"/> 高风险人工复核</span>
          <span class="bg-white/80 border border-[#E2E8F0] rounded-full px-3 py-1 text-[11px] text-[#64748B] flex items-center gap-1"><JcIcon name="report" :size="11" color="#64748B"/> 报告可留存查看</span>
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
  <section class="why-bg border-y border-[#E2E8F0]/30">
    <div class="max-w-[1200px] mx-auto px-6 py-20">
      <div class="text-center mb-12">
        <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">Why AI Diagnosis</p>
        <h2 class="text-3xl font-bold text-[#0F172A] mb-3">为什么需要 AI 初诊</h2>
        <p class="text-[#64748B] max-w-xl mx-auto">不是替代专业判断，而是把客户咨询前的信息收集、风险初筛和服务分层先标准化。</p>
      </div>
      <!-- 对比区 -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
        <div class="bg-white rounded-2xl p-6 border border-[#E2E8F0]/60" style="box-shadow:0 12px 30px rgba(15,23,42,0.03)">
          <h3 class="font-bold text-[#0F172A] mb-4 flex items-center gap-2"><JcIcon name="warning" :size="18" color="#94A3B8" /> 传统咨询常见问题</h3>
          <div class="space-y-3 text-sm text-[#64748B]">
            <div class="flex items-start gap-2"><span class="text-[#CBD5E1] mt-0.5">—</span>客户情况靠微信零散沟通，信息不完整</div>
            <div class="flex items-start gap-2"><span class="text-[#CBD5E1] mt-0.5">—</span>员工反复询问企业基础信息，效率低</div>
            <div class="flex items-start gap-2"><span class="text-[#CBD5E1] mt-0.5">—</span>客户风险轻重难以快速判断，跟进优先级不清晰</div>
            <div class="flex items-start gap-2"><span class="text-[#CBD5E1] mt-0.5">—</span>敏感问题容易直接沟通，缺少统一话术和复核边界</div>
          </div>
        </div>
        <div class="rounded-2xl p-6 border border-[#DBEAFE]" style="background:linear-gradient(180deg,#EFF6FF 0%,#F8FAFC 100%);box-shadow:0 12px 30px rgba(37,99,235,0.06)">
          <h3 class="font-bold text-[#0F172A] mb-4 flex items-center gap-2"><JcIcon name="success" :size="18" color="#2563EB" /> AI 初诊带来的改进</h3>
          <div class="space-y-3 text-sm text-[#1E3A8A]">
            <div class="flex items-start gap-2"><JcIcon name="success" :size="14" color="#2563EB" class="mt-0.5 flex-shrink-0" />通过结构化问卷一次性收集关键资料</div>
            <div class="flex items-start gap-2"><JcIcon name="success" :size="14" color="#2563EB" class="mt-0.5 flex-shrink-0" />系统按规则完成初步风险分层</div>
            <div class="flex items-start gap-2"><JcIcon name="success" :size="14" color="#2563EB" class="mt-0.5 flex-shrink-0" />低风险自动生成初诊结果，高风险进入人工复核</div>
            <div class="flex items-start gap-2"><JcIcon name="success" :size="14" color="#2563EB" class="mt-0.5 flex-shrink-0" />后台沉淀客户线索、风险等级和复核记录</div>
          </div>
        </div>
      </div>
      <!-- 3 张核心能力卡片 -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div class="group rounded-2xl p-7 transition-all duration-300 hover:-translate-y-1 bg-white" style="border:1px solid rgba(148,163,184,0.20);box-shadow:0 18px 45px rgba(15,23,42,0.05)">
          <div class="w-12 h-12 rounded-2xl bg-[#EFF6FF] border border-[#DBEAFE] flex items-center justify-center mb-5 group-hover:scale-105 transition"><JcIcon name="company" :size="24" /></div>
          <div class="text-xs text-[#1E3A8A] font-semibold mb-2 tracking-wide uppercase">Capability 1</div>
          <h3 class="font-bold text-[#0F172A] text-lg mb-2">信息结构化</h3>
          <p class="text-[#64748B] text-sm leading-relaxed mb-3">围绕企业基础信息、经营状态、申报情况、发票流水、社保用工和当前诉求设计问题，减少人工反复沟通。</p>
          <div class="flex flex-wrap gap-1.5"><span class="bg-[#F1F5F9] text-[#64748B] text-[11px] px-2 py-0.5 rounded-full">企业画像</span><span class="bg-[#F1F5F9] text-[#64748B] text-[11px] px-2 py-0.5 rounded-full">财税状态</span><span class="bg-[#F1F5F9] text-[#64748B] text-[11px] px-2 py-0.5 rounded-full">当前诉求</span></div>
        </div>
        <div class="group rounded-2xl p-7 transition-all duration-300 hover:-translate-y-1 bg-white" style="border:1px solid rgba(148,163,184,0.20);box-shadow:0 18px 45px rgba(15,23,42,0.05)">
          <div class="w-12 h-12 rounded-2xl bg-[#EFF6FF] border border-[#DBEAFE] flex items-center justify-center mb-5 group-hover:scale-105 transition"><JcIcon name="risk" :size="24" /></div>
          <div class="text-xs text-[#1E3A8A] font-semibold mb-2 tracking-wide uppercase">Capability 2</div>
          <h3 class="font-bold text-[#0F172A] text-lg mb-2">风险初步分层</h3>
          <p class="text-[#64748B] text-sm leading-relaxed mb-3">根据客户填写内容，系统对常见财税、工商、社保和注销场景进行规则筛查，形成低、中、高风险初步分层。</p>
          <div class="flex flex-wrap gap-1.5"><span class="bg-green-50 text-green-700 text-[11px] px-2 py-0.5 rounded-full">LOW</span><span class="bg-yellow-50 text-yellow-700 text-[11px] px-2 py-0.5 rounded-full">MEDIUM</span><span class="bg-red-50 text-red-700 text-[11px] px-2 py-0.5 rounded-full">HIGH</span></div>
        </div>
        <div class="group rounded-2xl p-7 transition-all duration-300 hover:-translate-y-1 bg-white" style="border:1px solid rgba(148,163,184,0.20);box-shadow:0 18px 45px rgba(15,23,42,0.05)">
          <div class="w-12 h-12 rounded-2xl bg-[#FEF3C7] border border-[#FDE68A] flex items-center justify-center mb-5 group-hover:scale-105 transition"><JcIcon name="review" :size="24" color="#D97706" /></div>
          <div class="text-xs text-[#92400E] font-semibold mb-2 tracking-wide uppercase">Capability 3</div>
          <h3 class="font-bold text-[#0F172A] text-lg mb-2">人工复核兜底</h3>
          <p class="text-[#64748B] text-sm leading-relaxed mb-3">涉及敏感或高风险内容时，报告不会直接展示给客户，而是进入君册内部复核流程，保障合规底线。</p>
          <div class="flex flex-wrap gap-1.5"><span class="bg-[#F1F5F9] text-[#64748B] text-[11px] px-2 py-0.5 rounded-full">待复核</span><span class="bg-[#F1F5F9] text-[#64748B] text-[11px] px-2 py-0.5 rounded-full">已通过</span><span class="bg-[#F1F5F9] text-[#64748B] text-[11px] px-2 py-0.5 rounded-full">已驳回</span></div>
        </div>
      </div>
    </div>
  </section>

  <!-- ===== 5. 财税风险场景矩阵 ===== -->
  <section id="scenes" class="risk-bg border-y border-[#E2E8F0]/60">
    <div class="max-w-[1200px] mx-auto px-6 py-20">
      <div class="text-center mb-12">
        <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">Risk Coverage</p>
        <h2 class="text-3xl font-bold text-[#0F172A] mb-3">覆盖企业常见财税风险场景</h2>
        <p class="text-[#64748B] max-w-xl mx-auto">系统仅作初步筛查，具体判断需要结合账务、申报、发票、流水、工商和社保资料进一步确认。</p>
      </div>
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-5">
        <div v-for="s in riskScenes" :key="s.title" class="group rounded-2xl p-6 transition-all duration-300 hover:-translate-y-1 cursor-default bg-white" style="border:1px solid rgba(148,163,184,0.18);box-shadow:0 12px 30px rgba(15,23,42,0.04);min-height:220px">
          <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 rounded-xl bg-[#EFF6FF] border border-[#DBEAFE] flex items-center justify-center group-hover:bg-[#DBEAFE] transition flex-shrink-0"><JcIcon :name="s.icon" :size="20" /></div>
            <h4 class="font-semibold text-[#0F172A] text-base">{{ s.title }}</h4>
          </div>
          <div class="space-y-2.5 text-sm">
            <div><span class="text-[#94A3B8] text-xs font-medium uppercase tracking-wide">关注问题</span><p class="text-[#475569] mt-0.5 leading-relaxed">{{ s.concern }}</p></div>
            <div><span class="text-[#94A3B8] text-xs font-medium uppercase tracking-wide">常见信号</span><p class="text-[#64748B] mt-0.5 leading-relaxed text-[13px]">{{ s.signals }}</p></div>
            <div><span class="text-[#1E3A8A] text-xs font-medium uppercase tracking-wide">建议方向</span><p class="text-[#475569] mt-0.5 leading-relaxed text-[13px]">{{ s.advice }}</p></div>
          </div>
        </div>
      </div>
      <p class="text-center text-[#94A3B8] text-xs mt-8 max-w-xl mx-auto leading-relaxed">以上场景仅用于初步筛查，不代表最终风险结论。具体问题需由专业人员结合完整资料复核。</p>
    </div>
  </section>

  <!-- ===== 6. 初诊流程（5步详情） ===== -->
  <section id="flow" class="flow-bg px-6 py-20">
    <div class="max-w-[1200px] mx-auto">
    <div class="text-center mb-12">
      <p class="text-[#1E3A8A] text-sm font-semibold mb-2 tracking-wide uppercase">How It Works</p>
      <h2 class="text-3xl font-bold text-[#0F172A] mb-3">初诊流程</h2>
      <p class="text-[#64748B]">从客户填写到内部复核，形成可追踪的初诊闭环</p>
    </div>
    <!-- 步骤卡片 -->
    <div class="space-y-4 max-w-3xl mx-auto">
      <div v-for="(s, i) in flows" :key="i" class="group rounded-2xl p-5 md:p-6 transition-all duration-300 hover:-translate-y-0.5 bg-white" :class="i===3?'border border-[#FDE68A]':'border border-[#E2E8F0]/60'" :style="i===3?'background:linear-gradient(180deg,#FFFBEB 0%,#fff 100%);box-shadow:0 12px 30px rgba(217,119,6,0.06)':'box-shadow:0 12px 30px rgba(15,23,42,0.03)'">
        <div class="flex flex-col md:flex-row md:items-center gap-3 md:gap-5 mb-3">
          <div class="flex items-center gap-3 flex-shrink-0">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center text-sm font-bold" :class="i===3?'bg-[#FEF3C7] text-[#92400E]':'bg-[#EFF6FF] text-[#1E3A8A]'">{{ s.num }}</div>
            <div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0" :class="i===3?'bg-[#FEF3C7]':'bg-[#EFF6FF]'"><JcIcon :name="s.icon" :size="16" :color="i===3?'#D97706':'#2563EB'" /></div>
            <h4 class="font-bold text-[#0F172A]">{{ s.title }}</h4>
          </div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-3 text-sm ml-0 md:ml-[88px]">
          <div class="bg-[#F8FAFC] rounded-xl px-4 py-3"><span class="text-[#94A3B8] text-xs font-medium uppercase tracking-wide">输入</span><p class="text-[#475569] mt-1 leading-relaxed">{{ s.input }}</p></div>
          <div class="bg-[#EFF6FF] rounded-xl px-4 py-3"><span class="text-[#1E3A8A] text-xs font-medium uppercase tracking-wide">系统处理</span><p class="text-[#475569] mt-1 leading-relaxed">{{ s.process }}</p></div>
          <div class="bg-[#F0FDF4] rounded-xl px-4 py-3"><span class="text-[#16A34A] text-xs font-medium uppercase tracking-wide">输出</span><p class="text-[#475569] mt-1 leading-relaxed">{{ s.output }}</p></div>
        </div>
      </div>
    </div>
    </div><!-- /max-w wrapper -->
  </section>

  <!-- ===== 7. 产品闭环展示 ===== -->
  <section class="bg-[#FAFBFD] border-y border-[#E2E8F0]/40">
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
  <section id="services" class="services-bg px-6 py-20">
    <div class="max-w-[1200px] mx-auto">
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
    </div><!-- /max-w wrapper -->
  </section>

  <!-- ===== 9. 底部 CTA ===== -->
  <section class="cta-bg bg-cover bg-center" style="background-image:url('/cta-bg.png')">
    <div class="max-w-[1200px] mx-auto px-6 py-20 text-center">
      <div class="w-14 h-14 rounded-2xl bg-white/10 border border-white/10 flex items-center justify-center mx-auto mb-5">
        <JcIcon name="success" :size="28" color="#FBBF24" />
      </div>
      <h2 class="text-3xl font-bold text-white mb-3">现在开始企业财税初诊</h2>
      <p class="text-[#94A3B8] max-w-lg mx-auto mb-8">填写基础信息后，系统将生成初步筛查结果。涉及高风险内容时，将由君册专业人员进一步复核。</p>
      <router-link to="/diagnosis/start" class="inline-flex items-center gap-2 bg-white text-[#0F172A] px-8 py-3.5 rounded-xl font-semibold text-base hover:bg-[#F1F5F9] transition shadow-lg">
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

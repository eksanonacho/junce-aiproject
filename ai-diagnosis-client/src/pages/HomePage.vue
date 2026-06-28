<script setup lang="ts">
import { ref } from 'vue';
import JcBrand from '../components/common/JcBrand.vue';
import JcIcon from '../components/ui/JcIcon.vue';

function scrollTo(id: string) {
  document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
}

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
  {
    icon: 'tax',
    title: '税务风险识别',
    tag: '税务申报异常',
    tone: 'red',
    points: ['核心：税负异常监控', '信号：长期零申报或申报数据异常', '建议：行业对标优化及合规申报'],
  },
  {
    icon: 'invoice',
    title: '票据合规穿透',
    tag: '发票与流水',
    tone: 'gold',
    points: ['核心：票据与资金流水交叉核验', '信号：上下游关系及异常往来资金', '建议：规范入账与资金管理流程'],
  },
  {
    icon: 'socialSecurity',
    title: '用工与社保风控',
    tag: '社保用工',
    tone: 'ink',
    points: ['核心：劳务派遣与社保合规分析', '信号：个税与社保基数不一致监测', '建议：多元化用工成本优化方案'],
  },
];

const flows = [
  { num: '01', icon: 'company', title: '信息收集', desc: '录入企业核心经营数据与资料' },
  { num: '02', icon: 'analysis', title: '规则匹配', desc: '系统匹配财税风险筛查规则' },
  { num: '03', icon: 'report', title: '生成报告', desc: '多维度评估生成可视化看板报告' },
  { num: '04', icon: 'review', title: '专家复核', desc: '高风险事项进入人工复核' },
  { num: '05', icon: 'service', title: '服务落地', desc: '衔接后续沟通与服务方案' },
];

const services = [
  { icon: 'report', label: '代理记账', desc: '精准录入、实时预警，让账目成为企业经营的指南针。' },
  { icon: 'warning', label: '合规整改', desc: '梳理历史遗留问题，建立长效的财税合规管理体系。' },
  { icon: 'tax', label: '税务筹划', desc: '在合规前提下优化税务结构，提升企业现金流综合效益。' },
  { icon: 'company', label: '工商变更', desc: '高效办理各类工商变更、资质办理及异常名录处理。' },
  { icon: 'secure', label: '注销清算', desc: '专业清理税务历史问题，安全高效办理企业退出流程。' },
  { icon: 'analysis', label: '财务外包', desc: '由专业财务团队参与并优化企业日常财务管理。' },
];
</script>

<template>
  <div class="home-shell min-h-screen text-[#1A1A1A] font-sans overflow-x-hidden">
    <nav class="fixed top-0 left-0 w-full z-50 h-20 bg-[#FFF8F3]/86 backdrop-blur-xl border-b border-[#D8C5A8]/35 shadow-[0_8px_28px_rgba(53,48,39,0.05)]">
      <div class="max-w-[1280px] mx-auto px-5 md:px-10 h-full flex items-center justify-between">
        <JcBrand />
        <div class="hidden md:flex items-center gap-10 text-[13px] font-semibold">
          <button @click="scrollTo('scenes')" class="text-[#785600] border-b-2 border-[#785600] pb-1">覆盖场景</button>
          <button @click="scrollTo('flow')" class="text-[#5E5548] hover:text-[#785600] transition">初诊流程</button>
          <button @click="scrollTo('services')" class="text-[#5E5548] hover:text-[#785600] transition">衔接服务</button>
        </div>
        <router-link to="/diagnosis/start" class="bg-[#785600] text-white px-5 py-2.5 rounded-xl text-[13px] font-semibold hover:bg-[#5D4200] transition shadow-[0_12px_26px_rgba(120,86,0,0.18)]">
          开始初诊
        </router-link>
      </div>
    </nav>

    <main class="pt-20">
      <section class="home-hero relative min-h-[790px] flex items-center overflow-hidden">
        <div class="absolute inset-0 bg-[rgba(255,248,243,0.82)]"></div>
        <div class="absolute inset-0 hero-grid pointer-events-none"></div>
        <div class="relative z-[1] max-w-[1280px] mx-auto px-5 md:px-10 py-20 md:py-28 w-full grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          <div class="lg:col-span-7 max-w-2xl">
            <div class="inline-flex items-center gap-2 rounded-full bg-[#F3E6C8] text-[#785600] border border-[#B8860B]/20 px-4 py-1.5 text-[12px] font-semibold mb-8 shadow-sm">
              <JcIcon name="secure" :size="15" color="#785600" />
              君册财税 · 企业财税风险初筛
            </div>
            <h1 class="text-[48px] md:text-[72px] lg:text-[82px] leading-[0.98] font-extrabold tracking-tight mb-7">
              AI <span class="text-bronze">企业经营初诊系统</span>
            </h1>
            <p class="text-[15px] md:text-[17px] leading-8 text-[#4F4535] max-w-xl mb-8">
              通过结构化问卷与资料上传，快速识别企业在税务申报、发票流水、用工合规及经营状态中的潜在风险，为后续人工复核和服务跟进提供参考。
            </p>
            <div class="flex flex-wrap gap-3 mb-8">
              <span class="home-pill"><JcIcon name="process" :size="14" color="#785600" />3分钟填写</span>
              <span class="home-pill"><JcIcon name="analysis" :size="14" color="#785600" />自动生成初诊结果</span>
              <span class="home-pill"><JcIcon name="review" :size="14" color="#785600" />高风险人工复核</span>
            </div>
            <div class="flex items-center gap-4">
              <div class="flex -space-x-3">
                <span class="home-avatar bg-[#0F2F32]"></span>
                <span class="home-avatar bg-[#173B3A]"></span>
                <span class="home-avatar bg-[#D8C5A8]"></span>
              </div>
              <span class="text-[13px] text-[#5E5548] font-medium">已为 5,000+ 企业提供风险预警</span>
            </div>
          </div>

          <div class="lg:col-span-5">
            <div class="glass-card rounded-[24px] p-7 md:p-8 shadow-[0_30px_80px_rgba(53,48,39,0.14)]">
              <h2 class="text-[22px] font-bold text-[#1A1A1A] mb-4">开始企业经营初诊</h2>
              <p class="text-[13px] leading-6 text-[#5E5548] mb-6">
                上传经营资料并补充关键信息，系统将生成利润、风险、现金流、效率四维经营看板。
              </p>
              <div class="space-y-4">
                <label class="block">
                  <span class="block text-[12px] font-semibold text-[#5E5548] mb-2">手机号码</span>
                  <input v-model="phone" maxlength="11" type="tel" placeholder="请输入您的联系方式" class="home-input" />
                </label>
                <label class="block">
                  <span class="block text-[12px] font-semibold text-[#5E5548] mb-2">验证码</span>
                  <div class="flex gap-2">
                    <input v-model="code" maxlength="6" type="text" placeholder="6位数字" class="home-input flex-1" />
                    <button @click="handleSendCode" :disabled="codeSending" class="px-4 rounded-xl border border-[#785600] text-[#785600] text-[12px] font-semibold hover:bg-[#F3E6C8] disabled:opacity-50 transition">
                      {{ codeSending ? '已发送' : '获取验证码' }}
                    </button>
                  </div>
                </label>
                <router-link to="/diagnosis/start" class="flex h-14 items-center justify-center rounded-xl bg-[#785600] text-white font-bold text-[16px] shadow-[0_18px_34px_rgba(120,86,0,0.22)] hover:bg-[#5D4200] transition">
                  开始免费初诊
                </router-link>
                <p class="text-center text-[11px] text-[#817563]">信息仅用于初诊与复核联系</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="scenes" class="bg-[#FFF8F3]/90 px-5 md:px-10 py-20 md:py-24">
        <div class="max-w-[1280px] mx-auto">
          <div class="flex flex-col md:flex-row justify-between md:items-end gap-5 mb-14">
            <div>
              <h2 class="text-[34px] md:text-[46px] font-extrabold tracking-tight mb-4">全维度风险穿透</h2>
              <p class="text-[14px] md:text-[16px] text-[#5E5548] max-w-2xl leading-7">针对核心经营环节，提供多层次的数据扫描与预警分析，涵盖税务、票据及用工等核心场景。</p>
            </div>
            <button @click="scrollTo('services')" class="hidden md:inline-flex items-center gap-2 text-[#785600] text-[13px] font-bold hover:gap-3 transition-all">
              查看所有覆盖场景 <JcIcon name="arrowRight" :size="14" color="#785600" />
            </button>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-7">
            <article v-for="scene in riskScenes" :key="scene.title" class="risk-card group" :class="`tone-${scene.tone}`">
              <div class="flex justify-between items-start mb-7">
                <span class="risk-icon"><JcIcon :name="scene.icon" :size="22" color="currentColor" /></span>
                <span class="risk-tag">{{ scene.tag }}</span>
              </div>
              <h3 class="text-[20px] font-bold mb-5">{{ scene.title }}</h3>
              <ul class="space-y-3 text-[13px] text-[#4F4535] leading-6">
                <li v-for="(point, i) in scene.points" :key="point" class="flex gap-2">
                  <span class="mt-2 h-1.5 w-1.5 rounded-full flex-none" :class="i === 0 ? 'bg-current' : i === 1 ? 'bg-[#B8860B]' : 'bg-[#2F6B48]'"></span>
                  <span>{{ point }}</span>
                </li>
              </ul>
            </article>
          </div>
        </div>
      </section>

      <section id="flow" class="bg-[#F9F7F2] px-5 md:px-10 py-20 md:py-24">
        <div class="max-w-[1280px] mx-auto">
          <div class="text-center mb-16">
            <h2 class="text-[34px] md:text-[44px] font-extrabold tracking-tight mb-4">诊断标准化流程</h2>
            <p class="text-[#5E5548] text-[14px] md:text-[16px]">科学、严谨、高效的五步走诊断法，助力企业稳健经营</p>
          </div>
          <div class="relative grid grid-cols-1 md:grid-cols-5 gap-4">
            <div class="hidden md:block absolute top-[34px] left-[8%] right-[8%] h-px bg-[#D8C5A8]"></div>
            <article v-for="step in flows" :key="step.num" class="relative z-[1] flex flex-col items-center text-center">
              <div class="w-16 h-16 rounded-full bg-[#EFE6D8] border-4 border-[#F9F7F2] flex items-center justify-center text-[#785600] mb-4 shadow-sm">
                <JcIcon :name="step.icon" :size="20" color="#785600" />
              </div>
              <div class="w-full rounded-xl bg-[#FFF8F3] border border-[#D8C5A8]/55 px-4 py-4 shadow-[0_10px_28px_rgba(53,48,39,0.04)]">
                <h3 class="text-[16px] font-bold mb-1">{{ step.num }} {{ step.title }}</h3>
                <p class="text-[12px] text-[#5E5548] leading-5">{{ step.desc }}</p>
              </div>
            </article>
          </div>
        </div>
      </section>

      <section id="services" class="bg-[#FFF8F3] px-5 md:px-10 py-20 md:py-24 relative overflow-hidden">
        <div class="absolute right-[-120px] top-[140px] w-[420px] h-[420px] rounded-full bg-[#B8860B]/8 blur-3xl"></div>
        <div class="max-w-[1280px] mx-auto relative z-[1]">
          <div class="text-center mb-14">
            <h2 class="text-[34px] md:text-[44px] font-extrabold tracking-tight mb-4">后续深度服务</h2>
            <p class="text-[#5E5548] text-[14px] md:text-[16px]">针对初诊结果，提供端到端的专业财税解决方案。</p>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <article v-for="svc in services" :key="svc.label" class="service-card">
              <div class="flex items-center gap-2 mb-3">
                <JcIcon :name="svc.icon" :size="18" color="#785600" />
                <h3 class="text-[18px] font-bold">{{ svc.label }}</h3>
              </div>
              <p class="text-[13px] leading-6 text-[#5E5548]">{{ svc.desc }}</p>
            </article>
          </div>
        </div>
      </section>

      <section class="px-5 md:px-10 py-16 md:py-20 bg-[#F3EDE3]">
        <div class="max-w-[1280px] mx-auto rounded-[32px] bg-[#121212] text-white px-6 md:px-20 py-16 md:py-20 text-center shadow-[0_28px_80px_rgba(18,18,18,0.18)]">
          <h2 class="text-[32px] md:text-[46px] font-extrabold tracking-tight mb-5">准备好进行企业“经营体检”了吗？</h2>
          <p class="text-[#C8C6C5] text-[14px] md:text-[16px] leading-7 max-w-2xl mx-auto mb-10">每一个经营风险都值得被提前看见。现在开始，为您的企业建立更清晰的经营判断基础。</p>
          <div class="flex flex-col sm:flex-row gap-4 justify-center">
            <router-link to="/diagnosis/start" class="px-9 py-4 rounded-xl bg-[#785600] text-white font-bold hover:bg-[#946D11] transition shadow-[0_16px_34px_rgba(120,86,0,0.28)]">
              即刻开始初诊
            </router-link>
            <button @click="scrollTo('flow')" class="px-9 py-4 rounded-xl border border-white/35 text-white font-bold hover:bg-white/10 transition">
              查看初诊流程
            </button>
          </div>
        </div>
      </section>
    </main>

    <footer class="bg-[#FFF8F3] border-t border-[#D8C5A8]/35 px-5 md:px-10 py-10">
      <div class="max-w-[1280px] mx-auto flex flex-col md:flex-row items-start md:items-center justify-between gap-5">
        <div>
          <JcBrand compact />
          <p class="text-[12px] text-[#817563] mt-3">© 2024 君册财税 AI. 保留所有权利。初诊报告仅供参考。</p>
        </div>
        <div class="flex gap-8 text-[12px] font-semibold text-[#5E5548]">
          <span>隐私政策</span>
          <span>服务条款</span>
          <span>数据安全</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
.home-shell {
  background: #fff8f3;
}

.home-hero {
  background-image: url('/brand/home-hero-office.png');
  background-size: cover;
  background-position: center;
}

.hero-grid {
  background:
    linear-gradient(90deg, rgba(120, 86, 0, 0.05) 1px, transparent 1px),
    linear-gradient(180deg, rgba(120, 86, 0, 0.04) 1px, transparent 1px);
  background-size: 78px 78px;
  mask-image: linear-gradient(180deg, transparent 0%, #000 24%, #000 82%, transparent 100%);
}

.text-bronze {
  color: #785600;
  text-shadow: 0 16px 36px rgba(120, 86, 0, 0.10);
}

.home-pill {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  border: 1px solid rgba(184, 134, 11, 0.20);
  border-radius: 10px;
  background: rgba(255, 248, 243, 0.86);
  color: #4f4535;
  padding: 7px 10px;
  font-size: 12px;
  font-weight: 600;
  box-shadow: 0 8px 20px rgba(53, 48, 39, 0.04);
}

.home-avatar {
  width: 38px;
  height: 38px;
  border: 2px solid #fff8f3;
  border-radius: 999px;
  display: inline-block;
}

.glass-card {
  border: 1px solid rgba(216, 197, 168, 0.58);
  background: rgba(255, 248, 243, 0.82);
  backdrop-filter: blur(20px);
}

.home-input {
  width: 100%;
  height: 48px;
  border-radius: 12px;
  border: 1px solid rgba(216, 197, 168, 0.85);
  background: rgba(255, 248, 243, 0.72);
  padding: 0 14px;
  color: #1a1a1a;
  font-size: 13px;
  outline: none;
  transition: border-color 0.2s ease, box-shadow 0.2s ease, background 0.2s ease;
}

.home-input::placeholder {
  color: #9a8c7a;
}

.home-input:focus {
  border-color: #785600;
  background: #fffdfa;
  box-shadow: 0 0 0 3px rgba(120, 86, 0, 0.10);
}

.risk-card {
  border: 1px solid rgba(216, 197, 168, 0.62);
  border-left-width: 4px;
  border-radius: 18px;
  background: rgba(255, 253, 250, 0.84);
  padding: 28px;
  min-height: 280px;
  box-shadow: 0 16px 42px rgba(53, 48, 39, 0.06);
  transition: transform 0.22s ease, box-shadow 0.22s ease;
}

.risk-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 24px 58px rgba(53, 48, 39, 0.10);
}

.tone-red {
  border-left-color: #9f1d1d;
  color: #9f1d1d;
}

.tone-gold {
  border-left-color: #785600;
  color: #785600;
}

.tone-ink {
  border-left-color: #153d4a;
  color: #153d4a;
}

.risk-icon {
  width: 46px;
  height: 46px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 13px;
  background: currentColor;
  color: #fff8f3;
  opacity: 0.92;
}

.risk-tag {
  border-radius: 999px;
  background: rgba(184, 134, 11, 0.12);
  color: #785600;
  padding: 5px 10px;
  font-size: 11px;
  font-weight: 700;
}

.service-card {
  border: 1px solid rgba(216, 197, 168, 0.58);
  border-radius: 18px;
  background: rgba(253, 242, 229, 0.56);
  padding: 24px;
  box-shadow: 0 12px 28px rgba(53, 48, 39, 0.04);
  transition: transform 0.22s ease, background 0.22s ease, box-shadow 0.22s ease;
}

.service-card:hover {
  transform: translateY(-4px);
  background: #f3e6c8;
  box-shadow: 0 20px 44px rgba(53, 48, 39, 0.09);
}

@media (max-width: 768px) {
  .home-hero {
    min-height: auto;
  }
}
</style>

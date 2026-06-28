<template>
  <div class="upload-shell min-h-screen overflow-x-hidden text-[#1A1A1A] pb-32">
    <header class="fixed top-0 left-0 w-full z-50 h-20 bg-[#FFF8F3]/86 backdrop-blur-xl border-b border-[#D8C5A8]/35 shadow-[0_8px_28px_rgba(53,48,39,0.05)]">
      <div class="max-w-[1280px] mx-auto px-5 md:px-10 h-full flex items-center justify-between">
        <div class="flex items-center gap-8">
          <JcBrand />
          <nav class="hidden md:flex items-center gap-8 text-[13px] font-semibold">
            <router-link to="/" class="text-[#5E5548] hover:text-[#785600] transition">场景覆盖</router-link>
            <span class="text-[#785600] border-b-2 border-[#785600] pb-1">诊断流程</span>
            <router-link to="/" class="text-[#5E5548] hover:text-[#785600] transition">后续服务</router-link>
          </nav>
        </div>
        <span class="hidden sm:inline-flex rounded-xl bg-[#F3E6C8] px-4 py-2 text-[12px] font-bold text-[#785600]">{{ modeLabel }}</span>
      </div>
    </header>

    <main class="max-w-[1280px] mx-auto px-5 md:px-10 pt-28">
      <div class="mb-10">
        <div class="flex items-center gap-2 text-[#817563] mb-2 text-[13px] font-semibold">
          <span>步骤 02</span>
          <span>/</span>
          <span class="opacity-70">上传经营资料</span>
        </div>
        <h1 class="text-[34px] md:text-[44px] font-extrabold tracking-tight mb-3">财务健康诊断</h1>
        <p class="text-[#5E5548] max-w-2xl text-[15px] leading-8">
          请提供以下证明文件，以便系统生成更完整的企业经营初诊报告。资料越完整，四维经营看板的参考价值越高。
        </p>
      </div>

      <div v-if="store.checklist" class="grid grid-cols-1 lg:grid-cols-[1.45fr_0.95fr] gap-8 items-start">
        <section class="space-y-4">
          <div class="flex items-center justify-between px-4 pb-2 border-b border-[#D8C5A8]/40">
            <span class="text-[13px] font-semibold text-[#5E5548]">所需文件</span>
            <span class="text-[13px] font-bold text-[#785600]">已上传 {{ store.checklist.uploadedCount }} / {{ store.checklist.requiredCount }}</span>
          </div>

          <article
            v-for="req in store.checklist.requirements"
            :key="req.code"
            @click="triggerUpload(req)"
            class="doc-card"
            :class="req.uploaded ? 'is-uploaded' : ''"
          >
            <div class="doc-icon" :class="req.uploaded ? 'success' : ''">
              <JcIcon :name="req.uploaded ? 'success' : 'report'" :size="24" :color="req.uploaded ? '#2F6B48' : '#785600'" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center gap-2 flex-wrap mb-1">
                <h3 class="text-[17px] font-bold text-[#1A1A1A]">{{ req.name }}</h3>
                <span v-if="req.required" class="doc-badge required">必填</span>
                <span v-else class="doc-badge">建议</span>
              </div>
              <p class="text-[13px] leading-6 text-[#5E5548]">{{ req.description }}</p>
              <div v-if="req.uploaded && req.uploadedDocument" class="mt-2 flex flex-wrap items-center gap-2 text-[12px]">
                <span class="text-[#2F6B48] font-bold">已上传</span>
                <span class="text-[#817563] truncate max-w-[260px]">{{ req.uploadedDocument.originalName }}</span>
              </div>
              <div v-else class="mt-2 flex flex-wrap gap-1.5">
                <span v-for="dim in (req.affectsDimensions as string[])" :key="dim" class="dim-chip">{{ dimLabel(dim) }}</span>
              </div>
            </div>
            <div class="flex flex-col items-end gap-2">
              <button v-if="req.uploaded" @click.stop="removeFile(req)" class="text-[12px] font-bold text-[#9F1D1D] hover:text-red-700">删除</button>
              <button v-else class="doc-upload-btn">上传</button>
              <span v-if="!req.uploaded" class="hidden sm:block text-[11px] text-[#9A8C7A]">PDF, XLSX, 图片</span>
            </div>
          </article>

          <div class="custom-file-card">
            <div class="w-12 h-12 rounded-full bg-[#F3E6C8] flex items-center justify-center text-[#785600] text-2xl font-light">+</div>
            <span class="font-bold">添加自定义财务文件</span>
            <span class="text-[13px] text-[#817563]">将其他相关文件补充给顾问复核。</span>
          </div>
        </section>

        <aside class="lg:sticky lg:top-24 space-y-6">
          <div class="readiness-card">
            <div class="text-center mb-8">
              <h2 class="text-[24px] font-extrabold mb-1">数据完整度</h2>
              <p class="text-[13px] text-[#817563] font-semibold">实时诊断准备就绪度</p>
            </div>
            <div class="relative w-48 h-48 mx-auto mb-10 flex items-center justify-center">
              <svg class="w-full h-full -rotate-90" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r="42" fill="transparent" stroke="#ECE1D4" stroke-width="8" />
                <circle cx="50" cy="50" r="42" fill="transparent" :stroke="scoreColor" stroke-width="8" stroke-linecap="round" stroke-dasharray="263.89" :stroke-dashoffset="263.89 - (263.89 * (store.checklist.completenessScore || 0)) / 100" />
              </svg>
              <div class="absolute inset-0 flex flex-col items-center justify-center">
                <span class="text-[44px] leading-none font-extrabold text-[#785600]">{{ store.checklist.completenessScore || 0 }}%</span>
                <span class="text-[11px] uppercase tracking-widest text-[#817563] mt-2">就绪</span>
              </div>
            </div>

            <div class="space-y-5">
              <div v-for="dim in dimensions" :key="dim.key">
                <div class="flex items-center justify-between mb-2">
                  <span class="text-[13px] font-bold text-[#1A1A1A]">{{ dim.label }}可信度</span>
                  <span class="text-[12px] font-bold text-[#785600]">{{ store.checklist.dimensionConfidence[dim.key] || 0 }}%</span>
                </div>
                <div class="h-2 w-full bg-[#ECE1D4] rounded-full overflow-hidden">
                  <div class="h-full bg-[#785600] rounded-full transition-all duration-700" :style="{ width: (store.checklist.dimensionConfidence[dim.key] || 0) + '%' }"></div>
                </div>
              </div>
            </div>

            <div v-if="store.checklist.missingDocuments.length" class="mt-8 p-4 rounded-xl bg-[#F3E6C8]/50 border border-[#D8C5A8]/55">
              <p class="text-[13px] leading-6 text-[#5E5548]">
                <span class="font-bold text-[#785600]">洞察：</span>
                补充 {{ store.checklist.missingDocuments[0] }} 可提升相关维度的可信度。
              </p>
            </div>
          </div>

          <div class="security-mini">
            <JcIcon name="secure" :size="20" color="#F7BD48" />
            <div>
              <h4 class="text-[13px] font-bold text-white">资料安全保护</h4>
              <p class="text-[12px] text-white/62">您的经营资料仅用于初诊和复核。</p>
            </div>
          </div>
        </aside>
      </div>

      <div v-else class="text-center py-20 text-[#817563] text-[14px]">加载资料清单中...</div>

      <input ref="fileInput" type="file" class="hidden" accept=".pdf,.xlsx,.xls,.docx,.doc,.jpg,.jpeg,.png" @change="onFileSelected" />
    </main>

    <div class="fixed bottom-0 left-0 w-full z-50 bg-[#FFF8F3]/92 backdrop-blur-xl border-t border-[#D8C5A8]/40 shadow-[0_-12px_32px_rgba(53,48,39,0.08)]">
      <div class="max-w-[1280px] mx-auto px-5 md:px-10 py-5 flex flex-col sm:flex-row items-center justify-between gap-4">
        <div class="flex items-center gap-3 text-[13px] text-[#5E5548] font-semibold">
          <span class="w-2 h-2 rounded-full bg-[#785600]"></span>
          <span>系统正在预处理已上传的文件...</span>
        </div>
        <div class="flex items-center gap-3 w-full sm:w-auto">
          <button @click="router.push('/questionnaire')" class="flex-1 sm:flex-none px-7 py-3 rounded-xl text-[13px] font-bold text-[#5E5548] hover:bg-[#F3E6C8] transition">
            跳过并进入问卷
          </button>
          <button @click="router.push('/questionnaire')" class="flex-1 sm:flex-none px-9 py-3 rounded-xl bg-[#785600] text-white text-[13px] font-extrabold hover:bg-[#5D4200] transition shadow-[0_14px_30px_rgba(120,86,0,0.2)]">
            继续填写问卷
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import JcBrand from '../components/common/JcBrand.vue';
import JcIcon from '../components/ui/JcIcon.vue';
import { useDiagnosisStore } from '../stores/diagnosis';

const router = useRouter();
const store = useDiagnosisStore();
const fileInput = ref<HTMLInputElement>();
const pendingDocType = ref('');

const modeLabel = computed(() => {
  const map: Record<string, string> = { QUICK: '快速初诊', STANDARD: '标准初诊', DEEP: '深度经营初诊' };
  return map[store.mode] || '标准初诊';
});

const scoreColor = computed(() => {
  const s = store.checklist?.completenessScore || 0;
  if (s >= 70) return '#2F6B48';
  if (s >= 40) return '#B8860B';
  return '#9F1D1D';
});

const dimensions = [
  { key: 'PROFIT', label: '利润' },
  { key: 'RISK', label: '风险' },
  { key: 'CASH_FLOW', label: '现金流' },
  { key: 'EFFICIENCY', label: '效率' },
];

function dimLabel(dim: string): string {
  const map: Record<string, string> = { PROFIT: '利润', RISK: '风险', CASH_FLOW: '现金流', EFFICIENCY: '效率' };
  return map[dim] || dim;
}

function triggerUpload(req: any) {
  pendingDocType.value = req.code;
  fileInput.value?.click();
}

async function onFileSelected(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0];
  if (!file || !pendingDocType.value) return;
  try {
    await store.uploadDoc(pendingDocType.value, file);
  } catch {
    // store handles error
  }
  (e.target as HTMLInputElement).value = '';
  pendingDocType.value = '';
}

async function removeFile(req: any) {
  if (!req.uploadedDocument?.publicId) return;
  try {
    await store.removeDoc(req.uploadedDocument.publicId);
  } catch {
    // store handles error
  }
}

onMounted(() => {
  store.loadChecklist();
});
</script>

<style scoped>
.upload-shell {
  background:
    radial-gradient(circle at 88% 10%, rgba(184, 134, 11, 0.10), transparent 30%),
    linear-gradient(180deg, #fff8f3 0%, #faf8f4 55%, #f3ede3 100%);
}

.doc-card,
.readiness-card {
  border: 1px solid rgba(216, 197, 168, 0.56);
  background: rgba(255, 253, 250, 0.78);
  box-shadow: 0 18px 48px rgba(53, 48, 39, 0.06);
  backdrop-filter: blur(18px);
}

.doc-card {
  border-radius: 16px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 20px;
  cursor: pointer;
  transition: transform 0.22s ease, box-shadow 0.22s ease, border-color 0.22s ease;
}

.doc-card:hover {
  transform: translateY(-4px);
  border-color: rgba(120, 86, 0, 0.40);
  box-shadow: 0 26px 60px rgba(53, 48, 39, 0.10);
}

.doc-card.is-uploaded {
  border-left: 4px solid #2f6b48;
}

.doc-icon {
  width: 48px;
  height: 48px;
  flex: 0 0 auto;
  border-radius: 12px;
  background: #f3e6c8;
  display: flex;
  align-items: center;
  justify-content: center;
}

.doc-icon.success {
  background: rgba(47, 107, 72, 0.12);
}

.doc-badge {
  border-radius: 6px;
  border: 1px solid rgba(216, 197, 168, 0.70);
  background: rgba(243, 230, 200, 0.52);
  color: #5e5548;
  padding: 2px 7px;
  font-size: 10px;
  font-weight: 800;
}

.doc-badge.required {
  border-color: rgba(120, 86, 0, 0.25);
  background: rgba(120, 86, 0, 0.10);
  color: #785600;
}

.doc-upload-btn {
  border-radius: 10px;
  background: #785600;
  color: white;
  padding: 8px 16px;
  font-size: 12px;
  font-weight: 800;
}

.dim-chip {
  border-radius: 999px;
  background: rgba(243, 230, 200, 0.62);
  color: #785600;
  padding: 3px 8px;
  font-size: 10px;
  font-weight: 700;
}

.custom-file-card {
  border: 1px dashed rgba(120, 86, 0, 0.42);
  border-radius: 20px;
  background: rgba(255, 248, 243, 0.48);
  min-height: 150px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  gap: 8px;
}

.readiness-card {
  border-radius: 28px;
  padding: 32px;
}

.security-mini {
  border-radius: 20px;
  background: #121212;
  padding: 22px;
  display: flex;
  align-items: center;
  gap: 14px;
  box-shadow: 0 24px 58px rgba(18, 18, 18, 0.14);
}

@media (max-width: 640px) {
  .doc-card {
    align-items: flex-start;
    gap: 14px;
  }
}
</style>

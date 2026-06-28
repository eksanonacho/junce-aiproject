<template>
  <div
    class="jc-dynamic-background"
    :class="[
      `variant-${variant}`,
      `intensity-${intensity}`,
      { 'without-city': !showCity, 'without-grid': !showGrid, 'without-light': !showOrbs },
    ]"
    aria-hidden="true"
  >
    <div v-if="showOrbs" class="ambient-light ambient-blue"></div>
    <div v-if="showOrbs" class="ambient-light ambient-gold"></div>
    <div v-if="showOrbs" class="ambient-light ambient-cyan"></div>
    <div v-if="showGrid" class="grid-layer"></div>
    <div class="flow-line flow-line-1"></div>
    <div class="flow-line flow-line-2"></div>
    <div class="flow-line flow-line-3"></div>
    <div v-if="showCity" class="city-layer"></div>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  variant?: 'hero' | 'report' | 'flow' | 'subtle' | 'page' | 'executive';
  intensity?: 'low' | 'medium';
  showCity?: boolean;
  showGrid?: boolean;
  showOrbs?: boolean;
}>(), {
  variant: 'hero',
  intensity: 'low',
  showCity: true,
  showGrid: true,
  showOrbs: true,
});
</script>

<style scoped>
.jc-dynamic-background {
  position: absolute;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  pointer-events: none;
  isolation: isolate;
  background:
    radial-gradient(ellipse at 18% 14%, rgba(30, 58, 138, 0.17), transparent 34%),
    radial-gradient(ellipse at 82% 20%, rgba(217, 119, 6, 0.13), transparent 30%),
    radial-gradient(ellipse at 72% 88%, rgba(14, 116, 144, 0.10), transparent 36%),
    linear-gradient(135deg, #F8FAFC 0%, #EEF4F8 45%, #F6F8FB 100%);
}

.jc-dynamic-background::before {
  content: "";
  position: absolute;
  inset: 0;
  z-index: -1;
  background:
    linear-gradient(118deg, transparent 0 42%, rgba(255, 255, 255, 0.58) 42.2% 43.4%, transparent 43.6%),
    linear-gradient(118deg, transparent 0 61%, rgba(15, 23, 42, 0.055) 61.2% 61.7%, transparent 61.9%),
    linear-gradient(90deg, rgba(255, 255, 255, 0.58), transparent 32%, rgba(255, 255, 255, 0.34));
}

.jc-dynamic-background::after {
  content: "";
  position: absolute;
  inset: 0;
  opacity: 0.72;
  background:
    linear-gradient(180deg, rgba(255, 255, 255, 0.24), transparent 28%),
    radial-gradient(ellipse at 50% 100%, rgba(15, 23, 42, 0.055), transparent 48%);
}

.variant-report {
  background:
    radial-gradient(ellipse at 18% 14%, rgba(30, 58, 138, 0.17), transparent 34%),
    radial-gradient(ellipse at 82% 20%, rgba(217, 119, 6, 0.13), transparent 30%),
    radial-gradient(ellipse at 72% 88%, rgba(14, 116, 144, 0.10), transparent 36%),
    linear-gradient(135deg, #F8FAFC 0%, #EEF4F8 45%, #F6F8FB 100%);
}

.variant-page,
.variant-flow,
.variant-subtle {
  background:
    radial-gradient(ellipse at 50% 0%, rgba(255, 255, 255, 0.88), transparent 38%),
    radial-gradient(ellipse at 88% 16%, rgba(30, 58, 138, 0.18), transparent 34%),
    radial-gradient(ellipse at 7% 26%, rgba(14, 116, 144, 0.11), transparent 32%),
    radial-gradient(ellipse at 74% 88%, rgba(217, 119, 6, 0.10), transparent 34%),
    linear-gradient(180deg, #EEF4F9 0%, #E4ECF4 45%, #DCE6EF 100%);
}

.variant-executive {
  background:
    radial-gradient(ellipse at 14% 8%, rgba(120, 86, 0, 0.12), transparent 32%),
    radial-gradient(ellipse at 88% 18%, rgba(53, 48, 39, 0.10), transparent 34%),
    radial-gradient(ellipse at 50% 100%, rgba(120, 86, 0, 0.08), transparent 42%),
    linear-gradient(180deg, #FFF8F3 0%, #F9F8F6 46%, #F1E7D9 100%);
}

.ambient-light {
  position: absolute;
  border-radius: 999px;
  filter: blur(48px);
  transform: rotate(-8deg);
}

.ambient-blue {
  width: min(60vw, 760px);
  height: min(28vw, 330px);
  top: -10%;
  left: -10%;
  opacity: 0.18;
  background: linear-gradient(90deg, rgba(30, 58, 138, 0.52), rgba(30, 58, 138, 0.04));
}

.ambient-gold {
  width: min(44vw, 560px);
  height: min(18vw, 240px);
  right: 5%;
  top: 8%;
  opacity: 0.20;
  background: linear-gradient(90deg, rgba(217, 119, 6, 0.42), rgba(217, 119, 6, 0.04));
}

.ambient-cyan {
  width: min(46vw, 590px);
  height: min(20vw, 260px);
  right: -10%;
  bottom: -7%;
  opacity: 0.13;
  background: linear-gradient(90deg, rgba(14, 116, 144, 0.36), rgba(14, 116, 144, 0.02));
}

.intensity-medium .ambient-light {
  filter: blur(42px);
}

.variant-page .ambient-light,
.variant-executive .ambient-light,
.variant-flow .ambient-light,
.variant-subtle .ambient-light {
  opacity: 0.14;
  filter: blur(58px);
}

.variant-executive .ambient-blue {
  background: linear-gradient(90deg, rgba(53, 48, 39, 0.32), rgba(53, 48, 39, 0.02));
}

.variant-executive .ambient-gold {
  background: linear-gradient(90deg, rgba(120, 86, 0, 0.34), rgba(120, 86, 0, 0.03));
}

.variant-executive .ambient-cyan {
  background: linear-gradient(90deg, rgba(247, 189, 72, 0.24), rgba(247, 189, 72, 0.02));
}

.grid-layer {
  position: absolute;
  inset: -1px;
  opacity: 0.20;
  background-image:
    linear-gradient(rgba(30, 58, 138, 0.10) 1px, transparent 1px),
    linear-gradient(90deg, rgba(30, 58, 138, 0.085) 1px, transparent 1px),
    linear-gradient(135deg, transparent 0 48%, rgba(217, 119, 6, 0.08) 48.2% 48.5%, transparent 48.7%);
  background-size: 44px 44px, 44px 44px, 220px 220px;
  mask-image: linear-gradient(90deg, transparent 0%, #000 12%, #000 82%, transparent 100%);
}

.variant-report .grid-layer {
  opacity: 0.20;
}

.variant-page .grid-layer,
.variant-executive .grid-layer,
.variant-flow .grid-layer,
.variant-subtle .grid-layer {
  opacity: 0.14;
  background-size: 52px 52px, 52px 52px, 260px 260px;
}

.variant-executive .grid-layer {
  background-image:
    linear-gradient(rgba(129, 117, 99, 0.10) 1px, transparent 1px),
    linear-gradient(90deg, rgba(129, 117, 99, 0.08) 1px, transparent 1px),
    linear-gradient(135deg, transparent 0 48%, rgba(120, 86, 0, 0.10) 48.2% 48.5%, transparent 48.7%);
}

.flow-line {
  position: absolute;
  height: 2px;
  border-radius: 999px;
  opacity: 0.42;
  background: linear-gradient(90deg, transparent, rgba(217, 119, 6, 0.72), rgba(30, 58, 138, 0.26), transparent);
  box-shadow: 0 0 18px rgba(217, 119, 6, 0.10);
}

.flow-line-1 {
  width: min(54vw, 680px);
  top: 23%;
  left: 7%;
  transform: rotate(-3deg);
}

.flow-line-2 {
  width: min(38vw, 480px);
  top: 58%;
  right: 7%;
  transform: rotate(4deg);
}

.flow-line-3 {
  width: min(26vw, 360px);
  top: 78%;
  left: 10%;
  opacity: 0.24;
}

.variant-page .flow-line,
.variant-executive .flow-line,
.variant-flow .flow-line,
.variant-subtle .flow-line {
  opacity: 0.24;
}

.variant-executive .flow-line {
  background: linear-gradient(90deg, transparent, rgba(120, 86, 0, 0.62), rgba(53, 48, 39, 0.18), transparent);
}

.variant-report .flow-line {
  opacity: 0.42;
  background: linear-gradient(90deg, transparent, rgba(217, 119, 6, 0.72), rgba(30, 58, 138, 0.26), transparent);
}

.city-layer {
  position: absolute;
  right: clamp(12px, 4vw, 56px);
  bottom: -1px;
  width: min(48vw, 620px);
  height: 38%;
  opacity: 0.075;
  background:
    linear-gradient(to top, rgba(15, 23, 42, 0.92), rgba(15, 23, 42, 0.18)) 0 100% / 8% 42% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.9), rgba(15, 23, 42, 0.16)) 9% 100% / 7% 64% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.9), rgba(15, 23, 42, 0.14)) 18% 100% / 10% 52% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.92), rgba(15, 23, 42, 0.18)) 31% 100% / 6% 78% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.9), rgba(15, 23, 42, 0.15)) 40% 100% / 12% 46% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.92), rgba(15, 23, 42, 0.16)) 55% 100% / 8% 70% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.9), rgba(15, 23, 42, 0.13)) 66% 100% / 11% 54% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.92), rgba(15, 23, 42, 0.16)) 80% 100% / 7% 82% no-repeat,
    linear-gradient(to top, rgba(15, 23, 42, 0.9), rgba(15, 23, 42, 0.12)) 90% 100% / 10% 48% no-repeat;
}

.variant-report .city-layer {
  opacity: 0.075;
}

.variant-page .city-layer,
.variant-executive .city-layer,
.variant-flow .city-layer,
.variant-subtle .city-layer {
  opacity: 0.06;
}

.variant-page::before,
.variant-executive::before,
.variant-flow::before,
.variant-subtle::before {
  background:
    linear-gradient(90deg, rgba(15, 23, 42, 0.085), transparent 16%, transparent 84%, rgba(15, 23, 42, 0.085)),
    linear-gradient(118deg, transparent 0 38%, rgba(255, 255, 255, 0.44) 38.2% 39.2%, transparent 39.4%),
    linear-gradient(118deg, transparent 0 63%, rgba(217, 119, 6, 0.12) 63.1% 63.35%, transparent 63.55%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.46), transparent 42%);
}

.variant-executive::before {
  background:
    linear-gradient(90deg, rgba(53, 48, 39, 0.06), transparent 15%, transparent 85%, rgba(53, 48, 39, 0.06)),
    linear-gradient(118deg, transparent 0 38%, rgba(255, 255, 255, 0.42) 38.2% 39.2%, transparent 39.4%),
    linear-gradient(118deg, transparent 0 63%, rgba(120, 86, 0, 0.12) 63.1% 63.35%, transparent 63.55%),
    linear-gradient(180deg, rgba(255, 255, 255, 0.48), transparent 42%);
}

.variant-page::after,
.variant-executive::after,
.variant-flow::after,
.variant-subtle::after {
  opacity: 0.84;
  background:
    radial-gradient(ellipse at 50% 18%, rgba(255, 255, 255, 0.62), transparent 28%),
    linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.42) 24%, rgba(255, 255, 255, 0.52) 50%, rgba(255, 255, 255, 0.34) 76%, transparent 100%),
    radial-gradient(ellipse at 50% 100%, rgba(15, 23, 42, 0.105), transparent 54%);
}

.variant-executive::after {
  opacity: 0.82;
  background:
    radial-gradient(ellipse at 50% 18%, rgba(255, 255, 255, 0.68), transparent 28%),
    linear-gradient(90deg, transparent 0%, rgba(255, 255, 255, 0.48) 24%, rgba(255, 248, 243, 0.56) 50%, rgba(255, 255, 255, 0.36) 76%, transparent 100%),
    radial-gradient(ellipse at 50% 100%, rgba(53, 48, 39, 0.08), transparent 54%);
}

.without-light .ambient-light,
.without-grid .grid-layer,
.without-city .city-layer {
  display: none;
}

@media (max-width: 768px) {
  .ambient-light {
    filter: blur(44px);
  }

  .ambient-blue {
    width: 92vw;
    height: 48vw;
    opacity: 0.12;
  }

  .grid-layer {
    background-size: 36px 36px;
    opacity: 0.12;
  }

  .flow-line {
    opacity: 0.18;
  }

  .flow-line-3 {
    display: none;
  }

  .city-layer {
    width: 82vw;
    height: 28%;
    opacity: 0.045;
    right: -18vw;
  }
}

@media (prefers-reduced-motion: reduce) {
  .jc-dynamic-background {
    scroll-behavior: auto;
  }
}

@media print {
  .jc-dynamic-background {
    display: none !important;
  }
}
</style>

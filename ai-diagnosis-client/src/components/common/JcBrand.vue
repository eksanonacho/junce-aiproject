<template>
  <router-link :to="to" class="jc-brand" :class="{ 'is-compact': compact }">
    <span class="jc-brand__seal" aria-hidden="true">
      <img src="/brand/junce-seal-icon.png" alt="" />
    </span>
    <span class="jc-brand__copy">
      <img class="jc-brand__wordmark" src="/brand/junce-wordmark.png" alt="君册财税" />
      <span v-if="subtitle" class="jc-brand__subtitle">{{ subtitle }}</span>
    </span>
  </router-link>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  subtitle?: string;
  to?: string;
  compact?: boolean;
}>(), {
  subtitle: '',
  to: '/',
  compact: false,
});
</script>

<style scoped>
.jc-brand {
  display: inline-flex;
  align-items: center;
  gap: 9px;
  min-width: 0;
  color: #785600;
  text-decoration: none;
}

.jc-brand__seal {
  width: 38px;
  height: 38px;
  flex: 0 0 auto;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  overflow: hidden;
  border-radius: 11px;
  box-shadow: 0 12px 26px rgba(53, 48, 39, 0.14);
}

.jc-brand__seal img {
  width: 100%;
  height: 100%;
  display: block;
  object-fit: cover;
  object-position: center;
}

.jc-brand__copy {
  display: inline-flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: center;
  gap: 3px;
  min-width: 0;
}

.jc-brand__wordmark {
  width: 108px;
  height: auto;
  display: block;
}

.jc-brand__subtitle {
  color: #4f4535;
  font-size: 11px;
  font-weight: 500;
  line-height: 1;
  letter-spacing: 0.12em;
  white-space: nowrap;
}

.jc-brand.is-compact .jc-brand__seal {
  width: 34px;
  height: 34px;
  border-radius: 10px;
}

.jc-brand.is-compact .jc-brand__wordmark {
  width: 96px;
}

@media (max-width: 640px) {
  .jc-brand {
    gap: 8px;
  }

  .jc-brand__seal {
    width: 34px;
    height: 34px;
    border-radius: 10px;
  }

  .jc-brand__wordmark {
    width: 94px;
  }

  .jc-brand__subtitle {
    display: none;
  }
}

@media print {
  .jc-brand__seal {
    box-shadow: none;
  }
}
</style>

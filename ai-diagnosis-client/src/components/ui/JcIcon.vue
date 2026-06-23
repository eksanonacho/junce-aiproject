<script setup lang="ts">
import {
  Building2, FileText, ShieldAlert, UserCheck, ClipboardList,
  BarChart3, LockKeyhole, BriefcaseBusiness, CheckCircle2,
  Clock3, TriangleAlert, Landmark, ReceiptText, Users, FileClock,
  Search, ArrowRight,
} from 'lucide-vue-next';

const props = withDefaults(defineProps<{
  name: string;
  size?: number;
  strokeWidth?: number;
  color?: string;
}>(), {
  size: 24,
  strokeWidth: 2,
  color: '#2563EB',
});

const iconMap: Record<string, any> = {
  company: Building2,
  report: FileText,
  risk: ShieldAlert,
  review: UserCheck,
  process: ClipboardList,
  analysis: BarChart3,
  secure: LockKeyhole,
  service: BriefcaseBusiness,
  success: CheckCircle2,
  pending: Clock3,
  warning: TriangleAlert,
  tax: Landmark,
  invoice: ReceiptText,
  socialSecurity: Users,
  history: FileClock,
  search: Search,
  arrowRight: ArrowRight,
};

const IconComp = iconMap[props.name];
</script>

<template>
  <component
    v-if="IconComp"
    :is="IconComp"
    :size="size"
    :stroke-width="strokeWidth"
    :color="color"
  />
</template>

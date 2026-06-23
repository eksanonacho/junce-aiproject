import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('../pages/HomePage.vue'),
    },
    {
      path: '/questionnaire',
      name: 'questionnaire',
      component: () => import('../pages/QuestionnairePage.vue'),
    },
    {
      path: '/questionnaire/success',
      name: 'questionnaire-success',
      component: () => import('../pages/SuccessPage.vue'),
    },
    {
      path: '/diagnosis/start',
      name: 'diagnosis-start',
      component: () => import('../pages/DiagnosisStartPage.vue'),
    },
    {
      path: '/diagnosis/upload',
      name: 'diagnosis-upload',
      component: () => import('../pages/DocumentUploadPage.vue'),
    },
    {
      path: '/report/:publicId',
      name: 'report',
      component: () => import('../pages/ReportPage.vue'),
    },
    {
      path: '/admin/login',
      name: 'admin-login',
      component: () => import('../admin/LoginPage.vue'),
    },
    {
      path: '/admin/submissions',
      name: 'admin-submissions',
      component: () => import('../admin/SubmissionsPage.vue'),
    },
    {
      path: '/admin/reports/:publicId',
      name: 'admin-report-detail',
      component: () => import('../admin/ReportDetailPage.vue'),
    },
  ],
})

export default router

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { login, saveAuth } from '../api/admin';

const router = useRouter();
const username = ref('admin');
const password = ref('Admin@123456');
const error = ref('');
const loading = ref(false);

async function handleLogin() {
  error.value = '';
  loading.value = true;
  try {
    const result = await login(username.value, password.value);
    saveAuth(result.accessToken, result.user);
    router.push('/admin/submissions');
  } catch (e: unknown) {
    error.value = (e as { message?: string }).message || '登录失败';
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="min-h-screen bg-gray-100 flex items-center justify-center p-6">
    <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-sm">
      <h1 class="text-xl font-bold text-gray-800 mb-6">AI 初诊后台管理</h1>
      <div class="mb-4">
        <label class="block text-sm text-gray-600 mb-1">用户名</label>
        <input v-model="username" class="w-full border px-3 py-2 rounded" @keyup.enter="handleLogin" />
      </div>
      <div class="mb-4">
        <label class="block text-sm text-gray-600 mb-1">密码</label>
        <input v-model="password" type="password" class="w-full border px-3 py-2 rounded" @keyup.enter="handleLogin" />
      </div>
      <div v-if="error" class="text-red-500 text-sm mb-4">{{ error }}</div>
      <button @click="handleLogin" :disabled="loading" class="w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 disabled:opacity-50">
        {{ loading ? '登录中...' : '登录' }}
      </button>
    </div>
  </div>
</template>

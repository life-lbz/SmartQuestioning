<script setup lang="ts">
import { BasicLayout } from '@vben/layouts';
import { Button, Space } from 'ant-design-vue';
import { useRouter } from 'vue-router';
import { api,session } from '#/views/data-agent/client';
const router=useRouter();
async function logout(){try{await api('/auth/logout',{method:'POST'});}finally{session.user=null;session.csrf='';location.assign('/login');}}
</script>
<template><BasicLayout @logout="logout" @clear-preferences-and-logout="logout"><template #user-dropdown><Space class="px-3"><Button type="text" @click="router.push('/account')">{{session.user?.display_name}}</Button><Button type="text" @click="logout">退出</Button></Space></template></BasicLayout></template>

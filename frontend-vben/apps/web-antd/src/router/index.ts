import { createRouter, createWebHistory } from 'vue-router';
const router = createRouter({ history: createWebHistory(), routes: [
 { path: '/', component: () => import('#/layouts/basic.vue'), redirect: '/workbench', children: [
  { path: 'workbench', name: 'Workbench', component: () => import('#/views/data-agent/workbench.vue'), meta: { title: '查询工作台', affixTab: true, icon: 'lucide:chart-no-axes-combined' } },
  { path: 'catalog', name: 'Catalog', component: () => import('#/views/data-agent/catalog.vue'), meta: { title: '数据目录', icon: 'lucide:database' } },
 ]},
 { path: '/:pathMatch(.*)*', redirect: '/workbench' },
] });
export const resetRoutes = () => {};
export { router };

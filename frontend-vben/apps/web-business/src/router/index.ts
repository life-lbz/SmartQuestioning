import { createRouter, createWebHistory } from 'vue-router';
import { loadSession, session } from '#/views/data-agent/client';
const management=() => import('#/views/data-agent/management.vue');
const router=createRouter({history:createWebHistory(),routes:[
 {path:'/login',name:'PlatformLogin',component:()=>import('#/views/data-agent/login.vue'),meta:{title:'登录'}},
 {path:'/',component:()=>import('#/layouts/basic.vue'),redirect:'/overview',children:[
  {path:'overview',name:'Overview',component:()=>import('#/views/data-agent/overview.vue'),meta:{title:'经营概览',affixTab:true}},
  {path:'workbench',name:'Workbench',component:()=>import('#/views/data-agent/workbench.vue'),meta:{title:'查询工作台'}},
  {path:'catalog',name:'Catalog',component:()=>import('#/views/data-agent/catalog.vue'),meta:{title:'数据目录'}},
  ...[['history','查询历史'],['favorites','收藏查询'],['approvals','审批中心'],['users','用户管理'],['audit','操作审计'],['account','个人设置']].map(([path,title])=>({path:path!,name:`platform-${path}`,component:management,meta:{title:title!}})),
 ]}, {path:'/:pathMatch(.*)*',redirect:'/overview'},
]});
router.beforeEach(async to=>{if(to.path==='/login')return true;try{await loadSession();}catch{return '/login';}if(['/users','/audit'].includes(to.path)&&session.user?.role!=='admin')return '/overview';return true;});
export const resetRoutes=()=>{};
export {router};

import { reactive } from 'vue';
import { useAccessStore } from '@vben/stores';
export interface User {id:number; username:string; display_name:string; role:'admin'|'analyst'|'viewer'}
export const session=reactive<{user:User|null;csrf:string}>({user:null,csrf:''});
export function updateMenus() {
  const items=[['经营概览','/overview','lucide:layout-dashboard'],['查询工作台','/workbench','lucide:chart-no-axes-combined'],['查询历史','/history','lucide:history'],['收藏查询','/favorites','lucide:bookmark'],['审批中心','/approvals','lucide:shield-check'],['数据目录','/catalog','lucide:database'],['个人设置','/account','lucide:settings']];
  if(session.user?.role==='admin') items.push(['用户管理','/users','lucide:users'],['操作审计','/audit','lucide:clipboard-list']);
  useAccessStore().setAccessMenus(items.map(([name,path,icon]) => ({name:name!,path:path!,icon})));
}
export async function api<T=any>(path:string, init:RequestInit={}):Promise<T> {
  const response=await fetch(`/api/v1${path}`,{...init,credentials:'same-origin',headers:{'Content-Type':'application/json','X-CSRF-Token':session.csrf,...init.headers}});
  if(!response.ok) {
    if(response.status===401) session.user=null;
    const body=await response.json().catch(() => ({detail:'服务不可用'}));
    throw new Error(typeof body.detail==='string' ? body.detail : JSON.stringify(body.detail));
  }
  return response.json();
}
export async function loadSession() {
  const result=await api<{user:User;csrf_token:string}>('/auth/me');
  session.user=result.user;session.csrf=result.csrf_token;updateMenus();
}

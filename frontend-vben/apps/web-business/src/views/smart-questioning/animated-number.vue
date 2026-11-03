<script setup lang="ts">
import {onBeforeUnmount,ref,watch} from 'vue';
const props=withDefaults(defineProps<{value:number;decimals?:number}>(),{decimals:0});
const current=ref(0);let frame=0;
watch(()=>props.value,value=>{
 cancelAnimationFrame(frame);
 const from=current.value;const start=performance.now();
 if(matchMedia('(prefers-reduced-motion: reduce)').matches){current.value=value;return;}
 function tick(now:number){const p=Math.min(1,(now-start)/1100);current.value=from+(value-from)*(1-(1-p)**3);if(p<1)frame=requestAnimationFrame(tick);}
 frame=requestAnimationFrame(tick);
},{immediate:true});
onBeforeUnmount(()=>cancelAnimationFrame(frame));
</script>
<template><span>{{current.toLocaleString('zh-CN',{minimumFractionDigits:decimals,maximumFractionDigits:decimals})}}</span></template>

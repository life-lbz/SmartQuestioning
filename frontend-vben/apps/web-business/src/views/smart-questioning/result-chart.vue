<script setup lang="ts">
import { computed, onMounted, onBeforeUnmount, ref, watch } from 'vue';
import { usePreferences } from '@vben/preferences';
import { EchartsUI, useEcharts } from '@vben/plugins/echarts';
import type { EchartsUIType } from '@vben/plugins/echarts';
import type { ChartSpec, QueryResult } from './types';
const props=defineProps<{result:QueryResult;chart:ChartSpec;dark?:boolean;height?:number}>();
const chartRef=ref<EchartsUIType>();
const {renderEcharts}=useEcharts(chartRef);
const {isDark}=usePreferences();
const dark=computed(()=>props.dark??isDark.value);
const motion=window.matchMedia('(prefers-reduced-motion: reduce)');

function render(){
 const {result,chart}=props;
 const colors=dark.value?['#36e2ce','#6095ff','#bf90ff','#f4bc6c']:['#3976f6','#10b8a6','#a079ed','#e9a447'];
 const fields=chart.yFields?.length?chart.yFields:result.columns.slice(1);
 const maxima=fields.map(f=>Math.max(0,...result.rows.map(r=>Math.abs(Number(r[f])||0))));
 const separate=fields.length===2 && Math.min(...maxima)>0 && Math.max(...maxima)/Math.min(...maxima)>20;
 const axis={type:'value' as const,splitNumber:4,axisLabel:{color:dark.value?'#94a3b8':'#64748b',formatter:(v:number)=>Math.abs(v)>=1e8?`${(v/1e8).toFixed(1)}亿`:Math.abs(v)>=1e4?`${(v/1e4).toFixed(0)}万`:String(v)},splitLine:{lineStyle:{color:dark.value?'#253345':'#edf1f7',type:'dashed' as const}}};
 renderEcharts({
  animation:!motion.matches,animationDuration:1100,animationDurationUpdate:650,animationEasing:'cubicOut',
  color:colors,backgroundColor:'transparent',
  tooltip:{trigger:'axis',confine:true,backgroundColor:dark.value?'#172337':'#fff',borderWidth:0,padding:14,extraCssText:'box-shadow:0 8px 36px rgba(15,30,60,.14);border-radius:10px;',textStyle:{color:dark.value?'#e2e8f0':'#1e293b'},axisPointer:{type:'line',lineStyle:{color:'#8ca9ef',type:'dashed'}}},
  legend:{bottom:0,icon:'roundRect',itemWidth:16,itemHeight:4,textStyle:{color:dark.value?'#94a3b8':'#64748b'}},
  grid:{left:12,right:separate?22:12,top:26,bottom:55,containLabel:true},
  xAxis:{type:'category',boundaryGap:chart.type==='bar',data:result.rows.map(row=>String(row[chart.xField??result.columns[0]!]??'')),axisTick:{show:false},axisLine:{show:false},axisLabel:{color:'#7c8ba1',margin:18,hideOverlap:true}},
  yAxis:separate?[axis,{...axis,splitLine:{show:false}}]:axis,
  series:fields.map((field,index)=>{const common={name:chart.seriesNames?.[field]??field,yAxisIndex:separate?index:0,
    data:result.rows.map(row=>Number(row[field])||0),smooth:0.32,showSymbol:false,symbol:'circle',symbolSize:8,
    lineStyle:{width:3,shadowColor:colors[index%colors.length]!+'44',shadowBlur:18,shadowOffsetY:5},
    areaStyle:chart.type==='bar'?undefined:{color:{type:'linear' as const,x:0,y:0,x2:0,y2:1,colorStops:[{offset:0,color:colors[index%colors.length]!+'38'},{offset:1,color:colors[index%colors.length]!+'02'}]}},
    itemStyle:chart.type==='bar'?{borderRadius:[5,5,0,0],color:{type:'linear' as const,x:0,y:0,x2:0,y2:1,colorStops:[{offset:0,color:colors[index%colors.length]!},{offset:1,color:colors[index%colors.length]!+'88'}]}}:undefined,
    emphasis:{focus:'series' as const},barMaxWidth:32,animationDelay:(i:number)=>Math.min(i*24,400),
  };return chart.type==='bar'?{...common,type:'bar' as const}:{...common,type:'line' as const};}),
 });
}
onMounted(()=>{render();motion.addEventListener('change',render);});
onBeforeUnmount(()=>motion.removeEventListener('change',render));
watch(()=>[props.result,props.chart,dark.value],render,{deep:true});
</script>
<template><EchartsUI ref="chartRef" :style="{height:`${height??360}px`}" /></template>

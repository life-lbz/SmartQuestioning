<script setup lang="ts">
import { onMounted, ref, watch } from 'vue';
import { EchartsUI, useEcharts } from '@vben/plugins/echarts';
import type { EchartsUIType } from '@vben/plugins/echarts';
import type { ChartSpec, QueryResult } from './types';
const props = defineProps<{result: QueryResult; chart: ChartSpec}>();
const chartRef = ref<EchartsUIType>();
const { renderEcharts } = useEcharts(chartRef);
function render() {
  const {result, chart} = props;
  renderEcharts({ tooltip: {trigger: 'axis'}, legend: {bottom: 0},
    grid: {left: 24, right: 24, top: 24, bottom: 50, containLabel: true},
    xAxis: {type:'category', data:result.rows.map(row => String(row[chart.xField ?? result.columns[0]!] ?? ''))},
    yAxis: {type:'value'},
    series: (chart.yFields?.length ? chart.yFields : result.columns.slice(1)).map(field => ({
      name: chart.seriesNames?.[field] ?? field, type:chart.type === 'bar' ? 'bar' : 'line',
      data:result.rows.map(row => Number(row[field]) || 0), barMaxWidth: 40,
    })),
  });
}
onMounted(render);
watch(() => props.result, render);
</script>
<template><EchartsUI ref="chartRef" style="height: 340px" /></template>

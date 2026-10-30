<script setup lang="ts">
import { PhChartLineUp as ChartLineUp, PhTable as TableIcon } from "@phosphor-icons/vue";
import { computed, nextTick, onBeforeUnmount, ref, watch } from "vue";
import * as echarts from "echarts/core";
import { BarChart, LineChart } from "echarts/charts";
import {
  GridComponent,
  LegendComponent,
  TooltipComponent,
} from "echarts/components";
import { CanvasRenderer } from "echarts/renderers";
import type { ChartSpec, QueryResult } from "../types";

echarts.use([
  BarChart,
  LineChart,
  GridComponent,
  LegendComponent,
  TooltipComponent,
  CanvasRenderer,
]);

const props = defineProps<{
  result: QueryResult;
  chart: ChartSpec;
}>();

const COLORS = ["#0f766e", "#d97706", "#64748b", "#2563eb"];
const mode = ref<"chart" | "table">(props.chart.type === "table" ? "table" : "chart");
const chartRoot = ref<HTMLDivElement | null>(null);
let instance: echarts.ECharts | null = null;
let resizeObserver: ResizeObserver | null = null;

const metricValue = computed(() => {
  const column = props.result.columns[0];
  return column ? props.result.rows[0]?.[column] : null;
});

function numberValue(value: unknown): number {
  const number = Number(value);
  return Number.isFinite(number) ? number : 0;
}

function maxFor(field: string): number {
  return Math.max(...props.result.rows.map((row) => Math.abs(numberValue(row[field]))), 0);
}

function secondaryFields(fields: string[]): Set<string> {
  if (fields.length < 2) return new Set();

  const base = maxFor(fields[0]);
  if (base === 0) return new Set();

  return new Set(
    fields.slice(1).filter((field) => {
      const current = maxFor(field);
      if (current === 0) return false;
      const ratio = current / base;
      return ratio >= 20 || ratio <= 1 / 20;
    }),
  );
}

function compactNumber(value: number): string {
  const absolute = Math.abs(value);
  if (absolute >= 100_000_000) return `${(value / 100_000_000).toFixed(1)}亿`;
  if (absolute >= 10_000) return `${(value / 10_000).toFixed(1)}万`;
  if (absolute >= 1_000) return `${(value / 1_000).toFixed(1)}k`;
  return String(value);
}

function ensureInstance(root: HTMLDivElement): echarts.ECharts {
  if (!instance || instance.isDisposed() || instance.getDom() !== root) {
    instance?.dispose();
    instance = echarts.init(root, undefined, { renderer: "canvas" });
  }
  return instance;
}

function renderChart(): void {
  const root = chartRoot.value;
  if (mode.value !== "chart" || props.chart.type === "metric" || !root) return;

  const fields = props.chart.yFields ?? [];
  if (!fields.length) return;

  const chartInstance = ensureInstance(root);
  const secondary = secondaryFields(fields);
  const hasSecondaryAxis = secondary.size > 0;
  const categories = props.result.rows.map((row) => String(row[props.chart.xField ?? ""] ?? ""));
  const rotateLabels = categories.length > 7;

  const series = fields.map((field, index) => {
    const usesSecondaryAxis = secondary.has(field);
    const seriesType = props.chart.type === "line" || usesSecondaryAxis ? "line" : "bar";
    const color = COLORS[index % COLORS.length];

    return {
      name: props.chart.seriesNames[field] ?? field,
      type: seriesType,
      yAxisIndex: usesSecondaryAxis ? 1 : 0,
      data: props.result.rows.map((row) => numberValue(row[field])),
      smooth: props.chart.smooth,
      symbol: "circle",
      symbolSize: 7,
      showSymbol: categories.length <= 16,
      barMaxWidth: 48,
      itemStyle: { color, borderRadius: seriesType === "bar" ? [5, 5, 0, 0] : 0 },
      lineStyle: { color, width: 2.5 },
      areaStyle:
        seriesType === "line" && fields.length === 1
          ? { color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [
              { offset: 0, color: "rgba(15, 118, 110, 0.24)" },
              { offset: 1, color: "rgba(15, 118, 110, 0.02)" },
            ]) }
          : undefined,
      emphasis: { focus: "series" },
    };
  });

  const primaryFields = fields.filter((field) => !secondary.has(field));
  const secondaryNames = fields.filter((field) => secondary.has(field));
  const makeAxis = (name: string, position: "left" | "right") => ({
    type: "value",
    name,
    position,
    nameTextStyle: { color: "#64706d", padding: position === "left" ? [0, 0, 4, 0] : [0, 0, 4, 0] },
    axisLabel: { color: "#64706d", formatter: compactNumber },
    axisLine: { show: hasSecondaryAxis && position === "right", lineStyle: { color: "#d7dfdc" } },
    splitLine: { show: position === "left", lineStyle: { color: "#e7ecea" } },
  });

  chartInstance.clear();
  chartInstance.setOption(
    {
      animationDuration: 500,
      color: COLORS,
      grid: {
        left: 20,
        right: hasSecondaryAxis ? 36 : 18,
        top: 64,
        bottom: rotateLabels ? 58 : 34,
        containLabel: true,
      },
      tooltip: {
        trigger: "axis",
        backgroundColor: "rgba(255,255,255,.98)",
        borderColor: "#d7dfdc",
        textStyle: { color: "#18211f" },
        axisPointer: { type: "shadow" },
      },
      legend: {
        top: 8,
        right: 8,
        itemWidth: 18,
        itemHeight: 10,
        textStyle: { color: "#64706d", fontSize: 12 },
      },
      xAxis: {
        type: "category",
        data: categories,
        axisTick: { alignWithLabel: true, show: false },
        axisLine: { lineStyle: { color: "#cfd8d5" } },
        axisLabel: {
          color: "#55615e",
          interval: 0,
          rotate: rotateLabels ? 28 : 0,
          width: 86,
          overflow: "truncate",
          margin: 12,
        },
      },
      yAxis: hasSecondaryAxis
        ? [makeAxis(primaryFields.join(" / "), "left"), makeAxis(secondaryNames.join(" / "), "right")]
        : [makeAxis(fields.join(" / "), "left")],
      series,
    },
    { notMerge: true },
  );

  requestAnimationFrame(() => chartInstance.resize());
}

async function setMode(nextMode: "chart" | "table"): Promise<void> {
  if (nextMode === "chart" && props.chart.type === "table") return;
  mode.value = nextMode;
  if (nextMode === "chart") {
    await nextTick();
    renderChart();
  }
}

watch(
  () => [props.result.rows, props.chart] as const,
  async () => {
    await nextTick();
    renderChart();
  },
  { deep: true, immediate: true },
);

watch(chartRoot, (root) => {
  resizeObserver?.disconnect();
  resizeObserver = null;
  if (!root) return;

  resizeObserver = new ResizeObserver(() => instance?.resize());
  resizeObserver.observe(root);
  nextTick(renderChart);
});

onBeforeUnmount(() => {
  resizeObserver?.disconnect();
  instance?.dispose();
  instance = null;
});
</script>

<template>
  <section class="result-view">
    <div class="result-toolbar">
      <div>
        <span class="eyebrow">查询结果</span>
        <h2>{{ chart.title }}</h2>
      </div>
      <div class="view-switch" role="group" aria-label="结果展示方式">
        <button
          type="button"
          :class="{ active: mode === 'chart' }"
          :disabled="chart.type === 'table'"
          @click="setMode('chart')"
        >
          <ChartLineUp :size="17" /> 图表
        </button>
        <button type="button" :class="{ active: mode === 'table' }" @click="setMode('table')">
          <TableIcon :size="17" /> 表格
        </button>
      </div>
    </div>

    <div v-if="chart.type === 'metric'" v-show="mode === 'chart'" class="metric-panel">
      <span>{{ result.columns[0]?.replaceAll('_', ' ') }}</span>
      <strong>{{ Number(metricValue).toLocaleString('zh-CN') }}</strong>
    </div>

    <div
      v-if="chart.type !== 'metric'"
      v-show="mode === 'chart'"
      ref="chartRoot"
      class="chart-canvas"
      role="img"
      :aria-label="chart.title"
    />

    <div v-show="mode === 'table'" class="table-wrap">
      <table>
        <thead>
          <tr>
            <th v-for="column in result.columns" :key="column">{{ column }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, rowIndex) in result.rows" :key="rowIndex">
            <td v-for="column in result.columns" :key="column">{{ row[column] }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

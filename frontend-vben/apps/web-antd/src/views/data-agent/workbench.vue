<script setup lang="ts">
import { computed, onMounted, ref } from 'vue';
import { Page } from '@vben/common-ui';
import { Alert, Button, Card, Collapse, CollapsePanel, Input, Select, Space, Statistic, Table, Tag, Timeline, TimelineItem } from 'ant-design-vue';
import { approveQuestion, askQuestion, getExamples, getSystemStatus } from './api';
import type { QuestionRecord } from './types';
import ResultChart from './result-chart.vue';
const examples = ref<string[]>([]);
const question = ref('今年每个月的已支付销售额是多少？');
const record = ref<QuestionRecord | null>(null);
const loading = ref(false);
const error = ref('');
const connected = ref(false);
const database = ref('data_agent_demo');
const view = ref('chart');
const columns = computed(() => record.value?.result?.columns.map(key => ({ title: key, dataIndex: key, key })) ?? []);
async function submit() {
  if (loading.value || question.value.trim().length < 2) return;
  loading.value = true; error.value = ''; record.value = null;
  try { record.value = await askQuestion(question.value.trim()); }
  catch (e) { error.value = e instanceof Error ? e.message : '查询失败'; }
  finally { loading.value = false; }
}
async function approve() {
  if (!record.value || loading.value) return;
  loading.value = true; error.value = '';
  try { record.value = await approveQuestion(record.value); }
  catch (e) { error.value = e instanceof Error ? e.message : '审批失败'; }
  finally { loading.value = false; }
}
onMounted(async () => {
  try {
    const [health, items] = await Promise.all([getSystemStatus(), getExamples()]);
    connected.value = health.database.connected; database.value = health.database.name ?? "data_agent_demo";
    examples.value = items;
    await submit();
  } catch (e) { error.value = e instanceof Error ? e.message : '服务连接失败'; }
});
</script>
<template>
  <Page title="查询工作台" description="销售数据查询、结果与执行记录">
    <div class="grid gap-4">
      <Card title="查询条件" :bordered="false">
        <template #extra><Tag :color="connected ? 'success' : 'error'">{{ connected ? '数据库已连接' : '数据库未连接' }}</Tag></template>
        <div class="mb-4 flex flex-wrap items-center gap-3 text-sm"><span>数据源</span><Tag>MySQL / {{ database }}</Tag><span class="text-muted-foreground">演示数据 · 只读访问</span></div>
        <label for="business-question" class="mb-2 block text-sm">业务问题</label>
        <Input.TextArea id="business-question" v-model:value="question" :rows="2" :maxlength="2000" @keydown.ctrl.enter.prevent="submit" />
        <div class="mt-4 flex flex-wrap items-center justify-between gap-3">
          <Space wrap><span class="text-sm">常用查询</span><Select aria-label="常用查询" placeholder="选择常用问题" :value="undefined" style="width: 320px; max-width: 100%" :options="examples.map(value => ({ value, label: value }))" @change="(value) => question = String(value)" /></Space>
          <Button type="primary" :loading="loading" :disabled="question.trim().length < 2" @click="submit">执行查询</Button>
        </div>
      </Card>
      <Alert v-if="error" :message="error" type="error" show-icon />
      <Alert v-if="record?.error" :message="String(record.error)" type="error" show-icon />
      <Card v-if="record?.status === 'approval_required'" title="查询审批" :bordered="false">
        <p v-for="reason in record.risk?.reasons" :key="reason">{{ reason }}</p>
        <Button type="primary" :loading="loading" @click="approve">确认执行</Button>
      </Card>
      <Card title="查询结果" :bordered="false" :loading="loading">
        <template #extra><Space><Tag v-if="record?.risk">{{ record.risk.level }}</Tag><span v-if="record?.result" class="text-sm">{{ record.result.row_count }} 行 · {{ record.result.elapsed_ms }} ms</span></Space></template>
        <template v-if="record?.result">
          <div class="mb-4 flex flex-wrap items-center justify-between gap-3"><span>{{ record.answer }}</span><Select v-model:value="view" aria-label="结果视图" :options="[{value:'chart',label:'图表视图'}, {value:'table',label:'数据表格'}]" style="width: 120px" /></div>
          <Statistic v-if="view === 'chart' && record.chart?.type === 'metric'" :title="record.chart.title" :value="Number(record.result.rows[0]?.[record.result.columns[0]!] ?? 0)" />
          <ResultChart v-else-if="view === 'chart' && record.chart && record.chart.type !== 'table'" :key="record.id" :result="record.result" :chart="record.chart" />
          <Table v-else :columns="columns" :data-source="record.result.rows.map((row, index) => ({ ...row, _key: index }))" row-key="_key" size="small" :pagination="{pageSize: 20, showSizeChanger: true}" :scroll="{x: 'max-content'}" />
          <Alert v-if="record.result.truncated" class="mt-3" message="结果已达到返回上限，请缩小查询范围。" type="warning" />
        </template>
        <div v-else class="py-12 text-center text-muted-foreground">暂无查询结果</div>
      </Card>
      <Collapse v-if="record" :bordered="false">
        <CollapsePanel key="sql" header="SQL 与查询口径"><pre class="overflow-auto rounded bg-muted p-4 text-sm">{{ record.normalized_sql || record.generated?.sql }}</pre><p class="mt-3 text-sm">{{ record.generated?.assumptions.join('；') }}</p></CollapsePanel>
        <CollapsePanel key="trace" header="执行记录"><Timeline><TimelineItem v-for="(event, index) in record.timeline" :key="index">{{ event.message }} <span class="ml-3 text-muted-foreground">{{ new Date(event.at).toLocaleTimeString('zh-CN') }}</span></TimelineItem></Timeline></CollapsePanel>
      </Collapse>
    </div>
  </Page>
</template>

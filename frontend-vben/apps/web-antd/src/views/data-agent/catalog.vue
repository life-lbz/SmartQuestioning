<script setup lang="ts">
import { onMounted, ref } from 'vue';
import { Page } from '@vben/common-ui';
import { Alert, Card, Table, Tag } from 'ant-design-vue';
const tables = ref<Record<string, unknown>[]>([]);
const error = ref('');
onMounted(async () => {
  try {
    const response = await fetch('/api/v1/metadata/tables');
    if (!response.ok) throw new Error(`读取数据目录失败 (${response.status})`);
    tables.value = (await response.json()).tables;
  } catch (e) { error.value = e instanceof Error ? e.message : '读取失败'; }
});
</script>
<template>
  <Page title="数据目录" description="当前只读账号可访问的业务表与字段">
    <Alert v-if="error" :message="error" type="error" class="mb-4" />
    <div class="grid gap-4">
      <Card v-for="table in tables" :key="String(table.name)" :title="String(table.name)" :bordered="false">
        <template #extra><Tag>MySQL</Tag></template>
        <p class="mb-4 text-muted-foreground">{{ table.description }}</p>
        <Table :data-source="table.columns as any[]" :columns="[{title:'字段名',dataIndex:'name'},{title:'数据类型',dataIndex:'type'},{title:'说明',dataIndex:'description'}]" row-key="name" size="small" :pagination="false" :scroll="{x:'max-content'}" />
      </Card>
    </div>
  </Page>
</template>

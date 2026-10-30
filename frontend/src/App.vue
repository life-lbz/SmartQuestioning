<script setup lang="ts">
import {
  PhArrowRight as ArrowRight,
  PhCheckCircle as CheckCircle,
  PhClockCounterClockwise as ClockCounterClockwise,
  PhDatabase as Database,
  PhLockKey as LockKey,
  PhPaperPlaneTilt as PaperPlaneTilt,
  PhShieldCheck as ShieldCheck,
  PhSparkle as Sparkle,
  PhWarning as Warning,
} from "@phosphor-icons/vue";
import { computed, defineAsyncComponent, onMounted, ref } from "vue";

import { approveQuestion, askQuestion, getExamples, getSystemStatus } from "./api";
import type { SystemStatus } from "./api";
import type { QuestionRecord } from "./types";

const ResultView = defineAsyncComponent(() => import("./components/ResultView.vue"));

const examples = ref([
  "今年每个月的已支付销售额是多少？",
  "本季度各区域销售额对比",
  "销售额最高的前 10 个商品",
  "各商品品类的销售额和订单量",
]);
const question = ref(examples.value[0]);
const record = ref<QuestionRecord | null>(null);
const systemStatus = ref<SystemStatus | null>(null);
const loading = ref(false);
const approving = ref(false);
const error = ref("");

const isReady = computed(() => question.value.trim().length >= 2 && !loading.value);
const riskClass = computed(() => `risk-${record.value?.risk?.level?.toLowerCase() ?? "l0"}`);
const databaseLabel = computed(() => {
  if (!systemStatus.value) return "正在检查数据库";
  if (!systemStatus.value.database.connected) return "数据库未连接";
  return `MySQL · ${systemStatus.value.database.name}`;
});

onMounted(async () => {
  const [statusResult, examplesResult] = await Promise.allSettled([
    getSystemStatus(),
    getExamples(),
  ]);
  if (statusResult.status === "fulfilled") systemStatus.value = statusResult.value;
  if (examplesResult.status === "fulfilled" && examplesResult.value.length) {
    examples.value = examplesResult.value;
  }
});

async function submit() {
  if (!isReady.value) return;
  loading.value = true;
  error.value = "";
  record.value = null;
  try {
    record.value = await askQuestion(question.value.trim());
  } catch (reason) {
    error.value = reason instanceof Error ? reason.message : "服务暂时不可用";
  } finally {
    loading.value = false;
  }
}

async function approve() {
  if (!record.value) return;
  approving.value = true;
  error.value = "";
  try {
    record.value = await approveQuestion(record.value);
  } catch (reason) {
    error.value = reason instanceof Error ? reason.message : "审批失败";
  } finally {
    approving.value = false;
  }
}
</script>

<template>
  <div class="app-shell">
    <header class="topbar">
      <a class="brand" href="#" aria-label="Data Agent 首页">
        <span class="brand-mark"><Database :size="19" weight="fill" /></span>
        <span>Data Agent</span>
      </a>
      <div class="topbar-meta">
        <span class="connection">
          <span :class="['status-dot', { offline: systemStatus && !systemStatus.database.connected }]" />
          {{ databaseLabel }}
        </span>
        <span class="security-note"><ShieldCheck :size="17" /> 只读安全网关</span>
      </div>
    </header>

    <div class="workspace">
      <aside class="sidebar">
        <div class="sidebar-heading">
          <p class="section-label">开始问数</p>
          <h2>从业务问题出发</h2>
          <p>系统会展示口径、SQL 与风险判断，执行权始终留在安全网关。</p>
        </div>

        <nav aria-label="示例问题">
          <button v-for="item in examples" :key="item" class="example-item" :title="item" @click="question = item">
            <span>{{ item }}</span><ArrowRight :size="16" />
          </button>
        </nav>

        <div class="boundary-note">
          <LockKey :size="19" />
          <div><strong>明确的数据边界</strong><span>写操作、系统库与危险函数永久拒绝。</span></div>
        </div>
      </aside>

      <main class="main-panel">
        <section class="composer" aria-labelledby="composer-title">
          <div class="composer-title">
            <div>
              <p class="section-label">自然语言查询</p>
              <h1 id="composer-title">今天想从数据里知道什么？</h1>
            </div>
            <Sparkle :size="27" aria-hidden="true" />
          </div>
          <form @submit.prevent="submit">
            <label class="sr-only" for="question">请输入业务问题</label>
            <textarea
              id="question"
              v-model="question"
              rows="3"
              maxlength="2000"
              placeholder="例如：今年每个月的已支付销售额是多少？"
              @keydown.ctrl.enter="submit"
            />
            <div class="composer-actions">
              <span>Ctrl + Enter 提交</span>
              <button class="primary-button" type="submit" :disabled="!isReady">
                <PaperPlaneTilt :size="18" weight="fill" />
                {{ loading ? "正在分析" : "安全查询" }}
              </button>
            </div>
          </form>
        </section>

        <div v-if="loading" class="loading-state" aria-live="polite">
          <div class="skeleton wide" /><div class="skeleton" /><div class="skeleton short" />
          <p>正在召回数据结构、生成 SQL 并检查风险</p>
        </div>

        <div v-else-if="error" class="error-state" role="alert">
          <Warning :size="22" weight="fill" />
          <div><strong>本次请求没有完成</strong><span>{{ error }}</span></div>
        </div>

        <template v-if="record">
          <section class="query-summary">
            <div class="answer-line">
              <CheckCircle v-if="record.status === 'completed'" :size="24" weight="fill" />
              <Warning v-else :size="24" weight="fill" />
              <div><p class="section-label">分析结论</p><h2>{{ record.answer ?? "SQL 已生成，等待下一步操作" }}</h2></div>
            </div>
            <div class="query-metrics">
              <span v-if="record.result"><strong>{{ record.result.row_count }}</strong> 行结果</span>
              <span v-if="record.result"><strong>{{ record.result.elapsed_ms }}</strong> ms</span>
              <span v-if="record.risk" :class="['risk-badge', riskClass]">{{ record.risk.level }} 风险</span>
            </div>
          </section>

          <section v-if="record.status === 'approval_required'" class="approval-panel">
            <div class="approval-icon"><ShieldCheck :size="24" /></div>
            <div>
              <p class="section-label">需要人工确认</p>
              <h2>这个查询触发了安全升级</h2>
              <ul><li v-for="reason in record.risk?.reasons" :key="reason">{{ reason }}</li></ul>
              <button class="primary-button" :disabled="approving" @click="approve">
                {{ approving ? "正在执行" : "确认并执行此 SQL" }}
              </button>
            </div>
          </section>

          <ResultView
            v-if="record.result && record.chart"
            :key="record.id"
            :result="record.result"
            :chart="record.chart"
          />

          <section class="audit-panel">
            <details open>
              <summary><span><ClockCounterClockwise :size="18" /> 执行轨迹</span><span>{{ record.timeline.length }} 步</span></summary>
              <ol class="timeline">
                <li v-for="event in record.timeline" :key="`${event.status}-${event.at}`">
                  <span class="timeline-mark" /><span>{{ event.message }}</span><time>{{ new Date(event.at).toLocaleTimeString('zh-CN') }}</time>
                </li>
              </ol>
            </details>
            <details v-if="record.normalized_sql">
              <summary><span><Database :size="18" /> 已验证 SQL</span><span>只读</span></summary>
              <pre><code>{{ record.normalized_sql }}</code></pre>
              <p v-if="record.generated?.assumptions.length" class="assumption">
                口径：{{ record.generated.assumptions.join('；') }}
              </p>
            </details>
          </section>
        </template>

        <section v-else-if="!loading && !error" class="empty-state">
          <div class="empty-symbol"><Sparkle :size="30" /></div>
          <h2>答案会出现在这里</h2>
          <p>输入一个清晰的业务问题。涉及高成本查询时，系统会在执行前请求确认。</p>
        </section>
      </main>
    </div>
  </div>
</template>

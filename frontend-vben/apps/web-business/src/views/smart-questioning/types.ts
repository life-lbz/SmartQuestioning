export type QuestionStatus =
  | "received"
  | "context_ready"
  | "sql_generated"
  | "sql_validated"
  | "cost_checked"
  | "approval_required"
  | "executing"
  | "completed"
  | "rejected"
  | "failed"
  | "cancelled";

export interface TimelineEvent {
  status: QuestionStatus;
  message: string;
  at: string;
}

export interface RiskAssessment {
  level: "L0" | "L1" | "L2" | "L3";
  reasons: string[];
  estimated_rows: number | null;
}

export interface QueryResult {
  columns: string[];
  rows: Record<string, unknown>[];
  row_count: number;
  elapsed_ms: number;
  truncated: boolean;
}

export interface ChartSpec {
  type: "table" | "metric" | "line" | "bar" | "pie" | "scatter";
  title: string;
  xField: string | null;
  yFields: string[];
  seriesNames: Record<string, string>;
  smooth: boolean;
  stack: boolean;
}

export interface QuestionRecord {
  id: string;
  question: string;
  requested_by: string;
  status: QuestionStatus;
  generated: {
    sql: string;
    reasoning_summary: string;
    assumptions: string[];
    suggested_chart: string;
  } | null;
  normalized_sql: string | null;
  sql_hash: string | null;
  risk: RiskAssessment | null;
  result: QueryResult | null;
  chart: ChartSpec | null;
  answer: string | null;
  error: string | null;
  timeline: TimelineEvent[];
  created_at: string;
}

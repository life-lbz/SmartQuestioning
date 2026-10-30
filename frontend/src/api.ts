import type { QuestionRecord } from "./types";

const API_BASE = import.meta.env.VITE_API_BASE ?? "/api/v1";

export interface SystemStatus {
  status: "ok" | "degraded";
  text_to_sql_mode: string;
  database: {
    connected: boolean;
    mode: string;
    name: string | null;
    version: string | null;
    error?: string;
  };
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const response = await fetch(`${API_BASE}${path}`, {
    ...init,
    headers: {
      "Content-Type": "application/json",
      "X-User": "local-user",
      ...init?.headers,
    },
  });
  if (!response.ok) {
    const body = await response.json().catch(() => ({ detail: "请求失败" }));
    throw new Error(body.detail ?? `请求失败 (${response.status})`);
  }
  return response.json() as Promise<T>;
}

export function askQuestion(question: string): Promise<QuestionRecord> {
  return request("/questions", {
    method: "POST",
    body: JSON.stringify({ question, preferred_chart: "auto" }),
  });
}

export function approveQuestion(record: QuestionRecord): Promise<QuestionRecord> {
  return request(`/questions/${record.id}/approve`, {
    method: "POST",
    headers: { "X-Role": "analyst" },
    body: JSON.stringify({ sql_hash: record.sql_hash }),
  });
}

export function getSystemStatus(): Promise<SystemStatus> {
  return request("/health");
}

export async function getExamples(): Promise<string[]> {
  const response = await request<{ questions: string[] }>("/examples");
  return response.questions;
}

import type { QuestionRecord } from './types';
import { api } from './client';
export interface SystemStatus { status:'ok'|'degraded';text_to_sql_mode:string;database:{connected:boolean;mode:string;name:string|null;version:string|null;error?:string} }
export const askQuestion=(question:string):Promise<QuestionRecord>=>api('/questions',{method:'POST',body:JSON.stringify({question,preferred_chart:'auto'})});
export const approveQuestion=(record:QuestionRecord):Promise<QuestionRecord>=>api(`/questions/${record.id}/approve`,{method:'POST',body:JSON.stringify({sql_hash:record.sql_hash})});
export const getSystemStatus=():Promise<SystemStatus>=>api('/health');
export async function getExamples():Promise<string[]>{return (await api('/examples')).questions;}

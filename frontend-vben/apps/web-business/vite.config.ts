import { defineConfig } from '@vben/vite-config';
export default defineConfig(async () => ({ application: {}, vite: { resolve: { dedupe: ['vue', 'vue-router', 'pinia'] }, server: {
 host: '127.0.0.1', port: 5181, strictPort: true,
 proxy: { '/api': { target: 'http://127.0.0.1:8013', changeOrigin: true } },
} } }));

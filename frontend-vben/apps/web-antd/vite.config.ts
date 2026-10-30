import { defineConfig } from '@vben/vite-config';
export default defineConfig(async () => ({ application: {}, vite: { server: {
 host: '127.0.0.1', port: 5180, strictPort: true,
 proxy: { '/api': { target: 'http://127.0.0.1:8011', changeOrigin: true } },
} } }));

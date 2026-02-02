import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [vue()],
  server: {
    origin: 'http://localhost:5173',
  },
  build: {
    outDir: 'public/dist',
    manifest: true,
    rollupOptions: {
      input: './src/js/app.js',
    },
  },
});

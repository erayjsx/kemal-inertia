import { defineConfig } from 'vite';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [svelte()],
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

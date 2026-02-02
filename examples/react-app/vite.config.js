import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    origin: 'http://localhost:5173',
  },
  build: {
    outDir: 'public/dist',
    manifest: true,
    rollupOptions: {
      input: './src/js/app.jsx',
    },
  },
});

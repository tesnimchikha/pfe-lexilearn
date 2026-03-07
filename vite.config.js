import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': 'http://localhost:3000',
      '/login': 'http://localhost:3000',
      '/register': 'http://localhost:3000',
      '/me': 'http://localhost:3000',
      '/user-stats': 'http://localhost:3000',
      '/user-full-stats': 'http://localhost:3000',
      '/game-history': 'http://localhost:3000',
    }
  }
})

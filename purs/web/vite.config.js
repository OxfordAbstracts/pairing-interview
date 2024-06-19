import { defineConfig } from 'vite'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [],
  test: {
    // 👋 add the line below to add jsdom to vite
    environment: 'jsdom',
    setupFiles: ['test/setup.js']
  },
})

// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  // Tokens de diseño y páginas: ver Docs/11. El público va estático on-demand.
  vite: {
    plugins: [tailwindcss()],
  },
});

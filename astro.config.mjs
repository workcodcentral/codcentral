import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  site: 'https://workcodcentral.github.io',
  base: '/codcentral',
  integrations: [tailwind()],
});

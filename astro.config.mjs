import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  site: 'https://codcentral.co.ke',
  integrations: [tailwind()],
});

import { defineConfig } from 'astro/config';
import tailwind from '@astrojs/tailwind';

export default defineConfig({
  site: 'https://codcentralstudios.co.ke',
  integrations: [
    tailwind({
      // Exclude admin pages from Tailwind processing to prevent style conflicts
      applyBaseStyles: true,
    }),
  ],
});

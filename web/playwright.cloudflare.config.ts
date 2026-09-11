import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/cloudflare',
  timeout: 45000,
  workers: 1,
  outputDir: 'test-results/cloudflare',
  use: { baseURL: 'https://pocket.changhai.me', browserName: 'chromium', channel: 'chrome' },
});

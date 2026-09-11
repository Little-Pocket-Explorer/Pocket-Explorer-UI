import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir: './tests/browser', timeout: 30000,
  use: { baseURL: 'http://127.0.0.1:4175', browserName: 'chromium', channel: 'chrome', trace: 'retain-on-failure' },
  webServer: { command: 'npm run start', url: 'http://127.0.0.1:4175/health', timeout: 30000,
    env: { PORT: '4175', PUBLIC_BASE_URL: 'http://127.0.0.1:4175', OWNER_KEY: 'browser-test-owner-00000000000000000000', DATABASE_PATH: 'test-results/browser.sqlite' } },
});

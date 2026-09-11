import { defineConfig } from 'vitest/config';
export default defineConfig({ test: { include: ['tests/**/*.test.{ts,tsx}'], coverage: { provider: 'v8', include: ['server/**/*.ts', 'worker/**/*.ts', 'src/**/*.{ts,tsx}', '../shared/story.ts'], exclude: ['server/main.ts', 'src/main.tsx'], reporter: ['text', 'json-summary', 'html'], thresholds: { lines: 80, branches: 80, perFile: true } } } });

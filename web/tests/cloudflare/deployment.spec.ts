import { expect, test } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { randomBytes } from 'node:crypto';
import { resolve } from 'node:path';
import type { Story } from '../../src/story';

const fixture = JSON.parse(readFileSync(resolve('../shared/fixtures/public-story-v1.json'), 'utf8')) as Story;

test('a clean browser can play a deployed story and sees its revocation', async ({ page, request }) => {
  const key = `pe1_${randomBytes(32).toString('hex')}`;
  const headers = { Authorization: `Bearer ${key}` };
  const created = await request.post('/api/shares', { data: fixture, headers });
  expect(created.status()).toBe(201);
  const receipt = await created.json() as { token: string; url: string };
  try {
    const other = { Authorization: `Bearer pe1_${randomBytes(32).toString('hex')}` };
    expect((await request.delete(`/api/shares/${receipt.token}`, { headers: other })).status()).toBe(404);
    expect((await request.delete(`/api/shares/${receipt.token}`)).status()).toBe(401);
    expect((await request.get('/api/shares/DmprLZx_BvlA75rki9n7MqFdl1b4U4hn')).status()).toBe(200);
    for (const width of [390, 1440]) {
      await page.setViewportSize({ width, height: 1000 });
      await page.goto(receipt.url);
      await expect(page.getByRole('heading', { name: fixture.title })).toBeVisible();
      expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
      await page.screenshot({ path: `../design/key-screens/cloudflare-${width}.png`, fullPage: true });
    }
    await page.getByRole('button', { name: 'Play memory', exact: true }).click();
    await expect(page.getByRole('button', { name: 'Pause memory', exact: true })).toBeVisible();
    await page.getByRole('button', { name: 'Pause memory', exact: true }).click();
    await page.getByRole('button', { name: 'Turn over Duck paddles' }).click();
    await expect(page.getByText(fixture.cards[0].observation)).toBeVisible();
    expect((await request.delete(`/api/shares/${receipt.token}`, { headers })).status()).toBe(204);
    await page.reload();
    await expect(page.getByRole('heading', { name: 'This adventure is no longer shared.' })).toBeVisible();
    await page.goto('/');
    await expect(page.getByRole('heading', { name: 'Big discoveries. Little explorers.' })).toBeVisible();
  } finally {
    await request.delete(`/api/shares/${receipt.token}`, { headers });
  }
});

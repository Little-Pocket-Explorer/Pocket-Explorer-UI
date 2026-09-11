import { test, expect } from '@playwright/test';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
const fixture = JSON.parse(readFileSync(resolve('../shared/fixtures/public-story-v1.json'), 'utf8'));
const authorization = { Authorization: 'Bearer browser-test-owner-00000000000000000000' };
test('an independently opened link plays, flips and becomes unavailable after revocation', async ({ request, browser }) => {
  const created = await request.post('/api/shares', { headers: authorization, data: fixture });
  expect(created.status()).toBe(201);
  const receipt = await created.json();
  const context = await browser.newContext({ viewport: { width: 390, height: 844 } });
  const page = await context.newPage();
  await page.goto(receipt.url);
  await expect(page.getByRole('heading', { name: fixture.title })).toBeVisible();
  await page.getByRole('button', { name: 'Next chapter' }).click();
  await expect(page.getByText(fixture.cards[0].observation)).toBeVisible();
  await page.getByRole('button', { name: 'Replay from the beginning' }).click();
  await expect(page.getByRole('heading', { name: 'It started with a why.' })).toBeVisible();
  await page.getByRole('button', { name: 'Pause memory' }).click();
  await page.getByRole('button', { name: 'Turn over Duck paddles' }).click();
  await expect(page.getByRole('button', { name: 'Show front of Duck paddles' })).toContainText(fixture.cards[0].observation);
  await page.screenshot({ path: '../design/key-screens/web-phone.png', fullPage: true });
  await request.delete(`/api/shares/${receipt.token}`, { headers: authorization });
  await page.reload();
  await expect(page.getByRole('heading', { name: 'This adventure is no longer shared.' })).toBeVisible();
  await page.screenshot({ path: '../design/key-screens/web-revoked.png', fullPage: true });
  await context.close();
});
for (const width of [375, 390, 768, 1440]) {
  test(`story fits ${width}px with keyboard focus and accessible touch targets`, async ({ page, request }) => {
    const created = await request.post('/api/shares', { headers: authorization, data: fixture });
    await page.setViewportSize({ width, height: 1000 });
    await page.goto((await created.json()).url);
    await expect(page.getByRole('heading', { name: fixture.title })).toBeVisible();
    expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
    const buttons = page.getByRole('button');
    for (const button of await buttons.all()) {
      const box = await button.boundingBox();
      expect(box?.height).toBeGreaterThanOrEqual(44);
      expect(box?.width).toBeGreaterThanOrEqual(44);
    }
    await page.keyboard.press('Tab');
    const focused = page.locator(':focus');
    await expect(focused).toHaveCSS('outline-style', 'solid');
    await page.keyboard.press('Enter');
    await expect(page.getByRole('button', { name: 'Pause memory' })).toBeVisible();
    if (width === 1440) await page.screenshot({ path: '../design/key-screens/web-desktop.png', fullPage: true });
  });
}
test('unknown and failed links have readable recovery states', async ({ page }) => {
  await page.goto('/s/' + 'z'.repeat(32));
  await expect(page.getByRole('heading', { name: 'This story wandered off.' })).toBeVisible();
  await page.route('**/api/shares/*', route => route.abort());
  await page.reload();
  await expect(page.getByRole('button', { name: 'Try again' })).toBeVisible();
  await page.screenshot({ path: '../design/key-screens/web-error.png', fullPage: true });
});

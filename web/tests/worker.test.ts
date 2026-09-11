import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { Miniflare } from 'miniflare';
import { createHash } from 'node:crypto';
import { mkdtempSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import worker, { type Env } from '../worker';

const fixture = JSON.parse(readFileSync(resolve('../shared/fixtures/public-story-v1.json'), 'utf8'));
const key = 'worker-test-owner-0000000000000000000000';
const directory = mkdtempSync(join(tmpdir(), 'pocket-d1-'));
let runtime: Miniflare;
let env: Env;
async function start() {
  runtime = new Miniflare({ modules: true, script: 'export default { fetch() { return new Response("D1 test"); } };',
    compatibilityDate: '2026-07-22', d1Databases: { DB: 'pocket-d1-test' }, d1Persist: directory });
  env = { DB: await runtime.getD1Database('DB') as unknown as Env['DB'], OWNER_KEY: key,
    SHARE_LIMITER: { async limit() { return { success: true }; } },
    PUBLIC_BASE_URL: 'https://stories.example', ASSETS: { async fetch() { return new Response('<main>Story viewer</main>'); } } };
}
function call(path: string, method = 'GET', body?: unknown, authorized = false, overrides: Partial<Env> = {}) {
  const headers: Record<string, string> = {};
  if (authorized) headers.Authorization = `Bearer ${key}`;
  return worker.fetch(new Request(`https://stories.example${path}`, { method, headers, body: body === undefined ? undefined : JSON.stringify(body) }), { ...env, ...overrides });
}
beforeAll(async () => {
  await start();
  await env.DB.exec(readFileSync(resolve('migrations/0001_shares.sql'), 'utf8').replace(/\n/g, ' '));
  await env.DB.exec(readFileSync(resolve('migrations/0002_share_ownership.sql'), 'utf8'));
}, 30000);
afterAll(async () => { await runtime?.dispose(); rmSync(directory, { recursive: true, force: true }); });

describe('Cloudflare Worker with a real D1 runtime', () => {
  it('lets a fresh installation share without a manually configured service key', async () => {
    const response = await worker.fetch(new Request('https://stories.example/api/shares', {
      method: 'POST', headers: { Authorization: `Bearer pe1_${'a'.repeat(64)}` }, body: JSON.stringify(fixture),
    }), env);
    expect(response.status).toBe(201);
  });
  it('creates an allowlisted snapshot, independently reads it and retains it after runtime restart', async () => {
    const created = await call('/api/shares', 'POST', { ...fixture, latitude: 1.23, rawRecording: 'private', ownerKey: 'secret',
      cards: fixture.cards.map((card: object) => ({ ...card, privatePhoto: 'private.jpg' })) }, true);
    expect(created.status).toBe(201);
    const receipt = await created.json() as { token: string; url: string };
    expect(receipt.token).toMatch(/^[A-Za-z0-9_-]{32}$/);
    expect(receipt.url).toBe(`https://stories.example/s/${receipt.token}`);
    const row = await env.DB.prepare('SELECT snapshot FROM shares WHERE token = ?').bind(receipt.token).first<{ snapshot: string }>();
    expect(JSON.parse(row!.snapshot)).toEqual(fixture);
    const next = await (await call('/api/shares', 'POST', fixture, true)).json() as { token: string };
    expect(next.token).not.toBe(receipt.token);
    await runtime.dispose();
    await start();
    const fresh = await call(`/api/shares/${receipt.token}`);
    expect(fresh.status).toBe(200);
    expect(await fresh.json()).toEqual(fixture);
    expect(fresh.headers.get('Cache-Control')).toBe('no-store');
    expect(fresh.headers.get('Referrer-Policy')).toBe('no-referrer');
    const head = await call(`/api/shares/${receipt.token}`, 'HEAD');
    expect(head.status).toBe(200);
    expect(await head.text()).toBe('');
    expect((await call(`/api/shares/${receipt.token}`, 'DELETE')).status).toBe(401);
    expect((await call(`/api/shares/${receipt.token}`, 'DELETE', undefined, true)).status).toBe(204);
    expect((await call(`/api/shares/${receipt.token}`)).status).toBe(410);
    expect(await env.DB.prepare('SELECT snapshot FROM shares WHERE token = ?').bind(receipt.token).first('snapshot')).toBe('{}');
    expect((await call(`/api/shares/${next.token}`)).status).toBe(200);
  }, 30000);

  it('protects mutations, rejects unknown routes and preserves static and health responses', async () => {
    for (const method of ['POST', 'PUT', 'PATCH', 'DELETE']) expect((await call('/api/shares', method, fixture)).status).toBe(401);
    const wrong = await worker.fetch(new Request('https://stories.example/api/shares', { method: 'POST', headers: { Authorization: 'Bearer wrong' } }), env);
    expect(wrong.status).toBe(401);
    for (const path of ['/api/missing', '/api/shares/invalid', `/api/shares/${'x'.repeat(32)}`]) expect((await call(path)).status).toBe(404);
    expect((await call(`/api/shares/${'x'.repeat(32)}`, 'DELETE', undefined, true)).status).toBe(404);
    expect((await call(`/api/shares/${'x'.repeat(32)}`, 'PUT', undefined, true)).status).toBe(405);
    expect((await call('/api/shares', 'PATCH', undefined, true)).status).toBe(404);
    expect(await (await call('/health')).json()).toEqual({ status: 'ok' });
    expect(await (await call('/')).text()).toContain('Story viewer');
    expect((await call('/s/example')).headers.get('X-Robots-Tag')).toBe('noindex, nofollow');
    expect((await call('/', 'POST')).status).toBe(405);
    expect(await (await call('/', 'HEAD')).text()).toBe('');
  });

  it('rejects invalid data, malformed JSON and both declared and streamed oversized requests', async () => {
    expect((await call('/api/shares', 'POST', { ...fixture, version: 2 }, true)).status).toBe(400);
    expect((await call('/api/shares', 'POST', undefined, true)).status).toBe(400);
    for (const [body, headers, expected] of [
      ['{', {}, 400],
      ['x', { 'Content-Length': '270000' }, 413],
      ['x'.repeat(270000), {}, 413],
    ] as const) {
      const result = await worker.fetch(new Request('https://stories.example/api/shares', { method: 'POST', body,
        headers: { ...headers, Authorization: `Bearer ${key}` } }), env);
      expect(result.status).toBe(expected);
    }
    const stream = new ReadableStream({ start(controller) {
      const bytes = new TextEncoder().encode(JSON.stringify({ ...fixture, firstName: 'Zoë' }));
      controller.enqueue(bytes.slice(0, 31)); controller.enqueue(bytes.slice(31)); controller.close();
    } });
    const request = new Request('https://stories.example/api/shares', { method: 'POST', body: stream,
      headers: { Authorization: `Bearer ${key}` }, duplex: 'half' } as RequestInit);
    expect((await worker.fetch(request, env)).status).toBe(201);
  });

  it('fails closed on missing secrets, invalid origins and unavailable storage without exposing internal errors', async () => {
    for (const ownerKey of ['', 'short']) {
      expect((await call('/api/shares', 'POST', fixture, true, { OWNER_KEY: ownerKey })).status).toBe(500);
    }
    for (const origin of ['bad', 'http://public.example', 'https://user@stories.example', 'https://:pass@stories.example',
      'https://stories.example/path', 'https://stories.example/?q=1', 'https://stories.example/#x']) {
      expect((await call('/api/shares', 'POST', fixture, true, { PUBLIC_BASE_URL: origin })).status).toBe(500);
    }
    const failed = new Proxy(env.DB, { get() { throw new Error('internal secret database detail'); } });
    const result = await call('/health', 'GET', undefined, false, { DB: failed });
    expect(result.status).toBe(500);
    expect(await result.json()).toEqual({ error: 'Sharing is temporarily unavailable.' });
    expect(result.headers.get('Cache-Control')).toBe('no-store');
  });
});


describe('installation-scoped D1 snapshots', () => {
  function device(path: string, credential: string, method = 'DELETE', body?: unknown, overrides: Partial<Env> = {}) {
    return worker.fetch(new Request(`https://stories.example${path}`, { method,
      headers: { Authorization: `Bearer ${credential}`, 'CF-Connecting-IP': '192.0.2.7' },
      body: body === undefined ? undefined : JSON.stringify(body) }), { ...env, ...overrides });
  }
  it('keeps public links read-only and preserves owner hashes after a D1 restart', async () => {
    const a = `pe1_${'c'.repeat(64)}`;
    const b = `pe1_${'d'.repeat(64)}`;
    const created = await device('/api/shares', a, 'POST', fixture);
    expect(created.status).toBe(201);
    const { token } = await created.json() as { token: string };
    const path = `/api/shares/${token}`;
    expect(await env.DB.prepare('SELECT owner_hash FROM shares WHERE token = ?').bind(token).first('owner_hash'))
      .toBe(createHash('sha256').update(`Bearer ${a}`).digest('hex'));
    const legacy = await (await call('/api/shares', 'POST', fixture, true)).json() as { token: string };
    expect((await device(path, b)).status).toBe(404);
    expect((await device(path, token)).status).toBe(401);
    expect((await device(`/api/shares/${legacy.token}`, a)).status).toBe(404);
    expect((await call(path)).status).toBe(200);
    await runtime.dispose(); await start();
    expect((await device(path, a)).status).toBe(204);
    expect((await call(path)).status).toBe(410);
    expect((await device(path, a)).status).toBe(204);
    expect((await call(`/api/shares/${legacy.token}`)).status).toBe(200);
    expect((await call(`/api/shares/${legacy.token}`, 'DELETE', undefined, true)).status).toBe(204);
  }, 30000);
  it('bounds creation by IP and owner while keeping reads and revocation available', async () => {
    const a = `pe1_${'e'.repeat(64)}`;
    const response = await device('/api/shares', a, 'POST', fixture);
    const { token } = await response.json() as { token: string };
    for (const blockedCall of [1, 2]) {
      const keys: string[] = [];
      const SHARE_LIMITER = { async limit({ key }: { key: string }) { keys.push(key); return { success: keys.length !== blockedCall }; } };
      const blocked = await device('/api/shares', a, 'POST', fixture, { SHARE_LIMITER });
      expect(blocked.status).toBe(429);
      expect(blocked.headers.get('Retry-After')).toBe('60');
      expect(keys[0]).toBe('ip:192.0.2.7');
      if (blockedCall === 2) expect(keys[1]).toBe(`owner:${createHash('sha256').update(`Bearer ${a}`).digest('hex')}`);
      expect((await device(`/api/shares/${token}`, a, 'GET', undefined, { SHARE_LIMITER })).status).toBe(200);
    }
    expect((await device(`/api/shares/${token}`, a, 'DELETE', undefined, { SHARE_LIMITER: { async limit() { throw new Error('Not called'); } } })).status).toBe(204);
    expect((await device('/api/shares', a, 'POST', fixture, { SHARE_LIMITER: { async limit() { throw new Error('Unavailable limiter'); } } })).status).toBe(500);
  });
});

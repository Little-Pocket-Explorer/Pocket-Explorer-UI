import { afterEach, describe, expect, it } from 'vitest';
import request from 'supertest';
import { DatabaseSync } from 'node:sqlite';
import { createHash } from 'node:crypto';
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { ShareStore } from '../server/store';
import { createApp } from '../server/app';
import { chaptersFor, storySchema } from '../src/story';
const fixture = JSON.parse(readFileSync(resolve('../shared/fixtures/public-story-v1.json'), 'utf8'));
const key = 'test-owner-key-only-00000000000000000000';
const openStores: ShareStore[] = [];
const directories: string[] = [];
function setup() {
  const directory = mkdtempSync(join(tmpdir(), 'pocket-sharing-')); directories.push(directory);
  const filename = join(directory, 'shares.sqlite');
  const store = new ShareStore(filename); openStores.push(store);
  const app = createApp({ store, ownerKey: key, publicBaseURL: 'https://stories.example' });
  return { directory, filename, store, app };
}
afterEach(() => { for (const store of openStores.splice(0)) store.close(); for (const directory of directories.splice(0)) rmSync(directory, { recursive: true, force: true }); });
describe('durable authenticated story service', () => {
  it('exports a random, allowlisted snapshot and survives a complete store reopen', async () => {
    const { app, store, filename } = setup();
    const malicious = { ...fixture, latitude: 12.123456, ownerKey: 'private', rawRecording: 'data', privateHistory: ['secret'], cards: fixture.cards.map((card: object) => ({ ...card, photoFilename: 'private.jpg', exif: { gps: 123 } })) };
    const created = await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).send(malicious).expect(201);
    expect(created.body.token).toMatch(/^[A-Za-z0-9_-]{32}$/);
    expect(created.body.url).toBe(`https://stories.example/s/${created.body.token}`);
    const second = await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).send(fixture).expect(201);
    expect(created.body.token).not.toBe(second.body.token);
    const fresh = await request(app).get(`/api/shares/${created.body.token}`).expect(200);
    expect(fresh.body).toEqual(fixture);
    expect(fresh.headers['cache-control']).toBe('no-store');
    expect(fresh.headers['referrer-policy']).toBe('no-referrer');
    store.close(); openStores.splice(openStores.indexOf(store), 1);
    const restarted = new ShareStore(filename); openStores.push(restarted);
    expect(restarted.read(created.body.token)).toEqual({ status: 200, story: fixture });
    const restartedApp = createApp({ store: restarted, ownerKey: key, publicBaseURL: 'https://stories.example' });
    await request(restartedApp).delete(`/api/shares/${created.body.token}`).set('Authorization', `Bearer ${key}`).expect(204);
    const gone = await request(restartedApp).get(`/api/shares/${created.body.token}`).expect(410);
    expect(gone.body).toEqual({ error: 'This adventure is no longer shared.' });
    expect(gone.headers['cache-control']).toBe('no-store');
    expect(restarted.read(created.body.token)).toEqual({ status: 410 });
  });
  it('rejects unauthenticated mutations, invalid data and unknown tokens', async () => {
    const { app } = setup();
    for (const method of ['post', 'put', 'patch', 'delete'] as const) await request(app)[method]('/api/shares').send(fixture).expect(401);
    await request(app).post('/api/shares').set('Authorization', 'Bearer wrong').send(fixture).expect(401);
    await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).send({ ...fixture, version: 2 }).expect(400);
    await request(app).get('/api/shares/invalid').expect(404);
    await request(app).get(`/api/shares/${'x'.repeat(32)}`).expect(404);
    await request(app).delete('/api/shares/invalid').set('Authorization', `Bearer ${key}`).expect(404);
    await request(app).delete(`/api/shares/${'x'.repeat(32)}`).set('Authorization', `Bearer ${key}`).expect(404);
    await request(app).get('/api/missing').expect(404);
    await request(app).head('/api/missing').expect(404);
    await request(app).get('/health').expect(200, { status: 'ok' });
  });
  it('accepts only explicit optional details and matching memory content', async () => {
    const { app } = setup();
    const body = { ...fixture, firstName: 'Alex', city: 'Sydney' };
    const created = await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).send(body).expect(201);
    expect((await request(app).get(`/api/shares/${created.body.token}`)).body).toEqual(body);
    expect(storySchema.safeParse({ ...fixture, cards: [...fixture.cards, ...fixture.cards] }).success).toBe(false);
    expect(storySchema.safeParse({ ...fixture, chapters: [...fixture.chapters].reverse() }).success).toBe(false);
    expect(storySchema.safeParse({ ...fixture, chapters: fixture.chapters.slice(0, 2) }).success).toBe(false);
    expect(storySchema.safeParse({ ...fixture, chapters: [...fixture.chapters, fixture.chapters[0]] }).success).toBe(false);
    expect(chaptersFor(fixture.cards)).toEqual(fixture.chapters);
  });
  it('handles invalid JSON, oversized input and store failure without leaking details', async () => {
    const { app, store } = setup();
    await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).set('Content-Type', 'application/json').send('{').expect(400);
    await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).send({ text: 'x'.repeat(270000) }).expect(413);
    store.close(); openStores.splice(openStores.indexOf(store), 1);
    const result = await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).send(fixture).expect(500);
    expect(result.body).toEqual({ error: 'Sharing is temporarily unavailable.' });
  });
  it('serves the actual static viewer and validates deployment configuration', async () => {
    const { store, directory } = setup();
    writeFileSync(join(directory, 'index.html'), '<main>A shared adventure</main>');
    const app = createApp({ store, ownerKey: key, publicBaseURL: 'http://127.0.0.1:4174', staticDirectory: directory });
    expect((await request(app).get('/s/example').expect(200)).text).toContain('A shared adventure');
    expect((await request(app).get('/').expect(200)).text).toContain('A shared adventure');
    expect(() => createApp({ store, ownerKey: 'weak', publicBaseURL: 'https://stories.example' })).toThrow();
    for (const origin of ['http://public.example', 'https://user:pass@stories.example', 'https://stories.example/path', 'https://stories.example/?q=1', 'https://stories.example/#x']) {
      expect(() => createApp({ store, ownerKey: key, publicBaseURL: origin })).toThrow();
    }
  });
});


describe('anonymous installation ownership', () => {
  it('preserves old rows and isolates ownership across devices and database reopens', async () => {
    const { app, filename, store } = setup();
    const a = `Bearer pe1_${'a'.repeat(64)}`;
    const b = `Bearer pe1_${'b'.repeat(64)}`;
    const legacy = await request(app).post('/api/shares').set('Authorization', `Bearer ${key}`).send(fixture).expect(201);
    const created = await request(app).post('/api/shares').set('Authorization', a).send(fixture).expect(201);
    const other = await request(app).post('/api/shares').set('Authorization', b).send(fixture).expect(201);
    const path = `/api/shares/${created.body.token}`;
    const db = new DatabaseSync(filename);
    const row = db.prepare('SELECT owner_hash FROM shares WHERE token = ?').get(created.body.token)!;
    expect(row.owner_hash).toBe(createHash('sha256').update(a).digest('hex'));
    db.close();
    await request(app).delete(path).set('Authorization', b).expect(404);
    await request(app).delete(path).set('Authorization', `Bearer ${created.body.token}`).expect(401);
    await request(app).delete(`/api/shares/${legacy.body.token}`).set('Authorization', a).expect(404);
    await request(app).get(path).expect(200, fixture);
    await request(app).get(`/api/shares/${legacy.body.token}`).expect(200, fixture);
    store.close(); openStores.splice(openStores.indexOf(store), 1);
    const restarted = new ShareStore(filename); openStores.push(restarted);
    const fresh = createApp({ store: restarted, ownerKey: key, publicBaseURL: 'https://stories.example' });
    await request(fresh).delete(path).set('Authorization', a).expect(204);
    await request(fresh).get(path).expect(410);
    await request(fresh).get(`/api/shares/${other.body.token}`).expect(200, fixture);
    await request(fresh).delete(`/api/shares/${legacy.body.token}`).set('Authorization', `Bearer ${key}`).expect(204);
    await request(fresh).delete(`/api/shares/${other.body.token}`).set('Authorization', `Bearer ${key}`).expect(204);
  });
});

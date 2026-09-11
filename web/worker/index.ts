import { randomBytes } from 'node:crypto';
import type { D1Database } from '@cloudflare/workers-types';
import { storySchema } from '../src/story';
import { authorize, type ShareOwner } from '../server/ownership';

export interface Env {
  DB: D1Database;
  ASSETS: { fetch(request: Request): Promise<Response> };
  OWNER_KEY: string;
  PUBLIC_BASE_URL: string;
  SHARE_LIMITER: { limit(options: { key: string }): Promise<{ success: boolean }> };
}

const maximumBytes = 256 * 1024;
const tokenPattern = /^[A-Za-z0-9_-]{32}$/;
const securityHeaders = {
  'Cache-Control': 'no-store',
  'Referrer-Policy': 'no-referrer',
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'X-Robots-Tag': 'noindex, nofollow',
  'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'",
};

function error(status: number, message: string) {
  return Response.json({ error: message }, { status });
}

async function readBody(request: Request): Promise<string | Response> {
  if (Number(request.headers.get('content-length')) > maximumBytes) return error(413, 'The request could not be read.');
  if (!request.body) return '';
  const reader = request.body.getReader();
  const decoder = new TextDecoder();
  let size = 0;
  let text = '';
  while (true) {
    const chunk = await reader.read();
    if (chunk.done) return text + decoder.decode();
    size += chunk.value.byteLength;
    if (size > maximumBytes) {
      await reader.cancel();
      return error(413, 'The request could not be read.');
    }
    text += decoder.decode(chunk.value, { stream: true });
  }
}

async function route(request: Request, env: Env): Promise<Response> {
  const url = new URL(request.url);
  const isRead = request.method === 'GET' || request.method === 'HEAD';
  if (url.pathname === '/health' && isRead) {
    await env.DB.prepare('SELECT 1 FROM shares LIMIT 1').all();
    return Response.json({ status: 'ok' });
  }
  if (!url.pathname.startsWith('/api/')) {
    if (!isRead) return error(405, 'This page is read-only.');
    return env.ASSETS.fetch(request);
  }
  let owner: ShareOwner | undefined;
  if (!isRead) {
    owner = authorize(request.headers.get('authorization'), env.OWNER_KEY);
    if (!owner) return error(401, 'Owner authorization is required.');
  }
  if (url.pathname === '/api/shares' && request.method === 'POST') {
    for (const key of [`ip:${request.headers.get('CF-Connecting-IP') ?? 'unknown'}`, `owner:${owner!.hash ?? 'legacy'}`]) {
      if (!(await env.SHARE_LIMITER.limit({ key })).success) {
        return Response.json({ error: 'Please wait a minute before sharing again.' }, { status: 429, headers: { 'Retry-After': '60' } });
      }
    }
    const origin = new URL(env.PUBLIC_BASE_URL);
    if (origin.protocol !== 'https:' || origin.username || origin.password || origin.pathname !== '/' || origin.search || origin.hash) {
      throw new Error('Invalid public origin');
    }
    const body = await readBody(request);
    if (body instanceof Response) return body;
    let input: unknown;
    try { input = JSON.parse(body); } catch { return error(400, 'The request could not be read.'); }
    const story = storySchema.safeParse(input);
    if (!story.success) return error(400, 'This story does not match version 1 of the public format.');
    const token = randomBytes(24).toString('base64url');
    await env.DB.prepare('INSERT INTO shares (token, snapshot, owner_hash) VALUES (?, ?, ?)').bind(token, JSON.stringify(story.data), owner!.hash).run();
    return Response.json({ token, url: `${origin.origin}/s/${token}` }, { status: 201 });
  }
  const match = /^\/api\/shares\/([^/]+)$/.exec(url.pathname);
  if (!match || !tokenPattern.test(match[1])) return error(404, 'Story not found.');
  const token = match[1];
  // Reading from the primary keeps revocation effective even if replicas are enabled later.
  const db = env.DB.withSession('first-primary');
  if (isRead) {
    const row = await db.prepare('SELECT snapshot, revoked FROM shares WHERE token = ?').bind(token).first<{ snapshot: string; revoked: number }>();
    if (!row) return error(404, 'Story not found.');
    if (row.revoked) return error(410, 'This adventure is no longer shared.');
    return Response.json(storySchema.parse(JSON.parse(row.snapshot)));
  }
  if (request.method === 'DELETE') {
    const result = await db.prepare("UPDATE shares SET revoked = 1, snapshot = '{}' WHERE token = ? AND (? = 1 OR owner_hash = ?)").bind(token, Number(owner!.admin), owner!.hash).run();
    return result.meta.changes > 0 ? new Response(null, { status: 204 }) : error(404, 'Story not found.');
  }
  return error(405, 'This operation is not supported.');
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    let response: Response;
    try { response = await route(request, env); }
    catch { response = error(500, 'Sharing is temporarily unavailable.'); }
    const headers = new Headers(response.headers);
    for (const [name, value] of Object.entries(securityHeaders)) headers.set(name, value);
    return new Response(request.method === 'HEAD' ? null : response.body, { status: response.status, headers });
  },
};

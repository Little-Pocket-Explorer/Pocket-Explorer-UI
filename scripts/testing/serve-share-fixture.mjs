import { createServer } from 'node:http';
import { randomUUID } from 'node:crypto';

const port = Number(process.env.POCKET_SHARE_FIXTURE_PORT || 4201);
const shares = new Map();
let pending = [];
let creates = 0;
let revokes = 0;
let holdRevocations = false;
let pendingRevocations = [];
createServer(async (request, response) => {
  const path = new URL(request.url, `http://127.0.0.1:${port}`).pathname;
  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);
  const text = Buffer.concat(chunks).toString();
  const input = text ? JSON.parse(text) : null;
  const json = (status, body) => {
    response.writeHead(status, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify(body));
  };
  if (path === '/__fixture/reset') {
    pending.forEach(finish => finish(503)); pending = []; shares.clear(); creates = 0;
    pendingRevocations.forEach(finish => finish()); pendingRevocations = []; revokes = 0; holdRevocations = false;
    return json(200, { reset: true });
  }
  if (path === '/__fixture/release') {
    pending.forEach(finish => finish(201)); pending = [];
    pendingRevocations.forEach(finish => finish()); pendingRevocations = [];
    return json(200, { released: true });
  }
  if (path === '/__fixture/hold-revocation') { holdRevocations = true; return json(200, { held: true }); }
  if (path === '/__fixture/status') return json(200, { creates, revokes, active: [...shares.values()].filter(Boolean).length, pending: pending.length });
  if (path === '/health') return json(200, { fixture: true });
  if (path === '/api/shares' && request.method === 'POST') {
    const token = randomUUID().replaceAll('-', ''); creates += 1;
    pending.push(status => {
      if (status === 201) shares.set(token, input);
      json(status, { token, url: `http://127.0.0.1:${port}/s/${token}` });
    });
    return;
  }
  const token = /^\/api\/shares\/([^/]+)$/.exec(path)?.[1];
  if (token && request.method === 'DELETE') {
    revokes += 1;
    const finish = () => { shares.set(token, null); response.writeHead(204); response.end(); };
    if (holdRevocations) pendingRevocations.push(finish); else finish();
    return;
  }
  if (token) return json(shares.get(token) === null ? 410 : shares.has(token) ? 200 : 404, shares.get(token));
  json(404, { error: 'fixture_route_missing' });
}).listen(port, '127.0.0.1', () => console.log(`Share fixture listening on 127.0.0.1:${port}`));

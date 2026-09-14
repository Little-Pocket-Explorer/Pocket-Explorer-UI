import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';

const port = Number(process.env.POCKET_FIXTURE_PORT || 4197);
const image = readFileSync(process.env.POCKET_FIXTURE_IMAGE || new URL('../../shared/fixtures/generated-card.png', import.meta.url));
const questions = new Map();
const jobs = new Map();
const shares = new Map();
const reply = {
  title: 'Blue sky', answer: 'Air scatters blue light more than red light. That is why the daytime sky looks blue.',
  invitation: 'Look at the sky away from the sun. What colour do you notice?', category: 'science',
  artworkPrompt: 'Blue sky and white clouds',
  quiz: { question: 'What scatters sunlight?', choices: ['Air', 'Paint', 'The Moon'], correctIndex: 0, explanation: 'Air scatters the blue part of sunlight.' },
};
createServer(async (request, response) => {
  const url = new URL(request.url, 'http://127.0.0.1');
  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);
  const text = Buffer.concat(chunks).toString();
  let input;
  try { input = text ? JSON.parse(text) : null; } catch { response.writeHead(400); response.end(); return; }
  function json(status, value) { response.writeHead(status, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }); response.end(JSON.stringify(value)); }
  if (url.pathname === '/health') return json(200, { status: 'ok', fixture: true });
  if (url.pathname === '/api/explorations' && request.method === 'POST') {
    if (input.question.includes('network failure')) return json(503, { error: 'fixture_failure' });
    const result = { id: input.id, question: input.question, status: 'ready', reply };
    questions.set(input.id, result); return json(200, result);
  }
  const exploration = /^\/api\/explorations\/([^/]+)$/.exec(url.pathname);
  if (exploration) return json(questions.has(exploration[1]) ? 200 : 404, questions.get(exploration[1]));
  if (/^\/api\/explorations\/[^/]+\/artwork$/.test(url.pathname)) {
    const id = randomUUID(); const job = { id, status: 'ready', attempts: 1, imagePath: `/api/artwork/${id}/image` };
    jobs.set(id, job); return json(202, job);
  }
  const art = /^\/api\/artwork\/([^/]+)(\/image|\/retry)?$/.exec(url.pathname);
  if (art) {
    if (art[2] === '/image') { response.writeHead(200, { 'Content-Type': 'image/png' }); response.end(image); return; }
    if (art[2] === '/retry') jobs.set(art[1], { id: art[1], status: 'ready', attempts: 2, imagePath: `/api/artwork/${art[1]}/image` });
    return json(jobs.has(art[1]) ? 200 : 404, jobs.get(art[1]) || { error: 'not_found' });
  }
  if (url.pathname === '/api/shares' && request.method === 'POST') {
    const token = randomUUID().replaceAll('-', ''); shares.set(token, input);
    return json(201, { token, url: `http://127.0.0.1:${port}/s/${token}` });
  }
  const share = /^\/api\/shares\/([^/]+)$/.exec(url.pathname);
  if (share) {
    if (request.method === 'DELETE') { shares.set(share[1], null); response.writeHead(204); response.end(); return; }
    const data = shares.get(share[1]); return json(data === null ? 410 : data ? 200 : 404, data);
  }
  json(404, { error: 'fixture_route_missing' });
}).listen(port, '127.0.0.1', () => console.log(`Native test fixture listening on 127.0.0.1:${port}`));

import { createServer } from 'node:http';
import { readFileSync } from 'node:fs';
import { randomUUID, createHash } from 'node:crypto';

const port = Number(process.env.POCKET_FIXTURE_PORT || 4197);
const image = readFileSync(process.env.POCKET_FIXTURE_IMAGE || new URL('../../shared/fixtures/generated-card.png', import.meta.url));
const narration = readFileSync(new URL('../../shared/fixtures/narration-en.wav', import.meta.url));
const narrationCounts = new Map();
const questions = new Map();
const jobs = new Map();
const corruptPictures = new Set();
const shares = new Map();
const reply = {
  title: 'Blue sky', answer: 'Air scatters blue light more than red light. That is why the daytime sky looks blue.',
  invitation: 'Look at the sky away from the sun. What colour do you notice?', category: 'science',
  artworkPrompt: 'Blue sky and white clouds',
  quiz: { question: 'What scatters sunlight?', choices: ['Air', 'Paint', 'The Moon'], correctIndex: 0, explanation: 'Air scatters the blue part of sunlight.' },
};
const asset = (bytes, kind) => {
  const sha256 = createHash('sha256').update(bytes).digest('hex');
  return { path: `/api/knowledge-assets/${sha256}.${kind}`, sha256, bytes: bytes.length };
};
let dailyRevision = 1;
let dailyOffline = false;
let dailyReplaced = false;
let dailyWithdrawals = [];
let dailyAssetReads = 0;
let dailyCatalogReads = 0;
let generatedQuestions = 0;
let generatedArtwork = 0;
const makeDaily = () => ['blue-sky', 'moonlight', 'ocean-salt'].map((topicID, index) => ({
  id: `11111111-1111-4111-8111-00000000000${index}`, version: 1, topicID, language: 'en', minAge: 5, maxAge: 18,
  question: ['Why is the sky blue?', 'Why does the Moon shine?', 'Why is the ocean salty?'][index], reply,
  policy: 'discovery-v1', verifiedAt: Date.now() - 86400000, reviewAt: Date.now() + 30 * 86400000, expiresAt: Date.now() + 90 * 86400000,
  artwork: asset(image, 'png'), narration: asset(narration, 'wav'), speechRevision: 'fixture-v1',
  sources: [{ url: 'https://spaceplace.nasa.gov/blue-sky/en/', sha256: 'a'.repeat(64) }],
}));
const initialDaily = process.env.POCKET_FIXTURE_CATALOG ? JSON.parse(readFileSync(process.env.POCKET_FIXTURE_CATALOG, 'utf8')) : makeDaily();
let demoOwner;
let demoAccessReads = 0;
const demoItems = [...initialDaily.map(item => ({ ...item, topicID: 'demo-' + item.topicID })), {
  ...initialDaily[0], id: '44444444-4444-4444-8444-444444444444', topicID: 'demo-prism', question: 'How does a prism make a rainbow?',
}];
const access = () => ({ authorized: true, id: '55555555-5555-4555-8555-555555555555', label: 'Fixture iPhone', expiresAt: Date.now() + 7 * 86400000 });
const frenchQuestions = ['Pourquoi le ciel est-il bleu ?', 'Pourquoi la Lune brille-t-elle ?', 'Pourquoi la mer est-elle salée ?'];
const daily = [...initialDaily, ...initialDaily.filter(item => item.language === 'en').map((item, i) => ({ ...item,
  id: `22222222-2222-4222-8222-00000000000${i}`, language: 'fr', question: frenchQuestions[i], reply: { ...reply, answer: 'Les molécules de l’air diffusent la lumière bleue du Soleil.' } }))];
createServer(async (request, response) => {
  const url = new URL(request.url, 'http://127.0.0.1');
  const chunks = [];
  for await (const chunk of request) chunks.push(chunk);
  const text = Buffer.concat(chunks).toString();
  let input;
  try { input = text ? JSON.parse(text) : null; } catch { response.writeHead(400); response.end(); return; }
  function json(status, value) { response.writeHead(status, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }); response.end(JSON.stringify(value)); }
  if (url.pathname === '/__fixture/demo/reset') { demoOwner = undefined; demoAccessReads = 0; dailyOffline = false; return json(200, { reset: true }); }
  if (url.pathname === '/__fixture/demo/revoke') { demoOwner = undefined; return json(200, { revoked: true }); }
  if (url.pathname === '/__fixture/demo/status') return json(200, { demoAccessReads });
  if (url.pathname === '/__fixture/daily/status') return json(200, { generatedQuestions, generatedArtwork, dailyAssetReads, dailyCatalogReads });
  if (url.pathname === '/__fixture/daily/reset') { dailyOffline = false; dailyReplaced = false; dailyWithdrawals = []; dailyRevision++; return json(200, { reset: true }); }
  if (url.pathname === '/__fixture/daily/offline') { dailyOffline = true; return json(200, { offline: true }); }
  if (url.pathname === '/__fixture/daily/withdraw') {
    dailyWithdrawals = daily.filter(item => item.topicID === url.searchParams.get('topic')).map(item => ({ id: item.id, version: item.version, reason: 'correcting' }));
    dailyRevision++; return json(200, { withdrawals: dailyWithdrawals });
  }
  if (url.pathname === '/__fixture/daily/revise') { dailyReplaced = true; dailyRevision++; return json(200, { revision: dailyRevision }); }
  if (dailyOffline && url.pathname.startsWith('/api/')) return json(503, { error: 'fixture_offline' });
  if (url.pathname === '/api/demo/activate') {
    if (input?.token !== 'x'.repeat(43) || (demoOwner && demoOwner !== request.headers.authorization)) return json(410, { error: 'activation_unavailable' });
    demoOwner = request.headers.authorization; return json(200, access());
  }
  if (url.pathname === '/api/demo/access') {
    demoAccessReads++; return json(200, demoOwner === request.headers.authorization ? access() : { authorized: false });
  }
  if (url.pathname === '/api/demo/catalog') {
    if (demoOwner !== request.headers.authorization) return json(403, { error: 'demo_not_authorized' });
    return json(200, { access: access(), catalog: { schemaVersion: 1, revision: 'demo-1', serverTime: Date.now(), refreshAfterSeconds: 21600,
      items: url.searchParams.get('language') === 'en' ? demoItems : [], withdrawals: [] } });
  }
  if (url.pathname === '/api/recommendations') {
    dailyCatalogReads++;
    let items = daily.filter(item => item.language === url.searchParams.get('language') && !dailyWithdrawals.some(ref => ref.id === item.id));
    if (dailyReplaced) items = items.map((item, i) => ({ ...item, id: `33333333-3333-4333-8333-00000000000${i}`, topicID: 'new-' + item.topicID, question: 'New discovery: ' + item.question }));
    return json(200, { schemaVersion: 1, revision: String(dailyRevision), serverTime: Date.now(), refreshAfterSeconds: 21600, items, withdrawals: dailyWithdrawals });
  }
  if (url.pathname.startsWith('/api/knowledge-assets/')) {
    dailyAssetReads++;
    const isImage = url.pathname.endsWith('.png');
    response.writeHead(200, { 'Content-Type': isImage ? 'image/png' : 'audio/wav' }); response.end(isImage ? image : narration); return;
  }
  if (url.pathname === '/health') return json(200, { status: 'ok', fixture: true });
  if (url.pathname === '/__fixture/answers/complete' && request.method === 'POST') {
    for (const result of questions.values()) {
      if (result.question === input.question) { result.status = 'ready'; result.reply = reply; }
    }
    return json(200, { completed: true });
  }
  if (url.pathname === '/__fixture/narration-count') return json(200, { count: narrationCounts.get(url.searchParams.get('question')) || 0 });
  if (url.pathname === '/api/explorations' && request.method === 'POST') {
    if (input.prepared) {
      const item = [...daily, ...demoItems].find(item => item.id === input.prepared.id && item.version === input.prepared.version);
      if (questions.has(input.id)) return json(200, questions.get(input.id));
      if (!item || dailyWithdrawals.some(ref => ref.id === item.id && ref.version === item.version)) return json(409, { error: 'prepared_content_unavailable' });
      const result = { id: input.id, question: input.question, status: 'ready', reply: item.reply, prepared: input.prepared };
      questions.set(input.id, result); return json(200, result);
    }
    generatedQuestions++;
    if (input.question.includes('network failure')) return json(503, { error: 'fixture_failure' });
    if (input.question.includes('demo allowance')) return json(429, { error: 'demo_limit' });
    const first = !questions.has(input.id);
    const status = first && input.question.includes('slow answer') ? 'thinking' : first && input.question.includes('failed answer') ? 'failed' : 'ready';
    const answer = input.question.includes('narration') ? { ...reply, answer: reply.answer + ' ' + input.question } : reply;
    const result = { id: input.id, question: input.question, status, reply: status === 'ready' ? answer : null };
    questions.set(input.id, result); return json(200, result);
  }
  const audio = /^\/api\/narration\/([^/]+)$/.exec(url.pathname);
  if (audio) {
    const question = questions.get(audio[1])?.question || '';
    narrationCounts.set(question, (narrationCounts.get(question) || 0) + 1);
    if (question.includes('unavailable narration')) return json(503, { error: 'speech_unavailable' });
    if (question.includes('slow narration')) await new Promise(resolve => setTimeout(resolve, 15000));
    response.writeHead(200, { 'Content-Type': 'audio/wav' }); response.end(narration); return;
  }
  const exploration = /^\/api\/explorations\/([^/]+)$/.exec(url.pathname);
  if (exploration) return json(questions.has(exploration[1]) ? 200 : 404, questions.get(exploration[1]));
  const createArtwork = /^\/api\/explorations\/([^/]+)\/artwork$/.exec(url.pathname);
  if (createArtwork) {
    const question = questions.get(createArtwork[1])?.question ?? '';
    if (!questions.get(createArtwork[1])?.prepared) generatedArtwork++;
    const slow = question.includes('slow illustration');
    const failed = question.includes('failed illustration') || question.includes('exhausted illustration');
    const attempts = question.includes('exhausted illustration') ? 2 : 1;
    const id = randomUUID(); const job = { id, status: failed ? 'failed' : slow ? 'working' : 'ready', attempts,
      updatedAt: Date.now() - (slow ? 35000 : 0), expiresAt: slow ? Date.now() + 180000 : null,
      canRetry: failed && attempts < 2, imagePath: failed || slow ? null : `/api/artwork/${id}/image` };
    if (question.includes('corrupt illustration')) corruptPictures.add(id);
    jobs.set(id, job); return json(202, job);
  }
  const art = /^\/api\/artwork\/([^/]+)(\/image|\/retry)?$/.exec(url.pathname);
  if (art) {
    if (art[2] === '/image') { response.writeHead(200, { 'Content-Type': 'image/png' }); response.end(corruptPictures.has(art[1]) ? Buffer.from('truncated picture') : image); return; }
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

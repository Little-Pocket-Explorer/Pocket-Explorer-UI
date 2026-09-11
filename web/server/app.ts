import express, { type ErrorRequestHandler } from 'express';
import { resolve } from 'node:path';
import { storySchema } from '../src/story.js';
import type { ShareStore } from './store.js';
import { authorize } from './ownership.js';

export function createApp(options: { store: ShareStore; ownerKey: string; publicBaseURL: string; staticDirectory?: string }) {
  if (options.ownerKey.length < 32) throw new Error('The owner key must be at least 32 characters.');
  const origin = new URL(options.publicBaseURL);
  if (origin.username || origin.password || origin.search || origin.hash || origin.pathname !== '/' ||
      !(origin.protocol === 'https:' || (origin.protocol === 'http:' && ['localhost', '127.0.0.1'].includes(origin.hostname)))) {
    throw new Error('Use an HTTPS origin or a loopback HTTP origin.');
  }
  const app = express();
  app.disable('x-powered-by');
  app.use((_request, response, next) => {
    response.set({ 'Cache-Control': 'no-store', 'Referrer-Policy': 'no-referrer', 'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY', 'X-Robots-Tag': 'noindex, nofollow',
      'Content-Security-Policy': "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self'; connect-src 'self'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'" });
    next();
  });
  app.use('/api', (request, response, next) => {
    if (request.method === 'GET' || request.method === 'HEAD') return next();
    const owner = authorize(request.get('authorization'), options.ownerKey);
    if (!owner) return response.status(401).json({ error: 'Owner authorization is required.' });
    response.locals.owner = owner;
    next();
  });
  app.use(express.json({ limit: '256kb' }));
  app.get('/health', (_request, response) => response.json({ status: 'ok' }));
  app.post('/api/shares', (request, response) => {
    const parsed = storySchema.safeParse(request.body);
    if (!parsed.success) return response.status(400).json({ error: 'This story does not match version 1 of the public format.' });
    const token = options.store.create(parsed.data, response.locals.owner);
    return response.status(201).json({ token, url: `${origin.origin}/s/${token}` });
  });
  app.get('/api/shares/:token', (request, response) => {
    const token = request.params.token;
    if (!/^[A-Za-z0-9_-]{32}$/.test(token)) return response.status(404).json({ error: 'Story not found.' });
    const result = options.store.read(token);
    if (result.status === 200) return response.json(result.story);
    return response.status(result.status).json({ error: result.status === 410 ? 'This adventure is no longer shared.' : 'Story not found.' });
  });
  app.delete('/api/shares/:token', (request, response) => {
    if (!/^[A-Za-z0-9_-]{32}$/.test(request.params.token) || !options.store.revoke(request.params.token, response.locals.owner)) {
      return response.status(404).json({ error: 'Story not found.' });
    }
    return response.status(204).end();
  });
  app.use('/api', (_request, response) => response.status(404).json({ error: 'Route not found.' }));
  if (options.staticDirectory) {
    const directory = resolve(options.staticDirectory);
    app.use(express.static(directory, { etag: false, lastModified: false, maxAge: 0 }));
    app.get(['/s/:token', '/'], (_request, response) => response.sendFile(resolve(directory, 'index.html')));
  }
  const errors: ErrorRequestHandler = (error, _request, response, _next) => {
    const status = error.type === 'entity.too.large' ? 413 : error.type === 'entity.parse.failed' ? 400 : 500;
    response.status(status).json({ error: status === 500 ? 'Sharing is temporarily unavailable.' : 'The request could not be read.' });
  };
  app.use(errors);
  return app;
}

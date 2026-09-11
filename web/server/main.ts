import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { createApp } from './app.js';
import { ShareStore } from './store.js';
const port = Number(process.env.PORT ?? 4174);
const ownerKey = process.env.OWNER_KEY ?? readFileSync(resolve('../.local/owner-key'), 'utf8').trim();
const store = new ShareStore(process.env.DATABASE_PATH ?? resolve('../.local/shares.sqlite'));
const app = createApp({ store, ownerKey, publicBaseURL: process.env.PUBLIC_BASE_URL ?? `http://127.0.0.1:${port}`, staticDirectory: resolve('dist') });
const server = app.listen(port, process.env.LISTEN_HOST ?? '127.0.0.1', () => process.stdout.write(`Pocket Explorer sharing is listening on port ${port}.\n`));
function close() { server.close(() => { store.close(); process.exit(0); }); }
process.once('SIGTERM', close);
process.once('SIGINT', close);

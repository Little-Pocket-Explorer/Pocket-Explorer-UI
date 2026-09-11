import { DatabaseSync } from 'node:sqlite';
import { randomBytes } from 'node:crypto';
import { chmodSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { storySchema, type Story } from '../src/story.js';
import type { ShareOwner } from './ownership.js';

export class ShareStore {
  private db: DatabaseSync;
  constructor(filename: string) {
    mkdirSync(dirname(filename), { recursive: true, mode: 0o700 });
    this.db = new DatabaseSync(filename);
    chmodSync(filename, 0o600);
    this.db.exec('PRAGMA journal_mode = WAL; CREATE TABLE IF NOT EXISTS shares (token TEXT PRIMARY KEY, snapshot TEXT NOT NULL, revoked INTEGER NOT NULL DEFAULT 0)');
    if (!this.db.prepare('PRAGMA table_info(shares)').all().some(column => column.name === 'owner_hash')) {
      this.db.exec('ALTER TABLE shares ADD COLUMN owner_hash TEXT');
    }
  }
  create(story: Story, owner: ShareOwner): string {
    const snapshot = storySchema.parse(story);
    const token = randomBytes(24).toString('base64url');
    this.db.prepare('INSERT INTO shares (token, snapshot, owner_hash) VALUES (?, ?, ?)').run(token, JSON.stringify(snapshot), owner.hash);
    return token;
  }
  read(token: string): { status: 200; story: Story } | { status: 404 | 410 } {
    const row = this.db.prepare('SELECT snapshot, revoked FROM shares WHERE token = ?').get(token);
    if (!row) return { status: 404 };
    if (row.revoked) return { status: 410 };
    return { status: 200, story: storySchema.parse(JSON.parse(row.snapshot as string)) };
  }
  revoke(token: string, owner: ShareOwner): boolean {
    return this.db.prepare("UPDATE shares SET revoked = 1, snapshot = '{}' WHERE token = ? AND (? = 1 OR owner_hash = ?)").run(token, Number(owner.admin), owner.hash).changes > 0;
  }
  close(): void { this.db.close(); }
}

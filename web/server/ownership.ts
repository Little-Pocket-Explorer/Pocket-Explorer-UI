import { createHash, timingSafeEqual } from 'node:crypto';

export interface ShareOwner { hash: string | null; admin: boolean }

export function authorize(header: string | null | undefined, legacyKey: string): ShareOwner | undefined {
  if (!legacyKey || legacyKey.length < 32) throw new Error('Missing owner configuration');
  const candidate = header ?? '';
  const hash = createHash('sha256').update(candidate).digest();
  const legacyHash = createHash('sha256').update(`Bearer ${legacyKey}`).digest();
  if (timingSafeEqual(hash, legacyHash)) return { hash: null, admin: true };
  // An anonymous installation can create snapshots and revoke only its own snapshots.
  if (/^Bearer pe1_[a-f0-9]{64}$/.test(candidate)) return { hash: hash.toString('hex'), admin: false };
  return undefined;
}

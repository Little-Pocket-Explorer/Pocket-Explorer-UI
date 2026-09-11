# Web and sharing verification

Validated with Node 26.8.2, TypeScript, Vitest and actual Google Chrome through Playwright.

- Type checking and the production Vite build passed.
- Ten unit/integration tests passed. They exercise the actual SQLite implementation, independent public reads, database close/reopen, random share tokens, owner authorization, unknown and revoked links, allowlisted optional details, private-field removal, malformed requests, service failure, viewer loading/retry, playback, card reversal and timer cleanup.
- Coverage: 100% of 116 executable source lines and 98.26% of 115 branches. This includes server/app.ts, server/store.ts, src/App.tsx and src/story.ts. Runtime entry wiring is covered by browser startup rather than instrumented in this unit report.
- Six Playwright tests passed in independent Chromium contexts. They verify playback, card reversal, revocation, missing/offline states, visible keyboard focus, touch targets and lack of document overflow at 375, 390, 768 and 1440 pixels.
- Browser screenshots are under design/key-screens/web-*.png.
- An actual local service runs on 127.0.0.1:4174. A saved sample story was independently read through HTTP and compared with the shared fixture.

A public HTTPS deployment and actual mobile Safari/second-device access are still pending. Local tests do not establish either. The SQLite file survives local service restarts, but deployed persistent-storage verification remains a separate acceptance item.

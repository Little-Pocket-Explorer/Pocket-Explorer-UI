# Final local verification

Date: 2026-09-11. This record covers the local prototype. Real-iPhone and public-hosting acceptance remain open in TODO.md.

| Check | Observed result |
| --- | --- |
| codex-project skill | Official quick_validate.py passed |
| Native final suite | 29 passed, 0 failed, 0 skipped |
| Swift app line coverage | 2316 / 2491 executable lines, 92.97% |
| Generic iPhone Release build | Passed without signing, not installed |
| 375pt and 390pt UI checks | Large text and map selection passed on both simulators |
| System Reduce Motion | Enabled in iOS Settings, verified, then the app's card was opened and reversed successfully |
| TypeScript type check and build | Passed |
| Web unit and service integration | 10 passed |
| TypeScript instrumented source coverage | 100% of 116 lines, 98.26% of 115 branches |
| Chromium browser suite | 6 passed, including 375, 390, 768 and 1440 pixel viewports |
| App-created sharing URL | Created by native UI, independently read by HTTP and opened by Chromium |
| Revocation | Fresh HTTP read returned 410 after native UI revocation |
| SQLite persistence | Independent store instances and complete close/reopen preserved the snapshot |
| Ignored private/generated files | Local key, SQLite, node_modules, coverage and test-results remain outside Git |

Evidence:

- Native results: /Users/haichang/tmp/pocket-final-tests.xcresult.
- Native coverage: /Users/haichang/tmp/pocket-final-coverage.json.
- App/browser bridge: /Users/haichang/tmp/pocket-app-browser-evidence.json and design/key-screens/app-created-web-story.png. The test link was subsequently revoked and the isolated test service stopped.
- Small-screen results: /Users/haichang/tmp/pocket-layout-tests-1.xcresult. Its four layout/marker runs passed. Its earlier reduced-motion test failed before its system interaction was corrected.
- Corrected reduced motion: /Users/haichang/tmp/pocket-motion-tests-2.xcresult and the successful final suite.
- Web coverage: web/coverage/coverage-summary.json, recreated by npm test.
- Review images: design/review/native-overview.png and design/key-screens.

The TypeScript coverage denominator contains server/app.ts, server/store.ts, src/App.tsx and src/story.ts. Entrypoint wiring is exercised through actual browser-test server startup. Hardware adapter branches still require real-device verification despite the overall Swift coverage threshold being met.

The local preview service on 127.0.0.1:4174 remains running. It is not a publicly available URL. Signing currently requires Xcode account configuration and a development provisioning profile. The paired iPhone connection, actual recording/camera flow, mobile Safari, human visual/VoiceOver approval and timed two-minute rehearsal are not complete.

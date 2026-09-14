# Pocket Explorer: Current Capabilities and Remaining Work

Updated 2026-09-15 after the eight-hour refinement window ended at 08:39:34 AEST. This records delivered capabilities, open acceptance and future work. TODO.md owns the latest execution evidence.

## Current delivery

TestFlight 0.1.0 (13) was published from this Mac. Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership. The Cloudflare backend and public viewer are deployed, with runtime, actual-page and revocation evidence.

The app remains the primary product. Web provides sharing without installation. Preserve the Miro cream-paper, forest-green illustrated direction and omit parental restrictions.

| Capability | Delivered behavior | Remaining acceptance or later work |
| --- | --- | --- |
| Live exploration | Text, speech and photo entry, real AI answers, persistent questions and cards | Physical recording, speaker, camera and usability acceptance remain open |
| Generated artwork | Explicit waiting states, deadlines, recovery and retries while saved cards stay readable | Provider duration remains variable. Instant generation is not promised |
| Languages | Ten UI and permission languages, explicit selection, content-language metadata and legacy compatibility | Native-speaker child-facing copy and natural speech need human review |
| Narration | Available high-quality female voices preferred, slower sentence pacing and content-language replay | Results depend on installed voices. The configured cloud TTS deployment is unavailable |
| Memories and rewards | One-day card questions and seven-day memories when the app is opened, with cards retained after wrong answers | Length-based native reading and chapter scrolling are released. Closed-app local notifications are not implemented |
| Map | Satellite map, personal card markers and optional private places | Public destinations, nearby 2 km exploration, arrival checks and exclusive collections remain later scope |
| Collection | Counts, search, categories, sorting, reversal and observation editing | Custom tags, achievements, deduplication and version history remain later work. V1 is a visual badge |
| Sharing | Revocable card/trip links, creation and revocation across page reentry, exact snapshots, scrollable large-text controls, ten-language Web and illustration fallback | Durable idempotency after process termination or a lost server response remains open. Accounts, friends, gifts and chat are deferred. Physical Safari acceptance remains open |
| Record continuity | Local journals plus server-side questions, artwork and sharing snapshots | Replacement-device recovery, complete backup/sync, export and deletion need later design. This is not a full cloud journal backup |

## Language scope

Delivered English, Simplified Chinese, Traditional Chinese, Spanish, French, German, Brazilian Portuguese, Japanese, Korean and Arabic: en, zh-Hans, zh-Hant, es, fr, de, pt-BR, ja, ko and ar.

Each iOS UI catalog contains 322 entries, with separate permission catalogs. System preference resolution, manual selection, errors, dates, original content language, Web lang/dir and Arabic RTL are implemented. UI switching does not overwrite a child's original content. This does not establish every world language or completed native-speaker and physical speech acceptance.

## Continue execution

| ID | Status | Next action |
| --- | --- | --- |
| T20.1 / B08.1 / B08.2 | Released | Preserve legacy journals, public links and language contract compatibility |
| T20.2 / T21.2 | Code released, physical review open | Verify actual voice naturalness, recording interruption, permissions and speech-unavailable fallback |
| T20.3 | Automated and screenshot checks complete, human review open | 375pt and iOS 27 large-screen sharing checks passed. Add physical-device and native-speaker acceptance. Automated results do not establish human approval |
| T21.1 / B09.1 | Released | Reproduce new stuck/recovery reports without repeating unchanged provider work |
| T21.3 / B09.3 | Web, native memory and sharing reentry fixes released | Follow the physical-device guide. Add durable cross-process sharing idempotency in the next iteration |

Each meaningful version still needs reproduction, tests, actual UI inspection, critique and independent release readback. Changed Swift lines require at least 80% coverage. Each changed TypeScript file requires at least 80% line and branch coverage.

See [the five-minute iPhone check](device-check.md) for the next physical-device pass.

## Priority reliability follow-up: interrupted publication recovery

The actual local Worker, D1 and a dropped HTTP response reproduced an unresolved boundary. The server saved the first share before its response was discarded, and the client received UND_ERR_SOCKET. Retrying created two distinct links. Revoking the second made it return 410 while the first still returned 200. Cleanup revoked both records and independently confirmed zero active shares. No production or AI requests were made. Evidence: [sharing-lost-response.json](evidence/sharing-lost-response.json).

This does not invalidate build 13's page-close/reentry correction. It establishes that continuity still lacks process and lost-response recovery. Implement the next correction as one complete App and Backend increment:

- Before the first request, persist a random publication-intent ID and exact snapshot in the app. Reuse them across reentry, relaunch and timeout recovery. Allocate a new ID only for an explicit new publication.
- Use an atomic server uniqueness constraint scoped to installation owner and request ID. The same ID and content returns the existing receipt. Conflicting content with the same ID is rejected. Disabled buttons or a lookup followed by an unconstrained insert are insufficient.
- Replaying a revoked request must not reactivate the story. Use additive fields/indexes compatible with historical shares. Replays must still validate ownership.
- Verify response loss, simultaneous duplicates, process termination/relaunch, receipt-persistence failure, payload conflict, replay after revocation, installation isolation and legacy public links. Restart the real local D1 runtime and independently check the unique row and recovered receipt.

This correction is not implemented or published. Keep it separate from build 13's completed work. A server-only deployment cannot establish end-to-end recovery.

## Evidence and limitations

Released native evidence is in docs/evidence/sharing-reentry.json, docs/evidence/memory-map.json and docs/evidence/language-photo.json, with reviews in docs/reviews/. Backend language, recovery, artwork and WebKit evidence is in the sibling repository's docs/evidence directory. TODO.md records active runs and later releases.

The post-release read-only device check lists the paired iPhone with tunnelState disconnected and ddiServicesAvailable false. The physical device remains unavailable for control. Simulator microphone crashes in Apple AudioToolbox were also reproduced on released source and are not attributed to this change. Physical microphone, camera, premium voice, VoiceOver and real Safari acceptance cannot be replaced by simulator results.

Publish TestFlight only from this Mac using Xcode 27 RC 27A266a, with [skip ci] commits and no GitHub iOS workflow. Preserve Cloudflare automatic backend deployment. Keep keys server-side, make no purchases or teammate messages, and retain the account/friend-chat deferral.

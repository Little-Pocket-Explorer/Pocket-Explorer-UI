# Pocket Explorer: Current Capabilities and Remaining Work

Updated 2026-09-15. The user authorizes continued refinement through 08:39:34 AEST. This replaces the earlier language-assessment-only plan. TODO.md owns current execution and the latest release.

## Current delivery

TestFlight 0.1.0 (12) was published from this Mac. Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership. The Cloudflare backend and public viewer are deployed, with runtime, actual-page and revocation evidence.

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
| Sharing | Revocable card/trip links, ten-language Web and immediate illustration fallback | Accounts, friends, gifts and chat are deferred. Physical iPhone Safari acceptance remains open |
| Record continuity | Local journals plus server-side questions, artwork and sharing snapshots | Replacement-device recovery, complete backup/sync, export and deletion need later design. This is not a full cloud journal backup |

## Language scope

Delivered English, Simplified Chinese, Traditional Chinese, Spanish, French, German, Brazilian Portuguese, Japanese, Korean and Arabic: en, zh-Hans, zh-Hant, es, fr, de, pt-BR, ja, ko and ar.

Each iOS UI catalog contains 321 entries, with separate permission catalogs. System preference resolution, manual selection, errors, dates, original content language, Web lang/dir and Arabic RTL are implemented. UI switching does not overwrite a child's original content. This does not establish every world language or completed native-speaker and physical speech acceptance.

## Continue execution

| ID | Status | Next action |
| --- | --- | --- |
| T20.1 / B08.1 / B08.2 | Released | Preserve legacy journals, public links and language contract compatibility |
| T20.2 / T21.2 | Code released, physical review open | Verify actual voice naturalness, recording interruption, permissions and speech-unavailable fallback |
| T20.3 | Automated and screenshot checks complete, human review open | Add iOS 27 large-screen and native-speaker checks. Automated results do not establish human approval |
| T21.1 / B09.1 | Released | Reproduce new stuck/recovery reports without repeating unchanged provider work |
| T21.3 / B09.3 | Web and native memory released | Correct the reproduced pending-sharing reentry issue, then verify and publish locally |

Each meaningful version still needs reproduction, tests, actual UI inspection, critique and independent release readback. Changed Swift lines require at least 80% coverage. Each changed TypeScript file requires at least 80% line and branch coverage.

## Evidence and limitations

Released native evidence is in docs/evidence/memory-map.json and docs/evidence/language-photo.json, with reviews in docs/reviews/. Backend language, recovery, artwork and WebKit evidence is in the sibling repository's docs/evidence directory. TODO.md records active runs and later releases.

This Mac lists a paired iPhone, but connection reads failed. Simulator microphone crashes in Apple AudioToolbox were also reproduced on released source and are not attributed to this change. Physical microphone, camera, premium voice, VoiceOver and real Safari acceptance cannot be replaced by simulator results.

Publish TestFlight only from this Mac using Xcode 27 RC 27A266a, with [skip ci] commits and no GitHub iOS workflow. Preserve Cloudflare automatic backend deployment. Keep keys server-side, make no purchases or teammate messages, and retain the account/friend-chat deferral.

# Pocket Explorer: Implementation Plan

## Azure narration integration (2026-09-15)

- DONE S1: the existing hai managed identity serves the dedicated Azure adapter. Speech S0 keeps local authentication disabled and uses a resource-scoped Speech User grant. The user approved Xiaoxiao gentle Chinese and Emma Dragon HD English. All ten language routes produced non-silent audio. The other eight voices still need human listening review.
- DONE S2: backend source 9004928 is deployed through workflow 34924912737 as Worker d6580f71-d1ca-4d7c-89ab-9a297de9aaf9 at 100%. Production synthesis, byte-identical cache replay and ownership checks passed. No Azure keys were retrieved, and service credentials stay on servers. Existing 120/18 safeguards are unchanged.
- DONE S3: final native runtime passed 108 unit tests and three narration UI tests. Changed executable-line coverage is 101/104 (97.12%), with each file above 80%. A further playback test passed and its settled screenshot was inspected. Cache expiry, corruption recovery, stop, timeout fallback and stale-response cancellation are verified.
- DONE S4: TestFlight 0.1.0 (14) was published from this Mac using source 65b3084af1e70b30b1a53fdc6685a015d64e960e. Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal membership. IPA, signing, source fingerprint, ten 322-entry catalogs and temporary-keychain removal are verified. Native commits use [skip ci], and no GitHub iOS run was started.
- REVIEW S5: physical iPhone playback, microphone, interruptions and the remaining voices' listening quality are unverified. Prepared daily recommendation audio and Vectorize knowledge reuse remain separate, unfinished work.

Evidence: docs/evidence/azure-narration.json and ~/tmp/review/pocket-release-speech-14. Native tests and uploads have ended. This iteration's fixtures on ports 4213 and 4215 were stopped and independently checked. Keep the expired heartbeat paused.

Work is isolated in ~/Worktrees/Pocket-Explorer-Backend-speech and ~/Worktrees/Pocket-Explorer-UI-speech. Preserve the primary checkouts' unpublished cache/content and design drafts. Earlier build checkpoints below are historical, and this section governs current narration delivery.

## Product decisions

The iPhone app is the primary product. The website lets recipients read shared cards and memories without installing it. Follow the [Miro board](https://miro.com/app/board/uXjVHn9F6EQ=/), preserving cream paper, forest green, original illustrations and a clear primary action. Figma Review 01 is an earlier interaction example.

Priorities are attractive child-facing UI, immediate feedback, and a satisfying exploration-to-card-to-memory-to-share journey. Preserve journals, existing public links and explicit language selection. Do not restore parental keys or approval gates. Accounts, friends and chat remain deferred.

This plan supersedes historical phase restrictions. Earlier plans and checkpoints are retained in [the plan archive](docs/history/20260915-pre-final-PLAN.md), [prompt archive](docs/history/20260915-pre-final-PROMPT.md) and [execution archive](docs/history/20260915-pre-final-TODO.md). Existing criteria in [ACCEPTANCE.md](ACCEPTANCE.md) are preserved. Automated checks do not close physical-device or human visual acceptance.

## Architecture and ownership

| Component | Location | Responsibility |
| --- | --- | --- |
| Native SwiftUI app | ios/PocketExplorer | Exploration, local journal, cards, private map, memories, speech and sharing |
| Native tests | ios/PocketExplorerTests and ios/PocketExplorerUITests | Domain, adapters, state transitions, persistence and real UI journeys |
| Public story contract | shared | Versioned public payloads and compatibility fixtures |
| Cloudflare API and Web | ../Pocket-Explorer-Backend | Real AI, artwork jobs, ownership, storage and public story viewer |
| Local TestFlight release | scripts/release and ios/fastlane | Signed archive, upload, internal distribution and source evidence |
| Miro synchronization | design/miro-sync | Existing independent design work, outside this native refinement |

Keep service credentials server-side. Installation ownership stays in Keychain. Public links exclude field photos and precise locations. Existing 120-question / 18-image safeguards stay in place. Do not purchase services or reopen payment configuration.

## Current implementation work

TestFlight 0.1.0 (14) was published locally from source commit 65b3084af1e70b30b1a53fdc6685a015d64e960e. Independent Apple reads confirm Hackathon Internal availability. IPA, signature and source checks passed. Evidence: [azure-narration.json](docs/evidence/azure-narration.json).

| ID | Outcome and concrete work | Completion evidence |
| --- | --- | --- |
| T20.1 | Extensible language selection, ten complete catalogs, locale-aware dates, RTL and content-language persistence. AppLanguage, Resources and domain records | Catalog parity, legacy decoding, language switching and actual screenshots. Native-speaker review remains open |
| T20.2 / T21.2 | Calmer narration and correct lifecycle. NarrationStyle and VoiceSession prefer available quality voices, pace sentences and stop on interruptions | Unit lifecycle tests plus actual non-silent rendering. Physical naturalness, microphone and premium voice acceptance remain open |
| T20.3 | Readable long text and accessible UI without breaking ordinary-size layouts | Small/large simulator screenshots, targeted accessibility checks and source-matched regression |
| T21.1 | Artwork never traps the child. AIClient, ArtworkCoordinator and ArtworkProgress retain saved cards, show slow/failed states, bound waits and distinguish explicit retry | Timeout, offline, relaunch, duplicate work, invalid pixels and recovery checks. Neutral keepsake art preserves a complete card when generation is unavailable |
| T21.3 | Polish question history, card reading, map, memories and sharing | Reproductions, actual UI inspection, changed-line coverage, critique and local release |
| T21.3 sharing increment | SharePublisher retains one in-flight request and exact snapshot across page reentry, persists receipts, coalesces revocation and removes completed revocations. SharePreviewView uses scrollable published controls at accessibility text sizes | Duplicate-link and revocation baselines fail. Final source passed delayed HTTP UI checks, failure/retry unit checks, French maximum-text clipping checks and live create/read/revoke, and was released in build 13 |
| T21.4 | Ship a tested increment from this Mac and independently read it back | Signed IPA, source fingerprint, Apple VALID / IN_BETA_TESTING, expected internal group and signing-keychain cleanup |

Backend B08/B09 implementation and deployment evidence remain in the sibling repository. The narration runtime 9004928 is independently deployed, and build 14 uses its private narration endpoint.

## Failure behavior

- A slow illustration must not prevent reading, saving, navigating or sharing words. The provider may remain slow, so instant generation is not promised.
- Corrupt completed artwork stops repeated automatic downloads in the current coordinator. HTTP 503 remains recoverable.
- A failed share creation clears pending state and offers an explicit retry. A failed revocation retains its receipt and permits retry.
- Closing a share sheet must not create another untracked link or cancel receipt persistence. A returning view shows the original in-flight snapshot.
- At accessibility sizes, published sharing controls scroll instead of consuming the reading area. Creation retains the existing primary button. Completion and revocation reveal the relevant state.
- Audio failure preserves reading and typing. Saved content keeps its original language when the UI language changes.
- A failed or wrong quiz response must not remove the child's card. Account recovery, full cloud journal backup and process-death share idempotency are outside the delivered guarantees.

## Verification and delivery

1. Reproduce each behavioral defect using an observable failure, screenshot or failing test.
2. Make a bounded correction and run the affected domain, integration and UI checks.
3. Inspect actual screenshots, including meaningful waiting and failure states.
4. Review the code and test design. Validate external reviewer findings before accepting them.
5. Require at least 80% changed Swift executable-line coverage per file. Backend changes require at least 80% line and branch coverage per changed TypeScript file.
6. Run appropriate regression on final application source. Keep earlier-source and final-source results distinct.
7. Commit native changes with [skip ci]. Publish only from this Mac with Xcode 27 RC build 27A266a. GitHub iOS quota is exhausted.
8. Independently verify the IPA, embedded version, signing entitlement, source hash and Apple distribution. Backend continues using its Cloudflare workflow.
9. Update TODO with precise evidence, limitations and next actions. Continue useful refinement through the agreed deadline.

Keep source frozen during tests and release. Independent UI runs need separate simulators, DerivedData and mutable HTTP fixtures. Do not substitute a debug fixture for the user's physical TestFlight installation.

## Remaining acceptance and later scope

Physical iPhone microphone, speaker naturalness, camera, VoiceOver and Safari remain unverified. The paired device previously returned CoreDevice 4000 / NWError 57. Simulator audio failures were also reproduced on released source. Preserve those limitations instead of declaring full device acceptance.

Delivered UI languages are English, Simplified Chinese, Traditional Chinese, Spanish, French, German, Brazilian Portuguese, Japanese, Korean and Arabic. These ten languages do not establish support for every world language or completed native-speaker review.

Later product work includes accounts, friend text chat, gifts, nearby public destinations, arrival checks, exclusive collections, custom tags, achievements, deduplication/version history, closed-app reminders and full backup/export/deletion. Do not add them to this refinement merely to fill time.

See [TODO.md](TODO.md) for current runs and release state, [PROMPT.md](PROMPT.md) for continuation, and [docs/next-iteration.md](docs/next-iteration.md) for the user-facing capability assessment.

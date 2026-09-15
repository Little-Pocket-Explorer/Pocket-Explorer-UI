# Pocket Explorer: Implementation Plan

## Final delivery qualification (2026-09-15)

Native qualification is now complete. Final-3 passed its actual HTTP integration and five UI tests. Across matching-source evidence, 139 unit and 25 UI checks pass, with the host-microphone case still pending. Changed executable coverage is 334/344 (97.09%), every file at least 85.37%. Actual final Home and Collection screenshots and card bounds are verified. Application source is frozen in ~/tmp/review/pocket-demo-native-tested-source.json. Next commit and upload locally, then independently verify Apple and the IPA.

This checkpoint supersedes older dated states below. Cached-answer presentation is implemented, including progressive grapheme-safe text, immediate skip, prepared narration, quiet history and lifecycle cancellation. Backend source ac49387 is deployed through successful workflow 34954953344. Independent reads confirm migration 0008, deployment 280b53b4-470c-4f0e-956b-f1f7eec69f17 and the complete real private-demo flow. Test data was revoked and unpublished. TestFlight remains 0.1.0 (16) until the next local upload is independently verified.

Native final-1 completed 139 unit tests with one optional HTTP-fixture skip and no failures, and 26 UI tests with one host-microphone skip and one camera-permission harness failure. Camera authorization is now handled explicitly and passes. Final-2 passed ten of eleven UI flows, including cached/offline narration, private demo, camera and English/German/Arabic card reading. The remaining grid assertion measured shadow bounds. The actual overflow was reproduced on the prior code and fixed with a square artwork container. Final-3 also adds an explicit card interaction shape and places the Home fade before its outer frame.

Final-3 is running in session 11762 on simulator 39E9AF25-D9B7-4783-99FF-C084F7E83C1A, with result ~/tmp/review/pocket-demo-native-final-3.xcresult. Fixture port 4235 belongs to this task. Test runner configuration requires TEST_RUNNER_POCKET_AI_FIXTURE_URL=http://127.0.0.1:4235. Native application source is frozen during the run. Earlier app-source changes after final-1 are limited to CardViews.swift and ChatHomeView.swift, so coverage for those files must come from final source. Other source files can retain final-1 evidence. Finish screenshots and coverage, commit with [skip ci], then publish locally with Xcode 27 RC 27A266a. No GitHub native build, expired heartbeat or subagent is authorized.

Studio instructions: Backend docs/demo-studio.md, Chinese copy ~/tmp/review/pocket-demo-studio.zh.md. Live evidence is ~/tmp/review/pocket-demo-live/verification.json. R2 allowance and usage report is ~/tmp/review/pocket-explorer-r2-usage.zh.md. Real-device checks and deferred event/social features remain explicit in the review.

## Current checkpoint: prepared-answer presentation and private demo (2026-09-15)

This checkpoint supersedes historical release and allowance statements below. Daily discovery is released: Backend d38080a through workflow 34946507042 and native c16eb46 as TestFlight 0.1.0 (16), independently VALID and IN_BETA_TESTING in Hackathon Internal. Build 16 does not include the new local demo or visual changes. Use Xcode 27 RC 27A266a for subsequent local native releases. No native release is currently running.

The user now requests identical presentation for cached and live answers, including progressive text and narration. The prepared-question path currently opens an existing record and returns before starting speech. Add a shared, skippable text reveal, start narration only for an explicitly opened discovery or newly answered question, preserve quiet history viewing, respect Reduce Motion and VoiceOver, and stop work on dismissal/backgrounding. Reuse prepared audio without generating it again. Verify a failing baseline, cached/offline playback, live playback, replay, saving and accessibility.

Private demo code is implemented locally but not deployed. Six native DemoTests pass. Backend has 182 passing checks and one existing integration test timeout under concurrent builds, so full acceptance is pending. New Studio frontend coverage, native demo UI checks, live privacy verification and release remain required. Additive migration 0008 is local only. Do not claim demo availability yet.

Miro App Suggestion and IOS App View were refreshed. Marketing main 87a1be5 supplies 13 backgrounds, three event scenes and six card illustrations. One backdrop and six Studio samples are integrated locally. Card fill, corner clipping and equal-height refinements await screenshot verification. Event flows, real accounts and friend chat are not implemented. Preserve the source images and original Figma baseline. The new Miro screenshot exports are thumbnail-limited, so pixel-exact review is not claimed.

Next: verify the prepared-answer baseline, implement and test the shared presentation, then finish demo/visual acceptance and release through the established channels. Keep all unfinished work and evidence. Native publishes from this Mac with [skip ci], Backend through its workflow. No expired heartbeat or subagent is started.

## Private demonstration content (2026-09-15)

The user approved author-prepared questions, answers and card illustrations with explicit priority, available only in an intentionally enabled demo mode. They accepted private single-use links that authorize specific phones. Ordinary users must have no demo entry. Follow the Backend docs/plans/private-demo-mode.md plan. This is the next implementation task, separate from the completed daily-discovery source. No demo feature is implemented yet.


## Azure and Cloudflare policy amendment (2026-09-15)

The user clarified that Azure API capacity is effectively unlimited for this project while Cloudflare resources remain constrained. This supersedes historical instructions preserving the 120-question, 18-image and 200,000-speech-character Azure caps. Use explicit `unlimited` policies and retain the existing usage ledger, actual provider failures, deadlines and retry controls.

Cloudflare protections remain separate: request and installation limits, six-hour scheduling with at most three new topics daily, queue concurrency two, bounded retries, caching and asset-size validation. Workers AI embeddings retain 1,000 daily and 10,000 cumulative reservations. These workload controls do not establish a US$10 account-level billing hard stop.

Reservations must be atomic across every applicable bucket. Rejection before a provider call consumes no other allowance, while attempted calls remain counted. Local implementation and regression are in progress. Live configuration remains unchanged, preparation is paused, qualified inventory is 10/12 and TestFlight remains 0.1.0 (14). Next verify policy changes, finish qualified content, deploy through the existing Backend workflow and upload native locally with [skip ci].


## Implementation started (2026-09-15)

The user approved implementation. The active worktree is /Users/haichang/Worktrees/Pocket-Explorer-UI-daily-discovery. B10.0 is in progress. Integrate from current origin/main, preserve existing narration, then implement and verify the continuous supply plan. Earlier planning-only statements are historical. No expired timer is resumed.

## Continuous content supply plan (2026-09-15)

The user requires continuous backend content replenishment before periodic client activation can work. The detailed [implementation plan](../Pocket-Explorer-Backend/docs/plans/daily-discovery-pipeline.md) owns supply cadence, package verification, immutable versions, native activation, Vectorize reuse and acceptance. This is the newest planning checkpoint and supersedes older task ordering below. Build 14 narration remains the released baseline. No runtime change or publication is part of this planning turn.

Working defaults: reconcile every six hours, admit at most three fresh canonical topics per UTC day, target 60 eligible topics per language/age slice with priority below 30, and begin with at least 12 qualified topics per slice. Keep a freshness path even when inventory is healthy. The client caches up to 60 and persists three daily selections. Counts and remaining provider capacity require B10.0 verification before preparation.

Backend scheduling and publication are core deliverables. The library must have complete text, illustrations and pre-generated narration before an item is recommended. Published audio is durable content rather than a disposable TTS-cache entry. Preserve exact prepared reads, stable daily activation, known-withdrawal handling, immutable collected versions, all ten languages and the accepted Vectorize route.

Dependency order: B10.0 integration/capacity, B10.2a content model, B10.2b scheduled supply, B10.2c validated multilingual publication, T22/B10.3 native activation. B10.4a semantic reuse uses the same model, and B10.4b feeds validated generic demand into preparation. T22/B10.5 verifies both complete paths, including two actual scheduled events without app traffic. Existing cumulative allowances remain unchanged.

## Completed isolated narration release (2026-09-15)

The user approved hai managed identity, Xiaoxiao gentle Chinese and Emma Dragon HD English. Backend source 9004928 is deployed through workflow 34924912737. Native source 65b3084 was published locally as TestFlight 0.1.0 (14). Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal. IPA, signing, ten 322-entry catalogs and unchanged application source are verified. Final runtime tests passed 108 unit and three narration UI checks at 97.12% changed executable-line coverage, and a settled playback screenshot was inspected. UI evidence commit f2e3880 and Backend evidence commit 89f97bb are pushed to main. No GitHub iOS build was started. Test fixtures 4213 and 4215 are stopped, and the expired heartbeat remains paused.

Current release evidence and guides are in ~/Worktrees/Pocket-Explorer-UI-speech and ~/Worktrees/Pocket-Explorer-Backend-speech. Physical iPhone playback, microphone and interruptions remain unverified. Preserve this checkout's unpublished Vectorize/content and design drafts. Prepared daily recommendation audio and semantic reuse remain unfinished and are not part of build 14. Merge the verified narration main changes carefully before resuming those drafts. Earlier authentication proposals below are historical.

## Current Vectorize decision (2026-09-15)

The user selected Cloudflare Vectorize as the preferred semantic-cache implementation. The [accepted design](../Pocket-Explorer-Backend/docs/research/semantic-cache-vectorize.md) supersedes the earlier exact-only first release recommendation. Vectorize retrieves candidates, Workers verifies reuse, D1 owns content versions and eligibility, and R2 holds illustrations. Prepared daily recommendations continue to read complete packages directly.

[Research](docs/research/daily-discoveries.md) is complete and updated. Next evaluate multilingual embeddings, false hits and index consistency before runtime integration. Existing local drafts remain incomplete and unverified. This checkpoint updates the design only, without a commit, deployment or TestFlight publication. The older timed work and heartbeat remain closed.

## Daily discoveries and reusable knowledge (2026-09-15)

The user requests a larger cached recommendation bank, three stable daily selections, prepared answers and illustrations, and long-lived reuse across matching questions. This is new implementation work. The previous timed refinement remains closed and its heartbeat remains paused.

- T22/B10.1 DONE: primary-source research, cache boundaries and the preferred Vectorize design are recorded.
- T22/B10.2 NEXT: server-owned prepared multilingual bank and immutable artwork, with no provider call when opened.
- T22/B10.3 NEXT: persistent native bank, daily selection and background refresh. Freeze the day's selection, including across relaunch and successful bank downloads. Keep typed, spoken and photographic exploration available.
- T22/B10.4 NEXT: exact fast path plus Vectorize semantic candidates and complete-answer verification, following the [design](../Pocket-Explorer-Backend/docs/research/semantic-cache-vectorize.md). Scope by language, validated age applicability and policy revision. Preserve content versions, separate personal records, bounded expiry and generation coordination.
- T22/B10.5 NEXT: meaningful reproductions, actual local D1/R2 integration, changed-file coverage, native UI and persistence tests, written critique and release verification. Backend delivery uses its workflow. Native delivery remains local with [skip ci].

Preserve existing data, private keys, 120/18 safeguards, ten languages, Miro design, untracked design/miro-sync and old public links. Do not revive the earlier eight-hour timer. Do not extend into accounts, friends, chat or unrelated sharing fixes.

Updated 2026-09-15. The authorized eight-hour refinement window ended at 08:39:34 Australia/Sydney, and the five-minute checkpoint is paused. Outstanding acceptance remains open.

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

TestFlight 0.1.0 (13) was published locally from source commit 339ff9e5832fb4cc8fa24cde30aa2f72a811e581. Independent Apple reads confirm Hackathon Internal availability. IPA, signature and source checks passed. Evidence: [sharing-reentry.json](docs/evidence/sharing-reentry.json).

| ID | Outcome and concrete work | Completion evidence |
| --- | --- | --- |
| T20.1 | Extensible language selection, ten complete catalogs, locale-aware dates, RTL and content-language persistence. AppLanguage, Resources and domain records | Catalog parity, legacy decoding, language switching and actual screenshots. Native-speaker review remains open |
| T20.2 / T21.2 | Calmer narration and correct lifecycle. NarrationStyle and VoiceSession prefer available quality voices, pace sentences and stop on interruptions | Unit lifecycle tests plus actual non-silent rendering. Physical naturalness, microphone and premium voice acceptance remain open |
| T20.3 | Readable long text and accessible UI without breaking ordinary-size layouts | Small/large simulator screenshots, targeted accessibility checks and source-matched regression |
| T21.1 | Artwork never traps the child. AIClient, ArtworkCoordinator and ArtworkProgress retain saved cards, show slow/failed states, bound waits and distinguish explicit retry | Timeout, offline, relaunch, duplicate work, invalid pixels and recovery checks. Neutral keepsake art preserves a complete card when generation is unavailable |
| T21.3 | Polish question history, card reading, map, memories and sharing | Reproductions, actual UI inspection, changed-line coverage, critique and local release |
| T21.3 sharing increment | SharePublisher retains one in-flight request and exact snapshot across page reentry, persists receipts, coalesces revocation and removes completed revocations. SharePreviewView uses scrollable published controls at accessibility text sizes | Duplicate-link and revocation baselines fail. Final source passed delayed HTTP UI checks, failure/retry unit checks, French maximum-text clipping checks and live create/read/revoke, and was released in build 13 |
| T21.4 | Ship a tested increment from this Mac and independently read it back | Signed IPA, source fingerprint, Apple VALID / IN_BETA_TESTING, expected internal group and signing-keychain cleanup |

Backend B08/B09 implementation and deployment evidence remain in the sibling repository. Runtime 5dac559 is independently deployed. This native increment does not need a backend change.

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

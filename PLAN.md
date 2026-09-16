# Pocket Explorer: Implementation Plan

## Accepted submission scope and qualification checkpoint (2026-09-16)

The owner explicitly approved preserving all features and submitting at Apple's current calculated age ratings: 13+ in 171 territories, 16+ in Australia, Vietnam and Brazil, and 15+ in Korea. FOUR_PLUS in older API records describes operating systems before version 26. Do not remove public discovery or social functionality to lower the rating. Kids Category enrollment is not requested for this release. The age rating does not replace applicable privacy obligations.

Epic KWS is deferred by the owner and removed from the release runtime. Existing family PIN, separate explicit Azure AI data permission, withdrawal, local-only speech recognition and account deletion are retained. A PIN is not verified parental consent. Previous KWS checkpoints are historical and superseded.

Backend/Web now pass 319 tests in 45 files with every-file coverage gates, 99.18% lines and 94.13% branches. Production build and an actual Chromium Worker/D1 create-unlock-grant-withdraw-delete flow pass. Browser activation and account deletion are implemented. Evidence: ~/tmp/review/pocket-app-store-release/no-kws-*.

Native integrated baseline has 190 passing units and 23 passing main UI journeys. Additional daily background refresh, invalid demo recovery, complete private-demo flow and speech-denial typing recovery pass. The corrected audio callback test passes. All 15 changed product Swift files pass same-source 80% line coverage, with a minimum of 81.75%. Final Chromium and WebKit regressions each pass 37 tests with one explicit fixture skip. All five artwork/actual-account flows pass, and the actual-account flow also passes WebKit with its mobile screenshot inspected.

The owner confirmed all supplied artwork and example content may be published. Mainland ICP availability is awaiting the owner. Version 1.0 and final review instructions are prepared. Next: finish Apple declarations, deploy Backend through its workflow, upload native 1.0 locally, attach the build and submit review. Publication is authorized. TestFlight remains 0.1.0 (20), App Store 1.0 is not submitted, and no release commit or production deployment has occurred. Do not start agents, timers or native GitHub builds.

## First-release scope correction (2026-09-16 21:21 AEST)

The owner explicitly deferred Epic KWS and asked to proceed with publication. Do not request Epic login or treat KWS approval as a release prerequisite. Preserve existing family PIN, explicit cloud AI permission and withdrawal, deletion, accurate provider disclosure and teammate features. The KWS experiment is archived outside the release worktrees at ~/tmp/review/pocket-app-store-release/kws-deferred-20260916 with file hashes. Its eleven dedicated files, runtime routes, page, migration and deletion dependencies are removed from the release candidate. No production deployment occurred.

Current work: complete browser grant activation using the existing family API, then finish native qualification and Apple declarations. Deploy Backend via its workflow and upload native 1.0 locally. App Store remains unsubmitted and TestFlight remains 0.1.0 (20). Deferring a vendor does not turn a PIN into verified parental consent or justify inaccurate declarations. Earlier KWS checkpoints below are historical and superseded.


## KWS implementation sequence (2026-09-16)

The accepted design and official API findings are maintained in native docs/app-store/parent-verification.md. K1 local callbacks, verification state, consent records and the ten-language parent page are qualified. K2 authenticated provider initiation and configuration await Epic login. K3 native/Web activation, status recovery, withdrawals and complete upload-scope enforcement follow the real contract. K4 real provider qualification, retention/contact disclosures and production approval precede the final native binary and Apple submission. Preserve TestFlight 20 compatibility until the coordinated transition. No partial gate deployment is authorized as a substitute for a usable client flow.

## App Store release boundary (2026-09-16)

The owner accepted KWS first-use verification on 2026-09-16. Implementation and account configuration are now in progress. Its eventual verification boundary must precede profile, social, location and AI uploads. Keep child profile drafts local until verification. Coordinate the server change with old TestFlight 20 and Web rather than deploying a gate alone. Track the saved Apple drafts and current coverage gaps in the latest TODO and native docs/app-store/release-readiness.md. No public review is submitted.

## Active: first App Store release (2026-09-16)

Provider clarification, 2026-09-16: the owner confirms Azure AI for question answering, image generation and narration. Treat the previous reasoning-provider question as answered. Use the updated Backend docs/ai-service-evidence.md and native release-readiness.md. Keep the observed Cloudflare embedding processing in the privacy description. No runtime endpoint changes follow from this documentation update. Parent verification, Web compatibility, qualification and Apple declarations remain active.

Current draft and qualification evidence are in the latest TODO and native docs/app-store/release-readiness.md. Native and Backend versioned AI permission are implemented locally, with final UI regression and broader coverage still pending. Web permission compatibility, parent verification, final provider disclosure and Apple declarations remain unfinished. No review has been submitted. See native docs/app-store/parent-verification.md and Backend docs/ai-service-evidence.md.

The user authorized public App Store publication. Work in /Users/haichang/Worktrees/Pocket-Explorer-UI-app-store-release, branch hai/app-store-release, from 257b1d4. Follow docs/plans/app-store-release.md, AS1-AS5. Backend worktree is /Users/haichang/Worktrees/Pocket-Explorer-Backend-app-store-release, from 732b6e6. Do not resume completed navigation work or old timers. Keep local-only native publishing and ten languages.

- AS1 AUDITED: Apple confirms build 19 is APP_STORE_ELIGIBLE. Existing App Store 1.0 has no attached build. English listing text, free pricing and three screenshots are saved. Owner confirmed free download, no IAP, ages 6-8 with a parent, and a non-commercial hobby project for non-trader declaration.
- AS2 IN_PROGRESS: correct missing AI data disclosure, remote-family deletion, public privacy and support pages. Social report/block already exist.
- AS3 IN_PROGRESS, AS4-AS5 PENDING: store materials, declarations, qualification, local binary and submission. Draft listing and free pricing are saved. Review submission remains pending.
- Evidence: ~/tmp/review/pocket-app-store-release. Current published native runtime remains build 19. Prior release checkpoints below are historical.
## Teammate TestFlight integration (2026-09-16)

- T20 DONE: Pull upstream main, preserve independent App Store work, correct reproduced merge and resource failures, and qualify the three-tab navigation with actual fixture services.
- Acceptance: successful native build, navigation/memory/profile/social and language checks, at least 80% coverage per changed Swift file, and independent production asset verification.
- Delivery: commit the integration corrections with [skip ci], publish from this Mac, verify the signed IPA and Apple VALID / IN_BETA_TESTING assignment. Keep physical-device acceptance explicit.

Navigation and the new identity were released locally as TestFlight 0.1.0 (19) on 2026-09-16. Independent reads confirm VALID / IN_BETA_TESTING in Hackathon Internal. Native source is f184e8674c7509a5d34c4366811b50e5dbb11db2. Qualification has 266 latest per-test passes, four explicit skips and current-hash coverage for all 30 changed product Swift files, minimum 88.27% and aggregate 95.53%. Physical-device and human visual acceptance remain separate. Do not repeat the completed release or resume expired timers.

## Delivered navigation and Jacky journey (2026-09-16)

The user prioritizes Jacky's demo flow and reports repeated backtracking during physical use. Follow [the navigation plan](docs/plans/jacky-navigation.md), P40 through P45, including the added app identity redesign. Proceed independently without waiting for teammate assignments. The current task supersedes historical continuation-only wording below. Preserve existing product rules, ten languages, data and permissions. Reuse the deployed Backend APIs where possible. Acceptance includes the whole journey and everyday detours, not only isolated feature tests.

## Verified roadshow delivery (2026-09-16 04:17 AEST)

TestFlight **0.1.0 (18)** is independently VALID and IN_BETA_TESTING in Hackathon Internal, published from this Mac. IPA source is d8d4114b9471b2e537d6d3ae24905e1523e8ac41, including upstream 906e743. Signature, tested runtime source and ten 542-entry catalogs are verified. External distribution is not verified.

Backend aafd4fe is deployed through successful workflow 34998228931. Production acceptance passes 81 requests. Backend tests pass 246 checks, with 34 Chromium and 34 WebKit scenarios. All 60 Marketing packages, 66 assets and 60 Vectorize records are independently verified.

Native qualification has 248 latest per-test passes, four gated skips and no unresolved failure across full and targeted runs. All 40 changed Swift files meet exact-hash coverage, minimum 89.28% and aggregate 96.24%. This is not a claim of one passing full final-source invocation.

Tests, release processes, owned fixtures and continuous simulated location have ended. The temporary signing keychain is removed. No native GitHub build ran. Preserve old checkpoints as history, not pending instructions. Physical iPhone microphone, camera, headphones, interruptions and listening acceptance remain open. Commercial billing is disabled. See the UI docs/evidence/pitch-native.json and docs/reviews/pitch-native-integration.md for evidence.


## Active roadshow implementation (2026-09-15)

Qualification and local publication are complete. Follow the verified delivery above and docs/evidence/pitch-native.json.

The eight roadshow slides now govern conflicting product decisions. The user explicitly requests all described product features this iteration. Follow docs/plans/pitch-alignment.md and the active TODO checkpoint. Parent controls, correct-answer unlocks, personalized exploration, event/location discovery, evolving cards, real friendships and text chat are in scope. Preserve old cards and links, ten languages, live AI, prepared content and private demo isolation.

Proceed through the complete acceptance matrix without treating an increment as overall completion. Update TODO after implementation and verification. Use the new hai/pitch-alignment worktrees. Native publishing is local with [skip ci], Backend through its workflow. Do not restart expired timers. Commercial transaction scope awaits the user's answer.

The earlier checkpoints and exclusions below are historical. Build 18 is the latest independently verified release for this iteration.

## Current delivery: cached-answer presentation and private demo (2026-09-15 20:28 AEST)

This is the current state. Older dated checkpoints below are historical and must not trigger another release or resume expired automation.

- TestFlight **0.1.0 (17)** is independently VALID and IN_BETA_TESTING in Hackathon Internal. Native source: bd75c0cea853b97912b989bd9b22f08a394d9ad9. Published from this Mac using Xcode 27 RC 27A266a, with [skip ci]. External distribution of this build is not verified.
- Cached and new answers use progressive text and automatic narration. Text can be expanded immediately. Prepared answers, illustrations and audio remain reused. History stays quiet. Backgrounding, dismissal, Reduce Motion and VoiceOver have explicit behavior. Narration is not word-synchronized highlighting.
- Private Studio is live at https://pocket.changhai.me/studio. Backend source ac493873a30d4c12341752c1fcd123ae753e2fa4 deployed through successful workflow 34954953344. Migration 0008 and deployment 280b53b4-470c-4f0e-956b-f1f7eec69f17 are independently verified. Exact authored text, original art, real Azure audio, one-use activation, privacy, sharing and revocation pass online. Test shares and phones were revoked, and the sample draft was unpublished.
- Native qualification passes 139 unit and 25 UI checks across matching-source runs. The host-microphone case remains a physical-device check. Changed executable coverage is 334/344 (97.09%), with every changed file at least 85.37%. Backend passes 188 checks, 26 Chromium, 26 WebKit and four artwork tests, including every-file 80% line/branch gates.
- Visual review reproduced and corrected overflowing collection art. Final cards have 20pt outside margins, a 14pt gap and equal heights. A matching interaction shape keeps taps inside each card. Home fades now follow the image bounds. Final screenshots are reviewed. Miro and Marketing source details are recorded in the native docs/design/miro-updates-20260915.md.
- Independent IPA reads confirm signing, build 17, all ten 346-entry catalogs, custom app activation scheme and unchanged tested source. The temporary signing keychain is removed. This task's fixture on port 4235 is stopped. No release, test, heartbeat or agent remains running.

Use Backend docs/demo-studio.md for organizer instructions and docs/reviews/private-demo-20260915.md for limitations. Local Chinese reviews are ~/tmp/review/pocket-demo-studio.zh.md and ~/tmp/review/pocket-demo-review.zh.md. The R2 report at ~/tmp/review/pocket-explorer-r2-usage.zh.md was refreshed at 20:24 AEST, recording 142.83 MB and 142 objects from a delayed snapshot, 144 Class A and 274 Class B operations, with estimated R2 charges still zero.

Remaining acceptance: real iPhone microphone, camera, listening quality and interruptions. Event/social mock flows, full map/settings reference restyling, accounts and friend chat remain deferred. The new Miro screenshots were thumbnail-limited, so pixel-exact reproduction is not claimed. Further development should start from this delivered baseline and the user's next priorities.

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

## App Store privacy permission increment (2026-09-16)

Implement versioned explicit cloud AI data permission before submission. Backend grants require the existing parent session and a reviewed revision. Withdrawal requires only the installation credential, takes precedence over stale grants, and blocks new model, artwork and speech jobs. Native transport checks run before upload, remember withdrawal while offline and retry on launch. Keep prepared content, saved records and local playback usable. Test the actual D1/R2 state, client request bodies, queue redelivery, concurrent grants and withdrawal, ten-language controls, and account deletion. This increment does not by itself resolve the separate children's-data or provider-disclosure requirements.

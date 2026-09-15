# Pocket Explorer: Current Execution State

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

## Active verification and deployment (2026-09-15 19:53 AEST)

The latest request is implemented locally: cached discoveries now use the same progressive text and automatic narration as new live answers. Quiet history remains quiet. A failing prepared-audio UI baseline was reproduced, then corrected. Four presentation unit tests and two actual UI flows pass, including offline playback and stopping in background. A stale SwiftUI task race was found and fixed with generation capture. All ten languages include the new full-answer action.

Demo logic has six passing unit tests. Actual custom-scheme UI tests verify one-use activation, no normal entry, ordered offline content, separate daily choices, disabled autoplay in history and revoked access. Early UI failures were diagnosed as test launch reset arguments and a switch row-center tap. The corrected actual-control flow passes. Profile and Home screenshots were inspected. Physical-device checks remain pending.

Backend ac49387 is committed and pushed to main after 188 tests, every-file coverage gates, 26 Chromium, 26 WebKit and four artwork browser tests, plus production build and Worker dry run. Its workflow deployment and independent live verification are next. Native final-source regression is running in session 82154, dedicated simulator 39E9AF25-D9B7-4783-99FF-C084F7E83C1A, result ~/tmp/review/pocket-demo-native-final-1.xcresult. Keep native application source frozen until it finishes. Snapshot: ~/tmp/review/pocket-demo-native-final-source.json. Fixture 4235 is session 82791.

Next: finish native regression and changed-line coverage, inspect multilingual/card screenshots, verify deployed Backend demo upload/publication/activation/privacy, and publish native locally with Xcode 27 RC 27A266a. TestFlight remains 0.1.0 (16). New visuals and demo are not released yet. The refreshed Miro/Marketing mapping is docs/design/miro-updates-20260915.md and the Chinese review is ~/tmp/review/pocket-explorer-miro-updates-20260915.zh.md. The Home hero has top/bottom fading, but side edges remain visible against the new backdrop and should be refined after this run with a focused screenshot check.

## Current checkpoint: prepared-answer presentation and private demo (2026-09-15)

This checkpoint supersedes historical release and allowance statements below. Daily discovery is released: Backend d38080a through workflow 34946507042 and native c16eb46 as TestFlight 0.1.0 (16), independently VALID and IN_BETA_TESTING in Hackathon Internal. Build 16 does not include the new local demo or visual changes. Use Xcode 27 RC 27A266a for subsequent local native releases. No native release is currently running.

The user now requests identical presentation for cached and live answers, including progressive text and narration. The prepared-question path currently opens an existing record and returns before starting speech. Add a shared, skippable text reveal, start narration only for an explicitly opened discovery or newly answered question, preserve quiet history viewing, respect Reduce Motion and VoiceOver, and stop work on dismissal/backgrounding. Reuse prepared audio without generating it again. Verify a failing baseline, cached/offline playback, live playback, replay, saving and accessibility.

Private demo code is implemented locally but not deployed. Six native DemoTests pass. Backend has 182 passing checks and one existing integration test timeout under concurrent builds, so full acceptance is pending. New Studio frontend coverage, native demo UI checks, live privacy verification and release remain required. Additive migration 0008 is local only. Do not claim demo availability yet.

Miro App Suggestion and IOS App View were refreshed. Marketing main 87a1be5 supplies 13 backgrounds, three event scenes and six card illustrations. One backdrop and six Studio samples are integrated locally. Card fill, corner clipping and equal-height refinements await screenshot verification. Event flows, real accounts and friend chat are not implemented. Preserve the source images and original Figma baseline. The new Miro screenshot exports are thumbnail-limited, so pixel-exact review is not claimed.

Next: verify the prepared-answer baseline, implement and test the shared presentation, then finish demo/visual acceptance and release through the established channels. Keep all unfinished work and evidence. Native publishes from this Mac with [skip ci], Backend through its workflow. No expired heartbeat or subagent is started.

## Private demonstration content (2026-09-15)

The user approved author-prepared questions, answers and card illustrations with explicit priority, available only in an intentionally enabled demo mode. They accepted private single-use links that authorize specific phones. Ordinary users must have no demo entry. Follow the Backend docs/plans/private-demo-mode.md plan. This is the next implementation task, separate from the completed daily-discovery source. Demo implementation is now local and remains under verification.

Daily backend source d38080a is independently deployed through workflow 34946507042. Compressed catalog ETags, ten language catalogs, cross-installation prepared text/image/audio reuse, ownership and sharing checks pass. Production is the sole Queue consumer, six-hour Cron is verified, and preparation was resumed with paused=0 read back. Twelve topics and 120 language packages meet the launch inventory.

The first local upload, build 15, was rejected by Apple with 90534 because Xcode 27 Beta 1 (27A5194q) was selected. The installed RC (27A266a) has been selected explicitly for build 16. Upload succeeded and Apple processing is pending in session 33368. Keep ios, shared, scripts and HEAD frozen until the local release exits. Do not claim build 16 is available before independent Apple readback.


## Azure and Cloudflare policy amendment (2026-09-15)

The user clarified that Azure API capacity is effectively unlimited for this project while Cloudflare resources remain constrained. This supersedes historical instructions preserving the 120-question, 18-image and 200,000-speech-character Azure caps. Use explicit `unlimited` policies and retain the existing usage ledger, actual provider failures, deadlines and retry controls.

Cloudflare protections remain separate: request and installation limits, six-hour scheduling with at most three new topics daily, queue concurrency two, bounded retries, caching and asset-size validation. Workers AI embeddings retain 1,000 daily and 10,000 cumulative reservations. These workload controls do not establish a US$10 account-level billing hard stop.

Reservations must be atomic across every applicable bucket. Rejection before a provider call consumes no other allowance, while attempted calls remain counted. All 177 backend tests and every changed-file 80% line/branch gate passed, and the production build passed. The old accounting behavior was reproduced by the same failing regression before the atomic fix. Validation deployment b9f676dc-13f2-4270-b3ca-2e278dfbc7c7 independently reports all three Azure policies as unlimited. Preparation is resumed with two corrected ten-language drafts under independent qualification. Inventory is still 10/12 and TestFlight remains 0.1.0 (14). Finish qualification, deploy production through its existing workflow and upload native locally with [skip ci].


## Current release checkpoint (2026-09-15 17:06 AEST)

The avatar alignment fix and implementation verification are complete locally. Release remains blocked on launch inventory and the unchanged provider allowances. Nothing in this checkpoint claims a new production or TestFlight release.

| Task | Status | Evidence or remaining condition |
| --- | --- | --- |
| B10.0 / B10.1 | VERIFIED | Current narration main integrated in isolated worktrees, research complete, actual capacity and embedding/index inspected |
| B10.2a | VERIFIED IN VALIDATION | Additive 0006/0007 D1 migrations, immutable R2 packages, publication and withdrawal |
| B10.2b | VERIFIED IN VALIDATION | Actual Cron admitted and published coral-animals and petroglyphs without app visits. Six-hour cadence restored |
| B10.2c | BLOCKED | Ten qualified themes, 100 language packages, every one of 140 slices at 10/12. No failed batch counted |
| T22/B10.3 | VERIFIED LOCALLY | Stable daily activation, background-entry download, offline bundle, versioned registration and sharing. Publication pending |
| B10.4a | VERIFIED IN VALIDATION | 300-case multilingual acceptance, including 40 actual model decisions. No false reuse observed in this bounded sample |
| B10.4b | VERIFIED LOCALLY | Routed-demand privacy classification, admission and independent source qualification tests. A production user-demand run is not claimed |
| T22/B10.5 | RELEASE BLOCKED | Final tests, coverage and visual review complete. Production workflow, Queue handover, local TestFlight and live readback remain |

- Backend coverage-11: 168 tests passed, all per-file line/branch gates passed. Build and earlier Chrome 24, WebKit 24 and artwork four-case browser checks passed.
- Native foundation-3: 129 unit and 20 UI passed, zero failures, one explicit host-microphone skip. Supplemental background-entry: 20 content unit and two UI passed, no skips. App code gained only a DEBUG background test trigger between these runs. Changed executable coverage: 477/481 (99.17%), every changed file at least 90%, with App coverage taken only from its latest source.
- Actual screenshots inspected: English, Simplified Chinese and Arabic Home and bundled artwork, withdrawn collected card, largest-text Arabic Memory, camera and Home after background refresh. The avatar now uses a centered transparent circle and consistent 44pt bounds. Six built PNGs independently match source hashes, and sixty localized bundle assertions pass.
- Runtime warning remains during iOS 27 camera DismissButton animation: Invalid frame dimension, without source location. Composer recovery passes and no corresponding visual failure was observed. AVAudioSession activation warnings remain. Physical-device microphone/camera/audio, actual OS scheduling and 200ms/500ms latency targets remain unverified. Bounded cl/Opus review returned no usable result.
- Isolated Worker pocket-explorer-content-validation deployment 13 retains the content Queue consumer and six-hour Cron. Independent status readback confirms paused=1, revision=10, no preparing backlog, usage 118/120 questions, 18/18 images, 21376/200000 speech characters and 142 embeddings. Do not reset or raise limits. Formal production CONTENT_ENABLED and SEMANTIC_ENABLED remain false.
- Production enablement preflight reads actual D1 and rejects the current 10/12 inventory. Account-credential resource checks passed. The GitHub workflow token remains unverified for the new resource operations.
- No feature commit/push, production workflow run or new native upload occurred. TestFlight remains 0.1.0 (14). Runtime fixtures and tests have been stopped after verification. The older port 4197 is unrelated and was not touched. No old heartbeat or subagent was started.

Next: obtain an explicit decision on the exhausted test allowances or the twelve-topic launch criterion, then qualify remaining content, transfer the Queue consumer through the documented handover, publish Backend through its workflow and publish iOS locally with [skip ci]. Do not imply that automatic replenishment continues while paused or after its cumulative allowance is exhausted. Recheck Xcode build immediately before publication, since this run used 27A5194q rather than the older recorded build.

Evidence: ~/tmp/review/pocket-daily-plan-20260915, native-qualified-coverage.json, native-foundation-3-summary.json, native-background-entry-summary.json, status-checkpoint-readback.json and launch-preflight.json. Portable native evidence and the written review are in the UI repository. The Chinese review is ~/tmp/review/pocket-explorer-daily-discovery-review.zh.md.

## Active implementation checkpoint (2026-09-15 16:36 AEST)

Implementation and release qualification continue. No feature commit, main workflow deployment or TestFlight upload has occurred. TestFlight remains 0.1.0 (14).

- Backend coverage-10 passed 167 tests and every 80% per-file line/branch gate. Latest production build passes. Coverage includes editorial retry and reused-illustration review corrections. Browser evidence remains Chrome 24, WebKit 24 and artwork four cases.
- Isolated validation deploy 13 is active. Shared D1 migrations 0006/0007, Queue and Vectorize are verified. Formal feature flags remain false. Seven complete ten-language topics are published. Three further batches reached publish with all narration ready. Inspect final-stage recovery if their five-minute leases expire. Latest usage: 118/120 questions, 18/18 images and 21,376/200,000 speech characters. Do not reset or increase allowances. At most ten existing qualified candidates can currently reach publication, so the twelve-topic launch gate is still open.
- Two real scheduled admissions, coral-animals and petroglyphs, reached complete publication without app activity. The configured isolated Cron is restored to six hours, independently read back. No new schedule or agent was started.
- Six real ten-language foundation packages and hash-checked 1024px illustrations were exported to ~/tmp/review/pocket-daily-plan-20260915/foundation. The contact sheet was visually inspected. These files have not yet been copied into native resources because the native regression is still running.
- Native-regression-2 remains active in session 15892, simulator 976BB247-A168-40D2-98C9-6F0154A7E7B3. Preserve native source until completion. Confirmed failures: Arabic largest-text Memory test targets a partly obscured button, and HomeEntry/Prototype camera dismissal use an identifier renamed in iOS 27. Fix targeting and rerun after reading failure screenshots. Do not suppress failures.
- Remaining native behavior: show a correction notice on collected withdrawn content, distinguish prepared_content_unavailable from request_conflict, persist permanent registration failure and stop its periodic retry. Add real bundled first-install offline coverage and inspect actual artwork in the app. Fixture-driven UI flows must explicitly isolate their injected bank from the real foundation bundle.
- A bounded read-only cl/Opus review of the newest server code is running in session 60498 with a 150-second process timeout. Its output is not yet a verified finding. Cloudflare tail session is recording final-stage recovery diagnostics to content-tail.jsonl.
- Operational runbook and aligned Chinese review copy were added. Production release still needs final tests, inventory gate, Queue consumer handover, workflow success and independent readback. Native release must be local and commits include [skip ci].

Next: finish and inspect native regression, implement remaining native corrections and bundle, retest and review. Diagnose any stuck publication with independent job reads. Preserve launch and coverage gates. Keep the old heartbeat paused and do not spawn subagents.

## Active implementation checkpoint (2026-09-15 16:00 AEST)

Runtime changes remain uncommitted. Production and TestFlight remain at their previously released versions, including native 0.1.0 (14).

- Content pipeline is resumed after a brief diagnostic pause. Administrative reconcile recovered existing work without admitting new topics. Latest blue-sky batch a7f78b5b-45c0-46de-9dd9-b5ce842ee641 passed source, ten-language text and scene illustration review. Eight language narrations are complete, Korean is working. English recovered automatically on attempt two. No stage or allowance was reset.
- Backend coverage-7 passed all 158 tests and all per-file gates. content-preparation.ts: 98.97% lines and 82.14% branches. New source illustration reuse always receives independent review for its new topic. A regression for rejection followed by fresh generation is running in content-reuse-recovery.log. This newest reuse code is not yet deployed to the isolated Worker.
- Source pool is 16 independently reachable authoritative seeds. Two reasoning diagnostics are counted in both cumulative and daily ledgers, with diagnostic-accounting.json evidence. Last observed cumulative use was 25 questions and 8 images. Refresh speech usage before further preparation.
- Native fixture-routing-1 passed all seven targeted UI checks: corrupt image recovery, three narration scenarios and three share reentry scenarios. Tests now consistently use fixture port 4231 and dedicated sharing port 4232. The earlier full regression passed 126 unit tests but was interrupted during UI checks, so it is not full acceptance. Native source is no longer under an active test run.
- German textClipped report is pixel-confirmed as a hyphenation false positive. The narrow exception now includes only reviewed iOS 27 at 402pt, alongside the prior iOS 26 at 375pt, for the same exact phrase with its complete frame visible. Reverification pending.
- Bootstrap and real Cron events are still pending. Keep allowance 120 questions, 18 images and 200000 speech characters. No published launch inventory, bundled content, calibrated semantic acceptance, completed generation coalescing or new release is claimed.

Next: deploy verified image reuse, finish the first complete package, initialize foundation content, and record two real isolated scheduled events. Continue semantic calibration/concurrency, native offline/withdrawal/rollover checks and final coverage/review, then workflow backend deployment and local TestFlight with [skip ci]. Keep the old heartbeat paused and do not start subagents.

## Active implementation checkpoint (2026-09-15 15:37 AEST)

Runtime changes remain uncommitted and unpublished to the main app. TestFlight is still 0.1.0 (14). Continue implementation and verification.

- Applied additive migration 0006 remotely and independently read d1_migrations. No old 0004 draft was applied. Existing application tables and journal records are preserved.
- Deployed isolated Worker pocket-explorer-content-validation with the content Queue, existing D1/R2 and Vectorize. Its public app routes return 404, and administrative routes require CONTENT_ADMIN_KEY. Cron is currently empty. It shares the existing allowance ledger. Production Worker pocket-explorer remains unchanged. Local ignored config and secrets are in Backend web/.local. Never print credentials.
- Actual source reading and ten-language text qualification succeeded for blue-sky and moonlight. Both initial illustrations were rejected, correctly quarantining the batches before publication. Inspected PNGs reveal misleading scientific diagram layouts. Artwork prompts now request a simple plausible subject or scene and forbid generated diagrams/insets/arrows. Verification remains strict. Rejection verdicts are now persisted for diagnosis. New runtime changes need targeted coverage and redeployment before retry.
- Real GPT request exposed HTTP 400 requiring the word JSON in input messages, not just instructions. reasoningObject now appends a JSON instruction in user content. Added a regression. Actual minimal probe passed HTTP 200 in 3.278 seconds. Existing answerQuestion already included JSON in user input. Two diagnostic calls were counted in cumulative question allowance, but their daily ledger entries still need adding. Last known usage: 19 questions / 120, 6 images / 18, 123 speech characters / 200000. No qualified package is published yet.
- New scheduler correction: manual reconcile recovers existing work only. Fresh admission requires an actual event identity. Initial bootstrap folds already-started foundation topics into its fixed ten topics, reclassifying only their same-day routine slots on first initialization, without refunding provider usage. This clarification is in both detailed plan copies. The two initial manual admissions are foundation topics, and initializeContent has not yet run remotely. Normal cadence remains one per event and three per UTC day.
- Backend full coverage before latest inventory/scene changes: 153 tests (verify exact log count) passed, all changed TS files >=80% lines/branches. New inventory function computes all 140 locale/integer-age slices from current catalog versions. Scheduler prioritizes category gaps in low-inventory slices. This newest priority change is not yet tested.
- Native tests: background-1 passed 17 PreparedDiscovery tests and the full prepared UI flow. RecommendationStore is now shared by TripStore/Home/background handler. BGAppRefresh requests earliest six hours later, cancellation releases download, and background refresh does not activate the daily snapshot. Info.plist includes fetch and the permitted task identifier. Real OS scheduling remains unverified.
- Native daily-ui-3 passed and screenshot confirms all three homepage rows are visible. Language bank eviction/ETag regression passed. Full native-regression-1 is running in exec session 84417, simulator 976BB247-A168-40D2-98C9-6F0154A7E7B3, DerivedData ~/tmp/review/pocket-daily-build. Its 126 unit tests have passed and UI tests are still running. Preserve application source until this run finishes.
- Backend targeted scene/inventory tests are running in exec session 15880, log content-scene-review.log. The newest scheduler priority edit happened after that run started, so run a new targeted check afterward.
- HTTP fixture session 9428 remains on port 4231. Prior fixture port 4197 is unrelated. No obsolete heartbeat or subagent was started.

Next: finish new source tests/coverage, deploy validation updates, retry blue-sky once with improved scene generation, then initialize the remaining foundation and enable a short isolated Cron for at least two actual events. Do not bypass quarantines or expand cumulative quotas. Build six-topic ten-language offline resources from qualified content. Complete semantic calibration/300-case acceptance, generation coalescing, operational metrics and real demand route proof, then full UI/coverage, workflow backend release and local TestFlight. See detailed plan for remaining gates.

## Verified implementation checkpoint (2026-09-15 15:15 AEST)

This is the current state. Runtime changes are still uncommitted and unpublished. TestFlight remains 0.1.0 (14). Continue implementation, not a planning-only turn.

- Backend: 147 full-suite tests passed before adding bounded foundation initialization and actual workerd PNG decoding. Latest full suite had one 5-second timeout in the expanded multi-tick integration test, not an assertion failure. The test now has a bounded 15-second timeout. Latest targeted run passed 14 pipeline/workerd tests. Re-run the full coverage gate after current changes.
- Cloudflare: content Queue pocket-explorer-content created and independently read back, ID 6ba593316e134802b03263ad1ab657f6, currently no producers/consumers. Vectorize pocket-explorer-knowledge-v1 exists with 1024 cosine dimensions and language/policy/minAge/maxAge indexes. No runtime binding, migration or vectors published.
- Wrangler draft now includes content Queue, AI, Vectorize and six-hour Cron. CONTENT_ENABLED and SEMANTIC_ENABLED remain false. Production build and deploy dry run pass. Actual workerd successfully decodes the PNG fixture using fast-png.
- New backend work includes sanitized generic-demand candidates, source-backed novelty verification, separate admin retry, bounded one-time foundation initialization (10 topics), one fresh topic per real scheduled event and at most three per UTC day, duplicate-tick records, and delayed Queue retry for transient failures. The bilingual detailed plan records initialization separately from regular freshness admissions. Initializer uses vetted seeds, not the original nine-topic draft.
- Source audit found four invalid seed references, including NOAA returning an HTTP-200 404 page. Those seeds were removed, soft-404 validation added, and comet URL updated to its independently observed destination. Fourteen seeds remain. Source text evidence: source-probes.json in the review directory. Real model qualification is still pending.
- Native: 118 full unit tests passed with normal simulator signing. The earlier unsigned run failed Keychain checks and is not acceptance. Later 29 focused tests passed, including durable narration fallback and deferred share preparation.
- Native UI found a real cancellation race: the first Home task cancelled a download while its replacement skipped the in-flight refresh. RecommendationStore now owns one durable Task per context, and replacement callers await it. Reproduction regression added. Full prepared answer/card/share/relaunch UI flow passes with zero generation requests against the HTTP fixture. Latest result: native-daily-ui-2.xcresult, 13 passing unit cases, one optional network-test skip, and one passing UI scenario. Actual HTTP integration separately passed one test in native-http-2.xcresult. native-http-1 ran zero tests due to an earlier failed file edit and is not evidence.
- Latest UI screenshots were exported and inspected from daily-ui-attachments. The homepage third row was partially covered at the initial scroll position, so hero height is now bounded at 230 points. This newest visual change needs another screenshot/check.
- New native review fix: an evicted language bank no longer sends its stale ETag or waits six hours before restoring the full catalog. A three-language eviction regression was added, not yet run.
- Native coverage: domain/network files meet 80% in unit evidence. Changed SwiftUI files still require combined final UI coverage. The older Home camera test also failed on iOS 27 camera presentation and needs investigation or a justified updated test. No physical-device checks completed.
- CLI Opus review was attempted via cl -p with read-only supplied source and tools disabled. It timed out at 180 seconds with no findings. Do not claim an external review passed.

Active local fixture: exec session 9428, port 4231, scripts/testing/serve-ai-fixture.mjs, log ~/tmp/review/pocket-daily-plan-20260915/daily-fixture.log. Preserve/restart only this fixture as needed. Port 4197 belongs to a pre-existing fixture and was not stopped. Simulator 976BB247-A168-40D2-98C9-6F0154A7E7B3 is dedicated to this work. DerivedData: ~/tmp/review/pocket-daily-build. No tests currently running at this checkpoint.

Next: verify the eviction/hero changes and full backend coverage, finish release preflight and immutable package validation, conduct bounded code review, then prepare real complete multilingual content in an isolated Cloudflare environment and record at least two actual scheduled events. Current plan explicitly permits shortened cadence in an isolated test environment. Restore and independently read the production six-hour schedule. Preserve shared provider allowances across staging and production rather than creating a separate unlimited budget. Produce six multilingual bundled foundation topics from qualified packages. Finish actual 300-case multilingual Vectorize evaluation, demand-path integration proof, inventory shortage behavior, concurrent generation policy, native lifecycle/background refresh, final UI coverage, workflow backend release and local TestFlight. Do not mark these open acceptance items complete using fixtures.


## Active implementation checkpoint (2026-09-15 14:57 AEST)

This checkpoint supersedes the older planning-only and release notes below. The user approved implementation. Both active worktrees use codex/daily-discovery from current origin/main. No runtime changes have been committed, migrated, deployed or uploaded.

- B10.0: baseline and capacities inspected. BGE-M3 returned 1024 dimensions. Vectorize index pocket-explorer-knowledge-v1 and four metadata indexes were created and independently read back. No production binding or vectors yet.
- B10.2a/b IN_PROGRESS: additive migration 0006, durable jobs, six-hour reconciler, bounded generation, immutable D1/R2 packages and prepared APIs implemented locally. Real Cloudflare content Queue/Cron still pending.
- Backend verification: 143 tests passed with actual Miniflare D1/R2 and fixture providers. Coverage gate passed. content-preparation.ts is 98.86% lines and 82.43% branches. All changed TypeScript files meet 80% currently. Real source/content generation and workerd image decode remain pending.
- B10.3 IN_PROGRESS: native modules compile. Home now uses RecommendationStore and persisted daily snapshots. Offline keep can persist cached illustration immediately. Registration and share snapshot synchronization are wired. 118 unit tests passed with normal simulator signing, including ten new daily-content tests. Tests ran on independent simulator 976BB247-A168-40D2-98C9-6F0154A7E7B3, with existing unit regression. Do not treat compilation as native acceptance.
- Native test command result: ~/tmp/review/pocket-daily-plan-20260915/native-unit-1.xcresult. Log: native-unit-1.log. Initial compile evidence: native-build.log. DerivedData: ~/tmp/review/pocket-daily-build.
- B10.2c PENDING: qualified initial content, actual sources, 12-topic launch bank, six-topic multilingual offline bundle, assets and real scheduler evidence.
- B10.4a/b IN_PROGRESS: exact/alias and Vectorize candidate verification exist. Actual multilingual evaluation, safe novel-question admission, full concurrent miss generation and independent novelty checks remain open.
- Remaining operational work: retry administration, inventory shortage priorities, bounded initialization, live content Queue/bindings/Cron, workflow delivery and independent readback. Native release uses local TestFlight only and [skip ci]. Preserve existing 120/18/200000 allowances.
- No subagents, teammate messages or expired timers are authorized. Continue through review and actual acceptance. Published baseline is still TestFlight 0.1.0 (14).


## Implementation started (2026-09-15)

The user approved implementation. The active worktree is /Users/haichang/Worktrees/Pocket-Explorer-UI-daily-discovery. B10.0 is in progress. Integrate from current origin/main, preserve existing narration, then implement and verify the continuous supply plan. Earlier planning-only statements are historical. No expired timer is resumed.

## Current content pipeline checkpoint (2026-09-15)

The user requires continuous backend content replenishment before periodic client activation can work. The detailed [implementation plan](../Pocket-Explorer-Backend/docs/plans/daily-discovery-pipeline.md) owns supply cadence, package verification, immutable versions, native activation, Vectorize reuse and acceptance. This is the newest planning checkpoint and supersedes older task ordering below. Build 14 narration remains the released baseline. No runtime change or publication is part of this planning turn.

| ID | State | Next action or evidence |
| --- | --- | --- |
| T22/B10.1 | DONE | Product/cache research and the detailed continuous-supply plan are written, with a Chinese review copy |
| T22/B10.0 | IN_PROGRESS | Integrate current main in fresh worktrees, inventory drafts/migrations and remaining capacity, verify embedding and index capabilities |
| B10.2a | PLANNED | Implement immutable content versions, assets, publication and withdrawal using actual D1/R2 |
| B10.2b | PLANNED | Add independent Cron, a dedicated preparation Queue, resumable jobs, accounting and fresh-topic admission |
| B10.2c | PLANNED | Validate multilingual seed packages and automatic publication, reaching the initial distinct-topic gate |
| T22/B10.3 | PLANNED | Ship native bank persistence, stable daily snapshots, prepared reads, prefetch and personal registration |
| B10.4a | PLANNED | Evaluate embeddings and implement scoped Vectorize reuse with held-out verification |
| B10.4b | PLANNED | Route only verified generic demand into candidate preparation |
| T22/B10.5 | PLANNED | Test scheduled supply and next-day activation together, inspect/review and independently verify both releases |

Planning evidence: inspected static draft with 90 localized entries but only nine topics and three illustrations, no content scheduler, and released build 14 bindings. Runtime/source hashes are recorded in ~/tmp/review/pocket-daily-plan-20260915/runtime-before.json. This turn verifies documents and source preservation, not feature behavior. No new provider calls, services or deployment are started.

Document verification passed: both repositories pass git diff --check, all 309 runtime-file hashes are unchanged, the detailed bilingual plan has matching sections and tasks, and all 19 checked local links resolve. Evidence: ~/tmp/review/pocket-daily-plan-20260915/document-checks.json. This is planning evidence, not implementation verification.

## Completed isolated narration release (2026-09-15)

The user approved hai managed identity, Xiaoxiao gentle Chinese and Emma Dragon HD English. Backend source 9004928 is deployed through workflow 34924912737. Native source 65b3084 was published locally as TestFlight 0.1.0 (14). Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal. IPA, signing, ten 322-entry catalogs and unchanged application source are verified. Final runtime tests passed 108 unit and three narration UI checks at 97.12% changed executable-line coverage, and a settled playback screenshot was inspected. UI evidence commit f2e3880 and Backend evidence commit 89f97bb are pushed to main. No GitHub iOS build was started. Test fixtures 4213 and 4215 are stopped, and the expired heartbeat remains paused.

Current release evidence and guides are in ~/Worktrees/Pocket-Explorer-UI-speech and ~/Worktrees/Pocket-Explorer-Backend-speech. Physical iPhone playback, microphone and interruptions remain unverified. Preserve this checkout's unpublished Vectorize/content and design drafts. Prepared daily recommendation audio and semantic reuse remain unfinished and are not part of build 14. Merge the verified narration main changes carefully before resuming those drafts. Earlier authentication proposals below are historical.

## Azure Speech resource created (2026-09-15)

Authentication probe: the Azure CLI Entra user token for haichang@microsoft.com was denied GET /tts/cognitiveservices/voices/list because the Speech frontend data action is missing. This is not a missing resource. The existing claude-proxy-copilot Container App has identity type None. Proposed integration uses an Azure-hosted adapter with managed identity and a resource-scoped Cognitive Services Speech User role, keeping the existing authenticated Cloudflare entry point and R2 audio cache. No identity or role changes have been made.

The user explicitly requested creation in subscription 4496e94c-b276-44d5-8809-1233f334e678 and selected Standard S0. Azure CLI validation and incremental deployment succeeded. Independent resource readback confirms pocket-explorer-speech, resource group hai, eastus, SpeechServices, S0 and disableLocalAuth=true. Endpoint: https://pocket-explorer-speech.cognitiveservices.azure.com/. See [creation evidence](../Pocket-Explorer-Backend/docs/evidence/azure-speech-resource.json).

The earlier DeploymentNotFound probes concerned other model routes. This new resource exists, but its Entra ID data-plane access, voice quality and application integration are still unverified. No role assignments were added and no API keys were retrieved. Next verify the caller identity and Speech permissions, render multilingual samples, then integrate server-side synthesis and R2 audio caching. Resource creation alone does not complete the speech work.

## Current Vectorize checkpoint (2026-09-15)

- DONE T22/B10.1: primary-source research and the user's Vectorize preference are recorded in the [design](../Pocket-Explorer-Backend/docs/research/semantic-cache-vectorize.md) and [research](docs/research/daily-discoveries.md).
- VERIFIED BY INSPECTION: the Worker already binds D1, R2 and Queues, but has no Vectorize or Workers AI binding. The knowledge draft provides normalized exact matching only.
- NEXT T22/B10.4: probe multilingual embeddings, confirm dimensions, evaluate false hits, then implement Vectorize retrieval, D1 validity checks and complete-answer verification. Test delayed index visibility, withdrawal, deadlines and concurrent generation.
- UNCHANGED: incomplete runtime/content drafts are uncommitted and unpublished. No cache integration or release is complete. This checkpoint updates documents only. Keep the expired timed refinement and heartbeat closed.

## Historical research-first correction (2026-09-15)

This historical correction predates the completed research and current Vectorize decision above. At that checkpoint, the user requested researching established practice before implementation, and implementation and publication were stopped. Local uncommitted drafts exist for prepared content, server caching and a migration. They are incomplete and unverified, and no app or backend changes have been committed or deployed. Do not mistake the last successful build for behavior verification. Next: finish primary-source research, compare product cadence and technical cache patterns, present a recommendation and resolve design choices before resuming implementation. No native source code has been changed yet.

## Daily discoveries and reusable knowledge (2026-09-15)

The user requests a larger cached recommendation bank, three stable daily selections, prepared answers and illustrations, and long-lived reuse across matching questions. This is new implementation work. The previous timed refinement remains closed and its heartbeat remains paused.

- T22/B10.1 DONE: primary-source research, cache boundaries and the preferred Vectorize design are recorded.
- T22/B10.2 NEXT: server-owned prepared multilingual bank and immutable artwork, with no provider call when opened.
- T22/B10.3 NEXT: persistent native bank, daily selection and background refresh. Freeze the day's selection, including across relaunch and successful bank downloads. Keep typed, spoken and photographic exploration available.
- T22/B10.4 NEXT: exact fast path plus Vectorize semantic candidates and complete-answer verification, following the [design](../Pocket-Explorer-Backend/docs/research/semantic-cache-vectorize.md). Scope by language, validated age applicability and policy revision. Preserve content versions, separate personal records, bounded expiry and generation coordination.
- T22/B10.5 NEXT: meaningful reproductions, actual local D1/R2 integration, changed-file coverage, native UI and persistence tests, written critique and release verification. Backend delivery uses its workflow. Native delivery remains local with [skip ci].

Preserve existing data, private keys, 120/18 safeguards, ten languages, Miro design, untracked design/miro-sync and old public links. Do not revive the earlier eight-hour timer. Do not extend into accounts, friends, chat or unrelated sharing fixes.

Updated 2026-09-15. The eight-hour refinement window ended at 08:39:34 AEST. Build 13 is released and the five-minute checkpoint is paused.

## Delivery

| Deliverable | Verified state | Evidence |
| --- | --- | --- |
| TestFlight 0.1.0 (13) | VALID / IN_BETA_TESTING, Hackathon Internal, published from this Mac | docs/evidence/sharing-reentry.json and ~/tmp/review/pocket-release-polish-13 |
| Cloudflare API and public viewer | Runtime 5dac559 deployed as Worker 44482a6c-a85a-488e-9acf-c8e763d11992, workflow 34894033434 succeeded | Sibling docs/evidence/png-integrity.json |

Published application source is 339ff9e5832fb4cc8fa24cde30aa2f72a811e581, pushed to main. Later documentation evidence commits are not the IPA source. Changed-line coverage uses base d7cdec643b4eea6a6b57d1fe34d05da975fd96f1. Preserve untracked design/miro-sync.

## Active work

| ID | State | Next action |
| --- | --- | --- |
| T21.3 sharing | DONE | Creation, revocation and exact snapshots survive page reentry, released in build 13 |
| T20.3 accessibility | REVIEW | 375pt and iOS 27 sharing checks passed and shipped. Human and physical acceptance remain open |
| T21.1 terminal illustration | DONE | Neutral keepsake and readable words remain on terminal failure, released |
| T21.4 publication | DONE | [skip ci] commit/push, local upload and independent Apple/IPA reads complete |
| T20.2 / T21.2 physical speech | REVIEW | Physical naturalness and recording remain unverified |
| Physical camera, VoiceOver and Safari | REVIEW | Post-release device read still shows disconnection. Preserve TestFlight installation |
| Final checkpoint | DONE | Evidence, Chinese copies and guides synchronized, checked and pushed. Checkpoint paused after the deadline with independent readback |
| Accounts, friends and chat | DEFERRED | Explicitly outside this iteration |

## Final verification and release

- Final complete native-final-13.xcresult: 154 passed, zero failed, two skipped. This includes 98 unit and 56 UI passes. Results are in ~/tmp/review/pocket-polish-20260915.
- native-sharing-ios27-13.xcresult: all three checks passed using an independent simulator, DerivedData and fixture 4205.
- native-final-13-coverage.json: 133/133 changed executable lines, all three files at 100%. native-final-13-source.json confirms source stayed unchanged during regression.
- Final screenshots and native-final-13-visual-review.jpg were inspected. Production sharing creation, independent reads and revocation passed. Live AI was not repeated. Simulator microphone was explicitly skipped for a failure also present on the released baseline.
- The read-only Opus 5 sharing review returned error_max_budget_usd with no usable conclusion. It is not counted as passed and will not be repeated. Manual code and test-design critique are complete.
- Formal evidence is docs/evidence/sharing-reentry.json. Review is docs/reviews/sharing-reentry-20260915.md.
- Apple build ID is 3a1b86da-7476-40d8-b992-348ae7c33c79. Only internal testing was confirmed, not external group availability.
- IPA SHA256 is 47e4fa3a37927a28ce4c2149513a2b3627104db1f170798121c288c766212b4e. Independent reads verified signing, get-task-allow:false, ten 322-entry catalogs, unchanged application source and temporary signing-keychain removal.
- Tests and upload processes have ended. No GitHub iOS runner was started. This session’s fixtures 4199, 4203 and 4205 were stopped, with independent port checks. Older 4197/4201 and independent design previews remain running.

## Reproductions and review scope

- Sharing creation reentry baseline failed four assertions, created two POSTs/links and left one after revocation. Another baseline reproduced loss of the selected first name.
- Revocation reentry baseline failed three assertions, with enabled actions and a stale URL after completion. Delayed HTTP, failure and retry checks passed after correction.
- Earlier 150-test complete regression, 46/46 coverage and worktree 77/77 coverage predate the final source. They do not replace final 154-test and 133/133 results.
- Maximum French text was clipped despite hittable controls. share-footer-audit-before.xcresult reproduced the targeted textClipped failure. Final screenshots and focused audit passed.
- The audit covers revoke-share and share-message, not a claim that the entire screen has no accessibility findings. It can move the viewport, so the test repositions controls afterwards.
- Node syntax, shellcheck and git diff --check passed. Documentation state updates require document and evidence checks without repeating application regression.

## Remaining acceptance and next priorities

1. Follow [the five-minute iPhone check](docs/device-check.md) for recording, natural speech, camera, Safari, large text and language switching. Post-release device read still reports tunnelState disconnected and ddiServicesAvailable false.
2. After physical voice acceptance, evaluate available high-quality multilingual voices. System resources vary by installation, the new Azure Speech resource still needs data-plane integration, and natural female narration in every language is not established.
3. Add durable sharing idempotency and recovery in the next iteration. Current continuity covers page navigation. A local Worker and D1 response-loss reproduction created a second link while leaving the first active. Evidence is docs/evidence/sharing-lost-response.json, with the correction contract in capabilities and remaining work.
4. Later product extensions remain in [capabilities and remaining work](docs/next-iteration.md). Do not add deferred accounts/social features merely to fill time.

Provider duration remains variable. Preserve existing 120/18 safeguards. No new live AI question or image generation was required for this sharing increment. Public-sharing tests used fictional data, independent reads and revocation.

## History and handoff

Earlier T00 through T21 work, releases and checkpoints are retained in [the execution archive](docs/history/20260915-pre-final-TODO.md). Preserve the product criteria in [ACCEPTANCE.md](ACCEPTANCE.md). Simulator checks do not replace human visual approval or physical-device acceptance.

The five-minute heartbeat pocket-explorer-5 was paused at 08:39:56 AEST and independently read back as PAUSED. No tests or uploads remain active. UI documentation evidence commit 72b3392 and Backend guide commit 83db0fb were independently confirmed on remote main. This final checkpoint-state commit does not change the published application source.

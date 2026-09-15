# Pocket Explorer: Project Continuation Prompt

## Sharing and illustration checkpoint (2026-09-15 07:27 AEST)

- The isolated sharing correction now covers both creation and revocation across page reentry. Revocation baseline failed three assertions. The corrected run passed 18 unit and two HTTP-backed UI checks, with 77/77 changed executable lines covered against its dbadd25 worktree base.
- Actual pending, completed, revoking and revoked screenshots are inspected. A supplementary French maximum-text revocation check passed on iOS 27. Its screenshots still need review.
- Primary native-sharing-13.xcresult remains running in session 61931 on the 375pt simulator. Primary native source stays frozen until it finishes. This full regression includes creation reentry only.
- After completion, integrate only the named sharing files, ten 322-entry catalogs, GlobalLanguageTests and the one-file neutral-compass illustration refinement. The source worktrees are ~/Worktrees/Pocket-Explorer-UI-sharing-reentry and ~/Worktrees/Pocket-Explorer-UI-keepsake-feedback. Preserve all unrelated work.
- Final primary-source unit, sharing, artwork and maximum-text checks must use artwork fixture 4199 and the new share fixture 4203. Verify each changed Swift file reaches 80% coverage. Then record critique and evidence, commit with [skip ci], and publish locally.
- TestFlight remains 0.1.0 (12). Continue through 08:39:34 AEST. The physical iPhone installation and open device acceptance are preserved.

## Sharing regression checkpoint (2026-09-15 07:12 AEST)

- Build 12 is published and independently verified. Primary HEAD d7cdec6 records delivery, with preexisting design/miro-sync untouched.
- Reentry baseline failed four assertions: two create requests, two active links, and one leftover after revocation. A follow-up failed when the pending preview lost the original first name. SharePublisher now preserves one in-flight task and its exact snapshot across view reentry, then saves the receipt before clearing the task.
- Ten unit checks and one HTTP-backed UI check passed. Changed Swift coverage is 46/46. Actual pending and completed screenshots are inspected. CI test setup now starts and cleans the isolated 4201 fixture, with shellcheck and Node syntax verification passed. No GitHub iOS run was started.
- These six files are integrated into primary. Complete native-sharing-13.xcresult is running in session 61931 on 375pt, with production sharing enabled and artwork fixture 4199. Source stays frozen. Final results, coverage and local publication remain pending.
- Separately, ~/Worktrees/Pocket-Explorer-UI-keepsake-feedback replaces the duplicate terminal-image heading inside the picture with the existing neutral compass illustration. Five existing artwork UI checks are running on iOS 27 in session 27938. This cosmetic change is not integrated. Inspect actual pixels and coverage before deciding whether to include it with the sharing release.
- Fixture sessions: 4199 in 85640, 4201 in 89106. Continue through 08:39:34 AEST. Physical voice/camera/VoiceOver/Safari acceptance stays open.

## TestFlight 12 released (2026-09-15 07:06 AEST)

- Published 0.1.0 (12) from this Mac. Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership. Build ID 96bf2c3e-9c6b-477c-9b67-470a9dd3a16c, source 5ebdde049c1c99d0c41a147f049469508370f52b.
- Independently verified IPA, signature, disabled debug entitlement, Xcode 27A266a, SDK 24A430, ten 321-entry catalogs and unchanged source. The temporary signing keychain is removed. Release artifacts are in ~/tmp/review/pocket-release-polish-12/, with formal evidence in docs/evidence/memory-map.json.
- Complete regression passed 143 with no failures and two explicit skips. Final-source subset passed 105, supplementary editor/narration passed three, and iOS 27 passed two. Final-source coverage union is 177/181 (97.79%), each file above 80%.
- Further sharing checks reproduced duplicate public links when closing and reopening a pending request. Revoking the visible link left another available. The isolated ~/Worktrees/Pocket-Explorer-UI-sharing-reentry fix reuses requests, with the completed test result owning exact counts. A follow-up reproduction lost Ari from the pending preview. That correction is running in share-reentry-snapshot-after.xcresult, session 19966. Independent share fixture 4201 runs in session 89106.
- Preserve the physical iPhone installation. Physical microphone, camera, natural narration, VoiceOver, Safari and human visual acceptance remain open. Continue through 08:39:34 AEST.

## Final-source verification (2026-09-15 06:50 AEST)

- Complete native-final-12.xcresult passed 143 tests, failed none and skipped two. Changed-line coverage is 174/178 (97.75%), with every file above 80%. Preserve raw Apple contrast/QoS reports and the characterized German hyphenation exception rather than claiming an empty audit.
- Copied the five independently verified corrupt-image recovery files from the artwork-result worktree into the primary checkout and verified byte equality. Final-source unit plus artwork, card, memory and saved-question UI checks are running in native-final-source-12.xcresult, session 86500, using fixture 4199. Keep source frozen.
- Cloudflare source 5dac559 is independently verified. Backend evidence commit 08b7558 is pushed. Fictional production shares are revoked, the old link remains available and no new live AI calls were made.
- Next read final results and coverage, inspect screenshots, update release evidence, commit with [skip ci] and publish from this Mac. TestFlight remains 11. Continue through 08:39:34 AEST.

## Artwork recovery checkpoint (2026-09-15 06:42 AEST)

- Primary native-final-12.xcresult is still running the complete regression, session 60891. All 91 unit and completed UI checks passed so far. Keep source frozen. Scope includes memories, map rendering, card-section translations and direct viewing of saved cards.
- ~/Worktrees/Pocket-Explorer-UI-artwork-result contains a verified, unintegrated corrupted-image correction. invalid-artwork-before.xcresult reproduced three failures. All subsequent 17 unit and five UI checks passed. After correcting a legacy test's missing imagePath, all 17 unit checks passed again. Three changed executable lines have 100% coverage. Actual failure-state and retained-card screenshots are inspected.
- Native changes are AIClient.swift, ArtworkCoordinator.swift, ArtworkRecoveryTests.swift, ArtworkFlowTests.swift and scripts/testing/serve-ai-fixture.mjs. Independent fixture 4199 runs in session 85640. Existing fixture 4197 was not restarted. After integration, use TEST_RUNNER_POCKET_ARTWORK_FIXTURE_URL=http://127.0.0.1:4199 for affected tests, rather than running the new corrupt-image case against the old 4197 fixture.
- Backend 5dac559 is pushed. Workflow 34894033434 is publishing, watched by session 88448. Passed 96 unit/integration, four artwork browser tests, build/dry run and 100% PNG/provider line and branch coverage. Independently read the deployed version, images and legacy share before updating formal release evidence.
- Next finish the primary full regression, integrate the tested artwork correction, then verify final-source coverage, UI and publication. TestFlight remains 11 and all new native changes remain unpublished. Continue through 08:39:34 AEST.

## Final integrated candidate 12 (2026-09-15 06:26 AEST)

- The original native-combined-12.xcresult full run passed 141 tests, failed one and skipped two, including 91 unit and 50 UI passes. Its only failure is the German hyphenation audit characterized against exact audit-time full-screen and element pixels. The narrow exception retains the raw report, with other findings still failing. All three final primary-checkout card checks passed in native-final-card-12.xcresult.
- Original combined changed-line coverage against fa793c0 is 155/156 (99.36%), with every file over 80%. Actual map, memory, card and multilingual screenshots are reviewed. Production Cloudflare sharing creation, independent read and revocation passed without additional live AI or image requests.
- A new reproduction failed two assertions: reopening an already saved question still offered an observation editor whose changes were discarded, and viewing its card repeated the new-card reveal. The correction opens the existing card and retains its observation. Five question/history UI checks passed, with 19/22 changed lines covered (86.36%). The isolated worktree is ~/Worktrees/Pocket-Explorer-UI-saved-question.
- That correction is integrated in the primary checkout for the same release as the memory, map and card-section changes. Final native-final-12.xcresult is running the complete 375pt regression, session 60891. Keep native source frozen. Final integrated coverage and screenshots remain to collect.
- TestFlight remains 0.1.0 (11), with the new candidate unpublished. Next finish results, critique, [skip ci] commit and local upload, then continue refinement through 08:39:34 AEST.

## Small-screen card checkpoint (2026-09-15 06:16 AEST)

- All nine targeted combined iOS 27 UI tests passed. The full 375pt/iOS 26.4 regression is still running, with 91 unit tests passed. The German maximum-text card has a textClipped audit failure, while the remaining tests continue.
- The finding identifies the card-front question, Wie schwimmen Enten?. Inspected pixels show complete hyphenated text. Actual pixel clipping is not established. An independent run reproduced the audit, and an intrinsic-height fixedSize experiment did not resolve it. That ineffective experiment is removed from the isolated worktree.
- Preserve the raw finding, hierarchy and screenshots in pocket-polish-20260915/card-small-clipping-artifacts. Keep the audit strict rather than silently filtering it. Next check stable card selection, the exact audit-time screenshot and the full regression result before fixing or explicitly characterizing this limitation.
- TestFlight remains 0.1.0 (11). The combined candidate is unpublished. Continue through 08:39:34 AEST.

## Combined candidate 12 (2026-09-15 06:02 AEST)

- The memory-only full native-candidate-12.xcresult run passed 135 tests, failed none and skipped three: 88 unit and 47 UI passes. Changed-line coverage is 59/59. Live sharing was not enabled in that run. The other skips are live AI and the known simulator microphone issue. All 23 supplementary iOS 27 UI checks passed.
- Map commit e0df57d is integrated in the primary checkout as dbadd25, not pushed. Preserve uncommitted memory/document work and the preexisting design/miro-sync directory. ~/Worktrees/Pocket-Explorer-UI-map-rendering retains experiment copies. Do not edit the current candidate there.
- New card-reading-defects-before.xcresult contains two failed tests and four failed assertions: untranslated German/Arabic headings and place text at y=930/983 below the tab bar starting at y=873. Fixes passed six language unit and two card UI checks. A literal-source audit also found Card details and From your discoveries. All three phrases now appear in ten 321-entry catalogs. The scan excludes interpolated and computed strings.
- Memory, map and card changes are integrated in the primary checkout. Full native-combined-12.xcresult is running on the 375pt simulator, with all 91 unit tests passed. Live sharing/readback/revocation is enabled, with no new live AI question or simulator recording enabled. Session 55123. Independent targeted iOS 27 UI verification is native-combined-ios27.xcresult, session 30426, with separate DerivedData.
- Next collect both runs and screenshots, correct failures if needed, calculate all changed-line coverage against fa793c0, update critique/evidence, commit/push with [skip ci] and publish locally. Freeze native source during the two runs. TestFlight remains 0.1.0 (11). Continue through 08:39:34 AEST.

## Memory and map checkpoint (2026-09-15 05:45 AEST)

- Four native memory reading UI checks passed. All 23 iOS 27 large-screen checks passed, covering ten languages, maximum text and memories. The 375pt full regression continues, with all 88 unit tests passed. No full-suite completion is claimed yet.
- The independent ~/Worktrees/Pocket-Explorer-UI-map-rendering checkout reproduces repeated map decoding: 100 identical updates rendered 100 images in 0.248434 seconds. Cached thumbnails reuse all 100 updates in 0.015147 seconds. Six unit and two UI checks passed. Six unit checks passed again after accurate cache-cost accounting. Changed Swift coverage is 35/35. Actual screenshots are inspected.
- Map changes are committed on codex/map-rendering as e0df57d, not pushed. Next collect the main memory regression and coverage, then integrate that commit and run final combined regression. Combine both improvements into the next TestFlight version rather than consecutive near-identical uploads.
- A focused Opus 5 request again returned no usable conclusion before its invocation budget limit. It is not a passed review. Manual code critique and screenshot review are complete. Do not blindly retry this route.
- TestFlight remains 0.1.0 (11). Backend 008a213 is deployed and verified. Preserve the physical iPhone's TestFlight installation. Continue through 08:39:34 AEST, with physical voice/camera/VoiceOver/Safari checks still open.

## Memory reading checkpoint (2026-09-15 05:32 AEST)

- IN_PROGRESS T21.3: reproduced five-second long-memory advancement and a maximum-text chapter opening hidden behind the navigation bar on released source. Current changes give 5–45 seconds based on text length and reveal the reading opening after next/replay.
- Initial fixes passed 12 unit and three UI checks. A later run using actual chapter titles passed three unit, five accessibility and three reading UI checks. A new pause test failed during setup: normal-size text was fully visible, so one swipe could not reach its assumed position. The failure video is inspected. Maximum text and position-based scrolling now exercise pause/resume preservation and same-chapter replay.
- Backend source 008a213 is deployed as Worker 2ae56910-76b4-4351-8e02-ca4d8e250486, workflow 34885725856 succeeded. Independent production Chromium/WebKit reads at 375/1440px passed, fictional shares are revoked and the old link returns 200. Documentation ca77486 is pushed and matches remote main.
- TestFlight remains 0.1.0 (11). Native memory changes are unpublished. Next resolve the pause check, inspect screenshots, run full regression and changed-line coverage, then publish locally. Continue through 08:39:34 AEST. Physical speech, camera and VoiceOver remain unverified.

## TestFlight 11 released (2026-09-15 05:17 AEST)

- Published 0.1.0 (11) from this Mac. Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership. Build ID af09f7fe-5c89-4111-aef0-a42ae1d6af32, source f26c017.
- Independent IPA checks verify bundle/version, Xcode 27A266a, SDK 24A430, signature and unchanged source. IPA SHA256 is 814980ee3c404c41d619b09f170c63bab2c05acb50b7c975a85ccde02dd814e6. The temporary signing keychain is removed.
- Next T21.3: use existing POCKET_TEST_JOURNAL input to reproduce five-second long-memory advancement and the visible opening after next/replay. Add failing tests before adapting duration and scrolling, with coverage, screenshots, review and local publication still required.
- Backend WebKit source 008a213 is pushed and workflow 34885725856 is running. Production readback in both engines is pending. Continue through 08:39:34 AEST. Physical voice, microphone, camera and VoiceOver acceptance remains open.

## Local release candidate ready (2026-09-15 05:07 AEST)

- Verified 85 unit and 44 distinct UI checks, with two explicit skips. The full run's French failure was a test tap on the tab bar. After correcting positioning, three independent French iterations and all 14 language flows passed. Application source remained unchanged.
- Changed Swift executable-line coverage is 401/411 (97.57%), each file above 80%. Application coverage is 4989/5193 (96.07%). Final ten-language, photo and maximum-text screenshots are reviewed. Original contrast reports and internal QoS warnings remain attached.
- No checked service/owner value was found in 275 repository files. Commit and archive/upload from this Mac now, using [skip ci] and no GitHub iOS workflow. TestFlight remains 0.1.0 (10) until independent Apple readback completes.
- Freeze ios/shared/scripts during upload. Afterwards refine native memory reading duration and scroll position, and resolve the new WebKit language-picker touch-area and collection-scroll findings. Continue through 08:39:34 AEST.

## Native checkpoint 11 (2026-09-15 04:56 AEST)

- All 85 final-candidate unit tests passed. UI regression continues. The French maximum-text sharing test failed once. Completed photo, question, card, memory and public-sharing journeys passed.
- Independent screenshot and hierarchy show the share button at y=489.5 with height 266pt, placing its center inside the tab bar beginning at y=584. The old helper checked only isHittable, which does not establish a visible tap center. Position the complete button inside the usable region before tapping. Three independent iterations are running, with the first passed. An earlier helper revision failed because the map has no navigation bar. That assumption is corrected.
- The website memory refinement reproduces and fixes five-second long-text advancement, offscreen pause, replay not resetting its interval, and next chapters opening at the collection. Passed 24 browser and 89 unit/integration checks. Independent review and publication remain pending.
- Native app code stays frozen. TestFlight is still 0.1.0 (10). Next inspect the full failure attachments and final coverage, verify corrected scrolling, and publish locally. After release, improve native memory reading pace and continue through 08:39:34 AEST.

## Native checkpoint 10 (2026-09-15 04:28 AEST)

- Reproduced large-text defects on independent 375pt simulator E571D373-70EE-43D4-B93E-9DE0EE7DE2BF with separate DerivedData, leaving the original full regression undisturbed. Four baseline UI checks failed. Measured home input height was 272pt, Play height 152.5pt, and card width 162pt.
- Adapted large-text input copy, fixed icon sizes, brand sizing, single-column collection, complete card titles/categories and stacked memory controls. Chapter position moves to the chapter text's VoiceOver value. The decorative 5pt progress strip is no longer a separate focus target. Ten catalogs now contain 318 entries.
- First fixes passed the three geometry assertions and clipping checks. Screenshots then exposed the brand's last letter wrapping, truncated categories and the progress strip's hit-region issue. Corrections are included in the second targeted run, together with French and Portuguese maximum-text journeys.
- Apple's contrast audit also samples scrolling labels behind bottom overlays. Raw findings and screenshots are retained for explicit pixel review. Ordinary test success must not be described as zero contrast findings. Clipping, hit-region, element-description and reading-space assertions remain strict. Original journal-count pixels were independently measured as #61746B against backgrounds with roughly 4.5 to 5 contrast. That finding disappeared in the first corrected layout.
- Added an actual Memories-tab chapter/back-navigation test, not run yet. The earlier full regression continues with no failures so far. TestFlight remains 0.1.0 (10), and new native code is unpublished.
- This Mac lists the paired physical iPhone, but reading this app's version/crash logs failed to connect (CoreDevice 4000 / NWError 57). No physical app was changed or reinstalled, and no physical verification is claimed.
- Next collect both running results and screenshots, address remaining observed defects, run final full regression and changed-line coverage, record review, and release locally. Continue through 08:39:34 AEST.

## Native checkpoint 09 (2026-09-15 04:17 AEST)

- Read the previous complete result: 84 unit tests had one legacy sharing-fixture failure. The 39 UI tests had two locale-scroll failures and two explicit skips. Corrected full regression is running, with all 84 unit tests passed so far.
- Actual screenshots exposed an oversized home composer, an Arabic collection word breaking across lines, and a squeezed multi-line memory Play label at the largest text size. Added AccessibilityFlowTests with actual Apple audits and reading-space assertions. This new test file is not part of the already-running regression and will first run against the unchanged app.
- Previous app coverage is 4736/5105 (92.77%). Changed executable lines are 321/331 (96.98%), with each changed file above 80%. Coverage does not turn failed tests into a complete pass.
- Backend compass fallback is deployed and independently verified, with remote main at e47cdfc. TestFlight remains 0.1.0 (10). Hold native publication until the newly observed large-text defects are addressed.
- Opus 5 is reviewing home, collection and memory accessibility and interactions. Next finish regression, reproduce the accessibility findings, fix and inspect screenshots, then release locally. Continue through 08:39:34 AEST.

## Native checkpoint 08 (2026-09-15 04:06 AEST)

- Completed ten 316-entry catalogs and localized permissions. New examples are created after first language selection with consistent titles, content and dates. Existing journals are retained. Reproduced and fixed first-launch loading that did not resume after language selection.
- The largest map text previously covered the collection entry. A bounded, fully scrollable trip panel corrected it and passed Arabic and German accessibility-size cases. Two later locale-picker checks overshot the target through long test swipes. The test now uses short drags calculated from actual element geometry.
- Full regression is still running. Of 84 unit checks, one legacy sharing-fixture comparison failed because new examples now include language metadata. The test is corrected to construct the original language-free record conditions. Photo, question, artwork-recovery and UI checks continue. No full-pass claim yet.
- Native Spanish production sharing passed independent HTTP content/language readback and HTTP 410 after revocation, without new AI or image calls. Apple currently returns zero TestFlight crash feedback submissions. That does not prove the absence of physical-device crashes.
- Verified photo-review fixes are retained. A focused Opus translation review led to checked corrections in Traditional Chinese, Japanese, Korean, German and Arabic. A larger review exhausted its budget and supplied no usable result. The foundation review's onReceive compile-error and missing-chapter-language claims contradict actual builds and tests. They were rejected. Its map-height finding was retracted.
- Added a matching native compass illustration for sharing without artwork. Sharing copy now scopes field-photo and precise-location exclusion to the public link, distinct from deliberately submitting a photo to AI.
- TestFlight remains 0.1.0 (10). New native code is uncommitted and unpublished. Backend keepsake/recovery source 4a4c0e0 is pushed, with workflow 34878450664 running.
- Next collect the full results, verify corrected fixture/picker checks, inspect final screenshots and coverage, then publish TestFlight locally. Continue with actual accessibility audits and other reproducible rough interactions through 08:39:34 AEST.

## Current language checkpoint (2026-09-15 03:35 AEST)

- Installed ten 316-entry UI/sample catalogs and ten permission catalogs. The 12 photo/language foundation unit tests passed. The new catalog, sample-preservation and explicit-date checks passed in a 15-test unit run.
- New examples are created after the first language selection, saved in that language with content metadata. Existing stories are preserved on UI changes. Prepared replies support all ten languages, and dates follow manual selection. Opus 5 is reviewing sensitive photo, speech and sharing translations.
- Native changes remain unpublished. TestFlight is 0.1.0 (10), while the ten-language Backend is deployed. Next resolve tests and review, inspect all ten locales, small screens, large text and RTL, then run full regression, coverage and local release. Continue through 08:39:34 AEST.

## Active eight-hour refinement (2026-09-15)

The user now authorizes implementation and repeated refinement through 2026-09-15 08:39:34 Australia/Sydney. This supersedes the planning-only checkpoint below. Prioritize rough interactions, gentle child-friendly speech, and slow or stuck image generation, then advance global multilingual quality within the same core journeys. Accounts and friend chat remain deferred.

- IN_PROGRESS T21.1 / B09.1: reproduce and fix artwork progress, deadlines, lost polling and safe retry. Preserve saved cards, avoid duplicate provider work, and test offline, timeout, relaunch and concurrent jobs.
- NEXT T21.2 / B09.2: improve voice selection, pacing, content-language replay and speech lifecycle. Evaluate available natural speech capabilities before adding a provider dependency. Missing speech must retain reading and typing.
- NEXT T21.3: inspect and polish the complete native flows, including loading/error/empty states, primary actions, scrolling, touch targets and image rendering. Then integrate T20/B08 language foundations as useful increments.
- REQUIRED for each candidate version: meaningful reproduction, targeted tests, coverage gates, actual UI screenshots and critique, fixes, regression and independent release readback. Use the user-authorized cl -p Opus 5 CLI as an independent reviewer. Reviewer opinions require verification.
- Current release is 0.1.0 (10), independently verified after local publication. Publish TestFlight only from local Xcode 27 RC build 27A266a. Preserve existing Cloudflare workflow, private credentials, journals, links and untracked Miro sync work. No teammate messages or new purchases.
- Review artifacts: ~/tmp/review/pocket-polish-20260915/. The five-minute heartbeat is ACTIVE until the deadline. Continue useful independent work across increments, rather than stopping after one upload or repeating unchanged checks.

## Latest direction: global languages (2026-09-15)

Read [Remaining work and language plan](../../docs/next-iteration.md) and the top of TODO first. The user requires multilingual support for children worldwide. The current assessment and plan are complete, while T20/B08 are not implemented. Continue from the next development instruction or specific issue without treating candidate languages or later features as delivered.

Language scope includes UI, permissions, errors, speech, AI answers, cards, quizzes, memories and Web sharing. Preserve original child content and its language, old journals and old shares. UI switching must not overwrite content, and unavailable speech retains the text flow. Verify RTL, long text, age-appropriate expression and actual speech. Preserve Miro visual quality and no parental gates. Accounts and friend chat remain deferred.

Release amendment: the user requires this TestFlight build to be archived and uploaded from this Mac because GitHub runner quota is exhausted. Run native checks locally and independently verify Apple processing. Do not trigger a GitHub TestFlight release for this iteration.

## Active implementation: Miro and live AI (2026-09-14)

The user now authorizes real native implementation, including live question answering and generated card artwork. This supersedes all earlier design-only restrictions and optional-AI statements below. Miro remains the visual and flow authority. Figma contains all 40 source screens and 189 hotspots, verified by native plugin readback. Older one-screen and blocked-delivery statements are historical.

Current scope is exploration, cards, maps, memories and public link sharing. Real accounts, friend relationships and cross-account chat are explicitly deferred. Preserve English, Simplified Chinese, the language chooser, existing journals and existing public links. Do not add parental keys, approval gates or controls. Use real SwiftUI controls and layouts, with decorative artwork. Full-screen source screenshots are references, not the app implementation.

Execute the active implementation plan above all historical continuation notes below. Continue through implementation, regression, visual inspection, authorized Cloudflare delivery and local TestFlight upload. Do not use GitHub runners for this TestFlight release. Keep TODO current. Do not restart completed Figma import work.

## Delivery status amendment (2026-09-14)

Production AI, R2 artwork, queue consumption, generated public stories and revocation are now independently verified. Persistent total allowances are 120 question attempts and 18 image attempts. The user directed implementation and publication to proceed without further pricing investigation. Current release evidence and remaining checks are in TODO.md.

This iteration uses local TestFlight publication because the user reported exhausted iOS runner quota. Backend delivery continues through the existing automatic Cloudflare workflow after an initial local rollout. Preserve both workflows for future use. Do not dispatch a GitHub iOS build or release. Accounts and friend chat remain deferred.

## Historical plan and evidence

## Current design authority (2026-09-14)

The user confirmed that [the Miro board](https://miro.com/app/board/uXjVHn9F6EQ=/) is the source of truth for UI design and flows. Figma Review 01 is an interaction example only. This decision supersedes conflicting visual baselines and Figma continuation instructions below, while explicit user decisions still take precedence over board content. The current phase is design and prototype review. Any new clickable prototype must follow Miro, and the existing Figma example does not establish completion of that work.


## Current priority: T18 Miro to Figma synchronization

Read `design/miro-sync/README.md`, `PROMPT.md`, and `TODO.md` first. The accepted approach is complete Miro images with transparent hotspots. Do not resume extraction. The local 40-screen, 189-hotspot preview is at http://127.0.0.1:4186/preview.html. The official Figma plugin has successfully authenticated, written nodes, uploaded images, and independently read the resulting layers. Further calls are currently rejected by the Starter MCP tool-call quota. The new source page contains one verified assembled screen, not a complete import. Preserve `design/miro-sync/manifest.json` and resume its existing nodes after access is restored. Do not use foreground browser automation or purchase an upgrade.

## Earlier T17 example

The user now wants design discussion before real application development. Read PLAN.md, PROMPT.md and TODO.md in /Users/haichang/.gstack/projects/pocket-explorer/designs/figma-review-20260911 first. Do not automatically modify or deploy the App or Backend based on older implementation tasks. The editable Figma file and clickable presentation are delivered. See TODO.md for URLs and verification. Continue with team design feedback and avoid duplicate imports. Do not request passwords or tokens.

Complete Pocket Explorer using the codex-project workflow. Implement and verify the required iPhone app and public sharing experience. Keep TODO.md current and continue across task boundaries while required actionable work remains.

## Product and user intent

Pocket Explorer turns a child's real-world question into a personal collectible card, a discovery on their map, a replayable memory and a story their family can share.

The iPhone app is the primary product. The first demo must include a real installed app with voice and camera entry. The website is the recipient's sharing surface. The user explicitly rejected deferring the app because it would compromise the child's experience.

Visual appeal is the highest priority. Visible accomplishment, memories and sharing are second. Preserve cream paper, forest green, rounded typography, pastel iridescent card borders, softly sculptural artwork and restrained reveal/flip animation. The approved reference is design/reference.html. Do not replace this direction with generic platform controls or emoji artwork.

The audience assumption is children aged 6–10 with a parent. Use fictional demonstration profiles and trips. Do not infer real children or locations from the developer's account or device.

## Required experience

The child opens the app, sees a friendly exploration companion, taps to speak, asks a question, hears a short response and receives one observation invitation. The child looks at the real world and describes what they noticed. Their own words become a card they can inspect, flip and revisit.

Cards belong to trips, persist after app relaunch, appear in a collection and appear on the map when a place is present. No correct quiz answer is required to keep a discovery. A location-free trip remains accessible.

On explicit trip completion, build a memory with question, observation and discovery chapters. Support one or multiple cards, stable ordering, pause, replay, manual controls and reduced motion. Seven days later, an in-app invitation may resurface the trip. Dismissal suppresses it for another seven days. There is no background push requirement.

The explorer previews the exact public story, selects what to include and creates a real URL. First name and broad city are off by default. Another device or independent browser must open the story without account creation or app installation. Public content excludes precise coordinates, raw recordings, photo metadata and private history. Links are revocable.

## Prepared and live capabilities

The first guide can use explicitly identified duck, leaf and shell responses. Real microphone capture, actual editable transcription, speaker playback and camera input are required. A different utterance cannot receive a hardcoded sample transcript. An unmatched question must be identified as outside the prepared demo rather than silently answered with a fixed example.

Keep actual questions and observations intact on failures. Handle denied permissions, audio interruption and backgrounding. Return to the foreground without automatically restarting recording. Camera denial cannot block voice-only exploration. Provide a parent typing fallback.

One live multimodal AI integration is optional after the complete required experience works. Keep service credentials server-side and expose failures honestly. Do not confuse the GPT-6 model used for development with an already configured product AI service.

## Current technical direction

Use SwiftUI for the iPhone app, system Speech/AVFoundation and camera interfaces, local atomic Codable storage, and MapKit or sourced geographical data. Share art, tokens, fixtures and a versioned public-story format with the React/TypeScript web viewer.

Use one persistent sharing service with owner-authenticated writes, public read-only snapshots, cryptographically random tokens and revocation-safe caching. Choose the runtime and storage against actual hosting capabilities. A static page or localhost-only preview does not satisfy remote sharing.

The paired development device is Hai's iPhone 17 Pro Max. Xcode 27.0, XcodeGen, Swift, Node and npm were checked on 2026-09-11. The user has an Apple Developer account and a valid development certificate. Recheck actual signing/device availability when installing. Never copy private keys into the repository.

Project root: /Users/haichang/Projects/Pocket-Explorer-UI.
New skill: /Users/haichang/.codex/skills/codex-project/SKILL.md.
The unrelated gaokao-kg project is outside scope.

## Start or resume

Read AGENTS.md, TODO.md, PLAN.md and the relevant ACCEPTANCE.md sections. TODO owns execution state. Inspect actual files, changes and recorded evidence before trusting completion marks. Resume running processes or unfinished work from the current checkpoint.

Choose an actionable task whose dependencies are satisfied. If a task combines independent code work with an unavailable device or deployment check, split it into explicit subtasks while preserving its acceptance mapping. Do not remove required evidence to close a task.

Build, verify and inspect a usable increment. Update TODO immediately after meaningful milestones with commands, results, evidence paths and unmet conditions. Then continue. Do not automatically stop after the first task or spawn a CLI restart loop.

Record concise decisions and observations, not hidden reasoning. A new user correction amends the current objective unless the user explicitly cancels or replaces it. Answer side questions briefly and continue authorized work.

## Verification

Added or changed Swift code requires at least 80% line coverage. TypeScript requires at least 80% line and branch coverage, reported separately. Test core behavior with meaningful assertions and actual persistence/service adapters with integration tests.

Use XCUITest for app navigation and flows, Playwright for public-web flows. Inspect safe areas, larger text, touch targets and reduced motion. Preserve result bundles and screenshots. Do not infer visual approval from automated tests.

Actual iPhone microphone, speaker, camera and full-flow verification are required. Simulator results do not replace them. If physical speech, an unlock or a permission interaction requires the user, prepare the app first, ask for the specific action and continue other work.

Run appropriate tests once, then broaden or repeat only after changes, failures or unresolved concerns. Preserve user data and isolate test fixtures. Record unrelated existing issues without making them project scope.

## Permissions and delivery

The user authorized building this project and installing the requested prototype on their development device. Preserve the host's actual permission rules. Do not send messages to other people. Prepare a concrete reviewable result before any publication approval that remains necessary. Do not purchase services, change account permissions or publish to the App Store implicitly.

There is no requirement to commit, push or tag after every task. Do not modify global model settings or run legacy bypass scripts. Do not create background automations or delegate to subagents without existing authorization.

Before yielding or compaction, update TODO with exact current state, running process identifiers, test evidence, blockers and next actions. Mark DONE only with the task's completion evidence. Use REVIEW for human checks and BLOCKED for unavailable external prerequisites, while continuing independent tasks.

Finish only when all required acceptance criteria and the actual demo journey are verified. Report what changed, how to run it, what was tested and any remaining optional or blocked work. Never claim the project complete while real-device or cross-device requirements remain unverified.

## Release continuation

The user authorized TestFlight and Cloudflare publication at pocket.changhai.me. The Cloudflare Worker/D1 deployment is live. T14 replaces the former manual owner-key setup with automatic installation ownership. See docs/deployment.md and docs/evidence/cloudflare-live.json.

T13 implements a persisted first-launch language choice of device language, Simplified Chinese or English, a home change action, fixed exploration controls and a direct card-to-memory-to-sharing-preview path. All 38 checks have passing evidence, with 93.94% aggregate changed-file Swift coverage. The full regression's map scrolling test passed separately after using a short controlled drag, without an app source change. See docs/evidence/first-use-build3.json.

Version 0.1.0 (3) was uploaded through Xcode 27 RC (27A266a) Organizer. App Store Connect independently shows Testing in Hackathon Internal. The user can update through TestFlight. Next obtain first-use feedback. Apple blocks adding build 3 externally while build 2 remains in Beta App Review. CLI exportArchive returned an account-access error while the GUI succeeded. Do not ask the user to log in again without new evidence. Explicitly use /Users/haichang/Downloads/Xcode.app. The system default is still the old Xcode.

App Store Connect independently confirms build 2 Installed on Hai's iPhone 17 Pro Max, iOS 27. Build 3 first use, speech and camera await user feedback. The external group previously showed build 2 Waiting for Review. The user completed that submission, so do not request the contact telephone again. The public invitation is https://testflight.apple.com/join/83Jzf4WB, limited to three testers. Do not resend email invitations.

## T14 continuation

The user likes the usability changes but cannot test sharing because of the parent key. Follow PLAN T14: remove manual configuration, persist a random installation credential in Keychain and a scoped owner hash per share, preserve old links, verify and deploy Cloudflare plus TestFlight build 4. Do not ask the user for an owner key.

User clarification: remove parental restrictions entirely. Sharing is available directly to the explorer, without parental approval, a parent key or a parent mode. Keep the public preview, optional disclosure choices and background ownership protection against other users revoking a link.

Latest continuation: T14 is released as 0.1.0 (5), independently confirmed Testing in Hackathon Internal. Cloudflare is deployed and verified. All software checks passed. Next obtain phone sharing acceptance after the user updates, while preserving the other outstanding physical-device and human checks. Never reintroduce parental restrictions or ask for a sharing key. Preserve the existing external build 2 review. See docs/evidence/sharing-build5.json.

## T15 repository setup

The user authorized creating an iOS UI repository under Little-Pocket-Explorer and configuring GitHub builds to update TestFlight. Use the private Pocket-Explorer-UI repository. Complete repository setup and verify automated delivery before starting the planned larger changes. Current authorization covers committing and pushing the baseline, configuring CI credentials and running an actual release. Do not change product behavior or cancel the existing external review. Resume from TODO T15.

## Future AI integration

The user selected image deployment gpt-image-2.5-sunburst. PLAN T12 records its endpoint and the source of earlier test evidence. The image key exists only in ignored local ../Pocket-Explorer-Backend/.local/ai/providers.json. Reuse the existing gpt-6-astra / copilot-proxy / xhigh configuration from ~/.codex/config.toml for GPT-6. Credentials must be used server-side and never copied into the app, website, repository or logs. Finish T15 first. This provider selection does not implement live AI, and the prepared demonstration responses remain in place.

External status update: independent API and public-page checks on 2026-09-11 confirm build 2 is IN_BETA_TESTING and public enrollment is available. Earlier pending-review statements are historical. CI automatically updates the internal group, while the external group currently retains build 2. See TODO's external status refresh.

The user confirmed Cloudflare for the future AI backend. Follow PLAN's accepted direction: Workers API and server-side secrets, Queues for durable image generation, R2 image objects and D1 job/relationship state. Backend code should use the existing empty Pocket-Explorer-Backend repository when that implementation begins. Finish T15 before changing product behavior. The current deployment still handles sharing only.

T15 is complete: all three jobs in GitHub run 34571657181 succeeded and automatically released 0.1.0 (6). Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership. All 39 native, 18 web and six browser tests passed, with 93.35% native app line coverage. Future work follows the accepted Cloudflare direction in PLAN, but larger changes and AI integration have not begun. Physical-device and human acceptance remain separate open items. Evidence: docs/evidence/github-setup.json.


## T16: Backend extraction and automatic Cloudflare delivery

Current authorized task: T16 extracts the website and sharing API to ../Pocket-Explorer-Backend and https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend. Follow its PLAN/PROMPT/TODO for deployment setup. Preserve existing Cloudflare resources and domain. Finish a real GitHub-to-Cloudflare release and update native CI to test against deployed Cloudflare. The user authorized commits, pushes and workflow deployment for this setup. Live AI remains future work.


T16 is complete. Website/backend source lives in ../Pocket-Explorer-Backend, where main automatically deploys to Cloudflare after checks. UI CI directly verifies the production sharing API. All 39 native tests passed and automatically released 0.1.0 (7), with independent Apple state and group verification. See docs/evidence/backend-extraction.json. No extraction blocker remains. Future AI work and physical-device acceptance are separate.

## Ordinary Figma plugin route (2026-09-14)

The user authorized an ordinary development plugin using the official Plugin API instead of the quota-blocked MCP write route.
Importing and launching the plugin in the desktop app is authorized. Canvas operations remain API driven.
Reuse sync.js, hotspots.js, the 40 complete source images, and 189 hotspots.
A loopback-only companion serves this sync package and images and records verification using a fresh per-process credential.
Independently read each mutation batch before saving external manifest.json checkpoints. Stop on manual-edit conflicts.
The companion cannot execute arbitrary code. Account and model credentials are never included in the plugin.
Acceptance includes at least 80% changed-code coverage, actual Figma import, independent readback, reruns, and visual inspection.
Current status: native import, readback, unchanged rerun, export, and staging cleanup are complete. Design review continues.

Current amendment: Figma Beta contains 40 screens and 189 hotspots. All 39 JavaScript tests pass, and the native unchanged rerun made zero changes. The 81 hidden staging layers are removed with formal screen signatures unchanged. Actual clicking is verified. Native source-update/conflict checks and alignment of the observed share hotspot remain pending. See design/miro-sync/TODO.md.

# Pocket Explorer: Execution State

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

## Native checkpoint 07 (2026-09-15 03:24 AEST)

- Reproduced duplicate questions after a broken saved photo using the actual UI. Temporarily restoring the old byte-comparison logic made photo-restore-before.xcresult fail on an extra original question. The fix is restored. photo-review-after.xcresult passed 33 unit and three UI tests. PhotoDraft.swift then had 79/79 executable lines covered (100%).
- Fixes cover explicit photo edits, same-photo reselection, failed restore without a new question, visible answered-photo errors, camera disabled during dictation, and removal of redundant main-thread image reads. Additional oversized/download error distinctions are added and under new unit verification.
- Added GlobalLanguageTests.swift. Seven 294-entry catalogs are installed: English, Simplified/Traditional Chinese, Spanish, French, German and Brazilian Portuguese. A full Japanese draft is in native-languages/ja.tsv, not installed. Korean and Arabic are not drafted. Permissions, supplemental messages, native locale screenshots and full regression remain.
- All new native changes are uncommitted and unpublished. Preserve design/miro-sync/. TestFlight remains 0.1.0 (10). Backend is deployed and independently verified, with HEAD 189a8b0, runtime source e245abd and Worker b3305fa0-a350-4119-a82e-b9dc549d6681.
- language-foundation-unit.xcresult is running. Keep the existing port 4197 fixture and 375pt simulator. Next complete remaining catalogs, errors/permissions, language regression and review, continuing through 08:39:34 AEST.


## Web language release checkpoint (2026-09-15 03:13 AEST)

- Cloudflare released e245abd as b3305fa0-a350-4119-a82e-b9dc549d6681 at 100% traffic. Both jobs in GitHub run 34872511954 succeeded. Independent reads confirmed the version tag and exact JS/CSS bytes.
- One real Spanish question about autumn leaf colours answered in 10.949 seconds. GET and raw D1 records match the response. The 390px viewer retained Spanish original content under Spanish, Arabic and Traditional Chinese controls. Revocation returned 410 and the old link still returned 200. This verification used one new question and no new generated image.
- Native actual system-picker selection, preview and removal preserve the question, with a passing UI test and inspected screenshot. Dismissing the keyboard before opening the picker fixed an observed obstruction. Eight photo unit tests previously passed for byte-preserving restore, dimensions, orientation, metadata and lifecycle.
- Completed a new Opus 5 photo review. Valid concerns include same-photo retry, duplicate questions after failed restore, hidden answered-photo errors, camera interrupting dictation and redundant main-thread file reads. Corrections are in progress, with reproductions and regression still required. These drafts are not released.
- Native global language foundations are edited. Five 294-entry locale drafts are installed. Five more catalogs, localized permissions, additional language/data-preservation tests and full regression remain. TestFlight is still 0.1.0 (10).
- Next: finish photo review regression, complete native languages, inspect screenshots and release from this Mac. Formal backend evidence: docs/evidence/languages-and-recovery.json. The production Web inspection also found a large blank decorative area on generated cards without an illustration, retained as a later visual-polish task.


## Refinement checkpoint 06 (2026-09-15 02:53 AEST)

- Web now has ten complete languages: English, Simplified and Traditional Chinese, Spanish, French, German, Brazilian Portuguese, Japanese, Korean and Arabic. Original content, old shares, manual preferences and RTL are preserved. The API accepts the same locales. Native language expansion is not released yet.
- Passed 82 unit/integration and 18 browser tests. Line coverage 99.26%, branches 95.62%, with per-file gates passed. Two artwork browser tests and Worker dry run passed for this increment before the final viewer/storage-only fixes.
- Reproduced and fixed indefinite share loading, stale responses restoring revoked content, card-save failure and overwritten unknown/corrupt collection data. Two Opus 5 reviews completed, with verified findings and translation corrections applied. Failed public revalidation still hides content until visibility can be confirmed rather than treating it as an offline snapshot.
- Native maximum-text regression passed. Photo UI verification reached the actual system picker and fictional fixture, but the system image node rejects ordinary tap. Continue using its observed center coordinate. TestFlight remains 0.1.0 (10).
- Preparing this Web candidate for publication. GitHub workflow and independent Cloudflare readback remain. Continue native photo and multilingual work through 08:39:34 AEST.


## Local release checkpoint (2026-09-15 02:25 AEST)

- Released TestFlight 0.1.0 (10) from this Mac. Independent Apple readback confirms VALID / IN_BETA_TESTING and Hackathon Internal assignment. Build ID: 04b7d1e3-ec88-427b-8254-7618dc0cebcc. Native source is b8e1d1f, pushed with [skip ci]. No GitHub iOS runner was used.
- Actual IPA readback confirms RC 27A266a and SDK 24A430. Signature, unchanged source and temporary signing-keychain removal passed. IPA SHA256: 4091d3aedf853a6e4b0652dd067613e9be21041117173e93540f0163b4f1dbb5. Local artifacts: ~/tmp/review/pocket-release-polish-10/.
- Continuing candidate two: ten-language Web drafts are integrated and under test/review. Four regressions reproduced against the released viewer: indefinite loading, old successful response restoring revoked content before/after body parsing, and browser storage failure trapping card reveal. Language changes are not deployed and are not yet available in iOS.

## Refinement checkpoint 05 (2026-09-15 02:11 AEST)

- First candidate regression passed: 68 unit tests and 24 UI tests, zero failures. One actual recording integration test explicitly skips the reproduced simulator AudioUnit environment crash. It is not a physical-recording pass. Result: ~/tmp/review/pocket-polish-20260915/full-regression-2.xcresult.
- App line coverage is 4480/4860 (92.18%). Changed/new native files total 2662/2835 (93.90%). VoiceSession whole-file coverage is 73.40%, while changed executable lines are 34/42 (80.95%). Hardware branches remain in the denominator.
- Inspected final artwork recovery, live answer and maximum-size text screenshots. The visible live answer independently matches the latest D1 result. Scanned 122 candidate files without finding configured service credentials.
- Next UI critique: at maximum accessibility text size, the answer's two fixed bottom actions consume too much reading space. Also investigate asynchronous photo-selection races and repeated full-data image decoding.
- Preparing the first local TestFlight refinement release, not uploaded yet. Backend recovery is deployed, while new language contracts remain unpublished. Continue global languages and those interaction defects after publication through 08:39:34 AEST.

## Refinement checkpoint 04 (2026-09-15 02:02 AEST)

- Completed recording controls: current code aborts in AudioUnit RPC initialization on iOS 26.4 and iOS 27, after restarting simulator audio and with the built-in microphone selected. The temporary input change was independently restored to original device 107. Isolated worktree ~/Worktrees/Pocket-Explorer-UI-audio-baseline at released commit 3e9d144 reproduces the identical system crash stack. It cannot be attributed to this refinement. Physical recording remains unverified.
- Retained the explicit POCKET_RUN_LIVE_MICROPHONE integration test. Ordinary regression reports its environment-specific skip rather than deleting it or claiming a pass. Fixed the independent review's interruption-type issue: handle began, ignoring ended and malformed notifications. The old handler reproduced unwanted callbacks, and the fixed unit test passes.
- Native full-regression-2.xcresult is running, with 68 unit tests passed. Live production question verification without image generation and live sharing are enabled. One microphone environment skip is expected. Final coverage is not read yet and no new TestFlight is uploaded.
- Backend reliability fixes are published through workflow and independently verified. Latest documentation commit is 1acb3af, with runtime source d1e01cd. B08.1 now adds ten-locale resolution, AI validation and original card/chapter language metadata while preserving old v1 shares and canonical protocol chapter titles. The stale JSON Schema is aligned. All 67 backend tests pass, 99.02% lines and 94.83% branches, with 100% in added locale and changed contract files. Language changes are unpublished and native/Web language interfaces remain outstanding.
- Next: collect full native results and screenshots, verify coverage and the real answer, record review and publish the first polish build locally, then continue global languages and photo-input details. The existing fixture process on 4197 remains active. Do not start duplicates or trigger GitHub iOS workflows.

## Refinement checkpoint 03 (2026-09-15 01:44 AEST)

- Reproduced an additional real R2 upload race: an old upload finishing after a newer retry overwrote the newer picture. Conditional R2 writes now keep completed pictures immutable, verified against actual Miniflare R2. All 61 backend tests pass, with 99% lines and 94.63% branches. Build and final deployment checks are continuing.
- Full native regression passed 65 unit tests. Of 23 UI tests, one live AI test was deliberately skipped and one microphone permission-reset test failed. The relaunch-after-reset fix passed independently. New actual speech playback completion and cancellation checks passed.
- A deeper microphone test triggered an AudioUnit RPC timeout and abort on the iOS 26.4 simulator, at system input initialization. Investigation continues without attributing it to the physical app or claiming microphone acceptance. Missing-image fallback is visible in screenshots and coverage, while the UI assertion is being adjusted to inspect the separate accessible photo section.
- Final Opus 5 review was read. The duplicate paid artwork claim contradicts the server unique constraint and concurrency tests and is not accepted. Card saving is idempotent, while its displayed state is being checked. Allowance exhaustion being mislabeled as a network issue is valid and now has a regression test under development. TestFlight remains build 9. Native changes are not committed, pushed or released.
- Next: publish and independently verify the backend, resolve native audio environment and allowance feedback, obtain a clean regression and coverage result, then publish locally and continue language and UI refinement within the eight-hour window and five-minute checkpoints.

## Refinement checkpoint 02 (2026-09-15 01:13 AEST)

- Verified Opus review model `databricks-claude-opus-5`. Five additional regressions reproduced its stale-question, ambiguous queue acknowledgment and concurrent-create findings, then passed after fixes. Also verified concurrent explicit retries and POST recovery of abandoned questions. Backend now passes 60 tests, 99% lines / 94.63% branches, per-file gates and build. The two-minute queue deadline deliberately remains bounded, with explicit recovery after expiry rather than unlimited waiting.
- Native voice selection now prefers available enhanced/premium female voices, excludes novelty/personal voices, retains the answer's saved language and adds gentle sentence pacing. Eighteen targeted voice/style/artwork tests passed. Actual English and Chinese synthesis produced non-silent audio and independent audio-file readback passed. Samples: `pocket-polish-20260915/gentle-system-en.wav` and `gentle-system-zh.wav`. The simulator only has basic voices, so subjective naturalness and enhanced voices on the iPhone remain unverified.
- Azure model catalog is accessible, but an actual `gpt-4o-mini-tts` synthesis request returned 404 `DeploymentNotFound`. The previously tested reasoning speech route also returned 404. No cloud TTS dependency has been added and no unsupported-platform claim is made.
- Added a true overall question deadline, cancellation, truthful failed-answer and quota messages, and saved-question pause/resume. Twelve client contract/recovery tests passed. First UI run caught a parent accessibility identifier overriding the Later button's identifier. Corrected it and its touch target. Seven unit and six UI checks with asynchronous cached image rendering are now running in `question-and-cache-2.xcresult`.
- Next: inspect those screenshots and results, complete microphone finishing/input preservation and home entry intents, then run full native coverage and independent review before local TestFlight release. Current release is still build 9. Focused Opus voice/question review is running. No production deployment or additional image generation occurred.


## Refinement checkpoint 01 (2026-09-15 00:59 AEST)

- Reproduced and fixed permanent polling loss after a transient artwork read failure, repeated unchanged journal writes, and the off-screen primary action on the 375pt phone. Native targeted verification: 13 unit and three UI tests passed in `~/tmp/review/pocket-polish-20260915/artwork-after-3.xcresult`. Exported screenshots confirm a persistent View Card action. Waiting, failed and exhausted illustrations retain readable cards and memories.
- Reproduced and fixed expired queue deliveries starting paid work and stale provider successes/failures overwriting explicit retries. Backend: 53 tests passed, 98.98% lines / 94.94% branches, per-file gates and build passed. No production deployment yet.
- Independent Opus 5 review is running with a smaller focused source bundle. Continue with polling backoff, warm speech and input lifecycle, then full native coverage and UI review before release. Current TestFlight remains build 9.


## Active eight-hour refinement (2026-09-15)

The user now authorizes implementation and repeated refinement through 2026-09-15 08:39:34 Australia/Sydney. This supersedes the planning-only checkpoint below. Prioritize rough interactions, gentle child-friendly speech, and slow or stuck image generation, then advance global multilingual quality within the same core journeys. Accounts and friend chat remain deferred.

- IN_PROGRESS T21.1 / B09.1: reproduce and fix artwork progress, deadlines, lost polling and safe retry. Preserve saved cards, avoid duplicate provider work, and test offline, timeout, relaunch and concurrent jobs.
- NEXT T21.2 / B09.2: improve voice selection, pacing, content-language replay and speech lifecycle. Evaluate available natural speech capabilities before adding a provider dependency. Missing speech must retain reading and typing.
- NEXT T21.3: inspect and polish the complete native flows, including loading/error/empty states, primary actions, scrolling, touch targets and image rendering. Then integrate T20/B08 language foundations as useful increments.
- REQUIRED for each candidate version: meaningful reproduction, targeted tests, coverage gates, actual UI screenshots and critique, fixes, regression and independent release readback. Use the user-authorized cl -p Opus 5 CLI as an independent reviewer. Reviewer opinions require verification.
- Current release remains 0.1.0 (9). Publish TestFlight only from local Xcode 27 RC build 27A266a. Preserve existing Cloudflare workflow, private credentials, journals, links and untracked Miro sync work. No teammate messages or new purchases.
- Review artifacts: ~/tmp/review/pocket-polish-20260915/. The five-minute heartbeat is ACTIVE until the deadline. Continue useful independent work across increments, rather than stopping after one upload or repeating unchanged checks.

## Latest request checkpoint (2026-09-15)

- DONE: assessed implementation gaps and recorded global multilingual support as an accepted requirement. See [assessment](docs/next-iteration.md) for source evidence, local contract probes and task dependencies.
- PLANNED: T20.1 extensible languages, complete copy and content-language metadata. Currently only English/Chinese have 239 localization keys each.
- PLANNED: T20.2 speech following input/content language, available regional voices and explicit fallback.
- PLANNED: T20.3 long text, RTL, translation quality, physical-device acceptance and subsequent local release. Depends on backend B08.1/B08.2.
- REVIEW: build 9 physical iPhone microphone, speaker, camera, VoiceOver, mobile Safari and visual approval remain pending. No new physical-device success is claimed by this assessment.
- Documents only: no runtime edits, provider calls, commits/pushes or releases. Continue from the next development instruction or specific device issue. Notifications, nearby destinations, achievements, tags, versions, accounts and social features form a later backlog, not an instruction to start them all.

Release amendment: the user requires this TestFlight build to be archived and uploaded from this Mac because GitHub runner quota is exhausted. Run native checks locally and independently verify Apple processing. Do not trigger a GitHub TestFlight release for this iteration.

## Active implementation: Miro and live AI (2026-09-14)

The user now authorizes real native implementation, including live question answering and generated card artwork. This supersedes all earlier design-only restrictions and optional-AI statements below. Miro remains the visual and flow authority. Figma contains all 40 source screens and 189 hotspots, verified by native plugin readback. Older one-screen and blocked-delivery statements are historical.

Current scope is exploration, cards, maps, memories and public link sharing. Real accounts, friend relationships and cross-account chat are explicitly deferred. Preserve English, Simplified Chinese, the language chooser, existing journals and existing public links. Do not add parental keys, approval gates or controls. Use real SwiftUI controls and layouts, with decorative artwork. Full-screen source screenshots are references, not the app implementation.

## Current delivery checkpoint (2026-09-14, 23:30 AEST)

- RELEASED: TestFlight 0.1.0 (9), built and uploaded from this Mac using Xcode 27 RC (27A266a). Apple independently confirms COMPLETE / VALID / IN_BETA_TESTING and Hackathon Internal assignment. Build ID: 8d4ac344-cfc6-4350-be18-72c40d65b32c.
- VERIFIED: 41 unit and 13 UI tests under the actual RC, zero failures or skips, 90.87% application line coverage. The suite includes the native App using production Cloudflare sharing, an independent read and revocation. Physical iPhone acceptance remains separate.
- RELEASED: Cloudflare Worker 1db2b9bd-29b4-46af-9782-c95eae7a4f6d at 100% traffic, source f5a41585ed6488bc22d099cefd43345e01eb2c83. GitHub run 34847308507 passed checks, deployment and live verification. Litian's upstream Web demo is preserved.
- VERIFIED: 48 backend unit/integration tests, seven browser tests and two artwork browser tests. Coverage is 98.94% lines and 95.73% branches, with every source-file gate passing. Production question, generated image, private ownership, public image byte equality, desktop/mobile browser display and revocation passed. Final asset hashes match and existing links survive.
- Server-side AI secrets, private R2, Queue and additive D1 migration are deployed. The cumulative allowances remain 120 questions and 18 image attempts. Independent readback shows one production question and one image used. No new subscription was purchased, and no GitHub iOS runner was used.
- Release package signature, bundle/team, expected RC build, source hash 5c3f60ac02cea8e8266b4badccc4affa45091244a25b708da5f2680e18d48770 and absence of configured credentials were independently verified. The temporary signing keychain is removed. Native test fixtures are stopped and the test simulator is shut down.
- Corrected a toolchain mismatch: build 8 used the system's Xcode 27 Beta 1 and was rejected with 90534. The downloaded RC now resides at /Applications/Xcode-27-RC.app. Local releases require an expected Xcode build and include failed uploads when choosing the next build number. Six release-helper tests passed with 97% executable-line coverage.
- REVIEW: physical iPhone microphone, speaker, camera, VoiceOver, mobile Safari and human visual approval. Accounts, friend chat and card version history remain deferred. V1 is a visual badge. No further provider calls or releases are needed without a new issue or requested change.
- The five-minute heartbeat remains available through 2026-09-15 09:41 AEST for new failures or feedback. With automatic delivery verified, stay quiet while only human review is pending. Do not repeat the completed tests or publish another build merely to remain busy.

Next: use TestFlight build 9 for the remaining physical-device review. Current evidence is docs/evidence/miro-live-ai.json. Local release artifacts are under ~/tmp/review/pocket-release-rc-upload/, RC regression under ~/tmp/review/pocket-native-rc/, and production evidence under ~/tmp/review/pocket-production-release/.

## Historical release checkpoint (2026-09-14, 23:00 AEST)

- IN_PROGRESS: local TestFlight archive/upload and Apple processing verification. Production live AI, generated artwork and sharing are verified. The user explicitly directed delivery to proceed without more pricing investigation.
- DONE: read-only Cloudflare preflight implementation and atomic persistent allowances. All 42 backend tests passed, with 99.01% lines and 97.15% branches. Three new guard tests reproduced the old failures before passing after the fix. Native regression remains 41 unit plus 13 UI tests, 90.87% app lines.
- DONE: R2 is active. Created and independently read the private pocket-explorer-artwork bucket and queue. R2 managed domain is disabled and there are no custom bucket domains. Expanded the existing scoped deployment token with R2 and Queues rights without changing its value. Provisioned the two AI Worker secrets and preserved OWNER_KEY.
- DONE: additive D1 migration and Worker/assets deployed, version ab41bcce-aca5-4562-bff5-8dc2db0c1f96 at 100% traffic. Queue consumer setup initially returned error 10063 because this account lacked a workers.dev subdomain. Registered pocket-explorer-changhai and independently verified the consumer binding. The Worker workers.dev endpoint and previews remain disabled.
- DONE: production GPT-6 question in 8.735 seconds, one real 1024x1024 Azure image in 43.745 seconds, D1 job readback, private ownership isolation, public image byte equality, mobile/desktop browser display and revocation. Existing links and the production browser regression passed. Production counters show one question and one image used.
- DONE: integrated Litian's upstream Web card demo (5951bf2), retaining its prepared questions and collection. Corrected the prepared-subject type mismatch and browser-storage unit-test setup. Merged build, 48 unit/integration tests, seven browser tests and two artwork browser tests passed. Coverage: 98.94% lines and 95.73% branches, all per-file gates passed. GitHub run 34847308507 passed and deployed f5a41585ed6488bc22d099cefd43345e01eb2c83 as Worker version 1db2b9bd-29b4-46af-9782-c95eae7a4f6d. Final generated-story verification reused the existing image and passed. Assets match the local build, old links remain live and AI counters remain at one each.
- DONE: local 0.1.0 (8) package uploaded successfully to Apple at 23:05 AEST. Signature, distribution identity, unchanged source hash and client credential scan independently passed. Apple build processing and internal group confirmation remain in progress.
- Current total allowances are 120 question attempts and 18 image attempts across the demo. Existing daily and installation limits also apply. These limits are not a verified monetary hard cap. Do not reset the counters or generate unnecessary images.
- The user-requested five-minute heartbeat pocket-explorer-5 remains active until 2026-09-15 09:41 AEST. Pause early only on verified completion. Do not trigger GitHub iOS builds or releases. Preserve preexisting staged documents and untracked Miro sync work.
- REVIEW: physical iPhone speech, speaker, camera, VoiceOver, mobile Safari and human visual approval. Accounts and friend chat remain deferred.

## Historical local checkpoint (2026-09-14, 22:33 AEST)

- DONE: final native regression, 41 unit plus 13 UI tests, zero failures or skips. App line coverage is 90.87% (3753/4130). Evidence: pocket-native-t19/final-regression.xcresult, final-summary.json and final-coverage.json.
- DONE: iOS 27 large-screen checks, 41 unit plus seven UI tests, actual system Reduce Motion, both languages, large text, map selection and card/answer/share journey. This subset is not the aggregate coverage gate. A subsequent focused test reproduced the 38pt home action, then verified the 44pt fix for the microphone and profile buttons. The duplicate home action was removed.
- DONE: one native UI test connected directly to local workerd and the real GPT-6 provider. The displayed shadow answer was independently read from the app journal and D1 and matched exactly. No additional image was requested. Evidence: native-live-worker.xcresult and native-live-independent.json.
- DONE: final local signed archive, version 0.1.0 (8), SDK iphoneos27.0. Independent IPA signature, bundle/team, get-task-allow:false, source hash and temporary-keychain removal passed. The final source hash is bf3147961f69af5c720063ae455459522cddfde552365c7e29e7d37985f818b9. The earlier archive is superseded by ~/tmp/review/pocket-release-final-archive/.
- DONE: backend 34 tests, six existing browser tests, two generated-artwork browser tests, 98.91% lines and 96.86% branches. Actual local workerd completed question, queued generation, private image, public share and revocation. Three image calls total. The final source and client credential scan found no configured secrets.
- BLOCKED: production AI rollout and TestFlight upload. The final R2 read at 22:23 AEST still returned HTTP 403 / error 10042, Please enable R2 through the Cloudflare Dashboard. Existing sharing remains deployed. No new production resources, secret changes, deployment, commit, push or TestFlight upload occurred.
- REVIEW: physical iPhone speech, speaker, camera, VoiceOver, human visual approval and mobile Safari. Accounts and friends remain deferred. V1 is a visual badge, not version history.
- The user authorized dismissing future crash dialogs with Ignore, Cancel or Close while retaining diagnostics. No dialog was present at the last check. The 21:40 PocketExplorer report points to the old guide unit test assertion, which was corrected and passed later runs.
- A subsequent CUA check was denied by tool safety policy for com.apple.UserNotificationCenter. No system crash dialog was inspected or dismissed in that attempt. Do not bypass the restriction. If such a dialog blocks work, the user must close it manually.
- Final overview: design/review/miro-native-overview.png. Formal evidence: docs/evidence/miro-live-ai.json. Local walkthrough: docs/implementation-review.md and its Chinese review copy. Test-only servers on 4197/4199 are stopped and both test simulators are shut down. The original design preview is preserved. No background loop or heartbeat was created.

Current next action: follow the running local upload in ~/tmp/review/pocket-testflight-upload.log and ~/tmp/review/pocket-release-upload/. Independently verify Apple VALID plus Hackathon Internal assignment, finalize documentation and publish the source without a GitHub iOS run. Do not use GitHub TestFlight runners. Preserve the existing staged documents and untracked Miro sync work.

## Historical plan and evidence

## Current design authority (2026-09-14)

The user confirmed that [the Miro board](https://miro.com/app/board/uXjVHn9F6EQ=/) is the source of truth for UI design and flows. Figma Review 01 is an interaction example only. This decision supersedes conflicting visual baselines and Figma continuation instructions below, while explicit user decisions still take precedence over board content. The current phase is design and prototype review. Any new clickable prototype must follow Miro, and the existing Figma example does not establish completion of that work.


## T18 BLOCKED: Figma delivery, local hotspot prototype ready

- The user accepted whole Miro images with transparent hotspots. Raster extraction is out of scope.
- Latest source snapshot: 40 images, 146 frame items, and 47 connectors. Two images were added and two replaced.
- Local prototype: http://127.0.0.1:4186/preview.html. All 189 hotspots were clicked in browser tests. All 39 interactive screens are reachable from Chat home. Screen 33 is reference only.
- JavaScript: 25 tests passed, 100% lines in sync.js and hotspots.js. Python: 12 tests passed, prepare.py 96% lines. Mobile layout, keyboard, back navigation, and zero browser errors were verified.
- The latest read-only Figma API call still reports the Starter MCP tool-call limit. The remote page still contains only the older six-layer Chat home. No remote update occurred.
- Preserve design/miro-sync/manifest.json. It retains the real mapped nodes, 81 uploaded assets, and 81 hidden staging nodes.
- Continue from design/miro-sync/TODO.md for actual Figma import, navigation, real-file rerun checks, and recorded design gaps.
- No App or Backend implementation, deployment, commit, push, or scheduled automation occurred.

## T17: Figma prototype delivered for team review

- [Editable design file](https://www.figma.com/design/Q0JYCcihpvABSCsPnnz4bw/Pocket-Explorer-%C2%B7-Review-01?node-id=1-3), in Hai Chang's team / Team project.
- [Clickable presentation](https://www.figma.com/proto/Q0JYCcihpvABSCsPnnz4bw/Pocket-Explorer-%C2%B7-Review-01?node-id=1-3&scaling=min-zoom&content-scaling=fixed&page-id=1%3A2&starting-point-node-id=1%3A3&show-proto-sidebar=1): 48 screens, 170 native navigation links and five flow starts.
- Independent native read confirmed 474 editable text layers, zero invalid navigation destinations and zero text-bound overflows. Eight same-state targets intentionally have no native navigation.
- Fixed native font rewrapping. Five importer/specification tests passed with 100% line and 95.08% branch coverage.
- Actual Figma presentation checks covered question to saved journal, incorrect answer to card, map to memory and public sharing, and friend card gifting. The desktop public story was visually inspected. The browser preview additionally covered both quiz outcomes and every disclosure combination.
- Figma access is currently limited to the team. No new collaborators were invited. Speech, AI, messages and copy actions use design states.
- Design and evidence directory: /Users/haichang/.gstack/projects/pocket-explorer/designs/figma-review-20260911. Human visual and product-rule review remains pending. Application code and deployments were not changed.

## T17 in progress: earned card unlock loop

- Product direction: the Hackathon Web experience is a required complete review surface, while the iPhone app provides the synchronized native experience. Core card-flow UI changes must be implemented in both repositories.
- Native implementation now separates saving a completed observation from revealing its earned card. The child reaches a dedicated locked-card stage, explicitly reveals the card, and then continues to the existing card, memory and sharing flow.
- Newly earned discoveries persist an unlock timestamp, exploration origin and initial `fieldFind` tier. All fields are optional so existing journals remain decodable. Public-story exports continue to exclude private journal and unlock metadata.
- Card faces now show the tier, origin and unlock date. The reveal uses a finite animation and immediately reaches the same result when Reduce Motion is enabled.
- Added unit coverage for metadata persistence, legacy JSON decoding and public export boundaries. Updated English, Simplified Chinese and the affected end-to-end UI paths.
- Windows validation passed: editor diagnostics report no errors in touched Swift files; all four shared JSON files parse; both localization files contain 152 unique keys; `git diff --check` passes.
- Matching Web implementation: the Backend root route now provides question entry, optional local image selection, short prepared answers, observation entry, an unlock stage and a persistent local Collection. The public `/s/:token` version 1 sharing route remains unchanged.
- Web verification passed on Windows: 24 unit/integration tests, 7 Chromium browser tests, 99.59% lines and 95.68% branches. The mobile unlock screenshot has no detected overflow or overlap.
- REVIEW: native XCTest, XCUITest, coverage and visual results still require the macOS CI workflow. Do not treat Windows diagnostics as an iOS build result.

## T16 complete: repository extraction and automatic delivery

- Website, sharing Worker, D1 migrations and web tests now live in [Pocket-Explorer-Backend](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend). UI retains native source and native shared resources.
- Backend [run 34575491870](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend/actions/runs/34575491870) passed and deployed https://pocket.changhai.me. Live create, independent read, playback, card flip, revocation and the existing example passed. Original D1 and secret bindings remain intact.
- UI [run 34575779608](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-UI/actions/runs/34575779608) passed all three jobs with 26 unit and 13 UI tests, zero failures. It released 0.1.0 (7). Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership, matching the release artifact.
- Main code pushes run checks before automatic publication. Documentation-only pushes do not publish. Credentials remain server-side.
- Evidence: docs/evidence/backend-extraction.json and Backend's docs/evidence/cloudflare-migration.json.
- No extraction blockers remain. Live AI, Queues and R2 remain future work. Physical-device and human acceptance remain separate.

## T15 delivery history

- Renamed pocket-explorer-ios-ui to Pocket-Explorer-UI at the user's request. An organization-admin read confirmed the older same-name repository was already absent, so no deletion was performed in this turn. Independent reads verified the repository ID, main commit, successful Actions run, testflight environment and six secret entries were preserved. Local origin and documentation links are updated.

- DONE: GitHub repository and automated TestFlight delivery. GitHub released 0.1.0 (6), independently confirmed Testing internally by Apple. Product behavior is unchanged.
- Accepted haha1903's organization invitation. Created and independently verified private repository with ADMIN access: https://github.com/Little-Pocket-Explorer/Pocket-Explorer-UI.
- Created a dedicated Apple API key, distribution certificate and App Store profile, independently verified through the API. Certificate and profile expire 2027-09-11. Configured and independently listed six GitHub testflight environment secrets. The environment accepts main only.
- Workflow, Fastlane and scripts are implemented. actionlint, shellcheck, Ruby syntax and lane loading passed. Pinned Xcode 26.6, XcodeGen 2.46.0 with SHA-256 verification and Fastlane 2.239.0. Npm tarball URLs use the public registry with versions and integrity values unchanged.
- Published main at code revision 1eecb89134c2b7f6ec866bcb5d36c6f71ea23b7f. The remote tree independently contains 148 files. The first-commit sensitive-content audit passed with no credentials, databases or generated projects tracked.
- Current run: https://github.com/Little-Pocket-Explorer/Pocket-Explorer-UI/actions/runs/34571657181. Web checks passed: 18 tests, six browser tests, 100% lines and 98.91% branches. Native regression passed all 39 tests with 2823/3024 app lines covered (93.35%). The release job completed successfully. Two earlier runs were superseded and canceled after configuration fixes.
- All three GitHub jobs succeeded. Native regression passed 26 unit and 13 UI tests with 93.35% app line coverage. Web passed 18 tests and six browser tests with 100% lines and 98.91% branches.
- The release result matches independent Apple reads: 0.1.0 (6), build ID 23b9c4d3-3b0c-4244-82f0-67607854ac88, VALID / IN_BETA_TESTING, assigned to Hackathon Internal. Remote testing notes identify the workflow source commit. Signing cleanup passed. Evidence: docs/evidence/github-setup.json.

States: TODO, IN_PROGRESS, BLOCKED, REVIEW, DONE, DEFERRED. DONE requires evidence. Simulator checks cannot replace real-device or public-sharing acceptance.

## Current checkpoint

- Objective: Deliver a complete Hackathon Web experience and a synchronized enhanced iPhone exploration experience.
- Current stage: T17 card unlock loop is implemented in both SwiftUI and Web. Web checks pass; native changes await macOS CI.
- New skill: /Users/haichang/.codex/skills/codex-project passed structural validation. Legacy codex-bootstrap is preserved.
- Local preview: http://127.0.0.1:4174/s/EDYeU5SzHaXpMEy1XAx9WqvE1Grjrmv3. This is accessible on this Mac only.
- Running processes: UI GitHub run 34575779608 and its local watcher exited successfully. The preview on port 4174 now runs from ../Pocket-Explorer-Backend (PID 17900). Its existing story was independently read before and after migration with identical SHA-256. The original SQLite file remains as a local backup.
- Next action: continue Miro-based design and prototype review. Retain native PR validation, TestFlight review and iPhone-browser Web testing as implementation follow-ups when requested. Live AI integration has not started. Phone sharing, speech and camera acceptance remain separate.
- Prerequisites: external build 2 is now confirmed IN_BETA_TESTING and public enrollment is available. External distribution of later builds is managed separately. Physical-device and human acceptance remain open.
- Human checks: Visual approval, VoiceOver, actual device speech/camera, mobile Safari and the two-minute full rehearsal.

## Tasks

| Task | State | Work | Evidence and remaining work |
| --- | --- | --- | --- |
| T00 | REVIEW | Device setup and installation | Build 2 installation was confirmed earlier. Build 7 is Testing internally. Await user update and phone acceptance. |
| T01 | REVIEW | Visual baseline and original assets | Native and web captures exist. Human visual approval is pending. |
| T02 | REVIEW | Native shell and accessibility | Navigation and large text passed on the main simulator and at 375pt and 390pt. Human VoiceOver inspection remains open. |
| T03 | DONE | Stable journal and persistence | Independent file reads, failed-write rollback, stable IDs, editing and process relaunch passed. |
| T04 | BLOCKED | Voice and camera exploration | Permission, cancellation, interruption and adapter tests pass. Actual iPhone recording, playback and camera still require the connected device. |
| T05 | DONE | Reveal, reverse and collection | Card content, relaunch and actual system reduced-motion checks pass. |
| T06 | DONE | Map and trip journal | Sourced MapKit positions, trip list and marker selection on both small-screen sizes pass. |
| T07 | DONE | Memory construction and playback | Deterministic chapters, order, idempotence, pause, replay and manual navigation pass. Playback tasks cancel on exit/background. |
| T08 | DONE | Later-visit resurfacing | Seven-day boundaries and persisted dismissal pass. Release compilation excludes the DEBUG time controls. |
| T09 | DONE | Durable authenticated sharing | Actual SQLite, independent reads, reopen, authorization, field allowlist and revocation pass locally. Workers/D1 is deployed. Public HTTPS create, independent read, allowlist and revocation passed. |
| T10 | REVIEW | Sharing preview and public viewer | An app-created local URL opened in independent Chromium. Live browser testing and native Cloudflare create, independent read, copy, revoke and HTTP 410 passed. Real-device mobile Safari inspection remains pending. |
| T11 | REVIEW | Final verification and delivery | Pre-release native baseline: 29 passed, 92.97% Swift line coverage. Release edits have separate targeted checks. Current web tests: 14 passed, plus 6 original browser tests and 1 live browser test. Device, visual, VoiceOver, mobile Safari and timed rehearsal checks remain. |
| T13 | REVIEW | First-use usability correction and language choice | User reports improved usability. Automated evidence remains in first-use-build3.json. Physical speech/camera and other human checks remain open. |
| T14 | REVIEW | Sharing without parental restrictions or manual setup | Released as 0.1.0 (5), Testing internally. Cloudflare and native sharing verified. Phone acceptance awaits user update. |
| T15 | DONE | GitHub repository and automated TestFlight delivery | All three GitHub jobs passed. Apple independently confirms 0.1.0 (6) Testing internally. See github-setup.json. |
| T16 | DONE | Extract Backend and automate Cloudflare delivery | Backend deployment and UI live integration passed. Apple independently confirms 0.1.0 (7) Testing internally. See backend-extraction.json. |
| T17 | REVIEW | Earned card unlock loop in Web and SwiftUI | Web implementation and full local tests pass. SwiftUI implementation and static checks pass; macOS native tests, TestFlight and human review remain. |
| T12 | DEFERRED | Optional live AI | Prepared duck, leaf and shell answers are explicitly labeled. A live generative service is optional. |

Task dependencies and the unchanged acceptance contract remain in PLAN.md and ACCEPTANCE.md.

## Verification evidence

- Native regression baseline before deployment edits: 29 passed, zero failures and zero skips, /Users/haichang/tmp/pocket-final-tests.xcresult. Swift app coverage is 2316 / 2491 lines, or 92.97%. The current unsigned Release build also passed.
- Four large-text and map-marker runs passed at 375pt and 390pt. Actual system reduced motion passed in pocket-motion-tests-2.xcresult and the final regression.
- Final evidence index: docs/evidence/final-checks.md. Native overview: design/review/native-overview.png.
- New skill: official quick_validate.py returned Skill is valid after the final workflow update.
- Initial core run: 11 passing tests, /Users/haichang/tmp/pocket-core-tests-1.xcresult.
- Native combined run: 24 passing tests, no failures, /Users/haichang/tmp/pocket-tests-3.xcresult. App Swift line coverage was 90.78% for that source revision.
- Native sharing integration: app-created URL, separate HTTP read, actual browser open, copy and revocation passed in /Users/haichang/tmp/pocket-share-integration-5.xcresult. Browser evidence: /Users/haichang/tmp/pocket-app-browser-evidence.json.
- Native large-text and empty-state checks also passed in the later mixed run. That full run is not counted as successful because its sharing test failed and another test was interrupted.
- TypeScript: npm test passed 10 tests, 100% of 116 executable source lines, 98.26% of 115 branches. Instrumented files: server/app.ts, server/store.ts, src/App.tsx, src/story.ts. Entrypoint wiring is exercised by browser startup.
- Browser: npm run test:browser passed all 6 tests at 375, 390, 768 and 1440 CSS pixels, including keyboard focus and 44px controls.
- Device Release compilation passed with CODE_SIGNING_ALLOWED=NO. This is not an installation. Release strings exclude the DEBUG time controls.
- Detailed records: docs/evidence/native-checks.md, docs/evidence/web-checks.md and design/review/device-setup.md.
- Review captures: design/key-screens. Human review: design/review/visual-review.md.

## Resolved implementation and test issues

- Documents-based DerivedData caused signing metadata errors. Use /Users/haichang/tmp/pocket-explorer-build.
- Compact MapKit interaction captured journal scrolling. Disabled panning in the overview while preserving marker taps.
- Delayed permission and speech callbacks could affect newer sessions. Generation checks and tests now isolate canceled work.
- An iOS Save Password sheet runs in SafariViewService. The integration test explicitly declines that optional prompt before continuing. It does not save test credentials in Passwords.
- An overlapping simulator test run interrupted another runner. Those results are excluded from success evidence. Subsequent runs use one owner per simulator.
- npm initially failed against the direct registry. Installing through the configured Microsoft package feed succeeded.

## Delivery limits

Current build 0.1.0 (6) is Testing in Hackathon Internal. The website is deployed, sharing no longer has parental restrictions or manual setup, and software checks passed. Phone sharing, physical speech/camera, VoiceOver, mobile Safari and the timed rehearsal remain unverified. External build 2 is now confirmed IN_BETA_TESTING, and the public invitation is available. T15 authorizes repository creation, commits and pushes. No public App Store release, live AI integration or teammate messages were performed.

## Release checkpoint (build 2 history)

- Live origin: https://pocket.changhai.me. Example: https://pocket.changhai.me/s/DmprLZx_BvlA75rki9n7MqFdl1b4U4hn.
- Worker version: c471f56e-cd4b-4952-932a-8552e17daf80. D1: 3868d2a6-c38c-42b9-97f2-c6e5d3850a1c.
- All 14 web tests passed. Source line coverage is 100% and branch coverage is 98.85%. Worker coverage is 100% for both. Production dependency audit reports no known vulnerabilities.
- Live native sharing passed in /Users/haichang/tmp/pocket-cloudflare-share-2.xcresult. Changed ParentShareView.swift coverage is 350 / 367 lines, or 95.37%. The earlier full regression was interrupted after a simulator white screen and is not counted as successful.
- Apple Developer agreement acceptance was independently verified for 2026-09-11. The App Store Connect app is Pocket Explorer (6810920731), bundle ID com.haichang.pocketexplorer, under paid team 5B858997A3.
- Current release: 0.1.0 (2), built with Xcode 27 RC (27A266a). Archive: /Users/haichang/tmp/PocketExplorer-RC-build2.xcarchive. Log: /Users/haichang/tmp/pocket-testflight-rc-archive.log.
- Independent archive verification confirmed arm64, UIDeviceFamily [1], encryption exemption, privacy manifest and the correct team. codesign --verify --deep --strict passed. ios/project.yml sets iPhone-only at the target level to prevent XcodeGen from adding iPad.
- Organizer confirmed upload success and App Store Connect upload status is Complete. The internal group contains build 2 with status Testing and automatic distribution disabled. Hai Chang has an independently verified Invited status. The external group contains build 2, independently verified as Waiting for Review. Group members are separate from Individual Testers, which remains 0.
- Build details: https://appstoreconnect.apple.com/teams/69a6de75-bfdc-47e3-e053-5b8c7c11a4d1/apps/6810920731/testflight/ios/14be6808-a515-42d0-8561-ba090d4d293d.
- RC tests: /Users/haichang/tmp/pocket-rc-unit-tests-signed.xcresult, all 20 passed. The initial command disabled signing and failed its Keychain test. Restoring normal signing passed without source changes.
- Earlier attempt: build 1 used old Xcode 27 beta (27A5194q). Apple rejected it with Unsupported SDK or Xcode version, error ID YEGI3WUYXRWGGS4IMNOJUZBXQM. The RC rebuild resolved that rejection.
- Toolchain location: /Users/haichang/Downloads/Xcode.app. This build explicitly sets DEVELOPER_DIR. The system default still points to the old beta at /Applications/Xcode.app. The global selection was not changed.
- Two byte-identical temporary browser downloads were removed. /Users/haichang/Downloads/Xcode_27_Release_Candidate.xip is retained.
- Evidence: docs/evidence/testflight-release.json, docs/evidence/testflight-ready.png and docs/evidence/testflight-invited.png. The user is already invited, so avoid a duplicate invitation. Teammate invitations require actual recipients and existing authorization.

## Initial external submission history

- State: REVIEW, with build 2 submitted for external Beta App Review and Waiting for Review.
- The user explicitly requested External Testing. Teammates need neither developer membership nor App Store Connect access.
- Hackathon External: eddab1cd-de9f-434a-b3b7-9d90af7951d6, independently read as an External Group with zero testers and one build.
- The user completed review submission. Browser tab 2 shows 0.1.0 (2) as Waiting for Review on the external group Builds page. Evidence: docs/evidence/testflight-external-waiting-review.png.
- The previous contact telephone question is no longer blocking and must not be repeated. External Waiting for Review is not approval. Installation remains dependent on approval.
- The user switched to Public Link: https://testflight.apple.com/join/83Jzf4WB. Creation was independently confirmed after a reload, with 0 of 3 places used. There is no approved build yet, so joining is currently unavailable.
- What to Test is saved on build 2. Sharing requires the workspace owner key, a limitation disclosed in test metadata without disclosing the key.
- Run browser commands with BROWSE_PARENT_PID=0 so the authenticated window survives its launching shell.

- The Email invitation form was inspected earlier, but the user now selected Public Link. No testers were added and no email invitations were sent or resent.

- Public-link verification: after reload, App Store Connect still shows https://testflight.apple.com/join/83Jzf4WB and 0 of 3, with Testers cannot join public link until this group has an approved build. A separate public-page visit shows This beta isn't accepting any new testers right now. Evidence: docs/evidence/testflight-public-link.png.

## First-use walkthrough (build 2 history)

- The user reports downloading the app and requests usage guidance. The missing invitation email investigation is paused. Do not continue resending invitations.
- The installed version, launch and real-device speech/camera results remain unconfirmed. Download completion does not satisfy full acceptance.
- Earlier build 2 labels and flow were verified to guide My world → What caught your eye?, an English duck question, an observation, card reversal and memory creation. Speech recognition and playback use en-AU. Guide replies use prepared duck, leaf/leaves and shell content.
- Build 2 history: the preview required the workspace owner key in Family sharing settings. T14 removes that setup and all parental restrictions. The TestFlight enrollment link is separate from a public story link.

- Active work: T13 first-use usability correction, following PLAN T13. The user reported that the app is difficult to use. Simplify the home entry, speech flow and saved-card-to-memory path.

- The user explicitly requested a language selection screen. T13 now includes a persisted first-launch choice of device language, Simplified Chinese or English, with a home-screen change action. Interface and voice follow the selection.

- T13 targeted run 2 passed all 24 unit and 4 UI tests: /Users/haichang/tmp/pocket-first-use-after-2.xcresult. Subsequent refinements compact the new-card heading and memory artwork and fix playback controls to the bottom. Regression run 1 was deliberately interrupted to correct the UI test language-reset launch arguments. It is not counted as passing evidence.
- Local build number is now 3. It has not yet been archived or uploaded. The isolated sharing integration server is running on port 4176, session 49287, with a test-only database under /Users/haichang/tmp.

- Build 3 archive succeeded at /Users/haichang/tmp/PocketExplorer-RC-build3.xcarchive. Independent Info.plist reads confirmed 0.1.0 (3), RC 27A266a, iPhone-only device family, encryption exemption and en/zh-Hans bundles. codesign --verify --deep --strict passed. Upload remains pending regression results.

- Regression 2 passed 25 unit and 12 UI tests. Its single failing map test overshot the marker with full-screen swipes. A short, controlled drag retained the original marker and destination assertions and passed separately in /Users/haichang/tmp/pocket-first-use-map-2.xcresult. All 38 checks now have passing evidence. Production source and localization hashes are unchanged since archiving.
- Changed-file coverage: 2680 / 2853 executable lines, 93.94%, across all 15 changed Swift files. Both new language files are 100%. VoiceSession.swift remains 66.7% for the full file, with actual recording hardware branches pending device verification. It remains included in the denominator. Build 3 upload has started.

- Xcode Organizer independently showed PocketExplorer 0.1.0 (3) uploaded, with Uploaded to Apple in the archive list. The CLI account-access failure was resolved through the existing GUI session without another login. Apple processing and group assignment are next.

## Build 3 delivery history

Build 0.1.0 (3) is uploaded and independently verified as Testing in Hackathon Internal. The user can update through TestFlight. Build 2 installation on Hai's iPhone 17 Pro Max, iOS 27, is confirmed. Build 3 first use, speech and camera await user feedback. Apple currently prevents adding build 3 to the external group because one build from version 0.1.0 is already in Beta App Review. Build 2 remains Waiting for Review.

Evidence: docs/evidence/first-use-build3.json and docs/evidence/testflight-build3-testing.png. What to Test was saved and independently read after reload. No T13 process remains running.

## T14 implementation history

- IN_PROGRESS: remove the manual family-key blocker with installation-scoped sharing ownership.
- Next: reproduce rejection of a fresh credential, implement zero-setup sharing, verify and release build 4.

User clarification: remove parental restrictions entirely. Sharing is available directly to the explorer, without parental approval, a parent key or a parent mode. Keep the public preview, optional disclosure choices and background ownership protection against other users revoking a link.

T14 progress: all 18 web tests pass, 100% lines and 98.91% branches. The original reproduction returned HTTP 401 for a fresh credential. Additive Cloudflare migration 0002 succeeded. Native full regression and Worker deployment are running. Native test compilation initially failed on an async XCTest autoclosure, corrected before the current run.

T14 progress: Cloudflare version 9795fbba-5d36-49bb-b509-a3e428732525 is deployed and its live browser test passed. All 26 native unit tests and the zero-setup create/read/relaunch/copy/revoke integration passed. Full UI regression continues. Build 4 archive succeeded and packaged English/Chinese resources contain no parental key/settings controls. Upload has not started.

T14 final copy check: build 4 uploaded, but screenshot review found an awkward Chinese heading introduced by replacing the family wording. Correct that sentence and release build 5 instead. Swift implementation is unchanged, so retain the full regression coverage and run only the relevant localized screen check. Both additional native checks against production sharing and Chinese entry passed.

Final build 5 has uploaded and finished App Store Connect processing. Save its testing notes and add Hackathon Internal, then independently verify Testing.

## T14 final checkpoint

- Released 0.1.0 (5), independently confirmed Testing in Hackathon Internal. Testing notes exactly match the saved draft after reloading App Store Connect.
- Full native regression: 39 passed, zero failures or skips. Changed Swift coverage: 1618/1763 lines (91.78%). ShareClient 96.67%, SharePreviewView 94.96%. VoiceSession full-file coverage remains 66.67%, with only its two covered permission-message lines changed in this task. Hardware capture branches remain unverified on a physical device.
- Production native sharing and Chinese UI: both additional checks passed. Build 5 has identical Swift source hashes to build 4, with only a Chinese heading and build number changed. Its separate Chinese UI check passed.
- Web: 18 passed, with 100% line and branch coverage in every changed TypeScript file. Live browser checks passed, including legacy-link preservation and foreign-owner rejection.
- Cloudflare version: 9795fbba-5d36-49bb-b509-a3e428732525. Production native checks cover creation, independent read, process relaunch, copy, revoke and independent HTTP 410.
- All tests, archives and uploads ended. The isolated 4176 service is stopped. The existing 4174 preview is preserved.
- Build 4 uploaded but was superseded before group distribution to correct a Chinese heading. Final build 5 App Store Connect ID: f0e34c4f-a22c-43e7-9f1c-145a521d1768.
- Next: phone acceptance after the user updates. External build 2 remains Waiting for Review and Apple disables selecting the external group for build 5. Do not cancel that review or resend invitations.
- Evidence: docs/evidence/sharing-build5.json, design/key-screens/sharing-preview-zh-build5.png, docs/evidence/testflight-build5-testing.png.
- Test harness note: after all regression tests passed, optional simctl diagnose stalled. Only that child was terminated, allowing xcodebuild to exit 0 and finalize its result bundle. The later focused checks used the supported -collect-test-diagnostics never flag without disabling assertions or coverage.

## Future AI configuration checkpoint

- Recorded the user's gpt-image-2.5-sunburst image endpoint and existing GPT-6 configuration in PLAN T12. Earlier image success is user-provided evidence and was not independently retested in this task.
- Saved the image key in ../Pocket-Explorer-Backend/.local/ai/providers.json. An independent read verified the deployment and 0600/0700 permissions, and git check-ignore confirmed exclusion. No GPT-6 key was copied and no global settings were changed.
- T12 remains DEFERRED. T15 delivery is verified. Larger product changes and AI integration have not started.

## External testing status refresh (2026-09-11)

- Independent Apple API reads confirm build 2 is VALID / IN_BETA_TESTING and remains assigned to Hackathon External. Earlier Waiting for Review entries are historical.
- Public link https://testflight.apple.com/join/83Jzf4WB is enabled with a limit of three testers. A fresh public-page load shows View in TestFlight instead of enrollment being closed. Screenshot: /Users/haichang/tmp/pocket-testflight-public-available.png.
- This was read-only verification. No testers, invitations or external assignments were changed. CI still distributes automatically to the internal group, while the public link exposes the older build 2.

## Accepted backend checkpoint

- The user confirmed Cloudflare for the future AI backend. PLAN records Workers, Queues, R2 and D1 responsibilities, server-only credentials and integration acceptance. No AI service deployment was performed.
- GitHub run 34571657181 passed native regression: 26 unit tests and 13 UI tests, zero failures. Web checks also passed. TestFlight 0.1.0 (6) is released and independently verified. Native logs: /Users/haichang/tmp/pocket-github-native-final.log.


## T16: Backend extraction and automatic Cloudflare delivery

- DONE: T16 repository extraction and automatic Cloudflare delivery. The backend repository was independently confirmed empty. Production Worker settings still bind the original D1 database, ASSETS, OWNER_KEY and rate limiter. Existing sharing is implemented and deployed. AI routes, Queues and R2 are not implemented.
- Completed: Backend workflow and scoped credentials, actual deployment, independent production verification, removal of duplicate UI source, native CI and TestFlight verification.

- T16 backend release verified: https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend/actions/runs/34575491870 succeeded. Cloudflare version 3bb481f8-00ca-49bd-9ed9-0f16592e99c0 serves 100% traffic and is tagged with backend commit d19e3a16086d6cf5773de0f43a4308342962b09c. Existing example and live create/read/play/revoke passed.
- UI extraction: removed tracked web source and Docker recipe, retained native resources and fixtures. Updated native workflow to call production through TEST_RUNNER_POCKET_SHARE_BASE_URL. actionlint and shellcheck passed. No Swift application code changed.

- Local migration: copied SQLite through its backup API, preserved the existing preview response, and restarted the preview from Backend. Image provider configuration and the legacy Cloudflare owner key moved into Backend .local with restrictive permissions. Old local preview database/key remain as migration backups, outside Git.

- Native extraction regression passed: 26 unit tests and 13 UI tests, zero failures. The deployed Cloudflare create/read/relaunch/copy/revoke test passed. The 80% application line coverage gate passed. TestFlight release 0.1.0 (7) passed in run 34575779608 and was independently verified in Apple.

## Local repository relocation (2026-09-12)

- DONE: moved the UI checkout to /Users/haichang/Projects/Pocket-Explorer-UI and the backend checkout to /Users/haichang/Projects/Pocket-Explorer-Backend, matching their GitHub names. The old directories no longer exist.
- Independent reads confirmed unchanged checkout and Git-directory inodes, HEAD revisions, origin URLs, working-tree status and pre-existing diff hashes immediately after the moves. Updated local path references afterward. No application code, commits, pushes or deployments were made.
- Restarted the existing backend preview from its new directory on port 4174, PID 38735. The existing SQLite records and public-story response are unchanged. Website HTML and both linked assets return HTTP 200. The design preview on port 4176 remains available.
- Updated the design verification helper's Playwright import and verified that it resolves from the new backend path. Continue with design feedback using the existing Figma file.

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

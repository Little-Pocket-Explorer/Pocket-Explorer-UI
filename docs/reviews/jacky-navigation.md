# Navigation and discovery identity review

Status: released locally as TestFlight 0.1.0 (19). Independent Apple and IPA reads confirm delivery to Hackathon Internal. Human visual approval remains open.

## Corrections and reproductions

- Ordinary browsing now uses four independent navigation paths with global tabs. Home returns directly to Chat and other tabs retain their paths.
- Atomic question, observation and photo drafts are isolated by family, language and demo context.
- A nested share-preview stack was independently reproduced returning to Map without showing sharing controls. The shared navigation correction passes its original regression.
- Restoring an answered draft from Home voice entry was independently reproduced starting hidden recording. The correction passes while unsent-draft camera entry remains available.
- A bottom memory-share action crowded maximum-text reading. It now lives in the top toolbar. Pause, reading-position, replay, toolbar sharing and return regressions pass.
- Event messages use validated internal URLs, independent drafts and stable retry IDs. Completion checks the owner and visible destination. Ordinary message drafts remain intact.
- Reminders start disabled and allow at most three afternoons within eight days, one per day. Late authorization cannot reverse cancellation. Actual system pending-request readback verifies Chinese content, discovery ID, sound, trigger time and removal.
- Reviewing an earned card updates recall time without another award. Cold and true warm links return to the original question context.
- The new mark uses a globe, stacked knowledge cards and a gold sparkle, without language-specific text. Small sizes, the compiled icon, welcome and Chinese/Arabic home screenshots were inspected.

## Qualification limits

The earlier full regression recorded 241 passes, 23 failures and four skips. Failures included obsolete navigation assertions, missing multilingual fixture content, stopped simulated location and an actual memory layout issue. It is not a passing full invocation. The correction runs pass 21 tests with one skip, then all 19 follow-up tests. The latest-per-test matrix has 266 passes, four explicit skips and no unresolved assertion failure. All 30 changed product Swift files meet current-hash coverage, minimum 88.27% and aggregate 95.53%.

Two bounded CLI review attempts timed out without an opinion. Neither is counted as external approval. Findings above come from source inspection and independently inspected test evidence.

No Backend runtime change is part of this iteration. The physical iPhone remains unavailable. Microphone, camera, headphones, interruptions, notification delivery, listening quality and human aesthetic approval remain separate acceptance items.

The earlier pocket-pitch-native-full-1.log also contains an Invalid frame dimension warning. Some current input transitions still log it. Its source is not isolated. Inspected settled screens show no corresponding display defect. Execution is not claimed to be warning-free.

The four gated checks require a dedicated three-item catalog fixture, working host microphone input, opt-in production question access and opt-in production sharing. Local end-to-end tests use the production Backend handlers but are not claimed as another deployed-service run. See [evidence](../evidence/navigation-identity.json) and the [quick check](../testing/navigation-journey.md).

The released source is f184e8674c7509a5d34c4366811b50e5dbb11db2 and Apple build ID is 89fb0dba-2128-48b8-a5ee-dfe62d1339cb. Release evidence is retained in ~/tmp/review/pocket-navigation-testflight-19. Later documentation commits do not change the IPA source.

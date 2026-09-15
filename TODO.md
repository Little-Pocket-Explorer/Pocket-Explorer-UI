# Pocket Explorer: Execution State

Updated: 2026-09-11.

## T19 in review: reference login visual system and orientation adaptation

- Replaced the prior registration composition with the supplied reference structure: full hero artwork, centered Pocket Explorer brand, large two-line title, equal Apple / Google / Email action rows, consent copy and an email form that opens only after choosing Email.
- The native app retains a portrait-first immersive sign-up and chat home. It does not rotate because `project.yml` remains portrait-only.
- The matching Web sign-up and chat home now have separate responsive layouts: portrait keeps the stacked mobile composition, while landscape uses a full-height hero beside the registration panel and a wider chat-home suggestion grid.
- Web checks passed after the redesign: 27 unit/integration tests, 9 Chromium browser tests, 98.96% lines and 94.57% branches. Browser checks include 390px portrait and 1440px landscape sign-up layouts with no horizontal overflow.
- Native source diagnostics pass. Native XCTest, XCUITest, coverage and device visual review must still run on macOS CI.
- BLOCKED: the reference's child-in-garden hero image is not present in the workspace, sibling Backend repository, Downloads or Desktop. Existing original duck artwork is used as a temporary hero. Pixel-identical visual parity requires an approved source image file; do not extract or reuse a screenshot as a shipped product asset.

## T18 in review: email registration and chat-first home redesign

- The first app surface is now a local email registration screen. A valid email creates a profile stored only on the current device/browser and enters the chat-first home directly using the device language.
- The new home follows the supplied mobile reference structure in both clients: garden hero, branded top row, child profile marker, question prompt, three suggested questions, bottom question composer, and Chat / Map / Collection / Social navigation.
- The existing Map, Collection, Memories and exploration data remain available in the native app. Suggested questions are passed into the existing exploration flow so the selected intent is preserved.
- Web registration validates email input, persists the demo profile in local storage, and retains the existing exploration, card unlock and public sharing flows. Apple and Google controls are intentionally unavailable until a real OAuth provider is configured; they do not simulate sign-in.
- Web verification passed on Windows: 27 unit/integration tests, 7 Chromium tests, 98.95% lines and 94.48% branches. The relevant browser test runs at 390px and verifies the email registration, chat-home recommendation and card unlock journey.
- Native source diagnostics and English/Simplified Chinese localization checks passed. Native XCTest, XCUITest, coverage and TestFlight verification remain required on macOS CI.
- The supplied reference's generated child character asset is not present in either repository. Both implementations reuse the existing original duck garden illustration, so the layout and interaction are synchronized but the hero artwork is not pixel-identical. Add an approved source image before claiming final visual parity.

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
- Current stage: T19 reference-driven sign-up layout and orientation adaptation is implemented in Web and SwiftUI. Web checks pass; native changes await macOS CI and visual review.
- New skill: /Users/haichang/.codex/skills/codex-project passed structural validation. Legacy codex-bootstrap is preserved.
- Local preview: http://127.0.0.1:4174/s/EDYeU5SzHaXpMEy1XAx9WqvE1Grjrmv3. This is accessible on this Mac only.
- Running processes: UI GitHub run 34575779608 and its local watcher exited successfully. The preview on port 4174 now runs from ../pocket-explorer-backend (PID 17900). Its existing story was independently read before and after migration with identical SHA-256. The original SQLite file remains as a local backup.
- Next action: provide an approved child hero asset for final visual parity, then run the native PR workflow before TestFlight review. Live AI integration has not started.
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
| T18 | REVIEW | Email registration and chat-first home | Web implementation and full local tests pass. Native diagnostics and localization checks pass; macOS native tests, TestFlight and visual approval remain. |
| T19 | REVIEW | Reference login layout and orientation adaptation | Web portrait and landscape layouts pass browser checks. Native remains portrait-first and passes diagnostics; approved child hero asset, macOS CI and visual review remain. |
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
- Saved the image key in ../pocket-explorer-backend/.local/ai/providers.json. An independent read verified the deployment and 0600/0700 permissions, and git check-ignore confirmed exclusion. No GPT-6 key was copied and no global settings were changed.
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

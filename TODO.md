# Pocket Explorer: Current Execution State

## Native Social loading responsiveness pending macOS qualification (2026-09-21)

- Investigated the physical-iPhone Card Detail -> Share to friend wait as actual latency rather than a timeout-display problem. The native request was not doing image generation; the sibling Backend gift endpoint repeated serial family/friend/sharing D1 reads and synchronous card-copy reads. The Backend root-cause optimization is recorded in its TODO and remains undeployed.
- The original 20-second Social request timeout is unchanged. Card sharing now shows progress inside the disabled Send action, cancels when its sheet closes, and retains the persisted transfer request ID so retry cannot create a duplicate gift.
- Friend-card artwork is now cached by friend, card and artwork version in `SocialStore`. Friend profile thumbnails, collection rows and card detail reuse the same bytes instead of downloading the same authenticated image again. The cache clears when account/friend access is rebound.
- Swift workspace diagnostics and `git diff --check` pass. The Social regression asserts one network read across repeated artwork loads. This Windows host has neither Swift nor Xcode, so XCTest/XCUITest, changed-file 80% coverage, measured physical-device latency and visual acceptance remain pending on macOS. No TestFlight upload occurred.

## DONE: App Store 1.0.1 (24) corrected and resubmitted (2026-09-19)

- Corrected ITMS-90062 with the only source change MARKETING_VERSION 1.0 -> 1.0.1. Runtime behavior and build 23's qualified source remain identical. Newer remote notification/refresh changes are not included.
- Signed and uploaded from this Mac as 1.0.1 (24). Independent Apple read confirms VALID / IN_BETA_TESTING and Hackathon Internal membership. Build ID: 4641bae6-3418-4c1d-a242-e8eb50bad345.
- Independent IPA verification confirms 1.0.1 / 24, strict signature, release entitlements, Xcode 27A266a and ten matching 660-entry catalogs. Source differences are limited to ios/project.yml. Prior build 22/23 tests apply without repeating feature regression for metadata alone. Physical-device acceptance was not repeated.
- Replaced build 23, independently read the selected build, resolved the rejected item, and resubmitted review 40be6edc-a2c4-446d-b670-fb13c8dc4c54 at 2026-09-19T03:49:59.129Z. API/UI confirm WAITING_FOR_REVIEW. At least five minutes of delayed checks found no invalid-binary recurrence or new failure notification. Approval is still pending.
- Free price, 174 territories excluding only CHN, metadata, review details and AFTER_APPROVAL are preserved. Live 1.0 (21) remains READY_FOR_SALE. No Backend deployment or GitHub native build occurred.
- Temporary signing credentials and keychain were removed, original keychain search list restored, and all owned release/check processes completed. No new automation. Evidence: docs/evidence/app-store-update-1.0.1-build24.json, docs/app-store/release-status.json and ~/tmp/review/pocket-app-store-update-20260919.

## DONE: App Store 1.0.1 submitted with build 23 (2026-09-19)

- Submitted at 2026-09-19T03:10:57.525Z, 13:10 Australia/Sydney. Independent version and review reads confirm WAITING_FOR_REVIEW. Submission: 40be6edc-a2c4-446d-b670-fb13c8dc4c54. UI confirms iOS App 1.0.1 / 1.0 (23).
- Apple accepted the existing VALID build 23, ID 840d4cd5-ca8f-4420-9440-80da8d07e82d, directly. No repackaging, new upload, runtime edit, test rerun or Backend deployment was needed. Existing build 22/23 qualification applies.
- Independent reads confirm free pricing, 174 available territories with only CHN excluded, three COMPLETE inherited screenshots, preserved review details and saved English release notes. Release is AFTER_APPROVAL, with immediate availability to all users after approval.
- Live 1.0 (21) remains READY_FOR_SALE. Approval and public availability of 1.0.1 are pending Apple review. No owner action or new automation is required.
- Remote main now contains separate notification and refresh fixes after build 23. They are not in this submission and are left for a later qualified release. Primary checkouts remain untouched.
- Evidence: docs/evidence/app-store-update-1.0.1.json, docs/app-store/release-status.json and ~/tmp/review/pocket-app-store-update-20260919. The review page is retained in the in-app browser.

## Main Map workflow aligned; macOS runtime qualification pending (2026-09-19)

- On 2026-09-20 the owner explicitly authorized pulling latest `main` and merging this implementation without completing the pending macOS XCTest/XCUITest or changed-Swift coverage run. This authorization permits source integration but does not convert those checks into passing evidence.
- The native main Map now has real `Me`, `Nearby` and `Friends` modes. `Me` shows local trip markers and story rows; `Nearby` shows cached Events plus public approximate-location cards; `Friends` reads the authenticated friends feed and shows accepted-friend cards. Cards shared without location remain in the Friends list and never receive a fake map pin.
- Added the missing top-level location action. It requests Core Location through the existing `DiscoveryLocation`, shows the user location, recenters MapKit through a revision-controlled focus request and refreshes Nearby only when the parent has allowed Events.
- Added the missing top-level map-share action. It lists verified public cards and opens the existing four-audience `MapSharingView`; when no eligible card exists, the menu explains that a verified card must be made first. Notifications and Collection remain directly available.
- The existing `Nearby events & discoveries` route still opens the detailed Nearby/Family settings workflow, preserving first-use Event setup. Main Map Event and shared-card pins open their existing detail routes.
- Added MapKit annotation/recenter tests, EventStore nearby/friend grouping coverage and an XCUITest assertion for the three scopes plus location/share/notification controls. Swift workspace diagnostics and `git diff --check` pass. All ten localization catalogs contain 700 unique matching keys with zero key-set differences.
- This Windows host has no `swift` or `xcodebuild`, so XCTest/XCUITest execution, responsive screenshots, changed-Swift coverage and physical-device review remain pending on macOS. TestFlight 1.0 (23) does not contain this work.

## Map audience selector implemented; deployment and macOS qualification pending (2026-09-18)

- Native and Web Card Detail now offer four explicit map scopes: Friends only, Friends with location, Public, and Public with approximate location. Native disables friend scopes unless Social is parent-enabled; location-free modes do not request location.
- The sibling Backend now stores `friends_only`, `friends_approximate`, `public`, or `public_approximate`. Friends reads require an accepted friendship and live Social/Sharing permission from both families. Location-free modes expose no shared coordinates; approximate modes are rounded on-device/in-browser and again at the server boundary. Legacy rows migrate to `public_approximate`.
- Backend D1 audience tests pass, including anonymous rejection, accepted-friend access, bilateral permission revocation, nullable coordinates, public/friends feeds, nearby filtering and old-client compatibility. Web build passes; final affected qualification passes 117 tests across 15 suites with every changed TypeScript file above 80% line and branch coverage. The broader Vitest run remains noisy on this Windows host with 22 pre-existing timeout/cascade failures outside these focused suites.
- Responsive browser inspection passes at 390x844 and 1280x800: all four options and the publish action fit with no horizontal or vertical overflow. A live `Public` publication persisted no `mapLocation`. Native Map merges the authenticated friends feed, showing no-location cards in its list and pins only for cards with approximate locations. Native diagnostics pass; final localization parity is recorded in the newer Main Map section above.
- Production is unchanged. Apply `0015_map_audience.sql` and deploy the sibling Backend through its existing workflow before releasing compatible clients. Native XCTest/XCUITest, changed-Swift 80% coverage and physical-device review remain pending on macOS; TestFlight 1.0 (23) does not contain this work.

## Video workflow notification alignment pending macOS qualification (2026-09-18)

- Re-audited the supplied two-minute workflow as behavior rather than a pixel-exact Web copy. Existing native flows already cover prepared question -> conversation -> card reveal/detail -> friend/map/link sharing -> nearby Event -> event conversation -> Friend Profile -> card request/gift/exchange -> recall quiz.
- Map now opens an App-styled Notifications destination that aggregates real incoming friendship requests, pending/received card transfers, cached nearby Events and due discovery quizzes. Actions reuse existing protected endpoints and routes: accept/decline, open received card, open Event, or switch to Chat recall. Notification settings remain reachable from the same screen.
- The native share sheet retains approved-friend card copy and revocable public links; map publication now continues into the four server-enforced audience scopes recorded above.
- Swift diagnostics, `git diff --check`, route assertions and ten-catalog parity pass; all catalogs contain 670 unique matching keys. Existing reminder UI tests now traverse Map -> Notifications -> settings, and a new UI case covers Notifications -> due quiz -> Chat. This Windows host cannot execute XCUITest or changed-Swift coverage. TestFlight 1.0 (23) does not contain this work.

## Social refresh cancellation fix pending macOS qualification (2026-09-18)

- A physical iPhone reproduced `Swift.CancellationError error 1` after tapping Refresh friends while an outgoing request was still waiting. SwiftUI task cancellation was being surfaced as a user-facing network error even though the cached friendship row remained valid.
- Social refresh now clears stale errors when a new attempt starts, ignores expected cancellation and still presents real service failures. Unit coverage distinguishes cancellation from `SocialError`, and the accepted-friend UI journey asserts a successful refresh leaves no `social-error`.
- Swift diagnostics and `git diff --check` pass on Windows. TestFlight 1.0 (23) does not contain this source correction; macOS XCTest/XCUITest and changed-file coverage remain required before another native upload.

## DONE: teammate TestFlight 1.0 (23) and Backend update (2026-09-18)

- Freeze this release at upstream 784267f, which deliberately restores the existing Social gate and gift-based card sharing. Profile settings and the share sheet remain. Earlier fb11b2c qualification is archived in ~/tmp/review/pocket-release-20260918 and does not define this release's feature scope.
- Preserve primary checkouts and App Store submission build 21. Publish native from this Mac with [skip ci]. Backend fbb5ccd is already deployed through successful workflow 35297449490, with independently verified traffic and tested asset hashes.
- Final-source qualification is complete: 18 affected units and four integration UI journeys have passing latest results. Gift retry and independent recipient readback, map publication/revocation, full settings persistence, copied-link reuse, events and exchanges pass. The first gift readback failed in the test decoder only. A typed response fixed that helper and gift-journey.xcresult passes with unchanged product source.
- All three changed Swift files pass matching-source coverage: CardShareView 94.96%, CardViews 89.28%, ProfileViews 91.24%. Ten catalogs contain 660 matching keys. Final screenshots were inspected. Evidence: docs/evidence/teammate-testflight-20260918.md and the accompanying coverage JSON.
- Apple independently read at 2026-09-18T03:14:03Z: version 1.0 and review submission both WAITING_FOR_REVIEW, build 21 unchanged. No owner action is required.
- Published source 0b909f7 from this Mac as TestFlight 1.0 (23). Apple build 840d4cd5-ca8f-4420-9440-80da8d07e82d is independently confirmed VALID, IN_BETA_TESTING and assigned to Hackathon Internal. No external beta review or native GitHub runner was started.
- Independent IPA verification passes: strict signing, release entitlements, expected bundle/version/build/Xcode, all ten 660-entry dictionaries, and matching qualified product hashes. IPA SHA256: af5eaaeb01e10620b81860fffd94399303a8a472debe29507266f0944c60f55d. Owned fixtures, test simulator, temporary signing keychain and signing copies are removed. The keychain search list is restored and original credentials preserved.
- Final App Store read at 2026-09-18T03:25:23Z still confirms WAITING_FOR_REVIEW and build 21 unchanged. Delivery is complete. Evidence: docs/evidence/teammate-testflight-23.json. Do not repeat completed qualification or upload without new changes. Physical-device acceptance remains separate.

## DONE: teammate TestFlight 1.0 (22) delivered (2026-09-17)

- Pulled c0149a6 and preserved the primary checkout. Corrected the two Swift compilation failures, restored conversation refresh, and made event sharing scrollable and expandable.
- Qualification is complete: all 193 unit cases pass after their prerequisites, 19 affected UI cases have passing latest results, zero latest failures, and one unchanged warm-link driver test is explicitly skipped. Every changed product Swift file exceeds 80% coverage, minimum 84.67%. Ten catalogs have 650 matching keys.
- Actual local Worker/D1/R2 integration, event award and map revocation, message retry and exchanges, Chinese/Arabic including maximum text, card V1/V2 evolution and persistence, and Jacky's complete journey pass. Reviewed screenshots are in ~/tmp/review/pocket-testflight-20260917.
- Published source 2cb49c6 from this Mac with Xcode 27A266a. Independent Apple reads at 2026-09-17T11:01:21Z confirm build 22 is VALID and belongs to Hackathon Internal. The release lane confirms IN_BETA_TESTING. The IPA signature, release entitlements, source snapshot and all ten compiled localization dictionaries were verified.
- App Store review remains WAITING_FOR_REVIEW with build 21 attached. No review submission was replaced or withdrawn. No Backend deployment or native GitHub runner was needed.
- Release work is complete. Evidence: docs/evidence/teammate-testflight-22.json and docs/evidence/teammate-testflight-20260917.md. Owned test processes, fixtures, simulators and temporary signing resources have been cleaned up. Do not repeat qualification or upload without a new change.
- The warm-link host-driver check and physical-device acceptance are distinct from the completed regression. Follow-up UI semantics are recorded in docs/evidence/teammate-testflight-20260917.md.

Earlier dated checkpoints below are historical and superseded where they conflict with this delivery record.

## Native Share and Profile additions pending macOS qualification (2026-09-18)

- Restored the existing Social family gate after confirming the unlocked Friends, Messages and Shared with Me workflow was already correct. No new Social message protocol or alternate locked-state UI remains.
- Profile now has distinct Child profile, Discovery preferences, Privacy, Location and Parent controls destinations with real FamilyStore-backed saves after PIN unlock. Notifications, Friends & family and Account retain their separate existing destinations, and one explicitly named Family settings row remains for setup and complete family administration.
- Card Detail exposes the new App-styled share sheet from both its top-right icon and body action. Its actions reuse existing native behavior: Gift a verified public card, open approximate-location map publishing, or create/copy the revocable public story link.
- Added UI regression coverage for all five Profile destinations and the three card-share options while retaining the already-qualified unlocked Social journeys. Swift workspace diagnostics, routing/action assertions, `git diff --check` and ten-catalog parity pass; all catalogs contain 660 unique matching keys.
- This Windows host has no `xcodebuild`, so XCUITest execution, screenshots and the required 80% changed-Swift coverage are pending macOS. TestFlight 1.0 (22) is unchanged and does not contain this correction.

## Native Event share reference alignment pending macOS qualification (2026-09-17)

- Native Event Detail now follows the supplied three-step reference: the top-right share icon opens a medium share-options sheet with compact Event preview, Share to friend and Copy link; friend sharing then shows a searchable single-select list and a recipient-specific `Send to ...` action.
- The existing Event read/share APIs, parent-controlled Events/Social/Sharing gates, post-send conversation routing and accessibility identifiers remain intact. Existing English/Chinese/Arabic journey tests were updated to traverse the new intermediate sheet, exercise Copy link and search, and still verify backend message readback.
- Swift diagnostics and `git diff --check` pass. All ten localization catalogs have 650 identical keys, zero duplicates and zero mismatches. This Windows host has no `xcodebuild` and no configured remote Mac, so the changed Swift runtime tests, screenshots and required 80% changed-file coverage are not yet claimed.
- There is no `master` branch; `main` and `origin/main` are currently identical. Do not commit or push this native alignment until the macOS test and coverage gate passes.

## Web Map card sharing restored (2026-09-17)

- The sibling Web `From your map` card-story screen now exposes Share in its title bar and routes the current card through friend selection into the conversation as a persisted shared-card message.
- `Rings of ice and rock` was shared with Dou Dou in the live browser. The Map/Social/journey regression, production build and per-file line/branch coverage gates pass. This is a Web correction; the TestFlight App Event sharing path remains unchanged and independently available.

## Demo App Event open/share verification (2026-09-17)

- The iOS Event path is independent of the Web Map filter that hid `Sky watchers`. Both the MapKit Event pin and Nearby Event row open `.event(id)`, `DiscoveryLinkView` reads the Event, and `EventDetailView` renders it.
- Event Detail provides `Share with friend` when both Social and Sharing are allowed, plus the iOS system `Share event` action whenever Sharing is allowed. Friend sharing reloads the Event, sends it to the selected approved friend, and opens that friend conversation after success.
- The six owning Event/navigation files have no differences from the exact TestFlight 1.0 (21) source commit `c1cf01a`. The existing full-journey XCUITest exercises Nearby -> `Sky watchers` -> friend selection -> send -> backend message readback, while final App Store qualification records 23 UI passes and zero failures. This Windows host cannot rerun XCUITest or perform a physical-device share; the presentation account must retain an approved friend and enabled Events, Social and Sharing permissions.

## Web Map event visibility fix (2026-09-17)

- The sibling Web Map now defaults to Nearby, so publishing `Moonlight is sunlight` no longer hides the Event marker behind the Me filter. The card remains available in Collection.
- The real MapLibre `Sky watchers` marker was clicked in the live browser and opened Event Detail with View on Map and Share with friend. Map/Event/journey tests pass, production build passes and both changed TypeScript files exceed 80% line/branch coverage. Changes remain local and undeployed.

## Moon private demo published (2026-09-17)

- The existing English `Moonlight is sunlight` private Studio record is now production Priority 999, Published version 2, ages 5-18. Its question is `Why does the moon shine?`; the recall question and three choices now teach sunlight reflection instead of placeholder text.
- An authenticated age-7 catalog read placed Moon first, ahead of Sky and Leaves, with prepared artwork and narration paths. The local Web filming browser independently displayed and opened that configured Moon answer without generation. Existing activated iPhones receive the same catalog after Demo mode refresh; physical iPhone display was not run on this Windows host.
- The temporary verification device was revoked. A purpose-labelled Web filming browser remains active through 2026-09-24. Evidence is in the sibling Backend repository at `docs/evidence/moon-demo-production-20260917.md`.

## Configurable shared questions and showcase flow (2026-09-17)

- The sibling Web now reads the same configurable prepared-content contracts as the app: public `/api/recommendations`, or the private Studio `/api/demo/catalog` after explicit single-use browser activation. It shows three configured questions when available and fills any missing slots with localized offline-safe fallbacks.
- Configured and fallback questions use the original native-style AI conversation without generation. Card Detail appears only after Make my card -> View my card. Native source already uses `RecommendationStore` / `DemoStore`; this increment adds compatible Web consumption and does not change the submitted app build.
- Automated and live-browser verification cover the requested route: configured AI conversation -> card -> Card Detail -> Map -> nearby Event Detail -> friend share -> Friend Profile -> Recent activity `A new card` -> request -> reciprocal owned card -> exchange -> Discovery Quizzes -> `Quiz me now` -> Chat ready to answer.
- In the live browser, production-configured Saturn/Mars/torii replaced the fallback questions. Saturn opened its configured reply with zero generation requests, and the route completed through quiz-ready Chat. Fresh practice preserves native due semantics with `Ready 0` plus one explicit `Quiz me now` row. The affected Web regression passes 154 tests, production build passes and all four changed TypeScript files exceed 80% line/branch coverage. Changes remain local and undeployed.

## Web AI conversation parity (2026-09-17)

- The sibling Web now ports the current native `ExploreView` visual hierarchy for arbitrary AI questions: focused title/close header, child question, leaf guide answer card, invitation, observation/location tools, pending safe-area bar, Make my card and persistent navigation. Stable recovery, explicit cloud permission and local-only speech safeguards remain intact.
- Configured and fallback prepared questions use the same native conversation design without a generation request. Card Detail appears only after the new card is made and opened; native app source and the submitted App Store build are unchanged by this Web-only increment.
- Ready and pending Web states were inspected at 390 x 844 with zero horizontal overflow, no nested scroller and no fixed-action overlap after scrolling. The affected Web regression passes 135 tests, production build passes and changed `App.tsx` coverage is 94.52% lines / 82.48% branches. Changes remain local and undeployed.

## App Store submission complete (2026-09-16 22:09 AEST)

- Pocket Explorer 1.0 (21) was submitted at 2026-09-16T12:09:12.422Z. Apple's page showed "1 Item Submitted", and independent version and submission API reads both confirm WAITING_FOR_REVIEW. Submission ID: 3ae5a282-1ec0-471b-a75f-2676572a254b. Release remains AFTER_APPROVAL. Approval and public availability have not yet occurred.
- The owner authorized excluding China mainland from the first release. Paginated independent reads confirm 174 of 175 territories selected, only CHN unavailable, and every other territory unchanged, including Hong Kong, Macau and Taiwan. All required owner decisions are settled.
- TestFlight 1.0 (21) remains VALID, APP_STORE_ELIGIBLE and IN_BETA_TESTING in Hackathon Internal. Native source c1cf01a was signed and uploaded from this Mac. No new binary was required for the territory change or final submission. Preserve ten languages and local native publishing with [skip ci].
- Backend 8244027 remains deployed through successful workflow 35092615551 with 100% traffic. Sixteen independent production privacy and AI checks pass. The fictional test account is deleted. Older native clients must update for the explicit AI permission flow.
- Release preparation and submission are complete. Await Apple's review, then address any concrete review response. Do not resubmit, rebuild or repeat completed qualification without a new reason. No new agent, timer or automation was created.
- Evidence: native docs/app-store/release-status.json and local ~/tmp/review/pocket-app-store-release/{mainland-exclusion-verified,submitted-version-readback,submitted-review-readback}.json. All owned test, fixture, upload and workflow-watch processes have ended.

Earlier dated checkpoints below are historical and superseded where they conflict with this submission record.

## Accepted submission scope and qualification checkpoint (2026-09-16)

The owner explicitly approved preserving all features and submitting at Apple's current calculated age ratings: 13+ in 171 territories, 16+ in Australia, Vietnam and Brazil, and 15+ in Korea. FOUR_PLUS in older API records describes operating systems before version 26. Do not remove public discovery or social functionality to lower the rating. Kids Category enrollment is not requested for this release. The age rating does not replace applicable privacy obligations.

Epic KWS is deferred by the owner and removed from the release runtime. Existing family PIN, separate explicit Azure AI data permission, withdrawal, local-only speech recognition and account deletion are retained. A PIN is not verified parental consent. Previous KWS checkpoints are historical and superseded.

Backend/Web now pass 319 tests in 45 files with every-file coverage gates, 99.18% lines and 94.13% branches. Production build and an actual Chromium Worker/D1 create-unlock-grant-withdraw-delete flow pass. Browser activation and account deletion are implemented. Evidence: ~/tmp/review/pocket-app-store-release/no-kws-*.

Native integrated baseline has 190 passing units and 23 passing main UI journeys. Additional daily background refresh, invalid demo recovery, complete private-demo flow and speech-denial typing recovery pass. The corrected audio callback test passes. All 15 changed product Swift files pass same-source 80% line coverage, with a minimum of 81.75%. Final Chromium and WebKit regressions each pass 37 tests with one explicit fixture skip. All five artwork/actual-account flows pass, and the actual-account flow also passes WebKit with its mobile screenshot inspected.

The owner confirmed all supplied artwork and example content may be published. Mainland ICP availability is awaiting the owner. Version 1.0 and final review instructions are prepared. Next: finish Apple declarations, deploy Backend through its workflow, upload native 1.0 locally, attach the build and submit review. Publication is authorized. TestFlight remains 0.1.0 (20), App Store 1.0 is not submitted, and no release commit or production deployment has occurred. Do not start agents, timers or native GitHub builds.

## First-release scope correction (2026-09-16 21:21 AEST)

The owner explicitly deferred Epic KWS and asked to proceed with publication. Do not request Epic login or treat KWS approval as a release prerequisite. Preserve existing family PIN, explicit cloud AI permission and withdrawal, deletion, accurate provider disclosure and teammate features. The KWS experiment is archived outside the release worktrees at ~/tmp/review/pocket-app-store-release/kws-deferred-20260916 with file hashes. Its eleven dedicated files, runtime routes, page, migration and deletion dependencies are removed from the release candidate. No production deployment occurred.

Current work: complete browser grant activation using the existing family API, then finish native qualification and Apple declarations. Deploy Backend via its workflow and upload native 1.0 locally. App Store remains unsubmitted and TestFlight remains 0.1.0 (20). Deferring a vendor does not turn a PIN into verified parental consent or justify inaccurate declarations. Earlier KWS checkpoints below are historical and superseded.


## Current App Store checkpoint (2026-09-16 21:14 AEST)

- The owner accepted first-use KWS parent verification. The decision is settled. Epic Developer Portal still displays sign-in. The owner has been asked to log in and supply a publicly usable privacy contact address and telephone number. Do not reuse Apple review-only contact details for the public policy without authorization.
- Official KWS documentation confirms separate adult verification and explicit parental consent. Initiation uses OAuth client_credentials, scope verification and the send-email service. The exact host/path/response contract and pre-verified-parent branch require the authenticated portal specification. No guessed transport or live KWS request was implemented. Test and production credentials are separate. Production configuration needs KWS review, documented as within seven business days with possible longer demand periods.
- Backend now has migration 0015, validated webhook/response signatures, product and request binding, replay/freshness protection, secure short-lived parent browser sessions, versioned scope decisions, withdrawal, and removal of verification records during account deletion. ParentPermission supplies a separate ten-language direct-notice and explicit-choice page. All choices begin off.
- These components are implemented locally. Native/Web verification initiation and the complete upload/consumer scope enforcement are unfinished. The requireCloudScope integration seam is not yet connected to every route. Do not describe production child-data protection as complete or deploy this partial flow.
- Full Backend/Web regression passes 337 tests in 47 files. Every-file 80% line/branch gates pass, with aggregate 99.20% lines and 94.47% branches. Production build passes. Actual browser testing selects only profile/AI in English and declines all scopes in Chinese, with independent D1 readbacks. Arabic RTL at 390x844 has no horizontal overflow. These are fictional local KWS callbacks, not real provider qualification.
- Evidence: ~/tmp/review/pocket-app-store-release/kws-qualification.json, kws-full-1.log, kws-full-coverage, kws-build-final.log, kws-browser-approval.json and kws-browser-decline.json. No product Swift changed this increment. Prior native coverage gaps and physical-device checks remain open.
- App Store 1.0 remains unsubmitted and without a new build. Latest published TestFlight is 0.1.0 (20). Apple drafts from the preceding checkpoint remain valid. No commit, push, production deployment, native upload, timer or agent was started. The local callback fixture on 4241 is stopped. Browser viewport override is reset. The Epic sign-in tab is retained for handoff.
- Next: complete Epic login and real API configuration, implement bounded initiation and both client flows, enforce all scopes and revocation races, finish Web deletion and privacy retention/contact disclosures, qualify real KWS test/production, complete native coverage and Apple declarations, then deploy through the existing channels and submit 1.0. Publication is already authorized.

Older checkpoints below are historical where they conflict with this checkpoint.

## Current App Store checkpoint (2026-09-16 19:49 AEST)

- Public review remains unsubmitted. Latest TestFlight is still 0.1.0 (20). No new commit, push, production deployment or binary upload occurred. Native main 41a6356 is integrated with pending privacy work and all teammate changes. Ten catalogs have 609 matching unique keys.
- Apple now has the full age questionnaire (FOUR_PLUS), DSA non-trader Active, 175 territories independently read back, copyright, privacy/support URLs and the reused beta reviewer contact. Thirteen privacy categories and their purposes/linkage/no-tracking settings are saved as drafts, not published. Version 1.0 has no build. Content rights, Kids Category, regional requirements and final review notes remain open.
- Web implements actual AI permission reads, local send guards, withdrawal persistence, online retry, on-device recognition enforcement and local-only fallback voices. A reproduced photo-preparation withdrawal race is fixed by checking again before sending. Web grant activation and account deletion still await the complete parent flow.
- Backend/Web pass 305 tests and every-file 80% line/branch gates (99.18% lines, 94.18% branches). Final production build passes. Full Chromium and WebKit each pass 37 checks and skip one event-fixture scenario. New privacy flows pass in both. Final English/Chinese mobile screenshots have been inspected after spacing improvements.
- Integrated native units pass 190 with one skip. privacy-journeys-4 passes all 23 selected UI journeys. The deletion test now verifies the visible button center before tapping and waits for the actual alert. Earlier failed/interrupted runs remain evidence, not acceptance. Current merged same-source coverage qualifies 13 of 15 changed Swift files. PocketExplorerApp.swift (73.68%) and VoiceSession.swift (76.19%) still need coverage before the release gate passes. docs/app-store/qualification.json now records this instead of the older seven-file result.
- The owner accepted KWS first-use verification on 2026-09-16. Do not ask for the product decision again. PIN-only setup is not adult verification. The boundary must cover profiles, social content, locations and AI before upload. See native docs/app-store/parent-verification.md. No KWS account, terms or production integration has been created.
- All tests have finished. Owned fixtures on 4236/4237 have been terminated. No release, timer or agent was started. Evidence is under ~/tmp/review/pocket-app-store-release, especially integration-20260916 and privacy-browser-report-final. Physical device acceptance remains separate.
- Next: verify the official KWS contract and account configuration, implement its activation/deletion and provider callbacks, reconcile final data disclosure, finish native coverage and final screenshots, coordinate old-client migration, deploy Backend through its workflow and publish 1.0 locally before submitting review. Do not repeat Apple login, pricing, age or publication permission questions.

Older checkpoints below are historical where they conflict with this checkpoint.

## App Store continuation: integrated baseline (2026-09-16)

- Current native baseline is main 41a6356, including TestFlight 20. The pending privacy work was backed up and restored with all upstream changes. The stash and 62-file hash manifest remain in the local integration evidence directory.
- Resolved additive document and localization conflicts. All ten catalogs have 609 unique keys and matching key sets. The combined native test build succeeds. Final qualification remains in progress.
- App Store Connect website is signed in as Hai Chang. API and website independently show version 1.0 in PREPARE_FOR_SUBMISSION with no build or review detail. Free price, Education and English text remain saved. Support URL, copyright, review information, age questionnaire, availability and privacy declarations remain unfinished.
- Parent verification preference was requested with the concrete KWS first-use proposal. No new service account or terms have been accepted. Continue independent privacy/Web work while that input is pending.
- Evidence: ~/tmp/review/pocket-app-store-release/integration-20260916 and resume-*.json. No deployment or review submission occurred.


## Latest baseline update (2026-09-16 18:58 AEST)

The user requested the teammate update as a separate TestFlight delivery. Build 0.1.0 (20) is independently VALID / IN_BETA_TESTING in Hackathon Internal, published locally from 9c568c1. Remote main includes delivery record 41a6356. Preserve all uncommitted App Store privacy changes in this worktree, and integrate current main before further qualification. The teammate release did not include or deploy these incomplete privacy changes. App Store 1.0 remains PREPARE_FOR_SUBMISSION. No website-login claim follows from the successful Apple API authentication. Evidence: ~/tmp/review/pocket-teammate-testflight-20260916.

## Active: first App Store release (2026-09-16)

Latest provider confirmation, 2026-09-16 15:56 AEST:
- The owner explicitly confirms Azure AI for the current AI services. Record question answering, images and narration accordingly. The previous reasoning-provider question is answered and must not be repeated as an outstanding owner input.
- Preserve evidence provenance: reasoning attribution is owner-confirmed, while image/narration also have prior independent call records. A gateway's historical name is not a current upstream audit. No production endpoint or key changed.
- Current semantic-cache code still computes embeddings through Cloudflare Workers AI with @cf/baai/bge-m3 and SEMANTIC_ENABLED=true. Record this implementation difference instead of removing it from disclosure or asserting that every model computation was independently verified as Azure. No embedding migration was requested or performed in this increment.
- Updated the unpublished privacy page to name Azure AI for the three primary features and to disclose Cloudflare's eligible-question processing. Removed obsolete upstream attribution and its privacy link. Updated bilingual attribution/readiness copies. These edits change documentation only and do not invalidate prior runtime test results.
- Remaining owner inputs are parent verification and Apple website login. Continue Web/native consent qualification and the release plan. No deployment, binary upload or review submission occurred.

Latest checkpoint, 2026-09-16 15:50 AEST:
- Answered the owner's Azure attribution question. Cloudflare hosting is compatible with Azure AI use. Image generation and Azure Speech have verified real calls. The separate Azure-hosted reasoning gateway does not by itself prove an Azure AI model deployment. No production provider was changed. See Backend docs/ai-service-evidence.md.
- Backend complete regression-4 passes 286 tests in 40 files and all per-file gates, 98.67% lines and 93.71% branches. The additional provider/permission subset passes 17 tests, covering official Azure auth, lookalike-host rejection for Azure auth, store:false and no automatic redirects. This is not a zero-retention claim.
- Native complete unit run remains 190 passed and one skipped. native-permission-build-4 succeeds. native-ai-permission-ui-2.xcresult passes all eight FamilyFlowTests, including both previously failing cases. Wrong-PIN errors now scroll into view. The deletion-cancel test verifies the still-present action and absence of deletion before proceeding with actual deletion/readback.
- Exported and inspected English/Chinese permission and offline-withdrawal screenshots in permission-ui-2-images/permission-visual-review.jpg. FamilySettingsView has 98.49% and AIDataPermissionView has 98.94% line coverage in this UI run. The current source snapshot remains unchanged. ExploreView, RootView and VoiceSession still require broader combined qualification. No complete native coverage claim is made.
- The updated fixture on 4237 now serves the previously authorized permission receipt for exploration-only tests. The 4236 real D1/R2 fixture keeps explicit unapproved Family test setups. Both owned fixture servers are stopped, and ports 4236/4237 independently read as closed. Commands and evidence remain under ~/tmp/review/pocket-app-store-release.
- Parent-verification research found Epic KWS. Its official homepage states no upfront cost, recurring charges or volume restrictions for developers/parents. Its PV service verifies the designated adult, not an independently proven guardianship relationship. Proposal: native docs/app-store/parent-verification.md. No KWS account was created, terms accepted or production integration enabled.
- Apple website still shows sign-in. Existing first-use parent-verification and final reasoning-resource questions remain unanswered. Do not repeat settled price, age, project-nature or publication-authorization questions.
- Web lacks AI permission UI/transport compatibility and may use remote browser speech recognition. Do not deploy the server gate alone: it would break Web free-form questions and old TestFlight 19. Resolve the verified-parent flow, then use it on both clients, preserve prepared content/public viewing and coordinate release.
- PLAN/PROMPT and bilingual readiness/attribution/verification documents are updated. Public privacy/support HTML remains unpublished and needs final provider and speech wording. No commit, push, deployment, binary upload or App Store review submission occurred. Next: resolve owner/account facts, implement final verification and Web flow, finish coverage and Apple declarations, then deliver through the authorized channels.

Latest checkpoint, 2026-09-16 15:21 AEST:
- The owner reaffirmed public release, retained the child-focused positioning, and authorized the privacy implementation. Do not repeat the price, age, project-nature or release questions.
- Implementing versioned cloud AI permission with parent-authorized grants, owner isolation, compare-and-swap protection against stale grants, fail-closed native transport guards and durable offline withdrawal. Prepared content and saved reads remain usable.
- Backend migration 0014 and enforcement are local. Ten new actual D1/R2 tests pass with 100% line and branch coverage of the permission module. Existing service regression fixtures must now explicitly represent previously authorized installations. Native build succeeds. The first 63-test run has one test-harness body-stream decoding failure and one existing skip, not yet an accepted regression.
- Direct Azure model-catalog GET returned 200. A small gpt-6-astra request to the supplied official Azure resource returned HTTP 400, "Insufficient quota available for instant inference." See azure-reasoning-probe.json. Catalog presence is not proof of an operational model deployment. The owner has been asked for the intended reasoning resource or confirmation that the original config is intended. No production endpoint was changed.
- Final provider disclosure, statutory children's-data handling and Apple declarations remain unfinished. The technical permission and parent PIN do not independently establish compliance. No Git push, production deployment, native upload or review submission has occurred.
- Next: finish consent and on-device speech safeguards, multilingual UI, complete runtime qualification, settle the actual reasoning deployment and child-data release requirements, then deploy and submit locally.

Latest release-preparation checkpoint, 2026-09-16 15:03 AEST:
- Confirmed decisions: free download without IAP, primary design ages 6-8 with a parent, non-commercial hobby project. The non-trader self-assessment is not yet a saved Apple DSA declaration.
- Apple has independently verified English listing text, subtitle, free USA-base pricing and the Education primary category. All three English 1320x2868 screenshots are COMPLETE. Version 1.0 remains PREPARE_FOR_SUBMISSION without a build. No new native upload, review submission, Git push or Backend deployment occurred.
- The current seven-file native change passes 25 unit and eight UI tests across native-privacy-regression and native-share-language. Every product Swift file has exact-current-hash coverage above 80%, minimum 91.05% and aggregate 97.04%. See docs/app-store/qualification.json. This is a scoped regression, not every product test. No test or build remains running.
- Native deletion requires confirmation and current parent unlock, supports offline retry, verifies the retired credential returns 410, and can create a new family after relaunch. The earlier family-create failure was an offscreen lazy Form assertion, confirmed by hierarchy/video. The test now scrolls and actually creates a new family.
- All ten location permission catalogs now disclose saving discoveries, nearby activities and visit checks. native-build-8 passes. Independent reads of compiled InfoPlist.strings match every source catalog. Product Swift sources are unchanged from the qualified UI run.
- Backend full-tests-3 passes 276 tests in 39 files and all per-file line/branch gates. Production build, 35 Chromium checks, 35 WebKit checks, four artwork checks and Worker dry run pass. Each general browser run has one explicit skip. Artwork fixtures now load all ordered migrations, resolving their reproduced HTTP 500 failures. No further runtime changes followed the full unit run.
- Account deletion migration 0013 and public privacy/support pages remain local. Existing recipient card artwork is preserved, owner writes are fenced, public links are revoked and R2 removal is deferred. Do not promise immediate physical deletion of every provider copy.
- Pending product clarification: retain the child-focused positioning and complete data-flow changes before App Store release, or continue TestFlight. Apple 1.3/5.1.4 add requirements for children's personal data and distinguish a PIN gate from parental data consent. Selected photos/free text may contain personal data. The owner has not answered this new question.
- Pending prior factual question: a public-app model endpoint or the basis for the current gateway use. The existing gateway sends requests to GitHub Copilot. No prohibition is established or claimed. Explicit AI data-sharing consent is still unimplemented. Do not label the gateway as an Azure Foundry model or make unverified retention promises.
- Owned fixture servers on 4236 and 4237 are stopped and both ports independently read as closed. Synthetic fixture data is unrelated to production.
- Native/backend changes remain uncommitted in their hai/app-store-release worktrees. Preserve all evidence under ~/tmp/review/pocket-app-store-release. The latest released app remains TestFlight 0.1.0 (19). Chinese review: ~/tmp/review/pocket-explorer-release-readiness.zh.md.
- Next: settle the child-data scope and provider facts, implement and qualify consent/data-flow changes, finalize declarations/public pages, deploy Backend through its workflow, build/upload 1.0 locally with [skip ci] and submit review. Do not restart old timers or spawn agents. Chinese home screenshot needs recapture if that localization is added.

The user authorized public App Store publication. Work in /Users/haichang/Worktrees/Pocket-Explorer-UI-app-store-release, branch hai/app-store-release, from 257b1d4. Follow docs/plans/app-store-release.md, AS1-AS5. Backend worktree is /Users/haichang/Worktrees/Pocket-Explorer-Backend-app-store-release, from 732b6e6. Do not resume completed navigation work or old timers. Keep local-only native publishing and ten languages.

- AS1 IN_PROGRESS: Apple confirms build 19 is APP_STORE_ELIGIBLE. Existing App Store 1.0 has no attached build or listing assets. Owner confirmed free download, no IAP, ages 6-8 with a parent, and a non-commercial hobby project for non-trader declaration.
- AS2 NEXT: correct missing AI data disclosure, remote-family deletion, public privacy and support pages. Social report/block already exist.
- AS3-AS5 PENDING: store materials, declarations, qualification, local binary and submission. Draft listing and free pricing are saved. Review submission remains pending.
- Evidence: ~/tmp/review/pocket-app-store-release. Current published native runtime remains build 19. Prior release checkpoints below are historical.
## Delivered teammate TestFlight release (2026-09-16)

- Pulled upstream main 3151a0f into hai/teammate-testflight-20260916 in an isolated worktree. Preserve the separate, uncommitted App Store privacy work.
- Qualify the Map/Social consolidation on macOS, correct release-blocking integration errors, then publish locally and independently verify internal TestFlight availability. Do not run native GitHub CI.
- Evidence: ~/tmp/review/pocket-teammate-testflight-20260916. No new build uploaded yet.
- Reproduced duplicate FriendProfileView compilation failure and stale background asset reference. Kept the released routed profile, removed the unused duplicate, and linked the new artwork. Updated renamed/moved-entry tests and all ten localization catalogs. build-3 succeeds.
- regression-1 completed: 192 passes, two UI targeting failures and one gated skip. All eight changed product Swift files pass matching-source coverage, minimum 88.56%. All three social journeys pass against actual Worker/D1/R2 fixture handlers. Production prepared content and sampled artwork/narration hashes pass independently.
- The return failure expected Done instead of the observed BackButton. The Arabic largest-text recording shows a partially visible toggle row whose switch midpoint was below the screen. Corrections update only the test targeting. build-4 succeeds, and corrections-1 rechecks both paths plus the new profile background. Product Swift hashes still match regression-1.
- corrections-1 passes all three selected tests. Latest-per-test qualification is 194 passes, one gated skip and no unresolved failure. Product source still matches the broad regression and all eight file coverage gates. Successful navigation, Social, Chinese/Arabic layouts and the failure recording were visually reviewed.
- TestFlight 0.1.0 (20) is independently VALID / IN_BETA_TESTING in Hackathon Internal, uploaded from this Mac. Source is 9c568c122d5e95a5337b13c035990d71443703de, pushed to main with no native GitHub run. Apple build ID: e14bdfbb-cc35-40e3-afbf-bb7113060148.
- Independent IPA verification confirms signature, release entitlements, tested source, Xcode 27A266a and all ten 583-entry catalogs. Test fixtures and the simulator are stopped, and the temporary signing keychain is removed. External distribution and physical iPhone acceptance are not established. App Store 1.0 remains PREPARE_FOR_SUBMISSION.
- See docs/evidence/teammate-testflight-20.json. This iteration is complete. Preserve the separate ongoing App Store privacy work and do not repeat this release without new input.
## Historical Web filming prototype (superseded 2026-09-17)

This prototype hard-coded Duck/Leaf/Moon and routed prepared answers directly to Card Detail. It is superseded by the configurable Web/App question flow at the top of this document: prepared questions use the native conversation design, and Card Detail follows card creation.

- The sibling Web prepared-question result now directly uses the supplied Card Detail reference rather than an AI chat-bubble answer: back/title/Home header, tappable answer/illustration card, category, Story/Knowledge/Location, My Question, optional story entry, Preview & share and fixed navigation. Arbitrary live AI answers still use conversation UI.
- Both Moon card faces were inspected at 390 x 844 with zero horizontal overflow, no nested scroller, clear fixed actions and a nonblank NASA image. The changed `App.tsx` passes 92.66% line / 80.10% branch coverage. This remains local and undeployed.
- The sibling Web no longer creates a nested `.home-shell` scrollbar on conversation or card reveal. At 390 x 844, Home has zero scrollable children and zero horizontal overflow; longer Moon screens use only document scrolling. Browser screenshots, 86 affected tests and production build pass. This remains local and undeployed.
- The sibling Web Home now treats Duck, Leaf and Moon as repeatable filming shortcuts: each opens its fixed localized answer immediately without live AI, and each run can reveal a fresh card under the exact `Discover a new card` heading.
- The third shortcut is `Why does the moon shine?`, with a fixed sunlight-reflection answer, `Moonlight is sunlight` card and local NASA/JPL/USGS PIA00405 artwork. All ten language catalogs contain matching Moon copy.
- Automated coverage verifies all three shortcuts, zero network calls and three consecutive card reveals. The affected regression passes 86 tests, production build passes and all changed TypeScript files exceed 80% line/branch coverage. The Moon shortcut, fixed answer and nonblank reveal image were checked in the live local browser. This remains local and undeployed.

## Historical production Web AI blocker (resolved upstream)

- The age-10 report is verified: production returns HTTP 403 `ai_permission_required`. Fresh `family:null` and explicit age-10 family `policy.exploration:true` installations receive the same response, so age and parent policy are not the cause.
- Current sibling Backend source has no such gate and its new regression verifies a fresh installation reaches the exploration route. Web now reports the service permission error accurately and preserves the question for retry. Focused tests and build pass; the full Node 24 release gate remains pending.
- No commit, push, workflow run or deployment was performed. Production AI remains blocked until an authorized Backend deployment and real age-10 answer readback succeed.

## Complete explorer journey continuation (2026-09-16)

- The three user-supplied Miro screenshot panels are the explicit reference for Map/Event/Quiz, Collection/Shared cards and Card Detail/share surfaces. Web alignment and browser geometry are recorded in [reference UI alignment](docs/evidence/reference-ui-alignment-20260917.md).
- Native Card Detail now matches the reference four-tab structure: Story, Knowledge, Versions and Location. Versions shows immutable version title/date cards and preserves Card history. Multilingual CardReadingFlowTests now address the new tab in English, maximum-size German and maximum-size Arabic.
- `SocialFlowTests.testJackyJourneyContinuesFromAIThroughMapEventProfileAndExchange` now continues after the accepted reciprocal exchange through Home -> Map -> Collection -> Discovery Quizzes -> voluntary practice -> recall prepared in the Chat tab.
- Fresh verified cards can be practiced early through `ReminderPolicy.practiceCandidate` only when no reminder is due. This does not alter the one-day / seven-day due policy or Ready badge count. A focused unit test covers newest-card selection, reviewed exclusion and due-reminder precedence.
- Swift workspace diagnostics pass and all ten catalogs retain 598 matching keys. This Windows host has no `xcodebuild`, so the extended unit/UI tests and changed-Swift coverage are not claimed as executed. Exact macOS commands and Web browser evidence are in [full journey evidence](docs/evidence/full-journey-20260916.md).

## Web AI Chat parity (2026-09-16)

- Web Map now ports the native always-visible Discovery Quizzes notification, top reminders badge, automatic due prompt, Ready/Completed sheet and persisted answer feedback. Empty Collection visibility and a due-quiz browser journey are verified. Native source remains unchanged.
- The sibling Web implementation now follows the native `ChatHomeView`, `ExploreView`, `AIClient` and `AnswerPresentation` flow: persistent questions/drafts, stable request IDs, live Worker polling, Later/Check answer recovery, quiet History restoration, text/photo/dictation input, optional observations and explicit card creation. The native implementation itself is unchanged in this checkpoint.
- Web Question History now follows the approved Chats drawer reference with grouped/searchable conversations, New chat, persistent row menus and the managed profile footer. Duplicate development records are coalesced without deleting their stored data.
- Web pending and completed AI conversations retain the fixed Chat / Map / Social bar; Chat provides the return path to a fresh question. The native implementation remains unchanged.
- Web now also ports the native observation dictation, separate photo-library/camera entries, optional location and safe-area card actions. Local places remain browser-private and drive the owner's Map marker. The native source remains unchanged.
- Web verification passes the affected test set, per-file 80% line/branch coverage gates, production build, ten 118-key catalog parity and a browser live-answer/recovery journey. The Web source remains local and undeployed.

## Social five-surface demo (2026-09-16)

- Web and native Social now share the same visible hierarchy: Friends / Messages / Shared with Me, avatar presence, parent approval in Messages, exact message time, durable unread badges, reference-style conversation, Cards / Places / Rare profile metrics, privacy-safe Shared map, a shared-card entry, Recent activity, collection and friend options. The Web production build and 17 focused tests pass; the 390 x 844 Friend Profile browser check reports zero bottom-navigation overlap and confirms Recent activity opens Card detail and returns correctly. Web remains browser-local; native remains protected by the real Social service and family policy.
- Friend conversation now follows the approved chat reference: a compact avatar/status/profile header, friend avatars on incoming messages, right-aligned child messages, full event invitation cards, and a fixed bottom composer with gifts/exchanges, text, friend cards and send controls. Cards and Gifts remain reachable as focused subviews without occupying the chat canvas.
- Presence is no longer decorative: Social friend tiles, activity rows, message rows, conversation headers and Friend Profile all read `ExplorerFriend.available`. Online uses a green dot and localized label; offline uses gray and a localized label. The real-service Social flow asserts the seeded friend is Online.
- Existing real behavior is preserved: durable text drafts, offline retry, 15-second refresh, protected event opening, friend-card browsing and gift/exchange receipts. Social UI tests now address the new section controls. This layout is diagnostics-verified on Windows but still requires macOS simulator screenshot and interaction qualification.
- Social now implements the five connected surfaces in the approved flow: Friends with real newest-card activity, searchable Messages with event previews, the event conversation, an interactive Friend Profile, and its mute/remove/block/report menu.
- Opening Social prefetches a bounded set of accepted friends' latest messages and public cards. Activity and collection artwork use the protected Social API. The Friend Profile shows card/rarity/growth metrics, a privacy-safe shared-map summary with exact locations hidden, newest activity and a tappable collection.
- The complete demo route is wired through existing idempotent and atomic service behavior: share an event to an accepted friend, open the resulting conversation, open the friend profile, choose the friend's newest card, request it, explicitly choose one verified public card to offer, submit the exchange, and return to the conversation to observe acceptance. The exchange screen no longer silently preselects a reciprocal card.
- Friend Profile mute state persists locally and displays a `bell.slash` state. Remove, block and report call the protected Social endpoints. Ten language catalogs contain the same 597 keys with no duplicates or omissions.
- The existing real-service `SocialFlowTests.testJackyJourneyContinuesFromAIThroughMapEventProfileAndExchange` now exercises all five surfaces and the reciprocal card choice. Windows workspace diagnostics pass, but this host cannot run Xcode/XCUITest or collect changed-Swift coverage; macOS qualification remains required before release.

## Default Map quiz notification (2026-09-16)

- Map now shows a real Ready-quiz count badge on the Discovery Quiz control. Collection always shows a visible Discovery Quizzes prompt, and automatically presents the medium-height Ready/Completed quiz sheet on first entry whenever `ReminderPolicy` reports at least one due discovery.
- The prompt uses real due-state counts rather than seeded display numbers. Selecting a ready quiz dismisses the sheet, switches to Chat and opens the existing recall question. With no ready quiz, Collection remains uninterrupted and the prompt stays available manually.
- `RecallRouteFlowTests.testMapCollectionShowsReadyQuizPromptByDefault` covers badge, default presentation, Ready count and Chat routing. Ten language catalogs contain the same 597 keys. Windows diagnostics pass; simulator execution and changed-Swift coverage remain pending on macOS.
## Current post-release navigation consolidation (2026-09-16)

- The latest source after TestFlight 19 removes the standalone Memories and Friends tabs. Primary navigation is Chat, Map and Social. Existing memory playback remains routed from Map-owned trip, reminder and new-card flows.
- Social owns Friends, Messages and Shared with Me. Profile's Friends & family row, event sharing, friend profiles, conversations, gifts and exchanges all route through the Social tab while preserving the released centralized navigation stack.
- Windows workspace diagnostics report no Swift errors and static route audits pass. This source has not run XCTest/XCUITest or changed-file coverage on macOS and is not a new TestFlight release. Build 19 remains the independently verified published baseline.

## Delivered navigation and Jacky journey (2026-09-16)

Worktree: /Users/haichang/Worktrees/Pocket-Explorer-UI-jacky-navigation, branch hai/jacky-navigation. Native source f184e8674c7509a5d34c4366811b50e5dbb11db2 is pushed to main and published locally as TestFlight 0.1.0 (19). No Backend runtime change is part of this iteration. Later documentation commits are not the IPA source.

Latest checkpoint, 2026-09-16 13:56 AEST:
- TestFlight 0.1.0 (19) is independently VALID / IN_BETA_TESTING and assigned to Hackathon Internal. Apple build ID: 89fb0dba-2128-48b8-a5ee-dfe62d1339cb. External distribution is not verified.
- IPA signature, get-task-allow:false, tested runtime source, ten 565-entry catalogs and the new icon are independently verified. IPA SHA256: 50d5ac09b39874caef63c1d2001c2057b6a9523a7caf3d23c9571f78ce771c87. Evidence: ~/tmp/review/pocket-navigation-testflight-19 and docs/evidence/navigation-identity.json.
- P40-P45 implementation, automated qualification and local delivery are complete. The latest-per-test matrix remains 266 passes and four explicit skips, with all 30 product Swift files meeting matching-source coverage. See docs/reviews/jacky-navigation.md for the exact scope and retained baseline warning.
- The temporary signing keychain is removed. Owned fixture ports 4203/4236/4237 are independently closed. Simulated location is cleared, Pitch is shut down, and the temporary notification simulator is removed. No new timer, agent or external message was started. GitHub Actions has no run for the native source commit.
- Physical microphone, camera, headphones, interruptions, notification delivery, listening quality and human visual approval remain REVIEW. Use docs/testing/navigation-journey.md for the next iPhone check. Preserve primary-checkout drafts and do not repeat this completed release.

Earlier checkpoint, 2026-09-16 13:47 AEST:
- Automated qualification is complete. review-followup-1 passes all 19 checks. The latest-per-test matrix across full and focused runs has 266 passes, four explicit skips and no unresolved assertion failure. This is not one passing full final-source invocation.
- All 30 changed product Swift files have matching-hash coverage of at least 80%. Minimum is 88.27%, aggregate 95.53%. Runtime/asset hashes remain unchanged.
- Final Chinese/Arabic event sharing, maximum-text memory sharing, accepted exchange and brand screenshots were inspected. Successful final-source Jacky recording is retained in final-jacky-video.
- Review and quick-check guide are complete. Next commit/push with [skip ci], publish locally, then independently read Apple and IPA. Published baseline remains build 18 until those reads succeed.

Latest checkpoint, 2026-09-16 13:33 AEST:
- All ten base-language flows now pass, including the previously selected English/Arabic-largest cases. The expanded maximum-text memory toolbar sharing and return test passes.
- review-followup-1 remains active in session 7713 for the three localized event-recipient flows and three social cases. Product hashes remain unchanged. The runtime snapshot includes 151 application/shared files and assets.
- Apple API preflight succeeds and the latest build remains 18. Use PATH=/opt/homebrew/opt/ruby/bin:$PATH from docs/local-release.md for publication. Default system Ruby cannot load the current Bundler. No global environment or lockfile change was made.

Latest checkpoint, 2026-09-16 13:23 AEST:
- review-corrections-1 passed 21 tests with zero failures and one explicit host-microphone skip. Hidden capture, maximum-text memory, photo recovery, sharing navigation and the full Jacky real-service route pass.
- The successful Jacky video is retained under jacky-success-video. Map, event message, accepted exchange and maximum-text memory screenshots were inspected. RootView is 92.94% and ExploreView 88.27% on matching source. All 30 changed product Swift files passed the coverage gate before the following cleanup.
- Removed one unused environment value from the Friends root. Extended the maximum-text memory test to open the new toolbar share action and return. final-qualified-build succeeded. Next: remaining 12 global-language cases, three localized event-recipient flows, all three social flows and the expanded memory regression. Recheck FriendsView coverage after cleanup.
- Six local-release helper tests and all ten 565-entry catalogs pass. The physical iPhone is unavailable. No commit, push or upload yet.

Latest checkpoint, 2026-09-16 13:11 AEST:
- native-regression-2 completed with 241 passes, 23 failures and four skips. Seventeen obsolete navigation assertions are updated. Three event-language failures came from an omitted fixture content directory, now restored. Two map/event failures show stale or unavailable simulator location. A finite normal-speed route replaces the stopped slow scenario without weakening app freshness checks.
- The large-text memory reading regression exposed a crowded viewport. RootView now places sharing in the top toolbar. The new answered-draft regression independently reproduced a hidden microphone permission request. ExploreView now returns after restoring an answered record, preserving unsent-draft camera/voice entry.
- review-fixed-build succeeded. Correction qualification starts next. A real UN pending-request readback test and expanded localized event-recipient checks are included.
- All 30 changed product Swift files passed the previous exact-source coverage gate. The two latest runtime fixes require new matching RootView/ExploreView evidence. No commit, push or publication yet.

Latest checkpoint, 2026-09-16 12:39 AEST:
- native-regression-2 still runs. GlobalLanguageFlowTests failures are confirmed obsolete Done-button assertions at line 69. The independent failure hierarchy includes native BackButton and navigation-home. Update the tests after the source freeze, preserving the remaining sharing assertions.
- EventFlowTests.testFamilySetupEventVisitChallengeAwardAndCoarseMapSharing fails at event-feedback after requesting location. The actual failure recording is required before classifying its cause.
- MemoryReadingFlowTests.testPausePreservesReadingPositionAndReplayRevealsTheSameChapterOpening cannot scroll the large-text chapter. Review whether the new root-level bottom sharing action crowds the reading viewport and intercepts the test's central swipe. The recording and exact reproduction must guide the fix.
- Native home-camera and restored typed-draft camera paths, denied microphone followed by typing, and the full AI/card/image/memory/share flow pass. Ten localization catalogs have 565 entries each with no missing or empty values. No product source edits during this run.
- Export PNG screenshots and only needed recordings after completion to avoid duplicating the entire multi-gigabyte result bundle. Release readback helpers are prepared locally but have not run for a new release.

Latest checkpoint, 2026-09-16 12:19 AEST:
- native-regression-2 continues with no recorded failure so far. Runtime source and artifacts remain frozen.
- The safe-mode CLI review attempt timed out after 180 seconds with an empty result. Both bounded reviewer attempts returned no opinion. Continue self-review and do not claim external reviewer approval.
- Source review identified a possible hidden-recording path when a Home voice entry restores an already answered record. Reproduce after the full run, preserve answered/observation drafts, and restore the prior no-entry-action behavior for existing records if confirmed. Unsent draft camera/voice entry must remain usable.
- Follow up with an independent read of actual UN pending requests. Unit scheduler and real permission UI checks alone do not establish request-content readback.

Latest checkpoint, 2026-09-16 12:07 AEST:
- navigation-final-targeted-2 passes both draft/Home/relaunch and true warm system URL routing with preserved Map context. Independent host driver records simctl exit 0. The earlier warm failure was the system Open confirmation alert, visible in the extracted video. The test now explicitly handles it through SpringBoard.
- The failed draft screenshot shows the keyboard accessory overlay intercepting taps after an interactive swipe. The existing hide-exploration-keyboard Done button is now exercised explicitly, followed by a no-keyboard assertion. The same app source passes.
- native-regression-2 is now running in session 82424 on the original iOS 27 simulator. No runtime edits, artifact replacements or second UI run on that device. Its driver preserves all automatic recordings and delivers real warm links. Source snapshot exists.
- Local release materials are linked only under ignored .local, with no credential content copied into source. Six local-release helper tests pass. No release has started. Chinese PLAN, PROMPT and TODO current-status sections were refreshed.

Latest checkpoint, 2026-09-16 12:04 AEST:
- Share preview regression was reproduced: opening the routed preview with its own NavigationStack returned to the Map root without exposing create-share. Independent hierarchy and exported video frame confirm it. SharePreviewView now uses FeatureNavigation and contextual back. The exact preview/Home/Done UI test passes in navigation-final-targeted-1.
- In-app original-context recall, wrong-answer review retaining the existing card, one-action Home and cold recall/unavailable links now pass on iOS 27 in navigation-final-targeted-1. Real warm simctl delivery and authorization tests are still running in session 38739.
- The same run's draft test failed immediately after swipeDown because Map was not hittable. Inspect the saved screenshot. An explicit hide-exploration-keyboard button already exists, so qualify actual dismissal rather than assuming every swipe closes the keyboard.
- native-regression-1 actually recorded 174 unit passes and one skip, with no unit failures. The interrupted bundle has no usable coverage report. A new uninterrupted broad run is still required.

Latest checkpoint, 2026-09-16 12:01 AEST:
- native-regression-1 passed 174 unit tests before UI qualification. It was intentionally interrupted (exit 75) after review found a remaining nested NavigationStack in SharePreviewView. Do not count this interrupted run as complete regression.
- share-navigation-baseline-1 is reproducing global Home and contextual Done from that preview before fixing it. Test session is recorded in the task tool output. Do not edit runtime source while this test runs.
- recall-fixed-1 passed four notification units, the restored-draft camera UI and actual system opt-in/disable with an exported permission screenshot. Its route test reached original context, review and retained card. The subsequent Map assertion failed because XCUIApplication.open launches a fresh app and does not simulate warm delivery.
- Warm URL delivery has a host-driven test with a simctl readiness marker. The local run-native.py driver handles it and records its actual exit/output. No runtime debug backdoor is added. A separate in-app recall plus cold-link test remains.
- Full test recording will use the documented xctestrun SystemAttachmentLifetime=keepAlways. The generated plan uses the legacy top-level target dictionary format, now handled by the local driver. The earlier interrupted run did not retain all automatic video.
- Fixtures: 4237, 4236 and newly started delayed-share fixture 4203 (session 18681). Health read passed. Original iOS 27 simulator rebooted with fresh continuous location. iOS 26.4 simulator remains idle.

Latest checkpoint, 2026-09-16 11:55 AEST:
- User added app logo redesign to this iteration. Two high-quality Azure concepts generated and independently inspected at 1024, 80, 60 and 40 pixels. Discovery-card globe (B) is provisionally integrated in AppIcon, home header and language welcome. User preference is optional/pending. Both files are independently decoded RGB PNGs. See docs/design/app-icon-20260916.md and local brand/comparison.png.
- Reminder authorization is supported and works. A stale system permission dialog was outside the app's accessibility tree. The SpringBoard interruption handler accepted it, and recall-springboard-1 passed actual opt-in/disable. Its route failure was an incorrect Other-element assertion: the independent hierarchy shows the original question as visible StaticText in Chat. No platform limitation or unresolved authorization API hang is claimed.
- Authorization can now be cancelled in the app, and late approval/error cannot reverse a newer choice. A suspended-client test covers this race. Home camera/voice entries now honor the explicit action after restoring a draft.
- recall-fixed-1 is running in session 27968 on iOS 26.4 after uninstalling the test app to reset authorization. Four notification units, two routing/system UI cases and restored-draft camera UI are selected. Source snapshot recorded. No runtime edits while it runs.
- Original iOS 27 simulator and continuous location were stopped to leave resources for the first-boot investigation. Reboot/set a fresh location before the complete map journey.

Latest checkpoint, 2026-09-16:
- jacky-flow-3 independently passed the full real-service journey: cached AI, correct unlock, card, current-area map publication, nearby event, actual friend message, recent friend card, bilateral exchange acceptance and one-action Home. Recipient, map and exchange readbacks passed. The overall run failed its separate notification opt-in test, so it is not a passing full suite.
- Navigation/draft regression navigation-drafts-3 passed 12 units and the Home/relaunch UI case. Draft and route implementation is verified for those paths. Broader exact-source coverage remains pending.
- Screenshots of map publication, event conversation and accepted exchange were independently reviewed. A complete successful-route video was not retained and is still required.
- iOS 27 reminder opt-in repeatedly stays disabled without completing authorization in recall-warm-1 and recall-diagnostic-1. App logs confirm requestAuthorization(options: 6), but no completion was observed. Diagnostic prints were removed. No platform support limitation is established.
- A fresh iOS 26.4 simulator (3F7B0D13-FFAB-48CF-BEDA-7CBBC6F28687) is investigating notification behavior. Test session 51665, boot session 66750, recall-ios26-1.xcresult and derived-notifications. Do not edit runtime source while it runs. The original iOS 27 simulator is idle with continuous location active.
- Next: qualify or correct notification opt-in, independently test original-context warm/cold routing, run broad native regression, meet matching-source per-file coverage, inspect multilingual/large-text layouts, review, integrate upstream and release locally. All changes remain uncommitted, with no new TestFlight upload.

Earlier implementation notes:

- P40 IN_PROGRESS: baseline-2 shows exploration as a sheet hiding the tab bar. The routed navigation builds in navigation-build-4 and passes navigation-fixed-2: type a question, dismiss keyboard, switch to Map, return to the same text. Screenshot independently inspected. The initial keyboard-visible test could not distinguish native keyboard occlusion from sheet behavior. The updated regression explicitly dismisses the keyboard.
- Added persistent exploration text/observation/photo drafts, scoped by family, language, demo mode and exploration context. One-action Home, app-link routes, memory routes and Home/relaunch draft tests await navigation-drafts-3.
- P41 IN_PROGRESS: card to map publication and nearby continuation are implemented. Cards without a saved place can explicitly use the current area. Existing coarse-location/privacy API and publication readback remain in place. Complete path verification is pending.
- P42 IN_PROGRESS: friend profile/activity, canonical event links, durable independent event-message drafts and exchange continuation are implemented. Unit tests cover hostile URLs, activity timestamps and offline retry without overwriting ordinary message drafts. Actual fixture integration is pending. New owner-change guard and visible-route check prevent stale send completions from changing another session or destination.
- P43 IN_PROGRESS: recall opens the original question in Chat. Already-earned cards can be reviewed after seven days without repeated awards. Opt-in afternoon notification scheduling, foreground suppression, click routing and private demo preview are implemented but not yet qualified. Physical notification acceptance remains separate.
- P44 IN_PROGRESS: 23 new keys added to all ten catalogs (565 entries each). Six language and three notification unit tests pass in jacky-flow-2, but complete qualification still requires exact-source per-file 80% coverage, Jacky journey, secondary/denied/offline paths, Chinese/Arabic/maximum text screenshots, review, upstream integration and local TestFlight release.
- Current test: session 30821, jacky-flow-3.xcresult, notification route UI and the full Jacky flow. navigation-drafts-3 passed 12 unit tests and the Home/relaunch draft UI test. Previous compilation failures are not test evidence. Do not edit runtime files or start another simulator test until the active run finishes.
- Read-only CLI review exceeded 240 seconds with no output. The process ended, and no reviewer approval is claimed. Continue self-review.
- Fixtures: session 24421 port 4237 native AI fallback, session 74622 port 4236 actual Miniflare D1/R2 and production handlers. Both health/seed reads succeeded. The fixed-2 test ran before the pitch fixture started, without consuming fixture content. This simulator is 810BF22C-8F9B-4C4C-9888-C804D524C5CA and requires DEVELOPER_DIR=/Applications/Xcode-27-RC.app/Contents/Developer.
- Evidence root: ~/tmp/review/pocket-jacky-navigation. Fixed-2 has a matching source hash snapshot and exported screenshot. Current source postdates it.
- Jacky-flow-1 reproduced the invitation keyboard obscuring tabs: UI hierarchy E8771981 and extracted video frame friend-keyboard-failure.png independently show Friends selected with the emoji keyboard. Sending invitations and messages now resigns focus, and social scrolling dismisses the keyboard. Jacky-flow-2 passed the invitation, cached answer, unlock and map-share entry, then reproduced unavailable simulator location. The end-of-video screenshot map-location-failure.png confirms a bounded timeout and preserved global navigation. The simulator had shut down after testing, so static location setup was lost. It is now explicitly booted with location permission and a continuous slow route. Jacky-flow-3 is active. Native screenshot command timed out waiting for screen surfaces and has ended. XCUITest video/frame evidence is available instead.
- New reminder unit checks pass: opt-in denial/disable/failure, owned-notification isolation, afternoon/day caps, hidden demo cards, review persistence without duplicate awards. Horizon expanded to eight days so a newly unlocked card can schedule its first weekly afternoon reminder. The new RecallRouteFlowTests tests real system opt-in and warm/cold app-link navigation. Its first run in jacky-flow-3 failed waiting for the enabled button after no permission alert appeared. Inspect its actual error/UI evidence when the complete run ends. Actual notification delivery still requires device acceptance.
- Remote main was rechecked and remains a64576a. The initial hash-matched coverage has AppNavigation 94.29%, ExplorationDraft 96.77%, EventMessage 97.78%, SocialStore 94.86%. RootView and ExploreView still need broader paths and later source changes require new matching snapshots.
- Next: finish notification integration/callback checks and the full real-service event/profile/exchange path. Do not claim release or complete navigation acceptance yet. Proceed independently without teammate assignments.

## Active roadshow implementation (2026-09-15)

## Map and Social consolidation (2026-09-16)

- Native primary navigation now matches the approved Collection reference with Chat, Map and Social only. The standalone Memories tab and `MemoriesView` list are removed. Existing question-observation-discovery playback remains available from Map trip details, Map-owned reminders and the new-card flow; `TripMemory`, `MemoryPlayer` and public sharing data remain intact.
- All user-facing friend routes now open `SocialView`: the primary Social tab and Profile's Friends & family row. The unused standalone `FriendsView` shell is removed, while its shared friend detail, chat, gift, exchange, report and profile views remain in use by Social.
- UI tests now enter playback through Map and address Social as the third tab. Workspace Swift diagnostics report no errors, and searches find no `MemoriesView`, `FriendsView`, `ReferenceSocialView`, Memories-tab tap or fourth-tab index references.
- This Windows host has no Xcode, Swift or xcodegen executable, so XCTest/XCUITest execution and changed-Swift coverage are not claimed here. The adapted native tests require the established macOS/Xcode qualification before a new TestFlight release.

## Profile and Social alignment (2026-09-16)

- App Profile now follows the Web settings hierarchy: child profile, discovery preferences, notifications, privacy, language, friends and family, location, parent controls and account. Each row connects to an existing native Family, language, reminders, map or Social screen.
- Language remains out of the native Chat home and now lives in Account. Native Friends & family is available and keeps the existing Family policy checks, message, card and gift flows.
- Social now uses the roadshow hierarchy: Friends, Messages and Shared with Me. Existing protected invitations, chats, cards, exchanges and reporting remain behind the reference-style Social entry points.
- Friend Chat now opens a Friend Profile with message, gift, statistics, recent activity, shared collection and local mute state. Shared friend cards use the existing exchange workflow through Request this card.
- Swift diagnostics pass for the touched Profile views and UI tests. XCTest/XCUITest execution remains a macOS/Xcode check.

## Web and native presentation parity (2026-09-16)

- Both products now expose the same primary order: Chat, Map and Social. Collection and question-observation-discovery playback live under Map; Profile, avatar and Social hierarchy remain aligned.

Latest checkpoint, 2026-09-16 04:17 AEST:
- Roadshow implementation is delivered. Backend runtime aafd4fe is deployed through workflow 34998228931. Native source d8d4114 is published locally as TestFlight 0.1.0 (18), with [skip ci]. Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal. External distribution is not verified.
- Independent IPA reads confirm signature, get-task-allow:false, unchanged tested runtime source and ten 542-entry catalogs. IPA SHA256: b6a753efb77b7026ee7e23bb77bf435bfa8d9c15d214caf4380a82661a4c25a2. Apple build ID: 79a87d4a-854c-4c3b-9437-9b327ceff677. Release evidence: ~/tmp/review/pocket-pitch-testflight-18/apple-readback.json and ipa-readback.json.
- Native qualification has 248 latest per-test passes, four gated skips and no unresolved failure across full/targeted runs. All 40 changed Swift files meet exact-hash coverage, minimum 89.28%, aggregate 96.24%. Backend passes 246 tests, 34 Chromium and 34 WebKit scenarios, and 81 actual production requests with cleanup.
- All 60 Marketing packages, 66 image/audio assets and 60 Vectorize records are independently verified. Semantic and repeated-query reuse pass. The legacy user share remains valid. Do not repeat content writes or deployment without a new runtime change.
- Final profile, interest, usage/demo contrast, RTL/large-text, messages and exchanged-card screenshots are reviewed. Integration preserves upstream 906e743 native and ac94a26 web updates. Primary checkout drafts are untouched.
- Test and release sessions have ended. Owned ports 4203, 4236, 4237 and 4238 are independently confirmed closed. Continuous simulator location is cleared. The temporary signing keychain is removed. No native GitHub workflow ran, and no new automation or agent was started.
- Remaining acceptance: the physical iPhone is disconnected. Microphone, camera, headphones, interruptions, listening quality and human visual approval need real-device use. Four deliberately gated native checks remain explicitly recorded. Commercial billing is not enabled.
- PLAN, PROMPT, TODO, release evidence and local Chinese review/quickstart are synchronized. Documentation-only commits after d8d4114 are not the IPA source. Continue from the delivered baseline only when the user supplies the next task or physical feedback.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 03:17 AEST:
- Backend workflow 34998228931 succeeded. Independent Cloudflare reads confirm deployment 01769e05-bb01-4277-8cc8-63fc92d3a4b0, version 9363f4b8-eb62-47d2-9922-570fda3d6217 and all four new migrations. Production acceptance passed all 81 requests and cleanup. Evidence: pocket-pitch-production-check-1, deployment-readback.json and migration-readback.json.
- All six Marketing topics were reindexed. Independent Vectorize reads verify all 60 records, package IDs, languages, versions and 1024 dimensions. A paraphrased prism question returns its prepared package in 4.951 seconds, and a second installation gets the identical reply in 0.152 seconds. Evidence: vectors-readback-2.json and semantic-production-1.json. Early reads exposed asynchronous index visibility. Subsequent complete readback passes.
- Native integrated build-for-testing passes. Added legacy migration and distinct-card statistics checks, and connected profile navigation tests. Superseded incoming signup and local privacy UI are removed. Original full regression 58074 continues. Seven failures now include two old tests not navigating the new conversation layer and three multilingual helpers that stopped before scrolling to offscreen Form fields. Those test adaptations are applied in the integration worktree and await verification. Nearby failures still need screenshot diagnosis.
- Next: finish frozen run, inspect all failures, run integrated targeted regression and per-file coverage, complete visual acceptance, then local TestFlight release. No native upload yet.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 03:09 AEST:
- Backend main aafd4fe includes Litian's ac94a26 and verified race/home fixes. Workflow 34998228931 passed Web/API checks and is deploying. Final local evidence: 246 tests, per-file coverage gates, 34 Chromium and 34 WebKit scenarios, build and Worker dry run.
- All 66 Marketing R2 objects and 60 multilingual packages are installed. Independent production reads verified every package and asset. Each language now has 18 topics. Six protected Vectorize reindex calls and semantic verification remain pending.
- Production acceptance harness passes 81 independent requests against the actual D1/R2 fixture. Production run awaits deployment. Evidence: pocket-pitch-production-fixture-check-3.log.
- Native implementation frozen at 8f0beb0 in pitch-alignment while full regression 58074 runs. Two nearby-map failures remain unresolved. Do not modify its source, fixture or simulator during the run.
- Native upstream integration is active in ~/Worktrees/Pocket-Explorer-UI-pitch-integration, branch hai/pitch-integration. The merge of 906e743 is uncommitted. Use separate DerivedData pocket-pitch-integration-derived. Removed superseded fake signup/local-policy views after the combined baseline failed to compile. New profile visuals connect to FamilyStore and preserve legacy profile drafts without importing privacy permissions. Connected profile tests and migration/metrics checks are being added.
- Next: build native integration, inspect completed regression failures, verify deployment and indexing, run production acceptance, finish native regression/coverage/visual review, then publish TestFlight locally. Latest verified TestFlight remains build 17.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 02:51 AEST:
- Remote main advanced with Litian's reference-login-home work. Backend main ac94a26 and UI main 906e743 must be integrated before release. Do not overwrite these commits.
- Backend implementation is committed locally as 7f044bd. Main integration is committed as 34b32d0. No push/deployment has occurred. The combined baseline passes 242 tests and all coverage gates. Native source is still uncommitted while its full run owns the simulator.
- Backend home merge review reproduced three visible-question mismatches and profile removal/reopening failure. All four now pass in web-merge-fixed-2. Browser regression reproduced hidden collections and an overlapping footer. Corrected CSS passes the exact browser journey in web-merge-browser-3. Full final browser/unit runs remain.
- The Web home remains a clearly labeled local design preview, with real protected family management in the native app. Public stories, events, discoveries and both Studio paths use real service routes. New native profile visuals must connect to FamilyStore, preserving language/demo entries and actual privacy enforcement. Upstream contains duplicate ExplorerProfile/ExplorerAvatar/ChatHomeView declarations, which must be reconciled rather than copied wholesale.
- Native full-1 is still running in session 58074. All family checks pass. Two nearby-map UI tests failed because expected event/shared-card rows did not appear. The public event fixture still returns valid content. Exact cause awaits failure attachments and a targeted reproduction. Do not mark the full run passed.
- Remote R2 staging is still running in session 85487, at 52/66 verified objects. No catalog or Vectorize changes yet.
- A bounded production verification script is prepared locally at ~/tmp/review/pocket-pitch-production-check.py. It uses fictional installations and cleans up public shares, map cards, events and friendships. Validate against fixture 4238 before any production run. Its first attempts exposed harness assumptions about volatile serverTime and canonical chapter titles, which are corrected. No new product defect is established by those harness failures.
- Next: finish backend merge verification and asset staging, integrate native upstream after its test process exits, diagnose nearby-map failures, complete multilingual visual/coverage review, then workflow deployment and local TestFlight release. Build 17 is still the latest verified release.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 02:35 AEST:
- P35/P36 secondary social acceptance now passes: incoming invitation, explicit exchange accept/decline, offline draft retry with one delivered message, and peer revocation. Opening an event link over Profile also passes without an implementation change. Evidence: deeplink-sheet-baseline-1.xcresult, two passing UI checks.
- P37 protected public reindex passes 24 pipeline tests. Full Backend regression passes 32 files / 231 tests with all file-level coverage gates, both in full-9 and the matching CI Node 24 run node24-1. Build and Worker dry run pass. An earlier Node 26 full-8 had a transient existing /api/missing status mismatch. Its isolated six tests and both later full runs pass, with no production code change for that unreplicated failure.
- P39 old unit and UI expectations were reproduced against pending unlocks and grouped conversations. Tests now explicitly answer the recall question before sharing and traverse the conversation layer. The two affected unit groups and answer presentation tests pass in memory-baseline-1. Its two remaining failures reproduced missing memory/close actions after the new quiz path.
- Added NewCardView to share the new-card memory and share journey across exploration, quiz and event awards. Explicit quiz-flow close returns to exploration's presenter. The exact two failing journeys pass in memory-fixed-1.xcresult, including independent share readback and saved observation reopening. Final aggregate coverage is pending.
- P39 full native regression is running in session 58074, log native-full-1. It includes all unit/UI tests and new Chinese/Arabic/maximum-size family, social and event cases. No native source modifications or second simulator test while this runs. Live microphone/provider/share checks remain separately gated.
- Native fixture routing is now explicit: FixtureServer uses 4237, PitchFixtureServer uses 4236, and delayed sharing uses 4203. Legacy fixture adds deterministic recall receipts for earlier artwork/speech recovery tests. Pitch fixture has real multilingual prism content for new language layouts and corrected fictional Moon text.
- P39 self-review reproduced three backend races in write-races-baseline-1: concurrent evolution reached 31 versions, event award survived parent revocation, and a map publication persisted invisibly then reappeared when permission was restored. SQL write conditions now enforce the limit and current family permission, revision and active usage. All 14 targeted checks pass in write-races-fixed-1. These changes postdate the previous full Backend regression and require another complete run.
- CLI review through cl -p again exceeded its 240-second deadline without a report. Do not claim independent reviewer approval. Self-review continues.
- P37 remote immutable asset staging is running in session 85487 with 16/66 independently hashed at this checkpoint. Evidence: pocket-pitch-content/remote-assets-verified.json. D1 catalog, events and Vectorize are unchanged. Native and Backend source remain uncommitted. TestFlight is still Build 17.
- Active services: 71116 legacy fixture 4237, 90581 pitch fixture 4236, 68285 separate Studio fixture 4238, 32046 delayed sharing 4203. Next: finish races/full regression and visual review, complete content installation and index verification, verify actual workflow rollout, then publish native from this Mac with [skip ci].

Earlier checkpoint:

Latest checkpoint, 2026-09-16 02:17 AEST:
- P37 all six Marketing illustrations now have 60 qualified ten-language packages and 60 real Azure narration files, 40.05 MiB total. No remaining content-review failure files. The qualification harness imported twice with a stable revision and verified 180 public API content/asset reads against actual D1/R2. Original art and 1024 px bundled derivatives are pixel-equivalent under uncropped LANCZOS resizing. No remote content writes yet.
- P38 complete prepared examples can start a new private Studio draft without overwriting the selected published draft. English, Chinese and Arabic text/artwork flows pass. Seven Chromium and seven WebKit scenarios pass in pocket-pitch-web-browser-8.log and web-webkit-3.log. Reviewed mobile screenshots show usable full-width forms and corrected date inputs.
- P32 shield dismissal restores the original Profile sheet after parent policy changes. The screenshot and interaction are verified in social-recovery-2.xcresult. FamilyPauseShield coverage is 97.62%.
- P36 revoked transfers are cleared, received cards recover from the owner's paginated collection even after friendship removal, and exchange drafts preserve their requested-card title. Six Social and six Collectible unit checks plus the Family UI check pass in social-recovery-2.xcresult. Store/client coverage is above 94%.
- P35 secondary-flows-1 passes all three map/event/link scenarios. Current-source coverage: NearbyDiscoveryView 97.97%, EventDetailView 96.36%, MapSharingView 98.58%. P36 main social interaction passes, FriendsView 93.57% and GiftComposerView 94.22%. The incoming-flow test used /cards instead of /collection and failed with 404. Corrected test rerun is active, alongside a deep-link-under-profile-sheet baseline, session 91972.
- P37 protected public-content reindex endpoint and three real-D1 scenarios added. All 24 content-pipeline tests pass in reindex-1. Its focused run is not a whole-project coverage gate. The upsert mock's TypeScript tuple signature was corrected afterward. Full regression, deployment indexing and live match verification remain pending.
- Active fixture sessions: 7821 on 4236, 68285 on 4238, 22201 on 4237. Native session 91972 owns the pitch simulator and DerivedData. No source changes while it runs.
- Next: inspect deep-link baseline, finish secondary social acceptance, RTL/large text, full native/backend regression and review. Publish the qualified content and event examples with independent reads during the backend rollout, then archive and upload TestFlight locally. All iteration changes remain uncommitted and undeployed. Latest verified TestFlight is still Build 17.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 01:55 AEST:
- P34 five actual GPT-6 responses are reviewed in pocket-pitch-live-replies-2.json. Aged-six versus aged-thirteen explanations differ appropriately. A sunset follow-up advancesCard=true, unrelated penguins and repetition=false. This is bounded provider evidence, not a general correctness guarantee.
- P35 event/discovery app links pass links-native-2.xcresult. DiscoveryLinkView has 100% line coverage. Shared content and unavailable-state screenshots inspected. NearbyDiscoveryView still needs its in-map shared-card sheet exercised against current source.
- P38 browser regression found and fixed mobile event datetime inputs overflowing. The original test selector also included option text in an implicit label. Public event/card pages and Event Studio now pass four Chromium and four WebKit scenarios in browser-5 and web-webkit-1. Separate actual D1/R2 Studio save/publish/readback/withdraw passes both engines in studio-live-1 and studio-live-webkit-1. Brand link styling was improved afterward and needs its final screenshot.
- P32/P39 an actual already-presented profile sheet bypassed the root screen-time overlay. sheet-baseline-1 fails at the unhittable pause button. FamilyPauseShield now covers presented sheets in a separate scene window while leaving protected parent settings reachable. Two Chinese/English UI tests pass in sheet-fixed-1, with 85.71% shield line coverage. Parent-driven dismissal/return to original sheet still needs verification.
- P37 six original square illustrations are visually checked and retained. 1254 px originals are resized to uncropped 1024 px service derivatives, never regenerated. Source excerpts are verified locally in pocket-pitch-content. Preparation harness testing/prepare-marketing-content.ts is running with two topics at a time, real text verification and real Azure narration. One full ten-language Maya package is ready. Red-panda and torii source/detail review failures and the first English speech timeout require correction/retry. No packages uploaded or published.
- Current sessions: 99303 content preparation, 82615 native social revocation baseline, 68285 independent Studio fixture port 4238, 7821 original pitch fixture 4236, 22201 legacy AI fixture 4237. Backend full regression is also running, log backend-full-6. Do not modify native source or launch a second native test until 82615 ends.
- Next: complete P37 source review, narration and Studio sample content, fix revoked-transfer memory and lost-receipt recovery, verify native incoming social/actions, shared map, RTL/large text, deep links under sheets, full regression, review and release. All iteration changes are still uncommitted and undeployed. Build 17 remains the latest TestFlight release.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 01:35 AEST:
- P35 event-native-flow-5 passes the complete family setup, native nearby map, wrong/correct challenge, institution card award, coarse map publication and revocation. Screenshots inspected. EventDetailView 97.01%, MapSharingView 98.58%. NearbyDiscoveryView is still 76.60%, requiring actual shared-card detail coverage. Public map artwork and event/discovery app-link entry were added afterward and await UI verification.
- P36 backend review fixed gift delivery while the recipient is taking a screen break. A failing regression proves the original refusal. Social writes now recheck both families' permissions at the SQL write boundary. Full Backend regression 29 files / 220 tests and per-file 80% gates pass in pocket-pitch-backend-full-4.log. Later P38 changes are not part of that evidence.
- P36 native private codes, acceptance, text chat, durable draft/transfer retries, friend collections, gifts, exchanges, reporting and block/removal are implemented. Four unit checks and one actual D1/R2-backed simulator flow pass in pocket-pitch-social-native-flow-2.xcresult. Independent peer API reads confirm sent messages and transfers. Screenshots inspected. Coverage: SocialModels 100%, SocialClient 98%, SocialStore 94.49%, FriendsView 91.69%, GiftComposerView 94.06%. The artwork in this deterministic fixture is a test image, not final Marketing content.
- Native reviews corrected received-card timestamps, blank provenance labels and a message-cursor issue where sending could skip unread messages. Sequence is the message identity, preserving messages from different senders even if their request UUIDs match.
- Added 110 event/social/link strings to all ten catalogs. Global language, event and social unit run now passes 13 checks in pocket-pitch-localized-unit-2.xcresult. New app-link screens, Chinese/Arabic/large-text layouts and the latest gift wording still require matching UI review.
- P38 public event and coarse discovery pages plus Event Studio (/studio/events) are implemented locally. Event Studio supports multilingual events, existing public reward selection, draft/publish/withdraw and private report review. Six frontend tests are implemented. An initial public test used Node's unavailable localStorage and another expected the wrong existing missing-page caption. These test fixtures are fixed. Full current Backend regression is running in session 37896, log pocket-pitch-backend-full-5.log.
- Fixtures: 4236/session 43132 now includes social migration/routes and a loopback-only fictional peer seed endpoint. 4237/session 22201 remains available. No native build or UI test is active at this checkpoint.
- Remaining required work: P34 live-provider checks, P35/P36 secondary UI/privacy boundaries, P37 six complete multilingual supplied-art packages and backgrounds, P38 browser/integration/coverage review, P39 complete native regression, old-expectation updates, screen-time coverage across presented sheets, final review and release. Current app-link behavior while another sheet is open also needs testing. Do not claim completion at this increment.
- All changes remain uncommitted, undeployed and unpublished. TestFlight is still Build 17. Native release must be local with [skip ci]. Do not restart expired timers or agents.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 01:18 AEST:
- P35 native events, nearby hybrid map, local eligibility, institution card receipt and coarse map publication are implemented. Fifteen focused unit/language checks pass. EventStore is 100%, EventClient 95.18%, EventModels 100% covered. Evidence: ~/tmp/review/pocket-pitch-events-native-unit-1.xcresult.
- Location regression independently reproduced waiting for reverse geocoding before exposing coordinates. Coordinates now become available immediately and a late geocoder can only refine the same request. All five DiscoveryLocation tests pass in events-native-flow-4. The same UI run reached exclusive-card award and map sharing, then failed because a toggle lacked its test identifier. Identifier corrected. Event UI rerun is active in session 89470, events-native-flow-5.xcresult. Do not run another native build concurrently.
- P36 backend friendship codes, acceptance, text chat, collections, gifts, explicit exchanges, block/report and artwork reuse are implemented with migration 0012. Six real D1/R2 integration scenarios pass in pocket-pitch-social-2.log. Initial five-second timeouts caused a cascading cleanup failure. Bounded longer deadlines resolve the long pagination/exchange scenarios. Per-file social coverage and review are still pending. A new recipient-screen-break regression is under verification.
- P35 native new event strings still need ten-language translation. P36 native social, P37 supplied content, P38 web/Studio and P39 final acceptance/release remain required. The latest public release is still Build 17. All current changes are local and uncommitted.
- Fixture 4236/session 59827 includes events but predates social routes/migration 0012. Restart only after the running event UI test finishes. Fixture 4237/session 22201 remains available.

Earlier checkpoint:

Latest checkpoint, 2026-09-16 00:55 AEST:
- P33/P34 native pending cards, wrong-answer retry, correct-answer reveal, durable recall outbox, verified versions/styles, evolution and grouped conversation history are implemented. Seven unit checks pass in collectible-flow-1. Actual D1-backed UI logs in collectible-flow-3 pass the complete V1 → V2 → style → relaunch → grouped history scenario. Xcode did not finalize its result bundle after the suite, so result/coverage export is not yet acceptance. The task-owned xcodebuild PID 16436 received INT to recover. The preceding flow-2 failure was an ambiguous underlying-sheet accessibility match, fixed in the test selector, not an app behavior failure.
- Review fixes: unverified evolution rejection restores pending state without changing older cards. Verification requires the specific exploration version. Concurrent recall callers await one task. The root pending route stays stable while answering a nested quiz. Twenty-nine new strings are translated in all ten catalogs, pending matching-source language/UI verification.
- P35 backend event authoring, localized previews, location/challenge claims, institution provenance and coarse public map deposits are implemented with migration 0011. Focused 16 tests pass. Full Backend regression now passes 28 files / 212 tests and every-file 80% line/branch gates. Evidence: ~/tmp/review/pocket-pitch-backend-full-2.log. No deployment or release.
- P35 native event/map interactions are next. P36 social, P37 full supplied content, P38 web/Studio and P39 final verification/release remain outstanding.
- Local fixtures: 4237/session 22201 and 4236/session 23977. The latter must be restarted before event testing to load migration 0011 and new routes. Its current live code covers P33/P34. Use TEST_RUNNER_POCKET_AI_FIXTURE_URL for xcodebuild UI runner overrides, and verify the actual target URL.

Earlier checkpoint details:


The user requested every product feature in the eight roadshow slides this iteration. Scope and acceptance: docs/plans/pitch-alignment.md. This active task supersedes previous deferrals and does not resume expired timers.

- P30 DONE: slide authority, scope matrix and bilingual plan independently read back.
- P31 VERIFIED LOCALLY: family/profile, PIN/recovery/session, active usage and existing AI/share enforcement pass 15 real D1 tests. All three new modules have 100% line/branch coverage. Final typecheck passed after correcting a missing ASSETS test fixture. Migration and deployment remain pending.
- P32 VERIFIED IN INITIAL FLOWS: native family settings, profiles, parent PIN/recovery, persistence and screen break pass 6 unit, 5 language and 2 real-D1-backed simulator UI tests. Final source coverage: FamilySettingsView 99.23%, FamilyStore 97.81%, FamilyClient 98.11%, FamilyModels 100%. Ten catalogs now have 402 entries. Chinese profile/break and English permissions/relaunch screenshots inspected. Additional large-text, Arabic and active camera/sheet timer boundaries remain in P39.
- P33 IN_PROGRESS: server correct-answer awards, immutable evolution versions, Common/Rare/Epic tiers, styles and pending-artwork share protection implemented. Tests cover duplicate requests, repeated questions, owner isolation, demo provenance and 30-version bounds. Native unlock/evolution is next.
- P34 IN_PROGRESS: backend conversation grouping, bounded profile/history/mastery, parent-managed age, personalized cache bypass and server-assessed evolution eligibility implemented. Derived demo context keeps demo provenance. Ordinary/prepared questions retain reuse. Native conversation UI and live-provider verification are pending.
- P35-P38 PENDING: events, social, complete supplied content and web/Studio views.
- P39 PENDING: per-increment tests/review, full regression, Backend workflow and local TestFlight release.
- Commercial scope: awaiting user answer about real subscription payments. Continue product work independently.
- Worktrees: ~/Worktrees/Pocket-Explorer-UI-pitch-alignment and ~/Worktrees/Pocket-Explorer-Backend-pitch-alignment. Branch hai/pitch-alignment in each. Baselines c413aaf and 8cca26f.
- All implementation changes and migrations 0009/0010 remain uncommitted and undeployed. Backend full regression: 27 files, 205 tests, all per-file 80% line/branch gates pass. Typecheck and diff checks pass. No new TestFlight release.
- Native final family result: ~/tmp/review/pocket-pitch-family-final-1.xcresult, coverage JSON and exported attachments alongside it. No build/test is running. Dedicated simulator 810BF22C-8F9B-4C4C-9888-C804D524C5CA is this task's device. Use ad-hoc simulator signing (CODE_SIGN_IDENTITY=-), not CODE_SIGNING_ALLOWED=NO, because unsigned simulator builds failed Keychain setup.
- Two task-owned fixtures remain running: native AI fixture port 4237/session 22201 and Backend testing/pitch-fixture.ts port 4236/session 64928. The latter uses actual Miniflare D1 for family/collectible routes and forwards other routes to 4237. Its running code predates the latest context schema, so restart before new context/collectible UI tests.
- Read-only cl -p review timed out after 145 seconds with no output. No clean-review conclusion is claimed. No Codex subagents or recurring timers were started.

Everything below describes earlier deliveries or historical checkpoints.

## Current delivery: cached-answer presentation and private demo (2026-09-15 20:28 AEST)

This is the current state. Older dated checkpoints below are historical and must not trigger another release or resume expired automation.

## Local Profile Hub (draft)

- The Chat profile entry now opens a complete local Profile hub: Child Profile, Discovery Preferences, Notifications, Privacy, Location and Account. Friends & Family remains visibly unavailable because there is no online friend system.
- Privacy follows the approved grouped visual structure and persists only to the on-device profile. Only me, location off and public sharing off remain defaults. No parent PIN or approval gate was reintroduced.
- Native diagnostics pass for the touched Profile views and tests. XCTest, XCUITest, coverage and physical-device review remain required on macOS.

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
| T22 local child profile | REVIEW | Email registration now leads to an editable child profile with avatar style, nickname, age, optional gender and interests before the Chat home. Data remains device-local. Web checks pass; native diagnostics pass and macOS CI remains required. |
| T23 local profile and privacy | REVIEW | Chat now opens a full Profile screen with child details, local discovery statistics, interests and settings. Privacy matches the approved grouped layout: audience, location, Permissions, AI content level and daily use. `02-wildflower-meadow` is the dedicated uncropped, full-width background for native and Web Profile surfaces. Preferences remain local; Only me, location off and public sharing off are defaults. Web checks pass; native diagnostics pass and macOS CI remains required. |
| T24 Web Chat home alignment | REVIEW | The Web root now follows the native Chat home: compact history/brand/profile header, hero art, three suggestion rows, a fixed camera/question/microphone composer and Chat/Map/Memories navigation. Existing exploration states remain intact. Web build and 13 focused home/Profile tests pass; human visual approval remains open. |
| T20.2 / T21.2 physical speech | REVIEW | Physical naturalness and recording remain unverified |
| Physical camera, VoiceOver and Safari | REVIEW | Post-release device read still shows disconnection. Preserve TestFlight installation |
| Final checkpoint | DONE | Evidence, Chinese copies and guides synchronized, checked and pushed. Checkpoint paused after the deadline with independent readback |
| Online accounts, friends and chat | DEFERRED | Explicitly outside this iteration; T22 and T23 are local device profile/preferences only |

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

# Full explorer journey evidence (2026-09-16)

## Journey

AI conversation -> make card -> view card -> share broad Map marker -> inspect nearby event -> share event with friend -> open friend profile -> open newest activity card -> request card -> choose reciprocal card -> return to conversation -> open quiz notification -> enter recall in Chat.

## Web

Status: executed end to end in Chromium at 390 x 844.

- The browser-local card was published with `Shared on map · broad location`; no precise location entered the public marker label.
- `Sky watchers` opened from Nearby events, then shared to the fictional `Dou Dou` profile and appeared in the friend conversation.
- Friend Profile Recent activity opened `Moon neighbour`. Requesting it required selecting `Duck paddles` as the reciprocal card before sending.
- The conversation displayed `Exchange requested` and `Waiting for your friend`.
- Discovery Quizzes opened the new card for voluntary practice and routed into the Chat tab with three choices. The correct choice produced `You remembered!` and Map remained reachable.
- Browser geometry: no horizontal overflow. The friend composer cleared the fixed navigation by 4.9 px. Recall rendered with Chat / Map / Social visible.
- Automated journey: `web/tests/journey.test.tsx`.
- Final affected regression: 84 tests passed. Production Vite build passed.
- Changed-file coverage: App.tsx 93.47% lines / 81.60% branches; SocialHub.tsx 97.91% / 86.33%; DiscoveryMap.tsx 100% / 90.62%; explorer.ts 100% / 87.71%.

## Native app

Status: implementation and static validation complete; runtime execution is pending on macOS.

- The existing `SocialFlowTests.testJackyJourneyContinuesFromAIThroughMapEventProfileAndExchange` already covers live/prepared AI, card reveal, Map publication readback, nearby event detail, protected event sharing, Friend Profile Recent activity, card request, explicit reciprocal offer and accepted exchange.
- The test now continues through Home -> Map -> Collection -> Discovery Quizzes -> voluntary `Quiz me now` -> recall question in the Chat tab.
- `ReminderPolicy.practiceCandidate` exposes the newest fresh verified card only when no reminder is due. It does not change the one-day / seven-day notification policy or Ready badge count.
- `RecallNotificationTests.testPracticeCandidateOffersNewestFreshCardWithoutChangingDueState` covers candidate ordering, reviewed-card exclusion and due-reminder precedence.
- Swift workspace diagnostics passed. All ten localization catalogs contain the same 598 keys with no duplicates, missing keys or extra keys.
- This Windows host has no `xcodebuild`; no native XCTest/XCUITest or changed-Swift coverage result is claimed for these edits.

Required macOS commands:

```sh
cd ios
xcodegen generate
export POCKET_SIMULATOR_ID="<available-iPhone-simulator-UDID>"
DEVELOPER_DIR=/Applications/Xcode-27-RC.app/Contents/Developer \
xcodebuild -project PocketExplorer.xcodeproj -scheme PocketExplorer \
	-destination "platform=iOS Simulator,id=$POCKET_SIMULATOR_ID" \
	-derivedDataPath "$HOME/tmp/review/pocket-full-journey-derived" \
	-resultBundlePath "$HOME/tmp/review/pocket-full-journey.xcresult" \
	-parallel-testing-enabled NO -collect-test-diagnostics never \
	-only-testing:PocketExplorerTests/RecallNotificationTests/testPracticeCandidateOffersNewestFreshCardWithoutChangingDueState \
	-only-testing:PocketExplorerUITests/SocialFlowTests/testJackyJourneyContinuesFromAIThroughMapEventProfileAndExchange \
	test
```

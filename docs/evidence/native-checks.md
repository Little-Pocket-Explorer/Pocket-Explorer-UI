# Native verification

Environment: Xcode 27.0 (27A5194q), iOS 17 deployment baseline, iPhone 17 Pro Max simulator on iOS 26.4.

- The app compiled after voice, cards, world, memories and sharing UI were added.
- First UI run passed 3 tests: three-tab navigation, card front/reverse, memory pause/replay/manual navigation, actual typed discovery saved across process relaunch, and explicit unmatched-demo behavior preserving input.
- Result bundle: /Users/haichang/tmp/pocket-ui-tests-1.xcresult.
- Second run added 4 passing sharing unit tests including actual Keychain writes and independent reads, shared-fixture export, owner authorization, bad-response handling and configuration checks. The trip-detail UI test failed because its scroll gesture was captured by the interactive map. The compact overview has been changed to retain marker taps without panning. The corrected flow passed in the final run.
- Result bundle: /Users/haichang/tmp/pocket-tests-2.xcresult.
- Screenshots are under design/key-screens. A system account alert interrupted the first capture. The later capture explicitly dismissed that unrelated reminder.

Real-device recording, playback, camera, permissions and full-flow evidence are pending. devicectl sees cached pairing data but cannot establish a connection. No real-device install is claimed.

The initial 87.2% core-only coverage predates most UI and is not the final coverage result. The final combined run passed 29 tests with 92.97% Swift line coverage. See final-checks.md for the current result and source denominator.

# First-use correction: build 3

First launch offers device language, Simplified Chinese or English. The choice persists and can be changed from home. Interface and voice use the same selection. Home places exploration before the map. Exploration has a fixed primary action, and a saved card leads directly to memory creation and parent share preview. Playback controls remain visible at the bottom.

The old home-entry problem was reproduced on the 375pt simulator. The corrected home, Chinese flow, language persistence, saved-card relaunch, larger text, reduced motion, memories and sharing have passing evidence. Regression 2 passed 25 unit and 12 UI tests. Its one map failure was caused by full-screen test swipes overshooting the marker. Short controlled scrolling passed the same marker and destination assertions separately without an app source change. All 38 checks have passing evidence across the two runs.

Changed-file Swift coverage is 2680 / 2853 executable lines, 93.94%, across all 15 changed files. The two new language files are 100%. VoiceSession.swift full-file coverage is 66.7%. Actual recording hardware branches remain unverified and are retained in the denominator.

Build 3 was archived with Xcode 27 RC and its signature independently verified. CLI upload returned an account-access error. Organizer subsequently confirmed PocketExplorer 0.1.0 (3) uploaded. Build 0.1.0 (3) is uploaded and independently verified as Testing in Hackathon Internal. The user can update through TestFlight. Build 2 installation on Hai's iPhone 17 Pro Max, iOS 27, is confirmed. Build 3 first use, speech and camera await user feedback. Apple currently prevents adding build 3 to the external group because one build from version 0.1.0 is already in Beta App Review. Build 2 remains Waiting for Review. Real-iPhone first use, speech, camera and human visual acceptance remain pending. The web viewer and storage format are unchanged. Creating public links still requires parent owner-key configuration.

See [structured evidence](first-use-build3.json) for result bundles, coverage by file and exact artifact paths.

# Private demo and prepared-answer presentation review

This candidate adds private content management, one-use phone activation, supplied artwork and backgrounds, and progressive text with automatic narration for prepared answers. TestFlight 0.1.0 (17) is independently VALID and IN_BETA_TESTING in Hackathon Internal. Native changes passed final qualification. Backend source ac49387 is deployed through workflow 34954953344.

## Corrected findings

- Prepared questions opened through the quiet history path and skipped narration. Explicit exploration now uses the same text and speech presentation as a new live answer. History remains quiet.
- An obsolete SwiftUI view task could begin after a new presentation and finish its text early. Tasks now capture their presentation generation. A failing UI test and a targeted regression cover the correction.
- Text reveal preserves full paragraph layout and can be skipped immediately. Dismissal and backgrounding end presentation and speech. Reduce Motion and VoiceOver get complete text, with no competing automatic narration for VoiceOver.
- Saving a draft followed by failed speech preparation left the editor on an obsolete revision. The saved revision now remains retryable, and explicit reload is available.
- Unpublishing after a publication lease expired did not cancel the old claim. Unpublishing now clears the claim, and actual D1 tests prove stale completion cannot republish.
- Invoking native browser fetch as a class method caused Illegal invocation. Actual Chromium testing reproduced it, and the call now has no class receiver.
- Local previews lacked /studio and /demo routes and blob image permission. Both were added. Cloudflare already has SPA asset routing.

## Established verification

- Backend: 188 unit and actual D1/R2 integration tests pass. Every source file meets the 80% line and branch coverage gates.
- Chromium at 390px and 1440px: actual uploaded PNG decoding, preview, saving, invitation links and no credential persistence.
- WebKit at both sizes: editor flows pass. Its interception protocol omits Blob request bodies, so byte decoding is covered by Chromium and Worker integration tests rather than claimed for WebKit interception.
- Six native demo logic tests cover authorization, persistence, offline state, expiry and revocation.
- Four presentation tests cover multiple scripts, emoji, skipping, old tasks, cancellation and bounded duration.
- Actual native UI tests cover prepared narration, offline reopening, background stop, quiet history, activation, absent ordinary-user entry, ordering, separate catalogs and revocation.
- Supplied background, demo Home, profile and full-answer screenshots were inspected. Collection screenshots exposed filled artwork enlarging grid cells. A failing bounds assertion reproduces this, and fixed square artwork containers passed final verification.
- Independent Cloudflare reads confirm migration 0008 and deployment 280b53b4-470c-4f0e-956b-f1f7eec69f17.
- Live upload, exact authored text and image, Azure English audio, one-use activation, isolation, sharing and revocation pass. The test share returns 410, test devices are revoked and the sample draft is unpublished.
- The first speech preparation failed at the 20-second request boundary. Later actual preparation succeeded and the saved draft remained retryable. Cold start is not a confirmed cause. Two validation-script contract errors, expecting queued status for completed artwork and omitting derived memory chapters, were corrected before the full live pass.

## Remaining gates

Native qualification is complete: 139 unit tests and 25 UI tests pass across matching-source runs. One host-microphone test remains skipped. The final supplement passed one real HTTP test and five UI tests. Changed executable-line coverage is 334/344 (97.09%), every changed file at least 85.37%. The collection cards have a 14pt gap, 20pt outside margins and equal 263.33pt heights. Final Home and Collection screenshots are inspected. Local publication is complete. Independent Apple and IPA reads verify build 17, its group, signing, all ten catalogs and unchanged tested source.
Physical iPhone microphone, listening quality, camera and operating-system interruptions still require device verification. Simulator state and validated audio files cannot substitute for them.
Event flows, real accounts and friend chat are not implemented. Miro references were thumbnail-limited, so pixel-exact implementation is not claimed.

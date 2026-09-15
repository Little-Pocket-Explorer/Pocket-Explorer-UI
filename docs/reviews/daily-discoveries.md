# Daily discovery review

Date: 2026-09-15. Status: implementation and local verification are complete. Release awaits completion of the remaining independently qualified content. TestFlight remains 0.1.0 (14).

## Findings and corrections

| Finding | Correction | Evidence |
| --- | --- | --- |
| A replaced Home task could cancel a download while its successor skipped the existing request | RecommendationStore owns one durable synchronization task per context | Cancellation and stable-download regressions |
| An evicted language bank could send an ETag for a bank no longer on disk | Fetch a full response without waiting six hours | Three-language eviction regression |
| Withdrawn discoveries lacked a notice in existing collections | Retain cards and memories and show a ten-language correction notice | Persistence assertions and rendered card flow |
| Permanently unavailable prepared references retried registration every minute | Decode the distinct error and persist permanent registration failure | A 409 reproduction covers relaunch, sharing and request counts |
| Xcode converted prepared PNG resources, invalidating server hashes | Disable both PNG compression and text stripping | The original sixty bundle assertions failed. All now pass, and six built PNGs match their source bytes |
| The top-right avatar contained an off-center circle and extra background | Crop the existing artwork to a transparent circle, draw the border inside and use consistent 44pt bounds | Actual English, Simplified Chinese and Arabic Home screenshots inspected |
| iOS 27 renamed the system camera dismiss identifier | Accept both observed identifiers in tests | Camera entry and dismissal regressions pass |
| The Arabic largest-text Memory test tapped under the tab bar | Scroll into the usable area before tapping | Original failure geometry and corrected Memory screenshot |
| The app background-refresh entry lacked direct coverage | A DEBUG-only background transition invokes the same refresh handler | An HTTP read occurs, today's questions remain stable and the following day works offline with the downloaded revision |

## Verification boundaries

The earlier complete regression ran 191 tests: 185 passed, three failed and three were explicitly skipped. Its failures were the two camera identifiers and obscured Memory tap above. It is not final-source acceptance.

The final resource and interface regression, native-foundation-3, ran 150 tests: all 129 unit and twenty UI tests passed, with no failures and one explicit host-microphone skip. It covers real offline resources, withdrawal, sharing, daily activation and avatar layout.

The supplemental native-background-entry run passed twenty content unit tests and two UI tests with no failures or skips. Only the App file gained a DEBUG testing entry between runs. All other application source was unchanged. Final changed executable-line coverage is 477/481, or 99.17%, with every changed file at least 90%. App-file coverage uses the last run alone, avoiding stale line-number merging.

Ordinary UI flows inject a controlled catalog. A separate fresh-install test uses the real six-topic resources with the server unavailable, covering English, Simplified Chinese and Arabic answers and artwork. Unit checks cover all ten language bundles. Screenshots of the three-language Home, real cards, withdrawal notice, largest-text Memory and camera were individually inspected.

The background test exercises the real refresh handler, not iOS scheduling punctuality. Physical iPhone microphone, camera, speech quality and interruptions remain unverified. The 200ms text and 500ms cached-audio goals have not been measured on a specified device.

During camera DismissButton animation, iOS 27 repeatedly reports Invalid frame dimension without a source location. The composer remains usable after dismissal and no corresponding layout failure was observed, but the warning's origin is unresolved. AVAudioSession synchronous-activation warnings also remain. Two bounded cl/Opus review attempts returned no usable result and do not count as a passed review.

## Release gate

The isolated backend has ten qualified topics and 100 complete language packages. All 140 language and age slices have ten topics. The accepted launch minimum is twelve, leaving two missing topics. The user clarified that Azure capacity is effectively unlimited for this project. Explicit unlimited question, image and speech policies now retain usage accounting without the former cumulative ceilings. Cloudflare controls remain separate. All 177 backend tests, changed-file coverage gates and the build pass. The old partial-reservation bug was reproduced and corrected with atomic D1 accounting.

The six-topic native bundle is complete. Production content and semantic flags remain disabled, and preparation is resumed in validation with two corrected ten-language drafts. This feature has not been committed, pushed, deployed to the production Worker or uploaded as a new TestFlight build. Complete independent content qualification before delivery through the established backend workflow and local native release.

Local evidence directory: /Users/haichang/tmp/review/pocket-daily-plan-20260915. The portable [native evidence](../evidence/daily-discovery-native.json) records verification results.

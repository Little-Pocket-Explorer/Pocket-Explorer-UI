# Roadshow native integration review

This iteration adds personalized exploration, family permissions, recall unlocks, evolving cards, nearby events and friend interactions to the existing iPhone product. It preserves ten languages, collected cards, old shares and private demo access.

## Upstream integration

Litian's 906e743 provides the new profile direction and meadow artwork. It also introduced duplicate native types and local-only profile/privacy screens. The integrated profile uses actual FamilyStore data, collection metrics and protected family settings. Superseded views remain in Git history.

Legacy details are only a setup draft. Migration preserves its original data and never imports permissive privacy flags. Existing protected family details take precedence and profile edits require parent authorization.

Review found that older discoveries inherit their locations from trips. Counting only discovery locations gave an incorrect profile place count. The metric now falls back to the trip location, while explicit discovery locations take precedence. Unit checks cover pending cards, duplicate evolving versions and distinct places.

Usage text and authorized demo controls have light panels to keep text readable over the meadow artwork.

## Verification and findings

The original full regression finished with 235 passes, seven failures and four explicitly gated skips. Nearby map paths passed with continuous simulated location. Old photo restoration and history tests needed to traverse the new conversation layer. Multilingual helpers needed to scroll to lazy Form fields and tap the actual switch position. Their corrected targeted checks pass.

Chinese, Arabic and maximum-text Arabic family/social/event journeys pass. Inspected screenshots cover RTL messages, scrollable challenge choices, event awards and map publication.

The latest result per identifier across full and targeted qualification runs is 248 passed, four explicitly gated skips and no unresolved failure. This does not claim one complete final-source invocation passed. Skips cover physical microphone capture, two explicit native live-service checks and an optional HTTP catalog check. Real model and production service acceptance have separate evidence.

Videos establish that the interest test overscrolled and the demo test tapped a clipped coordinate, opening reminders instead. Only test interactions changed. An exchange test read the service before asynchronous acceptance finished. It now waits up to eight seconds for independent service confirmation and verifies removal of the native pending-action button. Incoming acceptance, decline, offline message retry and peer revocation pass.

All 40 changed Swift files meet the gate with exact file hashes. Each uses one matching run, without combining unrelated covered line counts. Minimum coverage is 89.28%, aggregate coverage is 96.24%. All 143 application/shared runtime files match the tested snapshot.

Final screenshots confirm three inherited trip places, Chinese interests and family details, readable usage/demo panels, messages, bilateral exchanges and block feedback. Testing is complete. Local TestFlight archive, upload and independent readback remain pending.


## Limits

Physical iPhone microphone, camera, headphones, call interruption, listening quality and human visual acceptance remain separate. Simulator checks do not replace them.

Runtime output includes synchronous AVAudioSession activation on the main thread and one invalid dimension warning during dismissal of Apple's camera picker. This review does not claim zero warnings or prove physical-device crash freedom.

An optional external CLI review exceeded its deadline without a report. It is not counted as independent approval. Commercial subscription transactions are not enabled.

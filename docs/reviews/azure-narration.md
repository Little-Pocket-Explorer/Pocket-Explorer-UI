# Native Azure narration review

The user approved Xiaoxiao gentle for Simplified Chinese and selected Emma Dragon HD for English. The native app calls its existing Cloudflare origin with its installation credential. Azure and adapter credentials stay on servers.

## Review corrections

- Pending cloud speech now shares the existing generation token and stop lifecycle. A response arriving after cancellation cannot start audio or trigger fallback in another session.
- An asynchronous playback failure uses the current narration callback, rather than a callback left over from microphone recognition.
- Header-shaped but undecodable cached audio could cause repeated fallback. Cache validation now opens the audio decoder before accepting it, and corrupted cache entries are replaced.
- Cache identity includes the origin, installation, answer, language and voice revision. Cache writes are optional, so a full disk does not block playback.
- The Listen label originally exposed a roughly 20-point accessibility hit target despite its outer 44-point frame. The minimum height and content shape now belong to the button label. A UI assertion verifies the resulting 44-point control.
- A cancellation test initially tried to tap an offscreen Ask another question button because iOS reported it as hittable. A captured screenshot and hierarchy showed the button below the pinned footer. The test now scrolls it above that footer before tapping, and verifies cancellation after the delayed response arrives.

## Validation

The backend's real Azure identity, voice configuration, synthesis and cache replay were verified independently. Ten languages produced non-silent PCM audio. This establishes service availability, not universal human approval of every voice.

Native tests exercise disk reuse across client recreation, owner/language/origin isolation, expiry, size pruning, decoding failures, timeouts, local fallback, actual PCM playback and suppression of stale completion. Interface checks cover replay without another network request, stop, delayed responses and keeping a card.

The release evidence records final-source tests and changed executable-line coverage. Physical iPhone playback and interruptions remain separate acceptance checks. Publication uses the local TestFlight lane with GitHub iOS runs skipped.

The first playback screenshot caught an in-flight label crossfade. A repeat capture after the transition showed a clear Stop reply control. That single UI test passed. Its optional post-test simctl diagnostic collector was stopped after all test cases completed, and xcodebuild then finalized with TEST SUCCEEDED and exit 0. No test process or test assertion was skipped.

Release 0.1.0 (14) was published locally from source 65b3084af1e70b30b1a53fdc6685a015d64e960e. Independent Apple, IPA, signing, catalogs and source checks passed. The first release invocation selected system Ruby and stopped before archiving or uploading. Explicit Homebrew Python/Ruby selected the already installed bundle and completed the single binary upload. Physical acceptance remains open.

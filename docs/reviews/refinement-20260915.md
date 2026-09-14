# First refinement review

The candidate improves artwork recovery, speech pacing and first-use interactions. This record separates verified fixes from review hypotheses and remaining device checks.

## Independent review

The user-authorized `cl -p` reviewer reported model usage as `databricks-claude-opus-5`. It reviewed focused backend and native source bundles without tools or credentials. Findings were checked against code and meaningful regression tests.

- Fixed stale question completions and queue acknowledgment errors overwriting newer work. Concurrent artwork creation and explicit retries now return one job and enqueue once.
- Added an R2 upload-race regression beyond the review. Delaying an old upload until a newer retry completed reproduced image replacement. Conditional R2 writes preserve the completed image. The test uses actual Miniflare R2.
- Fixed failed allowance checks being treated as network outages. Exhausted demo/image limits stop background checks, daily limits resume at the next UTC day, and readable cards remain available.
- Fixed answer resumption to read a saved request before considering a new POST, retained question state, and refreshed card state after saving.
- Fixed audio interruption handling to act only on interruption start. End and malformed notifications cannot terminate a new session.
- Rejected the review's duplicate paid-image claim: artwork creation is already keyed by the unique owner/exploration pair. Concurrent and repeated request tests verify this contract.
- Rejected the claim that an expired job cannot be retried: expiry is the active-attempt deadline. The server separately exposes whether an explicit failed-job retry is permitted.

## Verification

The backend passed 61 unit/integration tests, seven existing browser tests, two generated-artwork browser tests, build and Worker dry run. Line coverage was 99% and branch coverage 94.63%, retaining per-file gates. Workflow and independent production readback verified the release, original links, private image isolation, matching public image bytes and revocation.

Native targeted checks cover saved questions, late cancellation, microphone denial, input intent, unavailable/slow/exhausted artwork, card readability, and decoded image replacement/deletion. Actual English and Chinese synthesis produces non-silent audio. Actual playback verifies final-sentence completion and cancellation. Full candidate regression and coverage evidence are recorded in TODO.

## Recording environment limitation

The new microphone integration test aborts inside AudioToolbox's synchronous input initialization on this Mac. The same AudioUnit RPC timeout occurs on iOS 26.4 and iOS 27, after restarting simulator audio, and with the built-in microphone instead of the USB input. The original input was restored and independently read back.

The released source at `3e9d144` reproduces the identical crash in an isolated worktree. The issue is not attributed to this refinement, and changing the recording category did not resolve it, so that experiment was reverted. The optional integration test remains under `POCKET_RUN_LIVE_MICROPHONE`. A skip is not a microphone pass.

Physical iPhone capture, camera, speaker naturalness and child-facing language quality remain separate acceptance checks. Simulator basic voices cannot establish the quality of enhanced voices installed on a real iPhone.

Review logs, screenshots, result bundles and temporary experiments are under `~/tmp/review/pocket-polish-20260915/`. No service keys or transcripts from a real child were given to the reviewer.

## Final candidate readback

The full native regression passed 68 unit and 24 UI tests with zero failures, plus one explicit recording-environment skip. App coverage is 92.18%, and changed/new native files total 93.90%. VoiceSession is 73.40% for the whole file and 80.95% for changed executable lines. The live answer visible in the app exactly matches the independently read production D1 answer.

Visual inspection retains a concrete follow-up: maximum accessibility text makes the two fixed answer actions consume too much reading space. The current controls remain reachable, but the next candidate should move the secondary action into the scrolling content and verify that the answer has useful room. Photo-selection cancellation and decoding performance also need investigation.

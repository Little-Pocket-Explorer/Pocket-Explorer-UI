# Memory, map and artwork refinement review

Released as TestFlight 0.1.0 (12) from this Mac. Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership. Source: 5ebdde049c1c99d0c41a147f049469508370f52b. Evidence: docs/evidence/memory-map.json.

## Reproductions and resulting behavior

- Long memories previously advanced every five seconds. Duration now estimates 5–45 seconds from content, with additional weight for compact Chinese, Japanese and Korean text. Pause remains available.
- After reading the bottom of a large-text chapter, the next opening could remain behind the navigation bar. Next and replay now reveal the reading opening. Pause/resume retain the reading position, and replay also resets the first chapter.
- One hundred unchanged map updates previously decoded/rendered 100 images in 0.248434 seconds. Cached updates took 0.015147 seconds and reused all 100 images. This is a simulator microbenchmark, not physical frame-rate evidence.
- Map images are downsampled and cached using actual pixel-byte cost. File time, size, identity and display scale distinguish entries, including atomic replacements. Missing/corrupt files retain fallback artwork.
- Selecting Location originally placed content at y=930/983 below the tab bar starting at y=873. Card-section changes now reveal their opening. My question, Card details and From your discoveries are included in ten 321-entry catalogs.
- Saved-question history offered an observation editor whose new input was discarded, then repeated the new-card reveal. Two baseline assertions failed. Existing cards now open directly and retain their observations. The card-detail editor remains available.
- An undecodable completed image was downloaded again after five minutes and described as a temporary connection error. Three baseline assertions failed. Invalid image content now stops automatic downloads and preserves the card, while an HTTP 503 remains recoverable.

## Verification

The full regression passed 143 tests with no failures and two explicit skips. That run preceded the three-line invalid-image correction. Final application source passed 92 unit and 13 UI checks. An additional editor-persistence check plus ten-language audio rendering passed all three tests. Final-source coverage combines those two result bundles: 177/181 changed executable lines (97.79%), with every file above 80%. Source hashes and denominators are retained.

Two final iOS 27 flow checks passed. Earlier combined large-screen checks covered nine card/memory cases, and 23 prior large-screen checks covered languages, maximum text and memories. These overlapping runs are recorded separately, not added into one distinct-test total.

Actual screenshots are inspected in native-final-12-visual-review.jpg and native-final-source-12-artifacts. Production sharing was independently created, read and revoked. Existing links remain available. No additional live AI question or image generation was needed for these changes.

## Critique and corrections

A pause test initially used text that fit entirely onscreen. It now uses maximum text and position-based scrolling while preserving its strict assertions. The card test now uses a stable duck ID and scrolls to lazy cells before querying. The old interrupted-download test omitted imagePath and never downloaded pixels. It now verifies an actual image GET, HTTP 503 recovery and saved PNG data.

On 375pt/iOS 26.4, Apple's textClipped audit flags Wie schwimmen Enten?. Exact audit-time screen and element pixels show complete two-line hyphenation. A fixedSize control did not change the finding and was removed. The exception accepts only this exact phrase, language, maximum text, device width, OS major version and a complete element frame between navigation/tab bars. Other clipping, hit-region and description findings still fail. Preserve the raw report in card-small-clipping-artifacts. This is not a zero-audit claim.

Manual code review covered timer cancellation, scene changes, Unicode duration, map file replacement, cache costs, saved observations and terminal/transient image errors. Bounded Opus 5 attempts supplied no usable conclusion and are not counted as passed independent reviews.

All ten languages rendered non-silent PCM with matching language families. All 15 voice checks passed. This simulator provides default-quality voices. Arabic uses an available male voice, and French uses an available Canadian French female voice. Render success does not establish naturalness or gentle female narration in every language. Samples and inventory are in global-narration-evidence.json.

## Publication and remaining limits

The IPA signature, disabled debug entitlement, ten 321-entry catalogs, Xcode 27A266a, SDK 24A430 and unchanged source were independently verified. IPA SHA256: c1a56f52506bf1b864080183758819db913993c5793925944d9985e129e349e3. The temporary signing keychain is removed. Artifacts: ~/tmp/review/pocket-release-polish-12/.

Cloudflare separately validates complete PNG structure and CRC before storage. Its source 5dac559 is independently deployed. Structural validation is not full pixel decoding.

Reading duration is an estimate. Initial map image/attribute reads still run on the main thread. The invalid-image card and status panel repeat a heading, which remains a visual refinement. These changes do not establish zero disk work or physical frame rate.

Physical iPhone microphone, camera, premium narration, VoiceOver, real Safari and human visual acceptance remain open. Preserve journals, public links and existing 120/18 allowances. Accounts and friend chat remain deferred.

A later sharing review has reproduced duplicate links when a pending creation page is closed and reopened. That isolated follow-up is outside build 12 and continues in TODO.md.

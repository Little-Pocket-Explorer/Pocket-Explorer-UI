# Memory and map refinement review

This candidate improves memory reading and map updates. It is not yet published. Combined regression and coverage are verified below. Independent Apple readback remains pending.

## Reproductions and fixes

- Native long memories previously advanced every five seconds. Duration now estimates 5–45 seconds from content, with additional weight for compact Chinese, Japanese and Korean text. Pause remains available.
- After reading the bottom of a large-text chapter, the next opening could be hidden behind the navigation bar. Next and replay now reveal the reading opening. Pause and resume preserve the current position.
- A new pause test first failed during setup. Its normal-size text was fully visible and could not reach the assumed scroll position. Inspection of the recording led to maximum text and position-based scrolling. The strict position-preservation assertions were retained.
- Every map update decoded and rendered unchanged artwork. One hundred identical refreshes of a 1024-pixel image took 0.248434 seconds with no rendered-image reuse. Cached refreshes took 0.015147 seconds and reused all 100 images. This is a focused simulator measurement, not physical iPhone frame-rate evidence.
- Map artwork is downsampled to marker pixels and cached with actual image-byte accounting. File time, size, identity and display scale distinguish entries, including atomic replacements. Missing and corrupt files retain visible fallback artwork.

## Completed checks

Four memory reading UI checks passed. All 23 large-screen iOS 27 UI checks passed, covering ten languages, maximum text and memories. Six map unit and two UI checks passed. Six unit checks passed again after accurate cache-cost accounting. Changed map coverage is 35/35.

Actual screenshots are inspected for small-screen markers, large-screen languages/memories and small-screen maximum-text next/replay behavior. Existing raw contrast reports are retained for pixel review. General test success is not an empty-audit claim.

## Code critique and limitations

Manual review covers timer cancellation, background/disappearance pausing, same-chapter replay reset, Unicode duration, map file replacement, empty images, cache costs and matching trip markers. A bounded Opus 5 request supplied no usable conclusion before its invocation budget limit. It is not counted as a passed independent review.

Reading duration is an estimate and cannot guarantee every age finishes before automatic advancement. Initial local image reads and file-attribute checks still run on the main thread. This change does not establish zero disk work or a measured physical-device frame rate.

Physical iPhone recording, camera, premium narration, VoiceOver and real Safari acceptance remain open. Preserve existing journals and shares without new AI or image allowances. Next complete integrated regression, commit with [skip ci], and publish TestFlight only from this Mac.

## Card-detail follow-up review

Actual German and Arabic captures exposed an untranslated My question heading. A literal-source audit also found Card details and From your discoveries. All three phrases now appear in ten 321-entry catalogs. This matching scan excludes interpolated and computed strings and does not establish complete runtime-copy coverage.

Selecting Location originally placed its content at y=930/983 while the tab bar began at y=873. Both reproduction tests failed two assertions. Selection now reveals the new section opening. Six language unit and two maximum-text card UI checks passed. The first Arabic test used an incorrect expected existing button translation. Correcting that test expectation is not an application fix.

The memory-only full run passed 135 tests, failed none and skipped three, with 59/59 changed lines covered. The final combined candidate adds standard-text card verification and enables real sharing checks. Its run is not yet complete.

## Characterized small-screen German audit limitation

On 375pt/iOS 26.4, textClipped flags the card-front question Wie schwimmen Enten? as potentially clipped. An independent repetition and a fixedSize intrinsic-height control both reproduced the report. The exact audit-time full-screen and element screenshots show every character in a complete two-line hyphenated rendering. Pixel clipping is not established. The ineffective application experiment is removed.

Retain the raw failed result and screenshots. The test accepts only this exact pixel-reviewed phrase in German at maximum text on 375pt/iOS 26, with the full element frame between the navigation and tab bars. Other clipping, hit-region and description findings still fail. This narrow exception is not a claim of zero raw Apple audit findings and does not cover unknown text. Revisit it when SDK audit behavior changes.

The test also replaces its lazily rebound first-card query with the stable duck card ID. Arabic and German require scrolling before this lazy node appears. After correcting test preparation, all three targeted card UI checks passed without application changes. The nine combined large-screen iOS 27 UI checks had already passed.

Raw materials are in pocket-polish-20260915/card-small-clipping-artifacts, including full-screen 5D876956-EB18-450D-A9BC-FF314E1980C7.png and element screenshot 84EF2C55-BE11-4CCE-8258-AEF8B4A4BF80.png. The targeted result is card-small-stable.xcresult.

## Viewing an existing card

A new reproduction found that saved-question history still offered an observation field, although saving returned the existing card and ignored new input. View my card also repeated the new-card reveal. The original UI test failed two assertions. Existing cards now open directly without the ineffective draft editor, while new discoveries keep their first reveal. Original observations remain available and can be changed through the existing card-detail editor.

Five question/history UI checks passed, with initial changed-line coverage of 19/22 (86.36%). Before/after pixels are reviewed in saved-question-visual-review.jpg. This correction is integrated into the full candidate, whose final regression is still running.

## Corrupted artwork follow-up

An isolated worktree reproduced repeated downloads of an undecodable completed image: two initial requests increased to four five minutes later, with a misleading transient-network message. The correction distinguishes invalid image content from a temporary HTTP 503. Invalid content stops automatic downloads and retains the words, while transient download failures can recover. Seventeen unit and five UI checks passed, with actual failure-state and readable-card screenshots inspected.

Self-review also found that the old interrupted-image-download test omitted imagePath and never requested an image. The corrected fixture verifies an actual image GET, HTTP 503 recovery and eventual saved pixels. All 17 unit checks passed again. This native correction is not yet integrated, pending completion of the primary full regression. Backend integrity source 5dac559 is pushed and Cloudflare workflow 34894033434 is running.

## Final verification and publication candidate

The complete regression passed 143 tests with no failures. Its two skips are an additional live AI request and recording on the simulator with the previously reproduced runtime issue. After integrating invalid-image recovery, final source passed 92 unit and 13 UI checks. Both additional iOS 27 flow checks passed. The affected subset did not exercise the card editor, so an additional persistence check and all-language audio checks ran and all three passed. Final-source coverage combines executable-line hits from those two runs: 177/181 (97.79%), retaining each denominator and source hash. Every file exceeds 80%.

Inspected native-final-12-visual-review.jpg, the final invalid-image state and readable observation captures. Card entry, map markers, memory openings and German/Arabic maximum-text location content remain visible. The invalid-image card and status panel repeat a heading. This is a remaining visual refinement, not a blocker to opening the card.

All ten languages rendered non-silent PCM with matching language families. All 15 voice checks passed. This simulator provides default-quality voices. Arabic uses the available male voice, and French uses the available Canadian French female voice. This does not establish gentle female narration in every language or the installed voice inventory of a physical iPhone. Samples and selection metadata are in global-narration-evidence.json.

Cloudflare image integrity is deployed and independently verified. The native candidate is ready for local archive and upload, with independent Apple publication readback still pending. Preserve physical-device and raw-audit limitations.

# Teammate TestFlight delivery, 2026-09-17

The owner requested the latest teammate update as a new local TestFlight release. The release worktree fast-forwarded to `c0149a6`. The primary checkout and App Store submission using build 21 are preserved.

## Integration corrections

- Fixed optional event URL access and an invalid SwiftUI frame overload that prevented compilation.
- Restored explicit refresh in friend conversations so incoming messages, exchanges and network recovery remain accessible.
- Made the event-share options scrollable and expandable for larger text.
- Updated UI tests for the new Back actions, request-card control, persistent tab navigation, system-owned location permission alert and content obscured by fixed actions.
- Added actual V1/V2 gallery assertions to the existing card evolution test.

## Verification

- Xcode 27.0, build 27A266a, with signed iOS 27 simulator execution.
- All 193 unit cases have passing results, including the prepared-content HTTP fixture and actual notification payload scheduling after permission opt-in.
- Every changed product Swift file exceeds 80% line coverage from a complete test run with matching source hashes. Twelve files qualify, with the lowest at 84.67%.
- Ten localization catalogs have 650 matching unique keys each.
- Actual local Worker/D1/R2 flows verify event award, wrong-answer correction, coarse map sharing and revocation, friendship, incoming exchanges, failed-message retry, card evolution and persistence.
- Screenshots confirm the actual version gallery, nearby map, event invitation in a conversation and accepted exchange. Chinese and Arabic journeys pass, including Arabic at maximum accessibility text. The final complete journey rerun passes. Latest results across affected flows contain 19 UI passes, zero failures and one explicit skip.
- One warm system-URL test requires its separate host driver and is explicitly skipped. Physical iPhone acceptance remains a separate human check.

## Review observations

The teammate's Online label represents friendship availability, not a live connection signal. Mute currently saves a local preference. The shared-map preview opens shared cards, and card details repeat some share/history shortcuts. These are follow-up product refinements outside the release integration corrections.

## Delivery

TestFlight **1.0 (22)** is available in **Hackathon Internal**. Source `2cb49c6ce92799f4be9bc63d679783f574566f3e` was signed and uploaded with the existing local Fastlane lane and Xcode 27A266a. No GitHub runner or Backend deployment was used.

Independent Apple API reads at `2026-09-17T11:01:21Z` confirm build `10d8a391-a095-49ad-9e2f-6a6614bea32d` is VALID and included in the internal group. The release lane reports IN_BETA_TESTING. App Store review remains WAITING_FOR_REVIEW with build 21 attached. The existing submission was not replaced or withdrawn.

The exported IPA independently passes strict signature, bundle/version/build and release-entitlement checks. All ten compiled localization dictionaries exactly match source. Its SHA256 is `f686c27ecf1b246376fb25e25eea09ecd4d937e40cf674f36f57508a65895cba`. Owned fixtures, test simulators, processes and temporary signing resources were cleaned up.

Machine-readable record: [teammate-testflight-22.json](teammate-testflight-22.json). Coverage record: [teammate-testflight-20260917-coverage.json](teammate-testflight-20260917-coverage.json).

Local evidence: `~/tmp/review/pocket-testflight-20260917`.

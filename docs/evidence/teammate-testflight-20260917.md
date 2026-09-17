# Teammate TestFlight qualification, 2026-09-17

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

Qualification is complete. Upload is pending. Native publication uses the existing local Fastlane lane, without a GitHub runner. The final Apple readback must confirm the new build is valid and assigned to Hackathon Internal, and that App Store review still uses build 21.

Local evidence: `~/tmp/review/pocket-testflight-20260917`.

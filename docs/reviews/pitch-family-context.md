# Family, collection and context increment

This is an implementation checkpoint for the full roadshow alignment. It is not release acceptance.

- Backend passes 205 tests across 27 files and every-file 80% line and branch coverage gates.
- Native family coverage passes six domain/client tests, five language tests and two simulator UI flows backed by actual local D1.
- New native family files range from 97.81% to 100% line coverage, with the settings view at 99.23%.
- The ten language catalogs contain 402 matching entries. Existing placeholder checks pass.
- Chinese profile and screen-break views and English permission/relaunch views were visually inspected.
- Three profile portraits use the original supplied character artwork. Crop geometry and hashes are in ../design/profile-avatar-provenance.json.

## Findings resolved

1. Optional parent enforcement evaluated installation authorization even with the feature disabled. This changed an existing configuration-error response. Guarding the evaluation preserves the legacy route behavior, and the original regression now passes.
2. New prepared records could otherwise briefly exist without a recall requirement. The requirement is now recorded in the initial insert.
3. A late provider result could overwrite a newer evolution eligibility decision. The eligibility update now requires the exact ready result still stored for that exploration.
4. Personalized replies and histories derived from private demo content could otherwise be treated as ordinary public knowledge. Personalized requests bypass sharing caches and their demo provenance is retained for downstream social/event checks.
5. Simulator UI setup initially failed because the build was unsigned, preventing Keychain writes. Ad-hoc signing restored the real credential path. Async UI tests now run on the main actor.
6. UI tests initially tapped a switch row label without changing the switch. They now target the visible switch and immediately assert its value before saving or checking persistence.

## Remaining acceptance

- Native correct-answer collection, version/evolution presentation and conversation grouping.
- Event/social isolation, public Web and Studio operations, and the remaining roadshow features.
- Real-provider personalization, independent production migration/deployment and local TestFlight publication.
- Large text, Arabic layout, active camera/sheet time-limit boundaries and physical-device behavior.
- An attempted read-only cl review returned no output before its 145-second timeout. It provides no review approval.

Evidence is under /Users/haichang/tmp/review/pocket-pitch-* on the development Mac. Existing TestFlight remains 0.1.0 (17).

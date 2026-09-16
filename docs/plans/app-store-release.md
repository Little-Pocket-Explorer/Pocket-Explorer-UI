# First App Store Release

The user authorized a first public App Store release on 2026-09-16. The existing TestFlight build is 0.1.0 (19), Apple build ID 89fb0dba-2128-48b8-a5ee-dfe62d1339cb. Independent API reads confirm VALID and APP_STORE_ELIGIBLE. The existing 1.0 App Store version remains PREPARE_FOR_SUBMISSION without an attached build. English listing text and free pricing are saved and verified. All three English screenshots are COMPLETE, and the Education category is saved. Privacy URL and age declarations remain pending.

## Scope and decisions

Preserve the shipped product and ten languages. Fix concrete submission gaps without reopening the feature roadmap. Build and upload locally. GitHub iOS builds remain prohibited because the quota is exhausted. Backend updates use its existing deployment workflow. Do not submit declarations that contradict runtime behavior or invent the owner's legal status.

## Work items

| ID | Goal and files | Verification and completion |
| --- | --- | --- |
| AS1 | Audit Apple records, current native source, Backend routes and official review requirements. Evidence is under ~/tmp/review/pocket-app-store-release. | Record actual gaps, distinguish existing beta data from App Store metadata, and preserve the current version. |
| AS2 | Public privacy and support pages, actual data-flow inventory, explicit AI sharing consent and in-app deletion where required. Relevant native Family/Profile/Explore and Backend family/storage paths. | Reproduce missing flows, exercise acceptance/decline/deletion, require 80% changed-file coverage, and independently read deployed behavior. Retain pending legal facts. |
| AS3 | Formal English listing, supported store localizations, actual-device screenshots and review instructions in docs/app-store. | Validate Apple field limits and accepted image sizes, inspect actual screenshots, and independently read uploaded metadata/assets. |
| AS4 | Select price, distribution, age category and legal declarations using owner-provided facts. | Verify Apple's saved state. Escalate only account-holder or legal facts that cannot be inferred. |
| AS5 | Prepare version 1.0, qualify any changed runtime, archive/upload locally and submit review. | Read the selected build, signature, version and final submission state. Report submitted-for-review separately from available-on-store. |

## Known gaps and limits

- Build 19 contains no public privacy/support links and no explicit disclosure/consent for third-party AI data sharing.
- Family profile creation persists remote data, but the family API exposes no account deletion operation.
- Existing social flows contain reporting and blocking. Confirm moderation operations and public support contact rather than inventing missing controls.
- Existing Apple beta description is obsolete and says live AI is not connected. It must not be reused as current store copy.
- Owner confirmed: free download with no in-app purchases, primary design age 6-8 with a parent, and a non-commercial hobby project. Use non-trader status based on this self-assessment. Kids Category enrollment is not yet selected and requires a separate actual-data review.
- A physical-device microphone/camera/listening check is still distinct from automated qualification.

## Primary references

- https://developer.apple.com/app-store/review/guidelines/ (1.2, 1.3, 5.1.1, 5.1.2)
- https://developer.apple.com/app-store/app-privacy-details/
- https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/

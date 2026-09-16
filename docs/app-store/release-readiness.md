# First App Store Release Readiness

## Current first-release scope (2026-09-16)

The owner deferred Epic KWS. Its local experiment is archived and removed from the release runtime. Epic login and KWS production approval are not release dependencies. Retain the existing family PIN, explicit AI permission and withdrawal, deletion and accurate disclosures. See [the corrected decision](parent-verification.md).

App Store 1.0 (21) was submitted on 2026-09-16 at 22:09:12 AEST (12:09:12 UTC) and is WAITING_FOR_REVIEW. The owner selected free download without IAP or subscriptions, primary design ages 6-8 with a parent, and a non-commercial hobby project. All required owner decisions are settled.

## Apple submission

English description, keywords, promotional text, subtitle, Education category, free price, copyright and three 1320x2868 English screenshots are saved. Privacy and support URLs have independent readbacks. Existing TestFlight reviewer contact details are saved to 1.0 and independently verified.

The owner approved the full feature set and Apple's current ratings: 13+ in 171 territories, 16+ in Australia, Vietnam and Brazil, and 15+ in Korea. The older FOUR_PLUS field applies only before OS version 26. This release is not submitted to the Kids Category. DSA non-trader status shows Active. The owner approved excluding China mainland from the first release. Paginated independent API reads confirm 174 of 175 territories selected, only CHN unavailable and every other territory unchanged, including Hong Kong, Macau and Taiwan. Configured availability does not guarantee distribution eligibility.

All 13 privacy categories, purposes, identity linkage and no-advertising-tracking declarations are published and independently observed on Apple's page. Reconcile them with the actual released data handling and provider retention conditions. See [the label mapping](privacy-label-draft.md).

App Store 1.0 is WAITING_FOR_REVIEW with build 21 attached. Apple's page showed "1 Item Submitted", and independent version and submission API reads confirm the state. Submission ID: 3ae5a282-1ec0-471b-a75f-2676572a254b. Apple recorded submission at 2026-09-16T12:09:12.422Z. TestFlight 1.0 (21) is independently VALID / APP_STORE_ELIGIBLE / IN_BETA_TESTING in Hackathon Internal. It was published locally from c1cf01a, preserving teammate changes and ten matching catalogs of 609 unique keys. The archive signature and source snapshot are verified. The temporary signing keychain is removed.

## Implementation and qualification

Account deletion freezes retired credentials, revokes stories and defers associated media cleanup. Recipients retain independent card copies with deleted-sender attribution removed on the server. Actual local Worker/D1/R2 tests verify removal and credential retirement. The latest native targeted deletion test verifies cancellation, confirmation, retired credentials and creating a new family afterward.

Native AI permission defaults off, preserves drafts and supports offline withdrawal. Web reads real permission, guards sends, withdraws immediately, persists offline work and retries on reconnection. Photo preparation checks permission again before sending. The same regression fails on the previous code and passes after the fix. Web grant activation and account deletion are implemented using the existing family API. Chromium and WebKit both verify the actual Worker/D1 create, unlock, separate grant, withdrawal and deletion flow.

Native speech recognition requires on-device processing. Web starts recording only with explicitly supported and enabled local recognition, and its fallback narration uses only local voices. Unsupported recognition returns to typing. Azure narration remains available.

Backend and Web pass 319 tests in 45 files and every-file 80% line and branch gates, with aggregate 99.18% lines and 94.13% branches. The production build passes. Full Chromium and WebKit suites each pass 37 checks and skip one scenario requiring an isolated event fixture. New permission and offline-withdrawal cases pass in both browsers. English and Chinese mobile screenshots were inspected.

The integrated native unit run passes 190 tests and skips one. All 23 selected main journeys pass. Additional callback, background refresh, private-demo and permission-denial journeys pass. Same-source merged coverage qualifies all 15 changed files, with a minimum of 81.75%. Earlier-source coverage does not qualify current source. Physical microphone, camera, listening and interruption acceptance remain separate from simulator testing.

## Service attribution and remaining work

The owner confirms Azure AI for question answering, images and narration. Images and speech also have independent call evidence. Semantic caching still uses Cloudflare Workers AI embeddings and remains disclosed. store:false and disabled redirects do not establish zero provider retention. See Backend docs/ai-service-evidence.md.

Backend 8244027 is deployed through successful workflow [35092615551](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend/actions/runs/35092615551). Sixteen independent production checks verify public privacy/support pages, a real AI answer, separate permission, withdrawal, rejection of stale grants, deletion and retired credentials. The fictional test account was deleted. Users of older TestFlight versions should update to 1.0 (21) for live AI.

Release preparation and submission are complete. Apple review is pending, and the app is not yet approved or publicly available. AFTER_APPROVAL is independently verified, so Apple will release the version automatically after approval. No owner input remains outstanding. Do not rebuild or resubmit without a new reason. See [the release record](release-status.json) and [Apple review](https://appstoreconnect.apple.com/apps/6810920731/distribution/reviewsubmissions/details/3ae5a282-1ec0-471b-a75f-2676572a254b). All owned test, fixture, upload and workflow-watch processes have ended.

References: [Apple review guidelines](https://developer.apple.com/app-store/review/guidelines/), [Apple privacy labels](https://developer.apple.com/app-store/app-privacy-details/), [FTC COPPA](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions), [KWS](https://kidswebservices.com/).

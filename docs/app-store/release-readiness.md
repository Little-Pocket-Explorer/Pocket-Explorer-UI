# First App Store Release Readiness

## Current first-release scope (2026-09-16)

The owner deferred Epic KWS. Its local experiment is archived and removed from the release runtime. Epic login and KWS production approval are not release dependencies. Retain the existing family PIN, explicit AI permission and withdrawal, deletion and accurate disclosures. See [the corrected decision](parent-verification.md).

Public review has not been submitted. The owner selected free download without IAP or subscriptions, primary design ages 6-8 with a parent, and a non-commercial hobby project. Publication remains authorized.

## Apple draft

English description, keywords, promotional text, subtitle, Education category, free price, copyright and three 1320x2868 English screenshots are saved. Privacy and support URLs have independent readbacks. Existing TestFlight reviewer contact details are saved to 1.0 and independently verified.

The owner approved the full feature set and Apple's current ratings: 13+ in 171 territories, 16+ in Australia, Vietnam and Brazil, and 15+ in Korea. The older FOUR_PLUS field applies only before OS version 26. This release is not submitted to the Kids Category. DSA non-trader status shows Active. All 175 territories are configured for release and independently checked through the paginated API. Mainland China's ICP and other regional requirements still require verification. Configured availability does not guarantee distribution eligibility.

All 13 privacy categories, purposes, identity linkage and no-advertising-tracking declarations are saved as drafts, not published. Reconcile them with the actual released data handling and provider retention conditions. See [the label mapping](privacy-label-draft.md).

App Store 1.0 remains PREPARE_FOR_SUBMISSION without an attached build. The latest TestFlight remains 0.1.0 (20), independently VALID / IN_BETA_TESTING in Hackathon Internal, without the pending privacy changes. Main 41a6356 is integrated, preserving teammate changes and ten matching catalogs of 609 unique keys. Apple website and API authentication both work.

## Implementation and qualification

Account deletion freezes retired credentials, revokes stories and defers associated media cleanup. Recipients retain independent card copies with deleted-sender attribution removed on the server. Actual local Worker/D1/R2 tests verify removal and credential retirement. The latest native targeted deletion test verifies cancellation, confirmation, retired credentials and creating a new family afterward.

Native AI permission defaults off, preserves drafts and supports offline withdrawal. Web reads real permission, guards sends, withdraws immediately, persists offline work and retries on reconnection. Photo preparation checks permission again before sending. The same regression fails on the previous code and passes after the fix. Web grant activation and account deletion are implemented using the existing family API. Chromium and WebKit both verify the actual Worker/D1 create, unlock, separate grant, withdrawal and deletion flow.

Native speech recognition requires on-device processing. Web starts recording only with explicitly supported and enabled local recognition, and its fallback narration uses only local voices. Unsupported recognition returns to typing. Azure narration remains available.

Backend and Web pass 319 tests in 45 files and every-file 80% line and branch gates, with aggregate 99.18% lines and 94.13% branches. The production build passes. Full Chromium and WebKit suites each pass 37 checks and skip one scenario requiring an isolated event fixture. New permission and offline-withdrawal cases pass in both browsers. English and Chinese mobile screenshots were inspected.

The integrated native unit run passes 190 tests and skips one. All 23 selected main journeys pass. Additional callback, background refresh, private-demo and permission-denial journeys pass. Same-source merged coverage qualifies all 15 changed files, with a minimum of 81.75%. Earlier-source coverage does not qualify current source. Physical microphone, camera, listening and interruption acceptance remain separate from simulator testing.

## Service attribution and remaining work

The owner confirms Azure AI for question answering, images and narration. Images and speech also have independent call evidence. Semantic caching still uses Cloudflare Workers AI embeddings and remains disclosed. store:false and disabled redirects do not establish zero provider retention. See Backend docs/ai-service-evidence.md.

1. KWS is deferred by the owner. Complete the existing release flow without introducing this provider.
2. Implementation, automated coverage, browser visuals and review instructions are qualified. Native 1.0 packaging and independent production checks remain.
3. The owner confirmed publication rights for supplied content. Publish the final privacy labels and resolve China mainland availability. Do not repeat settled content-rights, pricing, age, project-nature or login questions.
4. Coordinate TestFlight 20, Web and the new native client so a server-only restriction does not leave older clients receiving unexplained 403 responses. Then deploy Backend through its workflow, archive/upload 1.0 locally and submit review.

No commit, push, production deployment, new binary upload or review submission occurred in this increment. Evidence is under ~/tmp/review/pocket-app-store-release, with integrated-source testing in integration-20260916.

References: [Apple review guidelines](https://developer.apple.com/app-store/review/guidelines/), [Apple privacy labels](https://developer.apple.com/app-store/app-privacy-details/), [FTC COPPA](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions), [KWS](https://kidswebservices.com/).

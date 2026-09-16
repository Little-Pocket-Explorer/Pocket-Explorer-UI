# App Privacy Labels

Updated 2026-09-16. These thirteen declarations were published and independently observed on Apple's App Privacy page. They match native 1.0 (21) and deployed Backend 8244027.

## Current mapping

The installation credential associates records across features. A hashed installation identifier is not anonymous when the service can join it to a profile, conversation or visit. The label therefore marks the following data as linked to the user. No category is used for advertising tracking.

| Apple category | Application data | Purpose |
| --- | --- | --- |
| Name | Family nickname and permitted shared attribution | App Functionality |
| Precise Location | Event visits associated with a known venue and time | App Functionality |
| Coarse Location | Rounded public discoveries and optional shared city | App Functionality |
| Contacts | Friend relationships, requests and blocks | App Functionality |
| Emails or Text Messages | Friend message sender, recipient and body | App Functionality |
| Photos or Videos | A selected photo sent for scene interpretation | App Functionality |
| Customer Support | Reports and support requests | App Functionality |
| Other User Content | Questions, answers, recall context and shared stories | App Functionality, Product Personalization |
| Search History | Question history used in later explanations and discoveries | App Functionality, Product Personalization |
| User ID | Profile and social associations | App Functionality |
| Device ID | Random installation credential and retained protected hash | App Functionality |
| Product Interaction | Recall attempts, card progression and usage totals | App Functionality, Product Personalization |
| Other Data Types | Age, language, interests and explanation preferences | App Functionality, Product Personalization |

## Evidence and final calibration

- Contacts describes the server social graph. The app does not read the phone's address book.
- Event coordinates are checked transiently. Stored event claims and attempts reference a particular venue and timestamp. Keep the precise-location category until the venue-radius and retention review establishes a narrower disclosure.
- Public map locations round latitude and longitude to two decimal places. Raw journal coordinates and original photos are not included in public story payloads.
- The backend does not persist original photo bytes in D1. Provider-side retention remains to be verified, so do not remove the photo category based on D1 storage alone.
- Confirm the distinction between installation-level and profile-level identifiers when completing the verification design. The app does not use IDFA.
- Local-only speech recognition sends question text, not microphone recordings, to the backend. Native requires on-device recognition. Web refuses remote-only recognition and uses only a local voice for browser fallback narration. The label does not select Audio Data.
- KWS is deferred and is absent from the first-release runtime. No verification-provider email or identity data is collected through this experiment.
- Relevant implementation lives in Backend `web/worker/family-api.ts`, `family-store.ts`, `event-store.ts`, `nearby-discoveries.ts`, `social-store.ts`, `ai.ts`, `ai-data-permission.ts`, `ai-provider.ts` and `web/src/browser-speech.ts`.

The label is a disclosure, not evidence that parental verification, consent or Kids Category qualification is complete. The updated privacy and support pages are deployed and independently checked. App Store 1.0 (21) was submitted on 2026-09-16 and is WAITING_FOR_REVIEW.

Reference: [Apple App privacy details](https://developer.apple.com/app-store/app-privacy-details/).

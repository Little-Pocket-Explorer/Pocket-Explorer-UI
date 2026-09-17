# Reference UI alignment (2026-09-17)

The three user-supplied Miro screenshots in this review are the explicit visual reference for the connected explorer journey. They cover:

1. Map, nearby events, notification/quiz sheets, event detail and event sharing.
2. Collection, Discovery Quizzes, Shared with me and card grids.
3. Card Detail, Story/Knowledge/Versions/Location, share-to-friend and share-on-map sheets.

## Web alignment

- Card Detail is card-first, with a V1 badge, category/tier chips, Story/Knowledge/Versions/Location tabs, top share/options tools, `Share this card`, `Continue the chat`, and a bottom share sheet containing friend, Map and link actions.
- Map has functional Me/Nearby/Friends filtering. Event Detail has duration/audience/cost chips, three activity steps, an event reward, Map and friend-share actions.
- Shared with me has search, recipient filtering, All/Nature/Science/Animals/Space categories and a two-column card grid. Shared Card Detail uses the same four tabs and keeps Request this card as the primary action.
- Chromium at 390 x 844 verified Card Detail in one viewport with zero horizontal overflow; Event actions clear the fixed navigation by 6 px; Shared with me renders two 170.5 px columns with zero horizontal overflow; Shared Card Detail Request clears navigation with zero overlap.
- The complete journey remains executable through `web/tests/journey.test.tsx`.
- Final affected regression: 84 tests passed. Production Vite build passed.
- Changed component coverage: App.tsx 93.55% lines / 81.50% branches; SocialHub.tsx 98.18% / 86.28%; DiscoveryMap.tsx 100% / 91.17%.

## Native alignment

- Existing Map, Event, quiz, sharing and social screens already use the supplied reference hierarchy and protected service behavior.
- Native Card Detail now exposes Story, Knowledge, Versions and Location. Versions renders immutable version title/date cards and retains the Card history route.
- CardReadingFlowTests now addresses Versions in English, German maximum text and Arabic maximum text journeys.
- Swift diagnostics passed. All ten native catalogs contain the same 598 keys with no duplicates, missing keys or extra keys.
- This Windows host cannot run Xcode. Native XCTest/XCUITest and changed-Swift coverage for this alignment remain pending on macOS.

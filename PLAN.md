# Pocket Explorer: Prototype Plan

Date: 2026-09-11
Status: The iPhone app is confirmed as the primary product, with web sharing in the first demo. The visual direction is approved. Implementation is authorized. Current progress is maintained in TODO.md.
Companion: [Acceptance contract](ACCEPTANCE.md)

## 1. Outcome and priorities

Build a beautiful iPhone app prototype with a companion sharing website. A child speaks to an exploration companion in the app, turning a real-world question into a personal discovery, a place on their exploration map, a replayable memory, and a story their family can share through a browser link.

The user's priority order is explicit:
1. Visual appeal: an original, inviting interface with desirable collectible objects.
2. Feedback: children can see, revisit, and show what their exploration produced.

The core loop is: notice something → ask → observe → explain in your own words → receive a card → see it in your world → replay and share the adventure.

## 2. Confirmed decisions and working assumptions

- Start with children aged 6–10 exploring with a parent. This age range is a working assumption, not a confirmed research finding.
- The iPhone app is the primary product and must install on a real iPhone in the first demo. It owns exploration, collections, maps, memories, and parent sharing actions. The responsive website serves recipients.
- The user already has an Apple Developer account and explicitly accepts the additional app investment with AI-assisted development. Account ownership is established. The actual team, signing configuration, and device still require inspection.
- A parent handles initial permissions. Children actively tap to speak. The prototype requires neither continuous background listening nor an App Store release.
- Use fictional explorer profiles and prepared example trips during the prototype. Do not infer a real child's travel history from the user's account.
- Plan around a small team. Stage estimates below assume two contributors and are provisional.
- The prototype must work across devices for sharing. A local share-preview screen alone is insufficient.
- The first iteration can use explicitly labeled prepared AI responses, but actual recording, speech transcription, audio playback, and camera capture must be verified on the target iPhone. Questions outside prepared scenarios cannot silently become sample questions.
- Connect one live AI service after the real-device voice flow works. It remains an optional extension to the base prototype.
- The user authorized TestFlight and Cloudflare publication on 2026-09-11. This does not authorize external messages, paid subscriptions, a public App Store release, or changes to the partner's document.

## 3. Product and visual direction

Preserve the concept direction already approved by the user: cream paper, forest green, rounded typography, pastel iridescent card borders, softly sculptural objects, and restrained reveal and flip animation. Do not reopen the choice between two visual treatments.

The four initial screens are the voice companion, world map, discovery-card reveal, and trip-memory cover with its sharing entry point. Extend the same art direction to the voice entry. New screens still require actual review.

Visual requirements:
- Establish a consistent art direction for map markers, cards, memory covers, buttons, and typography.
- Use original or appropriately licensed finished artwork. Placeholder emoji may help explore layout, but cannot serve as the finished visual treatment.
- Give each card an identifiable silhouette, an attractive front, and a readable reverse containing the child's own observation.
- Make the child's content visually prominent: their question, observation, and explanation.
- Distinguish illustrative artwork from an observation photo and distinguish uncertain identification from established information.
- Keep map geometry accurate while styling it to match the product. Never substitute invented geography for real places.
- Respect reduced-motion preferences and provide a static equivalent for reveal and transition effects.

Beauty requires a human review gate. Automated layout and interaction checks support that review but cannot declare the interface beautiful.

## 4. Navigation and screens

| Surface | Main content | Main action |
|---|---|---|
| My world | Trips and discovery markers on a map, a relevant memory invitation | Open a place or start a discovery |
| Explore in the app | Companion, speech control, camera, question transcript, short spoken answer, one observation invitation | Ask aloud and record the observation in the child's own words |
| Discovery card | Reveal, front/reverse, personal explanation, trip association | Keep the discovery or revisit it |
| My finds | Collectible gallery grouped by trip or topic | Open a card |
| Trip journal | One trip's discoveries and a compact map or sequence | Finish the trip and view its memory |
| Memories | Finished trip covers and a resurfaced previous trip | Play a memory or prepare a share |
| Parent share sheet | Preview, selected content, optional first name and broad location | Create or revoke a share link |
| Shared web story | A polished, read-only adventure that works without an account | Replay the story and inspect its cards |

Use three bottom destinations in the app: My world, My finds, and Memories. Place a prominent companion and speech entry on My world. Explore and parent sharing are focused flows rather than additional navigation tabs. The website presents shared stories without duplicating the child's exploration workspace.

The voice flow is: tap to start → show listening → tap to finish → show the transcript and thinking state → play the response with text captions → invite another observation. A parent can correct the transcript. Camera input is optional, so denying camera access cannot block voice exploration. Backgrounding the app or receiving a system audio interruption stops capture and playback. The user explicitly retries after returning.

## 5. Feedback and memory behavior

### Immediate feedback
- Distinguish listening, thinking, and speaking with visible states and a stop action. Sound or color alone cannot communicate the state.
- Acknowledge the child's observation immediately after submission.
- Reveal the discovery card with a short animation, then leave a stable, inspectable result.
- Add the discovery to its trip and collection. Show it on the map when the trip has a location.
- Preserve the card when the child does not know an answer. A correct quiz response is not an ownership requirement.
- Later observation, comparison, or explanation can enrich the existing card.

### End-of-trip feedback
- The parent or child explicitly finishes a trip.
- Generate an editable memory from the question, observation, and discovery, using a small set of prepared story layouts.
- Offer one invitation to preview and share this trip. Skipping it does not block saving the memory.
- A one-card trip must still produce a useful story. Multiple discoveries extend the story without requiring a minimum count.

### Later feedback
- On a later app visit, surface an existing trip memory when it becomes eligible, initially seven days after the trip ends.
- Dismissing it suppresses the same invitation for seven days.
- Use in-app reminders for the prototype. Demonstrate elapsed time with a development-only clock control.
- An unopened app does not trigger a notification in this prototype. Push and email delivery are outside this iteration.

### Sharing as feedback
- Let the child admire and replay the share preview before the parent creates a link.
- The recipient gets the same visual quality as the originating experience, including readable cards and a complete memory sequence.
- Optional first name and broad place name are off by default.
- The public story excludes precise coordinates, original photo metadata, raw recordings, and private exploration history.
- The owner can revoke a link. Recipients have no editing capability.

## 6. Prototype scope

### Required before calling the prototype complete
- A coherent, reviewed visual system across the key screens.
- A native app that launches on the designated real iPhone, with reproducible installation steps and valid signing covering the demonstration date.
- One complete exploration flow with actual speech input, editable transcription, spoken answers, associated camera capture, and the child's own observation. Responses may come from explicitly labeled prepared scenarios.
- Cards that persist after app termination and relaunch, can be revisited, and belong to a trip.
- At least two example trips, including a multi-discovery trip, to demonstrate map browsing and memory selection.
- A map and an equivalent collection view for discoveries without a location.
- Memory playback with pause, replay, and manual navigation.
- A working share URL opened on a second device or clean browser session.
- Persistent shared stories and working revocation.
- Empty, loading, failure, permission-denial, interruption-recovery, and reduced-motion states for the central flow.

### Optional after the required experience works
- Connect one approved multimodal AI service through a server endpoint.
- Generate or select a card illustration dynamically while preserving the chosen visual style.
- Add first-person narration or one lightweight exploration-relay invitation.
- Add subtle reveal haptics when permitted by system settings.

### Deferred
- An Android app, dedicated hardware, a public App Store release, direct messaging, a full friend graph, nearby public discoveries, card trading, payment, subscriptions, and a curriculum system.
- Background push delivery, long-term learning analytics, and automatic learning-effect claims.

## 7. Implementation approach

Use the iPhone app as the primary product, supported by a public web viewer and a small shared-story service. This is the user's explicit first-demo scope. The app provides native voice and camera entry and contains cards, maps, and memories. A website shortcut or empty web container cannot replace it.

The user has confirmed an Apple Developer account. At implementation start, inspect Xcode, the target iOS version, demonstration iPhone, associated developer team, signing, and installation path. Select direct device installation or TestFlight based on the actual configuration. Record signing expiry and any reinstallation steps. If real-device execution is blocked, report the specific missing prerequisite. Simulator execution cannot satisfy real-device acceptance.

Proposed implementation directory: `/Users/haichang/Documents/ChatGPT/Hai/pocket-explorer/`. This is a new project directory and must not modify the unrelated `gaokao-kg` project.

Use SwiftUI for the app and system audio, camera, and speech capabilities for device interaction. Verify transcription for the target language and iOS version first. If server transcription is selected, document its data path and credential boundary. Use React and TypeScript for the public card and memory viewer only. Both clients share artwork, design tokens, and a versioned story format while rendering their own interfaces.

Use XCTest or Swift Testing for Swift logic and XCUITest for app flows. Use Vitest for TypeScript and Playwright for public-web verification. Use MapKit or sourced GeoJSON with a correct projection. Styling must preserve actual geographic relationships.

Persist private trips locally in the app and public share snapshots on the server. Private trip synchronization across devices is outside the first demo. Choose one server persistence and hosting path after checking the available runtime during implementation. Do not build multiple storage backends. A static-only host cannot be treated as providing the shared-story service.

Use one adult-owned demo workspace. Protect create, edit, and revoke operations with a server-validated owner session. Public routes are read-only. Authentication setup is a prerequisite to exposing real write endpoints.

Key records:
- Trip: ID, title, dates, optional broad place, discovery IDs, completion state.
- Discovery: ID, trip ID, question, observation, explanation, illustration reference, optional private source media.
- Memory: ID, trip ID, ordered story sections, cover, last-presented time, dismissed-until time.
- Share: opaque token, an allowlisted public snapshot, creation time, revocation time.

Prepared responses are an explicitly named demo data source. Live AI, when enabled, enters through the same narrow response boundary and cannot silently replace failed requests with an apparently live answer.

## 8. File responsibilities and tasks

Paths below are relative to the proposed project directory. Each task should be independently reviewable. App sources live in `ios/PocketExplorer/`, with tests in `ios/PocketExplorerTests/` and `ios/PocketExplorerUITests/`.

| Task | Files to create or change | Complexity | Dependencies | Deliverable |
|---|---|---|---|---|
| T00 | `ios/PocketExplorer.xcodeproj/project.pbxproj`, `ios/PocketExplorer/App/PocketExplorerApp.swift`, `ios/README.md`, `design/review/device-setup.md` | medium | none | Minimal app, toolchain, target device, signing, and actual installation and launch evidence |
| T01 | `design/visual-direction.md`, `design/key-screens/`, `shared/design-tokens.json` | medium | none | Approved visual baseline recorded and four key screens including voice entry |
| T02 | `ios/PocketExplorer/App/PocketExplorerApp.swift`, `ios/PocketExplorer/App/RootView.swift`, `ios/PocketExplorer/Design/Theme.swift`, `ios/PocketExplorerUITests/NavigationTests.swift` | medium | T00, T01 | Native shell, visual tokens, navigation, and accessibility |
| T03 | `ios/PocketExplorer/Domain/Models.swift`, `ios/PocketExplorer/Data/TripStore.swift`, `shared/fixtures/demo-trips.json`, `ios/PocketExplorerTests/TripStoreTests.swift` | medium | T02 | Seed trips, stable IDs, relaunch persistence |
| T04 | `ios/PocketExplorer/Explore/ExploreView.swift`, `ios/PocketExplorer/Explore/VoiceSession.swift`, `ios/PocketExplorer/Explore/CameraCapture.swift`, `ios/PocketExplorer/Explore/DemoGuide.swift`, `ios/PocketExplorerTests/ExploreTests.swift`, `ios/PocketExplorerUITests/ExploreTests.swift` | complex | T03 | Recording, transcription, spoken response, camera capture, observation saving, permissions, and interruptions |
| T05 | `ios/PocketExplorer/Cards/DiscoveryCard.swift`, `ios/PocketExplorer/Cards/CollectionView.swift`, `ios/PocketExplorerTests/CardTests.swift` | medium | T03, T04 | Card reveal, reverse, enrichment, collection |
| T06 | `ios/PocketExplorer/World/WorldMap.swift`, `ios/PocketExplorer/Trips/TripJournal.swift`, `shared/geography/`, `ios/PocketExplorerTests/WorldTests.swift` | medium | T03, T05 | Trip markers, trip detail, location-free fallback |
| T07 | `ios/PocketExplorer/Memories/MemoryBuilder.swift`, `ios/PocketExplorer/Memories/MemoryPlayer.swift`, `ios/PocketExplorerTests/MemoryTests.swift` | medium | T05, T06 | Repeatable story construction and playback controls |
| T08 | `ios/PocketExplorer/Memories/ReminderPolicy.swift`, `ios/PocketExplorer/Memories/MemoryShelf.swift`, `ios/PocketExplorerTests/ReminderTests.swift` | medium | T07 | Later-visit resurfacing and dismiss behavior |
| T09 | `server/owner-session.ts`, `server/share-repository.ts`, `server/share-routes.ts`, `shared/public-story.schema.json`, `server/tests/sharing.test.ts` | complex | T03, T07 | Protected share creation, durable snapshots, versioned story format, public reads, revocation |
| T10 | `ios/PocketExplorer/Sharing/SharePreviewView.swift`, `ios/PocketExplorer/Sharing/ShareClient.swift`, `ios/PocketExplorerTests/ShareTests.swift`, `web/src/PublicStory.tsx`, `web/src/styles/tokens.css`, `web/tests/sharing.test.tsx` | complex | T07, T09 | Sharing preview in the app, actual links, and polished public web viewer |
| T11 | `ios/PocketExplorerUITests/PrototypeTests.swift`, `web/tests/e2e/story.spec.ts`, `web/tests/e2e/layout.spec.ts`, `design/review/`, `README.md` | medium | T04–T10 | Real-device and browser verification, visual review, installation and two-minute demo instructions |
| T12, optional | `server/guide-route.ts`, `ios/PocketExplorer/Explore/GuideClient.swift`, `server/tests/guide.test.ts`, `ios/PocketExplorerTests/GuideClientTests.swift` | medium | T11 | One live AI integration with visible failure handling |

## 9. Sequence and team split

1. Device and visual baseline: confirm installation, signing, and the demonstration device. Preserve the approved style and design the voice entry.
2. Complete local loop: record, transcribe, and play a response on the real iPhone, then build card reveal, collection, and trip persistence.
3. Visible history: connect the map, trip journal, memory playback, and later-visit invitation.
4. Real sharing: deploy the supported share service and verify the recipient experience across devices.
5. Polish and rehearse: replace temporary assets, fix failure states, run the acceptance contract, and rehearse the two-minute story.

Suggested split: one contributor focuses on the iPhone app, device interaction, and motion. The other focuses on the shared-story service, public web viewer, and shared artwork. Define the story format first, review the full loop together at each stage, and prioritize helping polish the app when visual work needs more attention.

The previous three-to-four-day estimate for a web prototype no longer applies. Re-estimate after T00 device installation and the smallest T04 voice check. No unverified completion date is promised. If time shrinks, reduce themes, subjects, and card variants before cutting the app voice entry, map memories, or cross-device sharing.

## 10. Validation and visual review

Use the companion contract for machine-verifiable behavior. Added or changed Swift code must reach at least 80% line coverage. TypeScript code must reach at least 80% line and branch coverage. Report them separately rather than hiding gaps with an aggregate average. Critical Swift permission, recording-state, and interruption branches require explicit outcome assertions. Use integration tests for persistence, audio adapters, owner authorization, and sharing.

Inspect the app at 375pt, 390pt, and the demonstration iPhone's logical width, including safe areas, larger text, and reduced motion. Inspect the web viewer at 375px, 390px, 768px, and 1440px and verify public stories in mobile Safari and desktop Chromium. Actual iPhone microphone, camera, and complete exploration checks are mandatory. Simulator recordings do not replace them. Document unavailable coverage instead of claiming it passed.

Human visual review covers composition, appeal, art consistency, legibility, and how satisfying the reveal and replay feel. Keep a screen-by-screen issue list with screenshots. Visual approval is a separate gate from passing automated tests.

With a parent present, observe a child try one discovery, inspect its card, and revisit the trip. Treat the result as early design feedback. Do not claim improved learning or long-term engagement from a prototype session.

## 11. Two-minute demonstration

- 0–20 seconds: launch the app from the iPhone home screen and have the child ask the companion why a duck can swim.
- 20–45 seconds: show the actual transcript and play one short answer and a real-world observation invitation.
- 45–70 seconds: the child speaks an observation, confirms the transcript, and reveals a collectible card with their own words.
- 70–95 seconds: return to the trip, see the new discovery, and play its memory.
- 95–120 seconds: the parent creates a share link and a second device opens the finished story without installing an app.

Keep an explicitly labeled recorded demonstration as a fallback, but it cannot replace real-iPhone voice and camera acceptance. Identify prepared AI content, and use an actual functioning URL for sharing.

## 12. First implementation checkpoint

The first deliverable checkpoint is an app installed on the demonstration iPhone. The child can tap to speak, see an actual transcript, hear a response, and receive a duck card in the approved style. The first response can be explicitly labeled prepared content. The discovery and card must preserve the child's current input.

The concept's visual direction already has user approval. New native screens, voice interaction, and final assets still require inspection. At the planning baseline, the concept had no actual app, live AI, persistence or publicly reachable shared-story service. See TODO for current implementation status. A concept preview cannot stand in for the implemented product.

## 13. Verified environment and executable task design

Checked on 2026-09-11: Xcode 27.0 (27A5194q), XcodeGen, Swift, Node, npm and Python are available. The demonstration iPhone 17 Pro Max is paired, but the latest detail check cannot establish an actual connection. The Apple Development certificate expires on 2026-11-30. Team and device identifiers belong in local configuration.

Unavailable device or publication checks must not block independent implementation. Split build and delivery subtasks when needed while preserving the original acceptance mapping. The catalogued Sites skill is missing, so the implementation uses a Node/SQLite service and React viewer. Storage persists on disk. A public deployment requires independent verification.

### T00: Minimal app, toolchain, target device, signing, and actual installation and launch evidence

**Dependencies:** none
**Goal:** Minimal app, toolchain, target device, signing, and actual installation and launch evidence
**Files:** `ios/PocketExplorer.xcodeproj/project.pbxproj`, `ios/PocketExplorer/App/PocketExplorerApp.swift`, `ios/README.md`, `design/review/device-setup.md`
**Design:** Use XcodeGen to define the app and test targets with an iOS 17 baseline. Keep build output in ignored directories. Install with the existing developer team and verify the installed app independently.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Evidence: build logs, real-device launch evidence, signing inspection, and reproducible installation instructions. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-00.1, AC-00.2, AC-00.3, AC-00.4

### T01: Approved visual baseline recorded and four key screens including voice entry

**Dependencies:** none
**Goal:** Approved visual baseline recorded and four key screens including voice entry
**Files:** `design/visual-direction.md`, `design/key-screens/`, `shared/design-tokens.json`
**Design:** Extract the approved palette into shared/design-tokens.json. Create original duck, leaf and shell artwork in shared/art. Preserve the reference composition in design/reference.html and add the voice companion composition.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Evidence: asset inspection, four key screens, and the approved visual-direction record. Inspect the new voice entry separately. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-01.1, AC-01.2, AC-01.3

### T02: Native shell, visual tokens, navigation, and accessibility

**Dependencies:** T00, T01
**Goal:** Native shell, visual tokens, navigation, and accessibility
**Files:** `ios/PocketExplorer/App/PocketExplorerApp.swift`, `ios/PocketExplorer/App/RootView.swift`, `ios/PocketExplorer/Design/Theme.swift`, `ios/PocketExplorerUITests/NavigationTests.swift`
**Design:** RootView owns the three-tab selection and focused exploration presentation. Theme supplies rounded typography, paper surfaces, forest-green actions and iridescent gradients. Use native SwiftUI layout and accessibility identifiers.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: XCUITest navigation checks and app layout and accessibility inspection. Explore and sharing controls are checked in their respective feature tasks. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-02.1, AC-02.2, AC-02.3, AC-02.4, AC-02.5

### T03: Seed trips, stable IDs, relaunch persistence

**Dependencies:** T02
**Goal:** Seed trips, stable IDs, relaunch persistence
**Files:** `ios/PocketExplorer/Domain/Models.swift`, `ios/PocketExplorer/Data/TripStore.swift`, `shared/fixtures/demo-trips.json`, `ios/PocketExplorerTests/TripStoreTests.swift`
**Design:** Use Codable Trip, Discovery and Memory structs with stable UUIDs. TripStore atomically writes JSON under Application Support and owns private photo files. Initialize fixtures once. Save mutations only after persistence succeeds.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: store tests with fresh reads, relaunch verification, and injected write failures. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-03.1, AC-03.2, AC-03.3, AC-03.4

### T04: Recording, transcription, spoken response, camera capture, observation saving, permissions, and interruptions

**Dependencies:** T03
**Goal:** Recording, transcription, spoken response, camera capture, observation saving, permissions, and interruptions
**Files:** `ios/PocketExplorer/Explore/ExploreView.swift`, `ios/PocketExplorer/Explore/VoiceSession.swift`, `ios/PocketExplorer/Explore/CameraCapture.swift`, `ios/PocketExplorer/Explore/DemoGuide.swift`, `ios/PocketExplorerTests/ExploreTests.swift`, `ios/PocketExplorerUITests/ExploreTests.swift`
**Design:** Separate ExploreSession state from VoiceSession and CameraCapture adapters. Use Speech plus AVFoundation for editable actual transcription and spoken replies. Stages are question and observation. States are idle, listening, thinking, speaking and failed. Prepared duck/leaf/shell answers reject unmatched questions explicitly.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: voice-state and save unit tests, integration tests for the selected audio and recognition adapters, and real-device recording, playback, camera, permission, and interruption evidence. Include different utterances so a fixed script cannot pass. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-04.1, AC-04.2, AC-04.3, AC-04.4, AC-04.5, AC-04.6, AC-04.7, AC-04.8, AC-04.9, AC-04.10, AC-04.11, AC-04.12, AC-04.13, AC-04.14, AC-04.15

### T05: Card reveal, reverse, enrichment, collection

**Dependencies:** T03, T04
**Goal:** Card reveal, reverse, enrichment, collection
**Files:** `ios/PocketExplorer/Cards/DiscoveryCard.swift`, `ios/PocketExplorer/Cards/CollectionView.swift`, `ios/PocketExplorerTests/CardTests.swift`
**Design:** DiscoveryCard renders stable front/reverse states, with a finite reveal animation and child-authored observation verbatim. CollectionView reads persisted records. Enrichment edits the original ID.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: app card and collection interaction tests, system reduced-motion check. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-05.1, AC-05.2, AC-05.3, AC-05.4

### T06: Trip markers, trip detail, location-free fallback

**Dependencies:** T03, T05
**Goal:** Trip markers, trip detail, location-free fallback
**Files:** `ios/PocketExplorer/World/WorldMap.swift`, `ios/PocketExplorer/Trips/TripJournal.swift`, `shared/geography/`, `ios/PocketExplorerTests/WorldTests.swift`
**Design:** WorldMap uses MapKit or the sourced reference geography, never invented outlines. TripJournal opens the selected trip and preserves a list fallback when map/location is unavailable.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: geographic input checks, marker-selection tests, no-location test, app inspection of the rendered basemap. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-06.1, AC-06.2, AC-06.3, AC-06.4, AC-06.5

### T07: Repeatable story construction and playback controls

**Dependencies:** T05, T06
**Goal:** Repeatable story construction and playback controls
**Files:** `ios/PocketExplorer/Memories/MemoryBuilder.swift`, `ios/PocketExplorer/Memories/MemoryPlayer.swift`, `ios/PocketExplorerTests/MemoryTests.swift`
**Design:** MemoryBuilder creates ordered question/observation/discovery chapters from one or more discoveries. Finish is idempotent. MemoryPlayer cancels its timer when paused or dismissed and replays from chapter zero.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: deterministic construction tests and player tests using a controlled clock. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-07.1, AC-07.2, AC-07.3, AC-07.4, AC-07.5, AC-07.6

### T08: Later-visit resurfacing and dismiss behavior

**Dependencies:** T07
**Goal:** Later-visit resurfacing and dismiss behavior
**Files:** `ios/PocketExplorer/Memories/ReminderPolicy.swift`, `ios/PocketExplorer/Memories/MemoryShelf.swift`, `ios/PocketExplorerTests/ReminderTests.swift`
**Design:** ReminderPolicy uses an injected clock. Completion plus seven days is eligible, dismissal sets another seven-day interval. Persist dismissal and keep the demonstration clock under DEBUG compilation.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: controlled-clock tests immediately before and at eligibility and dismissal boundaries. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-08.1, AC-08.2, AC-08.3, AC-08.4

### T09: Protected share creation, durable snapshots, versioned story format, public reads, revocation

**Dependencies:** T03, T07
**Goal:** Protected share creation, durable snapshots, versioned story format, public reads, revocation
**Files:** `server/owner-session.ts`, `server/share-repository.ts`, `server/share-routes.ts`, `shared/public-story.schema.json`, `server/tests/sharing.test.ts`
**Design:** Use one actual durable store, authenticated adult-owned create/revoke operations and public read-only routes. A versioned public-story schema allowlists fields. Generate tokens with at least 128 bits of cryptographic randomness. Never include precise coordinates, raw recordings, private metadata or credentials.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: integration tests against the actual persistence implementation, including adversarial private fields and separate reads after writes. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-09.1, AC-09.2, AC-09.3, AC-09.4, AC-09.5, AC-09.6, AC-09.7, AC-09.8, AC-09.9, AC-09.10

### T10: Sharing preview in the app, actual links, and polished public web viewer

**Dependencies:** T07, T09
**Goal:** Sharing preview in the app, actual links, and polished public web viewer
**Files:** `ios/PocketExplorer/Sharing/SharePreviewView.swift`, `ios/PocketExplorer/Sharing/ShareClient.swift`, `ios/PocketExplorerTests/ShareTests.swift`, `web/src/PublicStory.tsx`, `web/src/styles/tokens.css`, `web/tests/sharing.test.tsx`
**Design:** SharePreviewView previews the exact public snapshot, with first name and city disabled by default. ShareClient retains the server-returned URL. React renders the same art, cards and memory chapters without sign-in, with keyboard and touch controls.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: app share-client and preview tests, plus an app-created link opened in an independent browser session. Confirm access on a second device when available. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-10.1, AC-10.2, AC-10.3, AC-10.4, AC-10.5, AC-10.6, AC-10.7, AC-10.8

### T11: Real-device and browser verification, visual review, installation and two-minute demo instructions

**Dependencies:** T04–T10
**Goal:** Real-device and browser verification, visual review, installation and two-minute demo instructions
**Files:** `ios/PocketExplorerUITests/PrototypeTests.swift`, `web/tests/e2e/story.spec.ts`, `web/tests/e2e/layout.spec.ts`, `design/review/`, `README.md`
**Design:** Retain Swift result bundles, TypeScript coverage, browser evidence and real-device observations in docs/evidence. Record real versus prepared integrations. Present the key screens for visual review and rehearse from app launch through independent share viewing in two minutes.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: Swift and TypeScript coverage reports, real-device and browser evidence, independent public reads, and a rehearsal recording beginning with app launch. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-11.1, AC-11.2, AC-11.3, AC-11.4, AC-11.5, AC-11.6, AC-11.7

### T12: One live AI integration with visible failure handling

**Dependencies:** T11
**Goal:** One live AI integration with visible failure handling
**Files:** `server/guide-route.ts`, `ios/PocketExplorer/Explore/GuideClient.swift`, `server/tests/guide.test.ts`, `ios/PocketExplorerTests/GuideClientTests.swift`
**Design:** Optional only after the required demo works: connect one authorized service through a server boundary. Keep service credentials server-side and retain actual input on timeout. Do not silently substitute a fixture for a failed live call.
**Failure behavior:** Preserve input, expose the error, record the cause and retry. Record an honest blocker when an external prerequisite is unavailable.
**Verification:** Tests: integration tests for the actual selected service boundary and a live smoke test when credentials are available. Use 5-second unit, 30-second integration and 60-second UI test deadlines by default, with a 15-minute build deadline.
**Completion:** Satisfy the corresponding ACCEPTANCE criteria: AC-12.1, AC-12.2, AC-12.3, AC-12.4


## 14. TestFlight and Cloudflare release

The user requested TestFlight distribution and Cloudflare hosting. This stage extends T00, T09, T10 and T11 without changing the 79 existing product criteria.

- TestFlight: add release version and build numbers, required privacy declarations and distribution export options. Validate an archive, upload to App Store Connect and independently confirm build processing. The user subsequently requested External Testing, authorizing external group setup and preparation of the first Beta App Review submission. Teammate invitations still require actual recipients and existing authorization.
- Cloudflare: one Worker serves the React assets and sharing API, with D1 persisting public snapshots. Keep Node/SQLite as the local development entry point. Preserve the public format, owner credentials, field allowlist and revocation semantics.
- Added files: web/worker/index.ts, web/migrations/0001_shares.sql, web/wrangler.jsonc, web/tests/worker.test.ts, ios/ExportOptions.plist, ios/PocketExplorer/PrivacyInfo.xcprivacy and docs/deployment.md.
- Failure behavior: configuration and database errors return sanitized responses. Unauthorized requests cannot mutate data. A failed deployment preserves the existing local prototype and database and does not change other projects.
- Verification: Worker line and branch coverage must each reach 80%. Exercise persistence against the actual local D1 runtime. Independently verify deployed create, read, revoke and browser playback. TestFlight completion requires observed App Store Connect build state, not just a successful archive.
- Runtime release state and exact evidence belong in TODO.md and docs/evidence release records. TestFlight installation, review and human usability acceptance must be verified separately.

## T13: First-use usability correction

- The user tried the app and reported that it was difficult to understand and operate. This is a failed first-use acceptance check that previous automated passes cannot override.
- Reproduction evidence: the home entry follows a large map and statistics. The exploration illustration consumes the screen, stopping speech still requires finding a separate submit button, and creating a memory requires navigating through the trip after saving.
- Outcome: the start action is immediately visible on launch. Exploration has one fixed primary action, stopping a question leads to its reply, observations have an explicit save action, and a saved card leads directly to memory creation. Preserve real speech, editable text, typing, permission recovery and honest prepared-content labeling.
- Confirmed language choice: show a first-launch language selection screen with device language, Simplified Chinese and English. Persist the choice and allow changing it from home. Recognition and playback use the selected language.
- Files: WorldView.swift, ExploreView.swift, RootView.swift, DemoGuide.swift, VoiceSession.swift, string resources and corresponding native tests.
- Verification: add UI checks that reproduce the old home-entry and primary-action problem before fixing it. Add speech-flow and bilingual-topic tests. Inspect 375pt, large text, saved-card relaunch and the direct memory entry. Changed Swift line coverage must reach 80%.
- Do not add live AI, an account system or a new backend. Preserve existing journals and published shares. Real-device first-use acceptance still requires user feedback.

## T14: Sharing without manual service setup

- Trigger: the user cannot test sharing because the app asks for a family owner key. The current client rejects an empty credential before making a request.
- Outcome: preview, create, share/copy and revoke work without entering a key or endpoint. Keep optional first name and city off by default. Keep the main sharing action visible below the preview.
- Ownership: generate a random 256-bit installation credential and persist it in Keychain before the first network request. The service stores only its SHA-256 hash per share. Creation accepts this anonymous owner capability. Revocation requires its matching credential. Public read tokens never authorize writes. Existing server-owner credentials and published links remain compatible. This provides ownership, not verified parental identity or an account recovery service.
- Abuse controls: retain strict schema and 256KB body limits. Rate-limit Cloudflare creation by both connection IP and credential to 20 requests per minute per location. Rate limits do not block reads or revocation.
- Files: native Sharing views/client, English/Chinese strings, Worker, local SQLite service, additive D1 migration, sharing tests and deployment records.
- Failure behavior: preserve local stories and credentials on network errors. Show a retryable message for service/rate-limit failures. Never embed the global owner key or overwrite existing Keychain ownership. A lost installation credential cannot recover old revocation rights through anonymous setup.
- Verification: reproduce a fresh installation credential being rejected by the old service. Exercise two independent owners, unauthorized revocation, legacy links, SQLite/D1 reopening, zero-setup native create/read/relaunch/copy/revoke, localization and network failure. Changed Swift line coverage and TypeScript line/branch coverage must reach 80%.
- Delivery: apply additive migration, deploy Cloudflare, independently read and revoke a new live story, preserve the existing example, archive the final build 5 and verify it is Testing in the internal TestFlight group. Human phone acceptance remains distinct.

User clarification: remove parental restrictions entirely. Sharing is available directly to the explorer, without parental approval, a parent key or a parent mode. Keep the public preview, optional disclosure choices and background ownership protection against other users revoking a link.

## T15: GitHub repository and automated TestFlight delivery

- Goal: preserve the working baseline in the private Little-Pocket-Explorer/Pocket-Explorer-UI repository. Complete repository and release setup before further product changes.
- Scope: retain iOS, shared resources and the current sharing website for a buildable baseline. Leave the organization's other repositories alone. Exclude generated and duplicate Xcode projects, certificates, private keys, databases, build artifacts and machine settings.
- Files: GitHub Actions workflow, Fastlane release configuration, runner scripts, release documentation and PLAN/PROMPT/TODO.
- Flow: pull requests run native and web tests. Main pushes and explicit manual releases upload only after tests pass, using dedicated signing credentials. Wait for Apple processing and assign Hackathon Internal.
- Build numbers: serialize releases and increment the latest Apple build number, including reruns. Preserve 0.1.0 (5). Avoid simultaneous manual uploads from another publisher.
- Credentials: store signing material only in encrypted secrets for the GitHub testflight environment. Restrict that environment to main. Pull requests receive no signing secrets. Pin Actions and tool versions and fail closed on errors.
- Verification: inspect sensitive content before the first commit, lint workflows and shell scripts, run actual GitHub tests and upload, then independently confirm internal TestFlight state. Existing external review and website deployment remain independent.

T15 is complete: all three jobs in GitHub run 34571657181 succeeded and automatically released 0.1.0 (6). Independent reads of Apple's build, internal group and testing notes agree with the release artifact. See docs/evidence/github-setup.json. This completion does not close existing physical-device acceptance or future AI integration.

## T12: Selected services for future AI integration

- On 2026-09-11 the user selected https://xuche-mohicupb-westus3.services.ai.azure.com/openai/v1/images/generations with Azure deployment gpt-image-2.5-sunburst. The user supplied earlier test evidence of HTTP 200 in 20.8 seconds with 1024×1024 and quality=low. This setup task records that evidence without repeating image generation.
- Future GPT-6 integration should reuse the existing ~/.codex/config.toml provider configuration. Read-only inspection confirmed gpt-6-astra, copilot-proxy and xhigh reasoning. Do not modify global Codex settings.
- The image credential is stored in ignored .local/ai/providers.json, with directory mode 0700 and file mode 0600. GPT-6 credentials remain in their original configuration. Future deployment must inject server-side secrets and keep them out of iOS, browser bundles, Git and logs.
- Complete T15 automated TestFlight delivery before larger product changes or AI integration. Provider selection does not mean the app is connected. Integration must verify real image/text requests, failure recovery and the approved visual style.

## Accepted Cloudflare AI backend direction

The user confirmed continuing with Cloudflare on 2026-09-11. Extend the existing hosting platform after T15 is verified. Keep the iOS app as the primary interface and use the existing Pocket-Explorer-Backend repository for subsequent backend work. That repository was independently confirmed empty, so no competing implementation was observed. The current repository remains a buildable baseline until any deliberate extraction.

- Workers provide the app API, validate requests, enforce caller access and usage limits, and call the selected upstream models. Upstream credentials are Cloudflare secrets. Clients never receive them.
- Use Queues for durable image-generation jobs, with D1 job state, request deduplication, bounded retries and explicit failure status. Closing the app must not cancel an accepted job. Do not use request-bound waitUntil as the durable job mechanism.
- Store generated image objects in R2, and store job/card/image relationships in D1. Preserve local private journals unless synchronization is explicitly added later. Retain the existing public-story field restrictions and revocation behavior.
- Verify app-to-backend-to-model requests, interrupted clients, duplicate submissions, upstream failures, image retrieval and isolation of private content before calling the integration complete. Current deployment still supports sharing only. No AI routes, queues or R2 storage have been deployed in T15.
- Cloudflare documents that network waiting does not consume CPU time, HTTP requests can continue while the client stays connected, waitUntil adds at most 30 seconds after disconnect, and queue consumers have a 15-minute wall-clock limit. References: https://developers.cloudflare.com/workers/platform/limits/ and https://developers.cloudflare.com/queues/platform/limits/.


## T16: Backend extraction and automatic Cloudflare delivery

The user authorized moving the website, Worker API, D1 migrations and web tests into Little-Pocket-Explorer/Pocket-Explorer-Backend, with successful main pushes deploying to Cloudflare. Preserve pocket.changhai.me, the existing D1 database, public links and server-side secrets. The iOS repository keeps native source and shared native fixtures. Its native integration checks use the deployed Cloudflare API with their own installation credential. Backend CI owns isolated database and browser tests. Repository policy disables Deploy Keys, and no policy change or cross-repository credential is introduced.

Tasks: extract the tracked web baseline, add Backend PLAN/PROMPT/TODO and a checks-to-deploy workflow, configure a dedicated Cloudflare API token in a main-only environment, run an actual GitHub deployment, independently verify deployed behavior and source version, then remove duplicate web implementation from the UI repository and verify its updated native integration workflow. Failed checks prevent deployment. D1 migrations remain additive and existing records must survive. This stage does not implement live AI, Queues or R2.

Verification: actionlint, build, existing unit/integration coverage thresholds, six browser checks, a live public-sharing check, Cloudflare API deployment reads and actual UI regression with deployed Cloudflare. Never copy the global Cloudflare key, AI credentials or signing material into Git or clients.

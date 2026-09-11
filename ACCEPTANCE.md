# Pocket Explorer: Prototype Acceptance Contract

Date: 2026-09-11
Plan: [Prototype plan](PLAN.md)
Status: Acceptance criteria remain unchanged. Automated verification is in progress. See TODO.md for current evidence and unmet criteria.

## Contract rules

Task IDs match the plan. Tests must assert observable outcomes rather than reproduce implementation details. All verification of a persistent write includes a separate read.

Machine checks cover behavior, layout, accessibility, and data boundaries. Human approval of visual quality is tracked separately and cannot be inferred from test results.

## T00: Real-device setup and installation

- AC-00.1: Documentation records the inspected Xcode version, target iOS version, and demonstration iPhone.
- AC-00.2: The selected build installs and launches on that real iPhone.
- AC-00.3: Installation instructions record signing expiry and installation or renewal steps covering the demonstration date.
- AC-00.4: The project contains no signing private keys, developer account passwords, or service credentials.
- Evidence: build logs, real-device launch evidence, signing inspection, and reproducible installation instructions.
- Complexity: medium. Regression guard: a simulator or website shortcut cannot replace real-device app acceptance. An App Store release is not required.

## T01: Visual direction

- AC-01.1: The design record references the approved concept baseline and contains four screens: voice entry, world map, card reveal, and memory/share entry.
- AC-01.2: Every shipped visual asset has an origin and usage-rights entry in the asset record.
- AC-01.3: The final prototype has no placeholder emoji in collectible artwork.
- Evidence: asset inspection, four key screens, and the approved visual-direction record. Inspect the new voice entry separately.
- Complexity: medium. Regression guard: later tasks preserve the selected visual direction.

## T02: Shell and layout

- AC-02.1: My world, My finds, and Memories each open their matching destination.
- AC-02.2: App primary actions are not clipped by safe areas at 375pt, 390pt, and the demonstration iPhone's width.
- AC-02.3: App primary controls have effective touch targets of at least 44 by 44pt.
- AC-02.4: Core app actions have usable VoiceOver labels and traversal order.
- AC-02.5: Shell navigation and the exploration entry remain reachable with larger system text enabled.
- Tests: XCUITest navigation checks and app layout and accessibility inspection. Explore and sharing controls are checked in their respective feature tasks.
- Complexity: medium. Regression guard: map and memory navigation remain usable after opening and closing overlays.

## T03: Data and persistence

- AC-03.1: Seed data includes two trips and at least one trip with two discoveries.
- AC-03.2: A saved discovery keeps its ID and trip association after app termination and relaunch.
- AC-03.3: A failed persistence operation leaves the user's entered observation recoverable.
- AC-03.4: Editing a discovery updates the existing record instead of creating a duplicate.
- Tests: store tests with fresh reads, relaunch verification, and injected write failures.
- Complexity: medium. Constraint: data code does not import UI components.

## T04: Exploration flow

- AC-04.1: A prepared question produces one short response and one observation invitation.
- AC-04.2: A child can save a nonempty observation without taking a quiz.
- AC-04.3: A failed request exposes a retry action without clearing the input.
- AC-04.4: Prepared content is identifiable as a demo source in the demo setup.
- AC-04.5: Question audio captured on the real iPhone produces an editable transcript corresponding to that utterance rather than a hardcoded example transcript.
- AC-04.6: The response plays through the target iPhone's speaker with visible text.
- AC-04.7: The interface distinguishes listening, thinking, and speaking states and includes a stop action.
- AC-04.8: Denied microphone or selected speech-recognition permission preserves existing input and offers a readily accessible alternative input route.
- AC-04.9: A photo captured on the real iPhone is associated with the current discovery and remains after a fresh record read.
- AC-04.10: Voice exploration remains completable when camera permission is denied.
- AC-04.11: Backgrounding or an audio interruption stops capture and playback while preserving existing text.
- AC-04.12: Capture and playback do not automatically resume after returning from the background or an interruption.
- AC-04.13: An unmatched prepared scenario produces an explicit demo-scope notice rather than a fixed example presented as the current question's answer.
- AC-04.14: The child's spoken observation can be transcribed, corrected, and saved as card content.
- AC-04.15: Speech, stop, save, and back actions remain reachable with larger system text enabled.
- Tests: voice-state and save unit tests, integration tests for the selected audio and recognition adapters, and real-device recording, playback, camera, permission, and interruption evidence. Include different utterances so a fixed script cannot pass.
- Complexity: complex. Constraint: device audio and camera handling remain separate from exploration state. Regression guard: saving does not require live AI, and voice exploration does not require camera permission.

## T05: Cards and collection

- AC-05.1: A saved discovery appears in the collection after a fresh store read.
- AC-05.2: The reverse of the card displays the child's stored observation verbatim.
- AC-05.3: The reveal settles into an inspectable card without continuous motion.
- AC-05.4: Reduced-motion mode reaches the same final card state without the reveal movement.
- Tests: app card and collection interaction tests, system reduced-motion check.
- Complexity: medium. Regression guard: card enrichment preserves existing ownership and trip association.

## T06: Map and trips

- AC-06.1: Displayed place positions are projected from sourced geographic coordinates.
- AC-06.2: Selecting a trip marker opens the matching trip's discoveries.
- AC-06.3: Both seed trips can be revisited through the world view.
- AC-06.4: A trip without a location remains reachable through a list or collection view.
- AC-06.5: Saving another discovery to an existing trip updates that trip's displayed contents without adding an unrelated marker.
- Tests: geographic input checks, marker-selection tests, no-location test, app inspection of the rendered basemap.
- Complexity: medium. Regression guard: a map-load failure does not remove access to saved discoveries.

## T07: Memory construction and playback

- AC-07.1: Completing a one-discovery trip produces a memory with question, observation, and discovery sections.
- AC-07.2: A multi-discovery memory preserves the chosen discovery order.
- AC-07.3: Pause stops automatic section advancement.
- AC-07.4: Replay starts at the first section.
- AC-07.5: Leaving the player clears its playback timer.
- AC-07.6: Finishing the same trip again does not create an unintended duplicate memory.
- Tests: deterministic construction tests and player tests using a controlled clock.
- Complexity: medium. Regression guard: manual navigation works with reduced motion.

## T08: Later-visit feedback

- AC-08.1: A completed trip is eligible for resurfacing seven days after completion.
- AC-08.2: A dismissal suppresses that memory invitation for the next seven days.
- AC-08.3: Before eligibility, the same invitation is absent.
- AC-08.4: The time-control interface is unavailable in the production build.
- Tests: controlled-clock tests immediately before and at eligibility and dismissal boundaries.
- Complexity: medium. Regression guard: dismissing an invitation does not delete the memory.

## T09: Shared-story service

- AC-09.1: An authenticated owner can create a share and receive an opaque, nonsequential token.
- AC-09.2: A fresh public read returns the saved, allowlisted story snapshot.
- AC-09.3: The story remains available after the service restarts on its deployed persistent storage.
- AC-09.4: Unauthenticated create, edit, and revoke requests return 401 or 403.
- AC-09.5: Public payloads exclude precise coordinates, raw recordings, original media metadata, and private history.
- AC-09.6: First name is absent unless the owner explicitly includes it.
- AC-09.7: Broad place name is absent unless the owner explicitly includes it.
- AC-09.8: After revocation, a fresh public request returns 410 with a readable no-longer-shared state.
- AC-09.9: An unknown token returns 404 without disclosing private data.
- AC-09.10: Public stories exported by the app and read by the website pass the same versioned format and shared-fixture checks.
- Tests: integration tests against the actual persistence implementation, including adversarial private fields and separate reads after writes.
- Complexity: complex. Constraints: public routes cannot mutate trips. Share tokens must have at least 128 bits of cryptographic randomness. Revocable responses must not be served from a stale public cache after revocation.

## T10: Share preview and recipient experience

- AC-10.1: The explorer previews the selected public content in the app before link creation.
- AC-10.2: Copying a link copies the actual returned URL only after share creation succeeds.
- AC-10.3: A clean browser session opens that URL without authentication or installation.
- AC-10.4: The recipient can replay the memory and inspect its included cards.
- AC-10.5: A failed share operation does not display a success confirmation.
- AC-10.6: The public website has no horizontal document overflow at 375, 390, 768, and 1440 CSS pixels.
- AC-10.7: Public-web playback and card controls are keyboard-operable with visible focus.
- AC-10.8: Public-web primary controls have effective touch targets of at least 44 by 44 CSS pixels at phone widths.
- Tests: app share-client and preview tests, plus an app-created link opened in an independent browser session. Confirm access on a second device when available.
- Complexity: medium. Regression guard: public viewing does not alter private trip state.

## T11: Verification and handoff

- AC-11.1: Added or changed Swift code reaches at least 80% line coverage, and TypeScript reaches at least 80% line and branch coverage, reported separately.
- AC-11.2: The complete exploration path passes on the target real iPhone, and public stories pass in mobile Safari and desktop Chromium. Missing real-device evidence leaves this criterion unmet.
- AC-11.3: The empty collection, failed guide request, failed share request, and revoked link each have an inspected screen.
- AC-11.4: The project records which integrations are live and which data is prepared.
- AC-11.5: Screenshots and a human visual-review issue list exist for the key screens.
- AC-11.6: The demo can complete its narrative within two minutes, including opening a real share URL.
- AC-11.7: Critical voice-state, permission-denial, and audio-interruption branches have tests asserting observable outcomes.
- Tests: Swift and TypeScript coverage reports, real-device and browser evidence, independent public reads, and a rehearsal recording beginning with app launch.
- Complexity: medium. Human gate: the user or designated design owner reviews visual appeal, consistency, readability, and reveal quality. Automated tests cannot close this gate.

## T12: Optional live AI

- AC-12.1: A successful live call returns a structured answer and one observation invitation.
- AC-12.2: Timeout or failure leaves the original question and observation intact.
- AC-12.3: A fallback response is visibly distinguished from a live response.
- AC-12.4: Service credentials do not appear in the iPhone app bundle, web bundle, or public responses.
- Tests: integration tests for the actual selected service boundary and a live smoke test when credentials are available.
- Complexity: medium. Regression guard: all required prototype flows remain demonstrable with the named prepared data source.

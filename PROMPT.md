# Pocket Explorer: Project Continuation Prompt

## Active eight-hour refinement (2026-09-15)

The user now authorizes implementation and repeated refinement through 2026-09-15 08:39:34 Australia/Sydney. This supersedes the planning-only checkpoint below. Prioritize rough interactions, gentle child-friendly speech, and slow or stuck image generation, then advance global multilingual quality within the same core journeys. Accounts and friend chat remain deferred.

- IN_PROGRESS T21.1 / B09.1: reproduce and fix artwork progress, deadlines, lost polling and safe retry. Preserve saved cards, avoid duplicate provider work, and test offline, timeout, relaunch and concurrent jobs.
- NEXT T21.2 / B09.2: improve voice selection, pacing, content-language replay and speech lifecycle. Evaluate available natural speech capabilities before adding a provider dependency. Missing speech must retain reading and typing.
- NEXT T21.3: inspect and polish the complete native flows, including loading/error/empty states, primary actions, scrolling, touch targets and image rendering. Then integrate T20/B08 language foundations as useful increments.
- REQUIRED for each candidate version: meaningful reproduction, targeted tests, coverage gates, actual UI screenshots and critique, fixes, regression and independent release readback. Use the user-authorized cl -p Opus 5 CLI as an independent reviewer. Reviewer opinions require verification.
- Current release is 0.1.0 (10), independently verified after local publication. Publish TestFlight only from local Xcode 27 RC build 27A266a. Preserve existing Cloudflare workflow, private credentials, journals, links and untracked Miro sync work. No teammate messages or new purchases.
- Review artifacts: ~/tmp/review/pocket-polish-20260915/. The five-minute heartbeat is ACTIVE until the deadline. Continue useful independent work across increments, rather than stopping after one upload or repeating unchanged checks.

## Latest direction: global languages (2026-09-15)

Read [Remaining work and language plan](docs/next-iteration.md) and the top of TODO first. The user requires multilingual support for children worldwide. The current assessment and plan are complete, while T20/B08 are not implemented. Continue from the next development instruction or specific issue without treating candidate languages or later features as delivered.

Language scope includes UI, permissions, errors, speech, AI answers, cards, quizzes, memories and Web sharing. Preserve original child content and its language, old journals and old shares. UI switching must not overwrite content, and unavailable speech retains the text flow. Verify RTL, long text, age-appropriate expression and actual speech. Preserve Miro visual quality and no parental gates. Accounts and friend chat remain deferred.

Release amendment: the user requires this TestFlight build to be archived and uploaded from this Mac because GitHub runner quota is exhausted. Run native checks locally and independently verify Apple processing. Do not trigger a GitHub TestFlight release for this iteration.

## Active implementation: Miro and live AI (2026-09-14)

The user now authorizes real native implementation, including live question answering and generated card artwork. This supersedes all earlier design-only restrictions and optional-AI statements below. Miro remains the visual and flow authority. Figma contains all 40 source screens and 189 hotspots, verified by native plugin readback. Older one-screen and blocked-delivery statements are historical.

Current scope is exploration, cards, maps, memories and public link sharing. Real accounts, friend relationships and cross-account chat are explicitly deferred. Preserve English, Simplified Chinese, the language chooser, existing journals and existing public links. Do not add parental keys, approval gates or controls. Use real SwiftUI controls and layouts, with decorative artwork. Full-screen source screenshots are references, not the app implementation.

Execute the active implementation plan above all historical continuation notes below. Continue through implementation, regression, visual inspection, authorized Cloudflare delivery and local TestFlight upload. Do not use GitHub runners for this TestFlight release. Keep TODO current. Do not restart completed Figma import work.

## Delivery status amendment (2026-09-14)

Production AI, R2 artwork, queue consumption, generated public stories and revocation are now independently verified. Persistent total allowances are 120 question attempts and 18 image attempts. The user directed implementation and publication to proceed without further pricing investigation. Current release evidence and remaining checks are in TODO.md.

This iteration uses local TestFlight publication because the user reported exhausted iOS runner quota. Backend delivery continues through the existing automatic Cloudflare workflow after an initial local rollout. Preserve both workflows for future use. Do not dispatch a GitHub iOS build or release. Accounts and friend chat remain deferred.

## Historical plan and evidence

## Current design authority (2026-09-14)

The user confirmed that [the Miro board](https://miro.com/app/board/uXjVHn9F6EQ=/) is the source of truth for UI design and flows. Figma Review 01 is an interaction example only. This decision supersedes conflicting visual baselines and Figma continuation instructions below, while explicit user decisions still take precedence over board content. The current phase is design and prototype review. Any new clickable prototype must follow Miro, and the existing Figma example does not establish completion of that work.


## Current priority: T18 Miro to Figma synchronization

Read `design/miro-sync/README.md`, `PROMPT.md`, and `TODO.md` first. The accepted approach is complete Miro images with transparent hotspots. Do not resume extraction. The local 40-screen, 189-hotspot preview is at http://127.0.0.1:4186/preview.html. The official Figma plugin has successfully authenticated, written nodes, uploaded images, and independently read the resulting layers. Further calls are currently rejected by the Starter MCP tool-call quota. The new source page contains one verified assembled screen, not a complete import. Preserve `design/miro-sync/manifest.json` and resume its existing nodes after access is restored. Do not use foreground browser automation or purchase an upgrade.

## Earlier T17 example

The user now wants design discussion before real application development. Read PLAN.md, PROMPT.md and TODO.md in /Users/haichang/.gstack/projects/pocket-explorer/designs/figma-review-20260911 first. Do not automatically modify or deploy the App or Backend based on older implementation tasks. The editable Figma file and clickable presentation are delivered. See TODO.md for URLs and verification. Continue with team design feedback and avoid duplicate imports. Do not request passwords or tokens.

Complete Pocket Explorer using the codex-project workflow. Implement and verify the required iPhone app and public sharing experience. Keep TODO.md current and continue across task boundaries while required actionable work remains.

## Product and user intent

Pocket Explorer turns a child's real-world question into a personal collectible card, a discovery on their map, a replayable memory and a story their family can share.

The iPhone app is the primary product. The first demo must include a real installed app with voice and camera entry. The website is the recipient's sharing surface. The user explicitly rejected deferring the app because it would compromise the child's experience.

Visual appeal is the highest priority. Visible accomplishment, memories and sharing are second. Preserve cream paper, forest green, rounded typography, pastel iridescent card borders, softly sculptural artwork and restrained reveal/flip animation. The approved reference is design/reference.html. Do not replace this direction with generic platform controls or emoji artwork.

The audience assumption is children aged 6–10 with a parent. Use fictional demonstration profiles and trips. Do not infer real children or locations from the developer's account or device.

## Required experience

The child opens the app, sees a friendly exploration companion, taps to speak, asks a question, hears a short response and receives one observation invitation. The child looks at the real world and describes what they noticed. Their own words become a card they can inspect, flip and revisit.

Cards belong to trips, persist after app relaunch, appear in a collection and appear on the map when a place is present. No correct quiz answer is required to keep a discovery. A location-free trip remains accessible.

On explicit trip completion, build a memory with question, observation and discovery chapters. Support one or multiple cards, stable ordering, pause, replay, manual controls and reduced motion. Seven days later, an in-app invitation may resurface the trip. Dismissal suppresses it for another seven days. There is no background push requirement.

The explorer previews the exact public story, selects what to include and creates a real URL. First name and broad city are off by default. Another device or independent browser must open the story without account creation or app installation. Public content excludes precise coordinates, raw recordings, photo metadata and private history. Links are revocable.

## Prepared and live capabilities

The first guide can use explicitly identified duck, leaf and shell responses. Real microphone capture, actual editable transcription, speaker playback and camera input are required. A different utterance cannot receive a hardcoded sample transcript. An unmatched question must be identified as outside the prepared demo rather than silently answered with a fixed example.

Keep actual questions and observations intact on failures. Handle denied permissions, audio interruption and backgrounding. Return to the foreground without automatically restarting recording. Camera denial cannot block voice-only exploration. Provide a parent typing fallback.

One live multimodal AI integration is optional after the complete required experience works. Keep service credentials server-side and expose failures honestly. Do not confuse the GPT-6 model used for development with an already configured product AI service.

## Current technical direction

Use SwiftUI for the iPhone app, system Speech/AVFoundation and camera interfaces, local atomic Codable storage, and MapKit or sourced geographical data. Share art, tokens, fixtures and a versioned public-story format with the React/TypeScript web viewer.

Use one persistent sharing service with owner-authenticated writes, public read-only snapshots, cryptographically random tokens and revocation-safe caching. Choose the runtime and storage against actual hosting capabilities. A static page or localhost-only preview does not satisfy remote sharing.

The paired development device is Hai's iPhone 17 Pro Max. Xcode 27.0, XcodeGen, Swift, Node and npm were checked on 2026-09-11. The user has an Apple Developer account and a valid development certificate. Recheck actual signing/device availability when installing. Never copy private keys into the repository.

Project root: /Users/haichang/Projects/Pocket-Explorer-UI.
New skill: /Users/haichang/.codex/skills/codex-project/SKILL.md.
The unrelated gaokao-kg project is outside scope.

## Start or resume

Read AGENTS.md, TODO.md, PLAN.md and the relevant ACCEPTANCE.md sections. TODO owns execution state. Inspect actual files, changes and recorded evidence before trusting completion marks. Resume running processes or unfinished work from the current checkpoint.

Choose an actionable task whose dependencies are satisfied. If a task combines independent code work with an unavailable device or deployment check, split it into explicit subtasks while preserving its acceptance mapping. Do not remove required evidence to close a task.

Build, verify and inspect a usable increment. Update TODO immediately after meaningful milestones with commands, results, evidence paths and unmet conditions. Then continue. Do not automatically stop after the first task or spawn a CLI restart loop.

Record concise decisions and observations, not hidden reasoning. A new user correction amends the current objective unless the user explicitly cancels or replaces it. Answer side questions briefly and continue authorized work.

## Verification

Added or changed Swift code requires at least 80% line coverage. TypeScript requires at least 80% line and branch coverage, reported separately. Test core behavior with meaningful assertions and actual persistence/service adapters with integration tests.

Use XCUITest for app navigation and flows, Playwright for public-web flows. Inspect safe areas, larger text, touch targets and reduced motion. Preserve result bundles and screenshots. Do not infer visual approval from automated tests.

Actual iPhone microphone, speaker, camera and full-flow verification are required. Simulator results do not replace them. If physical speech, an unlock or a permission interaction requires the user, prepare the app first, ask for the specific action and continue other work.

Run appropriate tests once, then broaden or repeat only after changes, failures or unresolved concerns. Preserve user data and isolate test fixtures. Record unrelated existing issues without making them project scope.

## Permissions and delivery

The user authorized building this project and installing the requested prototype on their development device. Preserve the host's actual permission rules. Do not send messages to other people. Prepare a concrete reviewable result before any publication approval that remains necessary. Do not purchase services, change account permissions or publish to the App Store implicitly.

There is no requirement to commit, push or tag after every task. Do not modify global model settings or run legacy bypass scripts. Do not create background automations or delegate to subagents without existing authorization.

Before yielding or compaction, update TODO with exact current state, running process identifiers, test evidence, blockers and next actions. Mark DONE only with the task's completion evidence. Use REVIEW for human checks and BLOCKED for unavailable external prerequisites, while continuing independent tasks.

Finish only when all required acceptance criteria and the actual demo journey are verified. Report what changed, how to run it, what was tested and any remaining optional or blocked work. Never claim the project complete while real-device or cross-device requirements remain unverified.

## Release continuation

The user authorized TestFlight and Cloudflare publication at pocket.changhai.me. The Cloudflare Worker/D1 deployment is live. T14 replaces the former manual owner-key setup with automatic installation ownership. See docs/deployment.md and docs/evidence/cloudflare-live.json.

T13 implements a persisted first-launch language choice of device language, Simplified Chinese or English, a home change action, fixed exploration controls and a direct card-to-memory-to-sharing-preview path. All 38 checks have passing evidence, with 93.94% aggregate changed-file Swift coverage. The full regression's map scrolling test passed separately after using a short controlled drag, without an app source change. See docs/evidence/first-use-build3.json.

Version 0.1.0 (3) was uploaded through Xcode 27 RC (27A266a) Organizer. App Store Connect independently shows Testing in Hackathon Internal. The user can update through TestFlight. Next obtain first-use feedback. Apple blocks adding build 3 externally while build 2 remains in Beta App Review. CLI exportArchive returned an account-access error while the GUI succeeded. Do not ask the user to log in again without new evidence. Explicitly use /Users/haichang/Downloads/Xcode.app. The system default is still the old Xcode.

App Store Connect independently confirms build 2 Installed on Hai's iPhone 17 Pro Max, iOS 27. Build 3 first use, speech and camera await user feedback. The external group previously showed build 2 Waiting for Review. The user completed that submission, so do not request the contact telephone again. The public invitation is https://testflight.apple.com/join/83Jzf4WB, limited to three testers. Do not resend email invitations.

## T14 continuation

The user likes the usability changes but cannot test sharing because of the parent key. Follow PLAN T14: remove manual configuration, persist a random installation credential in Keychain and a scoped owner hash per share, preserve old links, verify and deploy Cloudflare plus TestFlight build 4. Do not ask the user for an owner key.

User clarification: remove parental restrictions entirely. Sharing is available directly to the explorer, without parental approval, a parent key or a parent mode. Keep the public preview, optional disclosure choices and background ownership protection against other users revoking a link.

Latest continuation: T14 is released as 0.1.0 (5), independently confirmed Testing in Hackathon Internal. Cloudflare is deployed and verified. All software checks passed. Next obtain phone sharing acceptance after the user updates, while preserving the other outstanding physical-device and human checks. Never reintroduce parental restrictions or ask for a sharing key. Preserve the existing external build 2 review. See docs/evidence/sharing-build5.json.

## T15 repository setup

The user authorized creating an iOS UI repository under Little-Pocket-Explorer and configuring GitHub builds to update TestFlight. Use the private Pocket-Explorer-UI repository. Complete repository setup and verify automated delivery before starting the planned larger changes. Current authorization covers committing and pushing the baseline, configuring CI credentials and running an actual release. Do not change product behavior or cancel the existing external review. Resume from TODO T15.

## Future AI integration

The user selected image deployment gpt-image-2.5-sunburst. PLAN T12 records its endpoint and the source of earlier test evidence. The image key exists only in ignored local ../Pocket-Explorer-Backend/.local/ai/providers.json. Reuse the existing gpt-6-astra / copilot-proxy / xhigh configuration from ~/.codex/config.toml for GPT-6. Credentials must be used server-side and never copied into the app, website, repository or logs. Finish T15 first. This provider selection does not implement live AI, and the prepared demonstration responses remain in place.

External status update: independent API and public-page checks on 2026-09-11 confirm build 2 is IN_BETA_TESTING and public enrollment is available. Earlier pending-review statements are historical. CI automatically updates the internal group, while the external group currently retains build 2. See TODO's external status refresh.

The user confirmed Cloudflare for the future AI backend. Follow PLAN's accepted direction: Workers API and server-side secrets, Queues for durable image generation, R2 image objects and D1 job/relationship state. Backend code should use the existing empty Pocket-Explorer-Backend repository when that implementation begins. Finish T15 before changing product behavior. The current deployment still handles sharing only.

T15 is complete: all three jobs in GitHub run 34571657181 succeeded and automatically released 0.1.0 (6). Independent Apple reads confirm VALID / IN_BETA_TESTING and Hackathon Internal membership. All 39 native, 18 web and six browser tests passed, with 93.35% native app line coverage. Future work follows the accepted Cloudflare direction in PLAN, but larger changes and AI integration have not begun. Physical-device and human acceptance remain separate open items. Evidence: docs/evidence/github-setup.json.


## T16: Backend extraction and automatic Cloudflare delivery

Current authorized task: T16 extracts the website and sharing API to ../Pocket-Explorer-Backend and https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend. Follow its PLAN/PROMPT/TODO for deployment setup. Preserve existing Cloudflare resources and domain. Finish a real GitHub-to-Cloudflare release and update native CI to test against deployed Cloudflare. The user authorized commits, pushes and workflow deployment for this setup. Live AI remains future work.


T16 is complete. Website/backend source lives in ../Pocket-Explorer-Backend, where main automatically deploys to Cloudflare after checks. UI CI directly verifies the production sharing API. All 39 native tests passed and automatically released 0.1.0 (7), with independent Apple state and group verification. See docs/evidence/backend-extraction.json. No extraction blocker remains. Future AI work and physical-device acceptance are separate.

## Ordinary Figma plugin route (2026-09-14)

The user authorized an ordinary development plugin using the official Plugin API instead of the quota-blocked MCP write route.
Importing and launching the plugin in the desktop app is authorized. Canvas operations remain API driven.
Reuse sync.js, hotspots.js, the 40 complete source images, and 189 hotspots.
A loopback-only companion serves this sync package and images and records verification using a fresh per-process credential.
Independently read each mutation batch before saving external manifest.json checkpoints. Stop on manual-edit conflicts.
The companion cannot execute arbitrary code. Account and model credentials are never included in the plugin.
Acceptance includes at least 80% changed-code coverage, actual Figma import, independent readback, reruns, and visual inspection.
Current status: native import, readback, unchanged rerun, export, and staging cleanup are complete. Design review continues.

Current amendment: Figma Beta contains 40 screens and 189 hotspots. All 39 JavaScript tests pass, and the native unchanged rerun made zero changes. The 81 hidden staging layers are removed with formal screen signatures unchanged. Actual clicking is verified. Native source-update/conflict checks and alignment of the observed share hotspot remain pending. See design/miro-sync/TODO.md.

# Roadshow product alignment

## Authority and scope

Accepted on 2026-09-15: the user makes the eight roadshow slides authoritative for conflicting product decisions and explicitly requests every described product feature in this iteration.
The slides are Jacky Zheng's eight PNG attachments in the [Teams conversation](https://teams.microsoft.com/l/chat/19:meeting_ZDkyOWY1NzEtM2EzOS00MjFkLTk5MjAtMTU3ZDQ2ZDlmYzRk@thread.v2/conversations), message 1789478395354.
The original images are preserved locally in /Users/haichang/tmp/review/pocket-teams-latest-20260915.
Miro remains the visual and interaction reference where compatible with the slides. Explicit user instructions remain highest priority.
This supersedes the earlier removal of parent controls, participation-only card awards, and deferral of real friends and chat.
The paid subscription and commercial partnership phases have a pending scope question. Product implementation continues independently of that answer.
Preserve iPhone as the main product, ten languages, prepared content, calm narration, public web viewing, private demo access, and existing user data.

## Source requirements

| Slide | Required behavior |
| --- | --- |
| The Problems | Respond to child-initiated curiosity and make abstract knowledge tangible. |
| Design Principles | Encourage observation, give warm feedback, reward curiosity, and make knowledge collectible. |
| Vision | Support outdoor exploration and a healthy relationship with AI. |
| AI Exploration Companion | Voice, text and camera input. Short age-appropriate replies. Interests, history and understanding inform explanations. Grouped conversations and optional follow-up questions. |
| Map & Discovery System | Personal discovery map, nearby events, institution-exclusive cards, location and challenge requirements, and discoverable shared cards. |
| Collectible Knowledge System | Delayed recall questions, correct-answer unlocks, generated cards, evolving versions, Common/Rare/Epic tiers, and collection history. |
| Social & Parent Controls | Friends, text chat, gifts, exchanges, map sharing, parent-managed social/sharing access and screen time, and location privacy. |
| Business Model | Core exploration, optional family capabilities and custom card styling, institution events, and a future partnership-led model. Commercial transactions await the scope answer. |

## Decisions and invariants

1. New discoveries begin as saved observations with a pending card. A correct recall answer unlocks the card. Wrong answers explain and allow another attempt without losing the observation.
2. Existing collected cards stay collected. Explicit new unlock metadata distinguishes pending cards from legacy records. No silent relocking or deletion.
3. Recall opportunities can appear after one day. An explicit practice action can start earlier. Notifications are opt-in, have quiet hours and never shame inactivity.
4. A card evolves through additional, distinct exploration and a correct recall challenge. Store immutable versions and the reason for each award. Repeating one answer cannot farm progression.
5. Common/Rare/Epic describe earned exploration milestones and event conditions, not biological rarity or invented scientific facts. No paid chance mechanics.
6. Parent settings have a protected session. Sharing, social access, map publishing and daily active-use limits are enforced in the client and at applicable service endpoints. A hidden button alone is insufficient.
7. Keep private photos and precise personal locations out of public snapshots. Public map discoveries use coarse locations. Published institutional event locations can be exact.
8. Use existing installation credentials for a persistent explorer profile with a nickname, age, interests and avatar. One explorer per installation is the first complete path. The slides do not require email/password sign-in or cross-device account linking.
9. Friendship requires a private code and acceptance. Messages and transfers require an accepted friendship and both families' permission. Block/report and revocation must work.
10. Gift a collectible copy while preserving the sender's original discovery. Exchanges require explicit acceptance and atomically grant both agreed copies. Clearly label received cards and their provenance.
11. Device coordinates are user-controlled inputs, not cryptographic proof of physical presence. Validate recency, accuracy, distance and event conditions. Never allow demo location overrides outside private demo mode.
12. Personal AI context is scoped to the same explorer. Shared knowledge caching is used only when the answer is valid for the age, language and learning context. Personalized replies never enter the shared cache.
13. Do not invent partnerships. Initial fictional events are visibly labeled demonstration events. The organizer can publish real events through Studio with their own content.
14. Persist work before network calls. Retries are idempotent. Offline observations and cached reading remain available within parent settings. Social writes require the service.

## Architecture

Native domain and persistence: additive journal fields, FamilyStore, collectible progression, conversations, event visits, and social receipts.
Native interfaces: protected family settings, child profile, quiz/reveal, card versions and style, map event sheets, friends/chat/transfers, and notification opt-in.
Cloudflare: additive D1 family/profile, parent-session, collectible/version, event/claim, friendship/message/transfer and report tables.
Keep credentials in Keychain or server secrets. Parent PIN verifiers are salted and stretched. Sessions expire and attempts are limited. Never log PINs or recovery credentials.
The existing owner authorization identifies installations. Parent authorization is separate and required for policy mutation and recovery.
R2 holds shared illustrations. Reuse supplied Marketing assets and immutable content packages.
Studio adds event authoring and complete prepared content. The public website renders permitted shared cards, memories and event links without requiring installation.
Do not expose private demo content through public event or social routes.

## Execution tasks

| ID | Goal, files and dependencies | Failure behavior and completion evidence |
| --- | --- | --- |
| P30 | Record slide authority in AGENTS, PLAN, PROMPT and TODO in both repos. Add this plan and a Chinese review copy. | Read back all records and remove contradictory active instructions. Historical evidence remains historical. |
| P31 | Add family/profile contracts, D1 migration, parent sessions, policy and usage endpoints in worker/family-*.ts. | Test unauthorized changes, brute-force limits, independent readback, persistence, session expiry, offline-facing errors and migration on existing data. |
| P32 | Add native FamilyStore, profile, protected settings and active-time enforcement. Depends on P31. | Test language/age preferences, PIN setup/recovery, backgrounding, clock changes, relaunch, disabled features and large text. Parent settings remain reachable at the time limit. |
| P33 | Add pending/correct-answer unlocks, server collectible verification, versions, rarity and card styling. Update TripStore, cards, reminders and worker/collectible-*.ts. | Reproduce current immediate unlock. Test wrong/correct/retry, duplicate requests, legacy migration, immutable history, evolution without farming, and no sharing of pending cards. |
| P34 | Add grouped conversations and bounded profile/history/mastery context to AI contracts, provider and native exploration. Depends on P31/P33. | Test actual follow-ups, age/level differences, same-explorer history, isolation, cache bypass for personalized replies, prepared fast path and real provider output. |
| P35 | Add organizer events, nearby browsing, location/challenge eligibility, event links and map deposits using event backgrounds. Depends on P31/P33. | Test distance boundaries, stale/poor accuracy, event windows, language, withdrawal, duplicate claims, private demo isolation, public map privacy and actual map interactions. |
| P36 | Add accepted friendships, text chat, card gifts/exchanges, shared collections, block/report and parent enforcement. Depends on P31/P33. | Use fictional test profiles only. Test ownership, permissions on both sides, revocation, duplicate sends, atomic exchanges, reconnect, private images and current-profile isolation. |
| P37 | Prepare the six supplied card illustrations as complete multilingual content, integrate backgrounds and style options, and support organizer event content. | Verify exact original art, text and narration, all supported language catalogs, stable demo priority and discoverability through the new flows. |
| P38 | Complete public event/card web views and Studio operations, preserve legacy share links and explain unavailable/revoked content. Depends on P35/P36. | Browser checks in Chromium/WebKit at phone and desktop sizes, independent privacy reads, no client service keys and no accidental indexing. |
| P39 | Test and review each increment, run complete acceptance, update release notes, deploy Backend via workflow and publish iOS locally. | At least 80% changed-code coverage, real SQLite/D1/R2 integration, simulator interaction screenshots, source-matched IPA and independent TestFlight/deployment readback. Physical-device-only checks remain explicitly outstanding when not executable here. |

## Validation and release

Use isolated native simulators and test service ports. Never replace artifacts under running tests.
Use actual Cloudflare-compatible storage for boundary and race checks, and mocked providers for deterministic errors. Then run bounded real-provider checks.
Test flows for correct and incorrect recall, revoked family permissions, timer expiration, location denial, event completion, card evolution, friend acceptance, chat and transfers.
Review all new copy in ten languages and inspect Chinese, English, Arabic and large-text layouts.
Keep old shares working unless their owner or parent explicitly disables sharing.
Commit native changes with [skip ci]. Upload TestFlight only from this Mac using Xcode 27 RC.
Deploy Backend runtime changes through its existing GitHub workflow. Native quota restrictions do not change Backend delivery.
Do not send invitations or messages to actual colleagues during verification. Test with fictional owned installations.
Do not claim every PPT feature is complete until the matrix above has implementation and verification evidence.

## Current checkpoint

P30 is complete. P31 through P36 are implemented with focused D1/R2 and simulator verification.
Five actual model responses provide bounded evidence for age adaptation, valid evolution and rejection of unrelated progress.
P37 has six published Marketing topics, 60 ten-language packages, 60 real narration files and six uncropped original-art derivatives. All package and asset bodies were independently verified in production.
All 60 Vectorize records were read back and checked for package ID, language, version and 1024 dimensions. A paraphrased prism question reused the prepared content in 4.951 seconds. Another installation repeated it in 0.152 seconds with the identical answer. These are individual observations, not latency guarantees.
P38 public event/card pages and both Studio paths pass Chromium and WebKit checks, including actual D1/R2 publication and withdrawal.
Backend aafd4fe was deployed through successful workflow 34998228931. Independent reads confirm deployment 01769e05-bb01-4277-8cc8-63fc92d3a4b0 and migrations 0009 through 0012.
Production acceptance passes 81 independent requests. Temporary public shares, events, map deposits and friendships were withdrawn. Fictional private profiles remain for traceability.
P39 implementation, qualification and release are complete. The integrated profile uses Litian's 906e743 artwork and actual family details, with corrected legacy trip-place metrics. Latest per-test qualification results are 248 passes, four explicitly gated skips and no unresolved failure across full and targeted runs. All 40 changed Swift files pass matching-hash coverage, minimum 89.28% and aggregate 96.24%. Final Chinese, demo and social screenshots are reviewed.
Native source d8d4114 was published locally as TestFlight 0.1.0 (18). Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal. IPA signature, tested source and ten 542-entry catalogs are verified. External distribution is not verified. Test/release sessions, owned fixtures, simulated location and the temporary signing keychain are cleared.
The physical iPhone is disconnected. Physical microphone, camera, headphones, interruptions, listening quality and human visual acceptance remain separate. Commercial billing is disabled.

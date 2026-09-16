# Jacky's demo journey and everyday navigation

## Outcome

The user reports that browsing forces repeated backtracking to the home screen. Jacky's demo flow is the highest priority. Deliver a continuous journey with visible global destinations, contextual next actions, and preserved work. Proceed independently without waiting for teammate assignments.

Native baseline: a64576a, with runtime d8d4114 shipped as TestFlight 0.1.0 (18). Backend runtime aafd4fe already provides friends, messages, collections, exchanges, events and map publication. Remote main was independently checked on 2026-09-16. Primary-checkout drafts remain untouched.

Source: [Jacky's message](https://teams.microsoft.com/l/message/19:meeting_ZDkyOWY1NzEtM2EzOS00MjFkLTk5MjAtMTU3ZDQ2ZDlmYzRk@thread.v2/1789485530090), created 2026-09-15 15:18:50 UTC and edited 15:48:21 UTC. Miro remains the visual reference. The eight roadshow slides retain product authority where no newer user decision supersedes them.

## Observed problems

These baseline findings were recorded before implementation, using source inspection and the user's physical-device report. Final behavior and verification evidence are recorded in [the review](../reviews/jacky-navigation.md).

- RootView owns a private tab selection. Feature screens cannot intentionally continue in another destination.
- Exploration, nearby events, event details, friend cards and exchanges open independent sheets and NavigationStacks. These cover the global tab bar and create multiple exit layers.
- NewCardView emphasizes making a memory, while Jacky's next action is map publication.
- MapSharingView shows publication success without a direct transition to its map context.
- EventDetailView only exposes the system share sheet. FriendDetailView contains messages, cards and gifts, without a profile and recent-discovery landing page.
- DiscoveryRemindersView opens a standalone quiz. No system notification scheduling or callback implementation was found in the native source. Earlier broad delivery wording must not imply that this behavior was implemented.

## Target journey

1. Explore with AI and keep the discovery.
2. Complete the existing correct-answer unlock when required, then inspect the card.
3. Publish the permitted card to the map and continue directly to nearby discoveries.
4. Open an event and choose an accepted friend to share it with.
5. Continue directly to that friend's conversation, then profile and recent card.
6. Select a card to offer in exchange and send the request. Show its real pending/accepted state, never simulate peer consent.
7. A due recall reminder opens the associated exploration context and question in Chat.

The script's initial card acquisition and final quiz are distinct moments. Preserve the existing correct-answer unlock. A final reminder can revisit an older discovery. Do not quietly change the unlock rule or interrupt the presentation to ask about product policy.

## Navigation rules

- Keep the current four global destinations for this increment. Normal exploration, cards, maps and friend browsing belong in the app's navigation, not nested sheets.
- One tap switches a global destination. Preserve the previous destination's browsing state.
- A visible Home action returns directly to Chat's root from content detail. Back returns one contextual step. Closing a short form returns to its source.
- A contextual action routes to its named destination and selected object. It must not require manually finding the object again from a home screen.
- Reserve sheets for short editing, permissions and system camera/share interfaces. Avoid stacking feature sheets.
- Keep generated answers, image jobs and submitted transfers outside disposable view state. Preserve unsent text and observation drafts. Stop microphone and narration when leaving their screen.
- Show one clear next action after success. Failures retain the current content and retry context. Navigation must not imply that a pending write has succeeded.
- Maintain ten languages, RTL, large text, VoiceOver, Reduce Motion, original artwork and existing privacy controls.

## Minimal service changes

Reuse existing social messages to send the canonical public event link. Render only validated event URLs from the configured service as in-app event previews, and re-read the event before opening it. Preserve text compatibility and persistent retry IDs. Never open arbitrary message URLs as trusted internal routes.

Build the friend's recent discoveries from the permitted collection's actual createdAt and latest version awardedAt values. A style-only updatedAt change must not appear as a new discovery. Existing received-card provenance distinguishes gifts/exchanges. Show no invented presence, statistics, activity or exact location. Use the existing bilateral exchange APIs and permissions. Add backend work only if a verified contract gap prevents this journey.

Normal recall reminders are off by default and based on verified, non-demo history. Unlocked cards become eligible for review after seven days. Review updates its date without awarding another collectible. Schedule at most three reminders within the next eight days, at 17:00 local time with no more than one per day. Foreground notifications stay silent. Pending observations remain accessible in the in-app reminder list. They return to the matching exploration and never interrupt recording, answer playback or a transaction. Authorized demo guidance may offer a manual preview of an eligible reminder. It must be labeled and remain within private demo access.

## Work and dependencies

### P40: Navigation foundation

Dependencies: none. Files: App/RootView.swift, App/PocketExplorerApp.swift, a small App navigation model, and navigation tests.

Centralize cross-destination actions and Home behavior. Preserve independent browsing state, repeated-tap safety and draft recovery. Reproduce the existing hidden-tab/backtracking paths before changing them. Completion requires visible, tappable global navigation and one-action Home from the deepest supported content path.

### P41: Exploration, card and map continuation

Dependencies: P40. Files: Explore/ChatHomeView.swift, Explore/ExploreView.swift, Cards/NewCardView.swift, Cards/CardViews.swift, Events/MapSharingView.swift, Events/NearbyDiscoveryView.swift and Events/EventDetailView.swift.

Move ordinary feature browsing into the navigation shell. Add contextual map and event continuation, retain location/privacy constraints, and keep memory creation available. Verify image generation survives navigation, speech stops, draft text survives, and map publication is independently readable before presenting success.

### P42: Event sharing, friend profile and exchange

Dependencies: P40, event entry from P41. Files: Social/FriendsView.swift, Social/GiftComposerView.swift, Social/SocialModels.swift, Social/SocialStore.swift and focused new social views/models as needed.

Use real accepted friends and existing APIs. Add an event recipient picker, conversation continuation, recent-card profile and direct exchange entry. Preserve typed drafts when sharing an event. Offline retries reuse the same request ID. Verify recipient readback, blocked/revoked access, event withdrawal, declined exchanges and real receipt recovery.

### P43: Recall returns to Chat

Dependencies: P40. Files: Memories/DiscoveryRemindersView.swift, exploration context, a testable reminder adapter and routing tests.

Add due-reminder routing into the original question context and safe notification handling. Preserve pending unlocks and already-owned cards. Verify permission denial, deleted/unavailable content, foreground handling, cold/warm launch and private-demo separation. Physical notification behavior remains a device acceptance item.

### P44: Integrated usability qualification and release

Dependencies: P41, P42, P43. Files: native unit/UI tests, localization catalogs and docs/evidence.

Record the full Jacky route, then exercise everyday detours and recovery. Verify changed Swift files meet 80% line coverage. Test English, Chinese and Arabic, maximum text and Reduce Motion. Self-review each increment. Publish from this Mac only after qualification, with [skip ci]. Independently verify TestFlight processing and group availability. Backend publishes through its existing workflow only if backend code changes.

### P45: App identity

The user added a logo redesign during navigation qualification. Replace the unrelated duck app icon with a mark that represents the current exploration and knowledge-card experience. Preserve the warm cream and forest-green palette. Generate and compare pocket-world and discovery-card concepts, inspect small sizes, then use the selected opaque square master in the iOS icon catalog and the matching mark in the home header and language welcome. Keep independent PNG dimensions and opacity checks, native asset compilation and welcome/home screenshots. Selection and technical verification do not constitute human visual approval.

## Acceptance

- No deliberate visit to Home is required between adjacent steps in Jacky's script.
- Global destination switching and explicit Home work from nested content without repeated dismissal.
- Returning to Chat, Map or Friends retains the selected question, map region or friend context unless Home was explicitly chosen.
- Unsent exploration and friend text survive a navigation detour. An in-flight write never creates duplicates or reports a false success.
- Friend profile activity, shared event messages and exchanges use real permitted service records.
- A reminder identifies its original question and opens that context with no surprise autoplay.
- No legacy cards, language settings, protected permissions, public links or private demo isolation regress.
- Automated evidence and physical/human acceptance remain separately reported. Passing feature tests does not establish usable navigation by itself.

## Collaboration and handoff

The assistant owns the navigation shell, real-service integration, tests and local release. Jacky's ordered script and Miro annotations supply acceptance references. No teammate assignment, message or availability is assumed. Read remote changes before integration and preserve incoming work. Keep each increment reviewable through a short recording, concrete findings and updated TODO.

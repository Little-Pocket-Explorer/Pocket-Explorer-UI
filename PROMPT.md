# Pocket Explorer: Continuation Brief

## Azure narration integration (2026-09-15)

- DONE S1: the existing hai managed identity serves the dedicated Azure adapter. Speech S0 keeps local authentication disabled and uses a resource-scoped Speech User grant. The user approved Xiaoxiao gentle Chinese and Emma Dragon HD English. All ten language routes produced non-silent audio. The other eight voices still need human listening review.
- DONE S2: backend source 9004928 is deployed through workflow 34924912737 as Worker d6580f71-d1ca-4d7c-89ab-9a297de9aaf9 at 100%. Production synthesis, byte-identical cache replay and ownership checks passed. No Azure keys were retrieved, and service credentials stay on servers. Existing 120/18 safeguards are unchanged.
- DONE S3: final native runtime passed 108 unit tests and three narration UI tests. Changed executable-line coverage is 101/104 (97.12%), with each file above 80%. A further playback test passed and its settled screenshot was inspected. Cache expiry, corruption recovery, stop, timeout fallback and stale-response cancellation are verified.
- DONE S4: TestFlight 0.1.0 (14) was published from this Mac using source 65b3084af1e70b30b1a53fdc6685a015d64e960e. Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal membership. IPA, signing, source fingerprint, ten 322-entry catalogs and temporary-keychain removal are verified. Native commits use [skip ci], and no GitHub iOS run was started.
- REVIEW S5: physical iPhone playback, microphone, interruptions and the remaining voices' listening quality are unverified. Prepared daily recommendation audio and Vectorize knowledge reuse remain separate, unfinished work.

Evidence: docs/evidence/azure-narration.json and ~/tmp/review/pocket-release-speech-14. Native tests and uploads have ended. This iteration's fixtures on ports 4213 and 4215 were stopped and independently checked. Keep the expired heartbeat paused.

Work is isolated in ~/Worktrees/Pocket-Explorer-Backend-speech and ~/Worktrees/Pocket-Explorer-UI-speech. Preserve the primary checkouts' unpublished cache/content and design drafts. Earlier build checkpoints below are historical, and this section governs current narration delivery.

## Current objective

The user-authorized eight-hour refinement window ended at 2026-09-15 08:39:34 Australia/Sydney. Released build 13 includes improvements to UI transitions, narration pacing and slow-illustration feedback. When the user continues the project, resume from the current delivery and unresolved work. Every meaningful future version still needs tests, actual UI inspection, written critique and independent verification. Do not repeat unchanged tests, provider calls or near-identical uploads.

Read [TODO.md](TODO.md) first for the live checkpoint, then [PLAN.md](PLAN.md) and applicable AGENTS.md. Earlier checkpoints are in docs/history/20260915-pre-final-*.md. They are historical evidence, not current execution instructions.

## Settled decisions

- Primary app: /Users/haichang/Projects/Pocket-Explorer-UI.
- Backend/public website: /Users/haichang/Projects/Pocket-Explorer-Backend.
- Design authority: https://miro.com/app/board/uXjVHn9F6EQ=/.
- Preserve cream paper, forest green, illustrations, journals, real AI, private map, memories and public links.
- Preserve explicit language selection, ten delivered languages and original content-language metadata. Global ambition does not mean every language is already implemented.
- Do not restore parental restrictions. Accounts and friend chat are deferred.
- Keep API keys server-side. Preserve configured 120/18 safeguards. No purchases, pricing investigations or teammate messages.
- Keep preexisting untracked design/miro-sync work untouched.
- Do not spawn ordinary agents. The user permits a bounded read-only Opus 5 review via cl -p. Its findings need independent validation.

## Current delivery

TestFlight 0.1.0 (14) is independently verified VALID / IN_BETA_TESTING in Hackathon Internal. Source commit: 65b3084af1e70b30b1a53fdc6685a015d64e960e. Evidence: docs/evidence/azure-narration.json. External group availability has not been confirmed. Backend runtime 9004928 is deployed through workflow 34924912737.

Released build 13 fixes pending share creation and revocation across sheet reentry, preserves the exact public snapshot, adapts published controls for accessibility text sizes, and uses neutral keepsake art for terminal illustration failure. Ten UI catalogs have 322 entries.

The following regression belongs to build 13. An earlier complete regression passed 150 tests with no failures and two explicit skips. It predates final revocation, accessibility layout and keepsake changes. Final complete regression passed 154 tests with no failures and two explicit skips. Three independent iOS 27 sharing checks passed. Changed executable-line coverage is 133/133, each file at 100%. Actual screenshots, manual critique and source-freeze verification are complete. Apple, IPA, signing, ten catalogs and temporary-keychain cleanup were independently verified. Evidence, physical-device acceptance guidance and document pushes are complete. Next work is physical acceptance and the reproduced lost-response correction, following TODO.

## Execution rules

Use the codex-project skill and maintain PLAN/PROMPT/TODO with concise current facts. Chinese review counterparts live in ~/tmp/review/pocket-explorer-*.zh.md and stay out of Git. Apply Chinese review changes first, then synchronize formal English.

1. Read the actual workspace and active process state before changing anything.
2. Wait for ongoing tests to finish before changing their source or build artifacts.
3. Investigate failures using logs, actual screenshots and precise geometry. A hittable control may still have clipped text.
4. Require at least 80% changed Swift executable-line coverage per file. TypeScript needs 80% line and branch coverage per changed file.
5. Use independent simulators, DerivedData and mutable HTTP fixtures for parallel runs.
6. Reuse completed provider evidence. Do not silently substitute fixtures for real AI claims.
7. Preserve the physical iPhone TestFlight installation. Do not install a UI-test fixture on it.
8. Record remaining human/device checks explicitly. Do not mark them complete using simulator evidence.

## Local publication

Native commits must include [skip ci]. The user prohibits GitHub iOS builds because quota is exhausted. Backend changes retain the existing Cloudflare workflow.

Use Xcode /Applications/Xcode-27-RC.app with build 27A266a and the existing local release scripts. Invoke /opt/homebrew/bin/python3 with /opt/homebrew/opt/ruby/bin and /opt/homebrew/bin first in PATH so the installed Bundler 4.0.16 is selected. Archive/upload only after final-source tests, coverage, screenshots and critique are complete. Keep ios, shared, scripts and HEAD frozen during publication.

Build 14 is already published. Artifacts are in ~/tmp/review/pocket-release-speech-14. Do not upload it again. Only use scripts/release/local-testflight.py with a new output directory after a meaningful future application change and its verification.

apple-readback.json and ipa-readback.json preserve the independent release-time evidence. Later documentation commits are not the published IPA source. Do not rerun the previous verification script unchanged after a documentation commit because it requires HEAD to match the release commit.

## Completion and limitations

Physical microphone, camera, premium narration, VoiceOver and Safari remain open. Azure routes rendered non-silent audio in ten languages, including the approved Xiaoxiao gentle and Emma HD samples. The other eight voices and all physical-device playback remain unverified by a human. Installed system voices are the offline fallback, and their quality varies.

The five-minute heartbeat pocket-explorer-5 was paused through the automation tool after the deadline and independently read back. No tests, uploads or automatic continuation remain active. Preserve this evidence and continue according to the user’s next instructions.

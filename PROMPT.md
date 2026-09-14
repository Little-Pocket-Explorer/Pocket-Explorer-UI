# Pocket Explorer: Continuation Brief

## Current objective

Continue the user-authorized refinement through 2026-09-15 08:39:34 Australia/Sydney. Improve rough UI transitions, stiff narration and slow illustration feedback. Every meaningful version needs tests, actual UI inspection, written critique and independent delivery verification. Do not stop at an intermediate build. Do not manufacture activity through unchanged tests, extra provider calls or near-identical uploads.

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

TestFlight 0.1.0 (13) is independently verified VALID / IN_BETA_TESTING in Hackathon Internal. Source commit: 339ff9e5832fb4cc8fa24cde30aa2f72a811e581. Evidence: docs/evidence/sharing-reentry.json. External group availability has not been confirmed. Backend runtime 5dac559 is independently deployed, with deployment evidence at 08b7558.

Released build 13 fixes pending share creation and revocation across sheet reentry, preserves the exact public snapshot, adapts published controls for accessibility text sizes, and uses neutral keepsake art for terminal illustration failure. Ten UI catalogs have 322 entries.

An earlier complete regression passed 150 tests with no failures and two explicit skips. It predates final revocation, accessibility layout and keepsake changes. Final complete regression passed 154 tests with no failures and two explicit skips. Three independent iOS 27 sharing checks passed. Changed executable-line coverage is 133/133, each file at 100%. Actual screenshots, manual critique and source-freeze verification are complete. Apple, IPA, signing, ten catalogs and temporary-keychain cleanup were independently verified. Next finalize the evidence and physical-device acceptance guidance, following TODO.

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

Use Xcode /Applications/Xcode-27-RC.app with build 27A266a and the existing local release scripts. Archive/upload only after final-source tests, coverage, screenshots and critique are complete. Keep ios, shared, scripts and HEAD frozen during publication.

Build 13 is already published. Artifacts are in ~/tmp/review/pocket-release-polish-13. Do not upload it again. Only use scripts/release/local-testflight.py with a new output directory after a meaningful future application change and its verification.

apple-readback.json and ipa-readback.json preserve the independent release-time evidence. Later documentation commits are not the published IPA source. Do not rerun the previous verification script unchanged after a documentation commit because it requires HEAD to match the release commit.

## Completion and limitations

Physical microphone, camera, premium narration, VoiceOver and Safari remain open. Available simulator voices rendered non-silent audio in ten languages, but Arabic used a male voice and French a Canadian French voice. Do not describe every locale as natural female narration. Cloud TTS was unavailable.

The current five-minute heartbeat is pocket-explorer-5. Reuse it, do not create another. At the agreed deadline, record the final delivered versions and unresolved checks, pause the heartbeat through the automation tool, and give a concise Chinese report. Use the remaining time for useful independent work while tests or Apple processing run.

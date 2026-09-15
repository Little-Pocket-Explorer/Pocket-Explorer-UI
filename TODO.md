# Pocket Explorer: Current Execution State

## Azure narration integration (2026-09-15)

Use the user-approved existing hai managed identity. Speech S0 has local authentication disabled. Resource-scoped Speech User and the attached hai identity are independently verified. Reuse the existing immutable proxy image in a dedicated Container App with minReplicas=0 and maxReplicas=1. Keep credentials on servers.

- DONE S1: dedicated adapter deployed and ten languages synthesized. User selected Xiaoxiao gentle Chinese and Emma Dragon HD English.
- DONE S2: backend source 9004928 deployed through workflow 34924912737. Production synthesis, cache replay, owner checks and cleanup passed. Existing 120/18 safeguards are unchanged.
- DONE S3: final runtime source passed 108 unit tests and three narration UI tests. Changed executable-line coverage is 101/104 (97.12%), with each file above 80%. Decoder validation, cancellation, fallback and the 44-point Listen control are verified. The settled playback screenshot was inspected, and the playback UI test passed again after waiting for its label transition.
- IN_PROGRESS S4: commit with [skip ci], publish locally and independently read Apple and the IPA. Final visual and source evidence are saved. Physical iPhone acceptance remains open.

Work is isolated in ~/Worktrees/Pocket-Explorer-Backend-speech and ~/Worktrees/Pocket-Explorer-UI-speech on codex/azure-speech. Preserve the primary checkouts' unfinished cache and design drafts. Prepared recommendation audio will be implemented alongside the separate prepared-content work. Do not restart expired automation.

Updated 2026-09-15. The eight-hour refinement window ended at 08:39:34 AEST. Build 13 is released and the five-minute checkpoint is paused.

## Delivery

| Deliverable | Verified state | Evidence |
| --- | --- | --- |
| TestFlight 0.1.0 (13) | VALID / IN_BETA_TESTING, Hackathon Internal, published from this Mac | docs/evidence/sharing-reentry.json and ~/tmp/review/pocket-release-polish-13 |
| Cloudflare API and public viewer | Runtime 5dac559 deployed as Worker 44482a6c-a85a-488e-9acf-c8e763d11992, workflow 34894033434 succeeded | Sibling docs/evidence/png-integrity.json |

Published application source is 339ff9e5832fb4cc8fa24cde30aa2f72a811e581, pushed to main. Later documentation evidence commits are not the IPA source. Changed-line coverage uses base d7cdec643b4eea6a6b57d1fe34d05da975fd96f1. Preserve untracked design/miro-sync.

## Active work

| ID | State | Next action |
| --- | --- | --- |
| T21.3 sharing | DONE | Creation, revocation and exact snapshots survive page reentry, released in build 13 |
| T20.3 accessibility | REVIEW | 375pt and iOS 27 sharing checks passed and shipped. Human and physical acceptance remain open |
| T21.1 terminal illustration | DONE | Neutral keepsake and readable words remain on terminal failure, released |
| T21.4 publication | DONE | [skip ci] commit/push, local upload and independent Apple/IPA reads complete |
| T20.2 / T21.2 physical speech | REVIEW | Physical naturalness and recording remain unverified |
| Physical camera, VoiceOver and Safari | REVIEW | Post-release device read still shows disconnection. Preserve TestFlight installation |
| Final checkpoint | DONE | Evidence, Chinese copies and guides synchronized, checked and pushed. Checkpoint paused after the deadline with independent readback |
| Accounts, friends and chat | DEFERRED | Explicitly outside this iteration |

## Final verification and release

- Final complete native-final-13.xcresult: 154 passed, zero failed, two skipped. This includes 98 unit and 56 UI passes. Results are in ~/tmp/review/pocket-polish-20260915.
- native-sharing-ios27-13.xcresult: all three checks passed using an independent simulator, DerivedData and fixture 4205.
- native-final-13-coverage.json: 133/133 changed executable lines, all three files at 100%. native-final-13-source.json confirms source stayed unchanged during regression.
- Final screenshots and native-final-13-visual-review.jpg were inspected. Production sharing creation, independent reads and revocation passed. Live AI was not repeated. Simulator microphone was explicitly skipped for a failure also present on the released baseline.
- The read-only Opus 5 sharing review returned error_max_budget_usd with no usable conclusion. It is not counted as passed and will not be repeated. Manual code and test-design critique are complete.
- Formal evidence is docs/evidence/sharing-reentry.json. Review is docs/reviews/sharing-reentry-20260915.md.
- Apple build ID is 3a1b86da-7476-40d8-b992-348ae7c33c79. Only internal testing was confirmed, not external group availability.
- IPA SHA256 is 47e4fa3a37927a28ce4c2149513a2b3627104db1f170798121c288c766212b4e. Independent reads verified signing, get-task-allow:false, ten 322-entry catalogs, unchanged application source and temporary signing-keychain removal.
- Tests and upload processes have ended. No GitHub iOS runner was started. This session’s fixtures 4199, 4203 and 4205 were stopped, with independent port checks. Older 4197/4201 and independent design previews remain running.

## Reproductions and review scope

- Sharing creation reentry baseline failed four assertions, created two POSTs/links and left one after revocation. Another baseline reproduced loss of the selected first name.
- Revocation reentry baseline failed three assertions, with enabled actions and a stale URL after completion. Delayed HTTP, failure and retry checks passed after correction.
- Earlier 150-test complete regression, 46/46 coverage and worktree 77/77 coverage predate the final source. They do not replace final 154-test and 133/133 results.
- Maximum French text was clipped despite hittable controls. share-footer-audit-before.xcresult reproduced the targeted textClipped failure. Final screenshots and focused audit passed.
- The audit covers revoke-share and share-message, not a claim that the entire screen has no accessibility findings. It can move the viewport, so the test repositions controls afterwards.
- Node syntax, shellcheck and git diff --check passed. Documentation state updates require document and evidence checks without repeating application regression.

## Remaining acceptance and next priorities

1. Follow [the five-minute iPhone check](docs/device-check.md) for recording, natural speech, camera, Safari, large text and language switching. Post-release device read still reports tunnelState disconnected and ddiServicesAvailable false.
2. After physical voice acceptance, evaluate available high-quality multilingual voices. System resources vary by installation, cloud TTS is unavailable, and natural female narration in every language is not established.
3. Add durable sharing idempotency and recovery in the next iteration. Current continuity covers page navigation. A local Worker and D1 response-loss reproduction created a second link while leaving the first active. Evidence is docs/evidence/sharing-lost-response.json, with the correction contract in capabilities and remaining work.
4. Later product extensions remain in [capabilities and remaining work](docs/next-iteration.md). Do not add deferred accounts/social features merely to fill time.

Provider duration remains variable. Preserve existing 120/18 safeguards. No new live AI question or image generation was required for this sharing increment. Public-sharing tests used fictional data, independent reads and revocation.

## History and handoff

Earlier T00 through T21 work, releases and checkpoints are retained in [the execution archive](docs/history/20260915-pre-final-TODO.md). Preserve the product criteria in [ACCEPTANCE.md](ACCEPTANCE.md). Simulator checks do not replace human visual approval or physical-device acceptance.

The five-minute heartbeat pocket-explorer-5 was paused at 08:39:56 AEST and independently read back as PAUSED. No tests or uploads remain active. UI documentation evidence commit 72b3392 and Backend guide commit 83db0fb were independently confirmed on remote main. This final checkpoint-state commit does not change the published application source.

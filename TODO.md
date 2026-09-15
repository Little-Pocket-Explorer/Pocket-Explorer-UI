# Pocket Explorer: Current Execution State

## Azure narration integration (2026-09-15)

- DONE S1: the existing hai managed identity serves the dedicated Azure adapter. Speech S0 keeps local authentication disabled and uses a resource-scoped Speech User grant. The user approved Xiaoxiao gentle Chinese and Emma Dragon HD English. All ten language routes produced non-silent audio. The other eight voices still need human listening review.
- DONE S2: backend source 9004928 is deployed through workflow 34924912737 as Worker d6580f71-d1ca-4d7c-89ab-9a297de9aaf9 at 100%. Production synthesis, byte-identical cache replay and ownership checks passed. No Azure keys were retrieved, and service credentials stay on servers. Existing 120/18 safeguards are unchanged.
- DONE S3: final native runtime passed 108 unit tests and three narration UI tests. Changed executable-line coverage is 101/104 (97.12%), with each file above 80%. A further playback test passed and its settled screenshot was inspected. Cache expiry, corruption recovery, stop, timeout fallback and stale-response cancellation are verified.
- DONE S4: TestFlight 0.1.0 (14) was published from this Mac using source 65b3084af1e70b30b1a53fdc6685a015d64e960e. Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal membership. IPA, signing, source fingerprint, ten 322-entry catalogs and temporary-keychain removal are verified. Native commits use [skip ci], and no GitHub iOS run was started.
- REVIEW S5: physical iPhone playback, microphone, interruptions and the remaining voices' listening quality are unverified. Prepared daily recommendation audio and Vectorize knowledge reuse remain separate, unfinished work.

Evidence: docs/evidence/azure-narration.json and ~/tmp/review/pocket-release-speech-14. Native tests and uploads have ended. This iteration's fixtures on ports 4213 and 4215 were stopped and independently checked. Keep the expired heartbeat paused.

Work is isolated in ~/Worktrees/Pocket-Explorer-Backend-speech and ~/Worktrees/Pocket-Explorer-UI-speech. Preserve the primary checkouts' unpublished cache/content and design drafts. Earlier build checkpoints below are historical, and this section governs current narration delivery.

## Delivery

| Deliverable | Verified state | Evidence |
| --- | --- | --- |
| TestFlight 0.1.0 (14) | VALID / IN_BETA_TESTING, Hackathon Internal, published from this Mac | docs/evidence/azure-narration.json and ~/tmp/review/pocket-release-speech-14 |
| Cloudflare API and public viewer | Runtime 9004928 deployed as Worker d6580f71-d1ca-4d7c-89ab-9a297de9aaf9, workflow 34924912737 succeeded | Sibling docs/evidence/azure-narration.json |

Published narration application source is 65b3084af1e70b30b1a53fdc6685a015d64e960e, pushed to main. Build 13 used 339ff9e5832fb4cc8fa24cde30aa2f72a811e581. Later documentation evidence commits are not the IPA source. Build 13 coverage uses base d7cdec643b4eea6a6b57d1fe34d05da975fd96f1. Build 14 uses 0f326e0. Preserve untracked design/miro-sync.

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

## Earlier build 13 verification and release

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
2. Accept the newly delivered cloud voices on iPhone. Xiaoxiao gentle and Emma HD samples are approved. Eight additional language routes were service-tested, but their listening quality is not established. Prepared daily audio and Vectorize knowledge reuse remain unfinished.
3. Add durable sharing idempotency and recovery in the next iteration. Current continuity covers page navigation. A local Worker and D1 response-loss reproduction created a second link while leaving the first active. Evidence is docs/evidence/sharing-lost-response.json, with the correction contract in capabilities and remaining work.
4. Later product extensions remain in [capabilities and remaining work](docs/next-iteration.md). Do not add deferred accounts/social features merely to fill time.

Provider duration remains variable. Preserve existing 120/18 safeguards. No new live AI question or image generation was required for this sharing increment. Public-sharing tests used fictional data, independent reads and revocation.

## History and handoff

Earlier T00 through T21 work, releases and checkpoints are retained in [the execution archive](docs/history/20260915-pre-final-TODO.md). Preserve the product criteria in [ACCEPTANCE.md](ACCEPTANCE.md). Simulator checks do not replace human visual approval or physical-device acceptance.

The five-minute heartbeat pocket-explorer-5 was paused at 08:39:56 AEST and independently read back as PAUSED. No tests or uploads remain active. UI documentation evidence commit 72b3392 and Backend guide commit 83db0fb were independently confirmed on remote main. This final checkpoint-state commit does not change the published application source.

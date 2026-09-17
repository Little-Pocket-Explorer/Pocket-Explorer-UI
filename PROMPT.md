# Pocket Explorer: Continuation Brief

## Complete: teammate TestFlight 1.0 (22) delivered (2026-09-17)

The owner-requested teammate update c0149a6 and qualified integration corrections are published from source 2cb49c6 as TestFlight 1.0 (22). The local Xcode 27A266a release completed. Independent Apple reads confirm VALID processing and Hackathon Internal membership. IPA signing, source snapshot and ten compiled localization dictionaries are verified. See TODO and docs/evidence/teammate-testflight-22.json for final qualification and delivery evidence. The dirty primary checkout is preserved. App Store 1.0 remains attached to build 21 and WAITING_FOR_REVIEW. Do not replace or withdraw it, repeat the upload, or rerun completed qualification without a new reason. All owned temporary test and signing resources have been cleaned up.


## App Store submission complete (2026-09-16 22:09 AEST)

- Pocket Explorer 1.0 (21) was submitted at 2026-09-16T12:09:12.422Z. Apple's page showed "1 Item Submitted", and independent version and submission API reads both confirm WAITING_FOR_REVIEW. Submission ID: 3ae5a282-1ec0-471b-a75f-2676572a254b. Release remains AFTER_APPROVAL. Approval and public availability have not yet occurred.
- The owner authorized excluding China mainland from the first release. Paginated independent reads confirm 174 of 175 territories selected, only CHN unavailable, and every other territory unchanged, including Hong Kong, Macau and Taiwan. All required owner decisions are settled.
- TestFlight 1.0 (21) remains VALID, APP_STORE_ELIGIBLE and IN_BETA_TESTING in Hackathon Internal. Native source c1cf01a was signed and uploaded from this Mac. No new binary was required for the territory change or final submission. Preserve ten languages and local native publishing with [skip ci].
- Backend 8244027 remains deployed through successful workflow 35092615551 with 100% traffic. Sixteen independent production privacy and AI checks pass. The fictional test account is deleted. Older native clients must update for the explicit AI permission flow.
- Release preparation and submission are complete. Await Apple's review, then address any concrete review response. Do not resubmit, rebuild or repeat completed qualification without a new reason. No new agent, timer or automation was created.
- Evidence: native docs/app-store/release-status.json and local ~/tmp/review/pocket-app-store-release/{mainland-exclusion-verified,submitted-version-readback,submitted-review-readback}.json. All owned test, fixture, upload and workflow-watch processes have ended.

Earlier dated checkpoints below are historical and superseded where they conflict with this submission record.

## Accepted submission scope and qualification checkpoint (2026-09-16)

The owner explicitly approved preserving all features and submitting at Apple's current calculated age ratings: 13+ in 171 territories, 16+ in Australia, Vietnam and Brazil, and 15+ in Korea. FOUR_PLUS in older API records describes operating systems before version 26. Do not remove public discovery or social functionality to lower the rating. Kids Category enrollment is not requested for this release. The age rating does not replace applicable privacy obligations.

Epic KWS is deferred by the owner and removed from the release runtime. Existing family PIN, separate explicit Azure AI data permission, withdrawal, local-only speech recognition and account deletion are retained. A PIN is not verified parental consent. Previous KWS checkpoints are historical and superseded.

Backend/Web now pass 319 tests in 45 files with every-file coverage gates, 99.18% lines and 94.13% branches. Production build and an actual Chromium Worker/D1 create-unlock-grant-withdraw-delete flow pass. Browser activation and account deletion are implemented. Evidence: ~/tmp/review/pocket-app-store-release/no-kws-*.

Native integrated baseline has 190 passing units and 23 passing main UI journeys. Additional daily background refresh, invalid demo recovery, complete private-demo flow and speech-denial typing recovery pass. The corrected audio callback test passes. All 15 changed product Swift files pass same-source 80% line coverage, with a minimum of 81.75%. Final Chromium and WebKit regressions each pass 37 tests with one explicit fixture skip. All five artwork/actual-account flows pass, and the actual-account flow also passes WebKit with its mobile screenshot inspected.

The owner confirmed all supplied artwork and example content may be published. Mainland ICP availability is awaiting the owner. Version 1.0 and final review instructions are prepared. Next: finish Apple declarations, deploy Backend through its workflow, upload native 1.0 locally, attach the build and submit review. Publication is authorized. TestFlight remains 0.1.0 (20), App Store 1.0 is not submitted, and no release commit or production deployment has occurred. Do not start agents, timers or native GitHub builds.

## First-release scope correction (2026-09-16 21:21 AEST)

The owner explicitly deferred Epic KWS and asked to proceed with publication. Do not request Epic login or treat KWS approval as a release prerequisite. Preserve existing family PIN, explicit cloud AI permission and withdrawal, deletion, accurate provider disclosure and teammate features. The KWS experiment is archived outside the release worktrees at ~/tmp/review/pocket-app-store-release/kws-deferred-20260916 with file hashes. Its eleven dedicated files, runtime routes, page, migration and deletion dependencies are removed from the release candidate. No production deployment occurred.

Current work: complete browser grant activation using the existing family API, then finish native qualification and Apple declarations. Deploy Backend via its workflow and upload native 1.0 locally. App Store remains unsubmitted and TestFlight remains 0.1.0 (20). Deferring a vendor does not turn a PIN into verified parental consent or justify inaccurate declarations. Earlier KWS checkpoints below are historical and superseded.


## Current continuation (2026-09-16 21:14 AEST)

KWS first-use verification is accepted. Continue the App Store release from the latest TODO and native docs/app-store/parent-verification.md. Backend callbacks, consent state, secure parent sessions and a ten-language parent page are implemented locally and pass a 337-test regression plus per-file coverage gates. Live KWS initiation, native/Web activation and complete cloud-scope enforcement are still incomplete. Epic login and public privacy contact address/phone are pending owner inputs. KWS production setup also requires its own review. Do not deploy the partial gate or claim real KWS verification passed. No Swift product code changed this increment, and prior native coverage gaps remain. TestFlight stays at 0.1.0 (20), App Store 1.0 is unsubmitted, and all owned processes have stopped. Native publishing remains local and Backend uses its workflow. Do not repeat accepted product or publication permission questions.

## Current continuation (2026-09-16 19:49 AEST)

Continue the first App Store release from the latest TODO checkpoint. Review has not been submitted. Apple website/API login is working. Age questionnaire, DSA, all 175 territories, URLs and reviewer contact are saved. Thirteen privacy categories are only drafts. The owner accepted KWS first-use verification on 2026-09-16, and must cover profile/social/location uploads as well as AI. Web read/withdrawal and local speech safeguards are qualified, but activation/deletion are unfinished. Native units pass 190 with one skip and 23 UI journeys pass. Two changed Swift files still miss the 80% coverage gate. Do not deploy the server restriction alone because TestFlight 20 lacks the new flow. Tests and owned fixtures are stopped. Native release stays local and Backend uses its existing workflow. No commit, push, new upload or review submission occurred.

This summary supersedes conflicting historical checkpoints below. Use native docs/app-store/release-readiness.md and parent-verification.md for the remaining work.

## App Store continuation: integrated baseline (2026-09-16)

- Current native baseline is main 41a6356, including TestFlight 20. The pending privacy work was backed up and restored with all upstream changes. The stash and 62-file hash manifest remain in the local integration evidence directory.
- Resolved additive document and localization conflicts. All ten catalogs have 609 unique keys and matching key sets. The combined native test build succeeds. Final qualification remains in progress.
- App Store Connect website is signed in as Hai Chang. API and website independently show version 1.0 in PREPARE_FOR_SUBMISSION with no build or review detail. Free price, Education and English text remain saved. Support URL, copyright, review information, age questionnaire, availability and privacy declarations remain unfinished.
- Parent verification preference was requested with the concrete KWS first-use proposal. No new service account or terms have been accepted. Continue independent privacy/Web work while that input is pending.
- Evidence: ~/tmp/review/pocket-app-store-release/integration-20260916 and resume-*.json. No deployment or review submission occurred.


## Latest baseline update (2026-09-16 18:58 AEST)

The user requested the teammate update as a separate TestFlight delivery. Build 0.1.0 (20) is independently VALID / IN_BETA_TESTING in Hackathon Internal, published locally from 9c568c1. Remote main includes delivery record 41a6356. Preserve all uncommitted App Store privacy changes in this worktree, and integrate current main before further qualification. The teammate release did not include or deploy these incomplete privacy changes. App Store 1.0 remains PREPARE_FOR_SUBMISSION. No website-login claim follows from the successful Apple API authentication. Evidence: ~/tmp/review/pocket-teammate-testflight-20260916.

## Active: first App Store release (2026-09-16)

Provider clarification, 2026-09-16: the owner confirms Azure AI for question answering, image generation and narration. Treat the previous reasoning-provider question as answered. Use the updated Backend docs/ai-service-evidence.md and native release-readiness.md. Keep the observed Cloudflare embedding processing in the privacy description. No runtime endpoint changes follow from this documentation update. Parent verification, Web compatibility, qualification and Apple declarations remain active.

The owner reaffirmed publication and authorized continued children's privacy work. Versioned AI data permission is implemented locally and undergoing qualification. Use the latest TODO checkpoint rather than the historical unresolved product-direction question. Provider facts and remaining Apple declarations still require accurate evidence before submission.

Current draft and qualification evidence are in the latest TODO and native docs/app-store/release-readiness.md. Native and Backend versioned AI permission are implemented locally, with final UI regression and broader coverage still pending. Web permission compatibility, parent verification, final provider disclosure and Apple declarations remain unfinished. No review has been submitted. See native docs/app-store/parent-verification.md and Backend docs/ai-service-evidence.md.

The user authorized public App Store publication. Work in /Users/haichang/Worktrees/Pocket-Explorer-UI-app-store-release, branch hai/app-store-release, from 257b1d4. Follow docs/plans/app-store-release.md, AS1-AS5. Backend worktree is /Users/haichang/Worktrees/Pocket-Explorer-Backend-app-store-release, from 732b6e6. Do not resume completed navigation work or old timers. Keep local-only native publishing and ten languages.

- AS1 AUDITED: Apple confirms build 19 is APP_STORE_ELIGIBLE. Existing App Store 1.0 has no attached build. English listing text, free pricing and three screenshots are saved. Owner confirmed free download, no IAP, ages 6-8 with a parent, and a non-commercial hobby project for non-trader declaration.
- AS2 IN_PROGRESS: correct missing AI data disclosure, remote-family deletion, public privacy and support pages. Social report/block already exist.
- AS3 IN_PROGRESS, AS4-AS5 PENDING: store materials, declarations, qualification, local binary and submission. Draft listing and free pricing are saved. Review submission remains pending.
- Evidence: ~/tmp/review/pocket-app-store-release. Current published native runtime remains build 19. Prior release checkpoints below are historical.
## Delivered teammate TestFlight request (2026-09-16)

TestFlight 0.1.0 (20) is independently VALID / IN_BETA_TESTING in Hackathon Internal. Source 9c568c122d5e95a5337b13c035990d71443703de includes the latest teammate code and qualified integration fixes. This release request is complete. Follow the next user input or resume the separate App Store work only in its existing worktrees. Work in /Users/haichang/Worktrees/Pocket-Explorer-UI-teammate-testflight-20260916 on hai/teammate-testflight-20260916, based on upstream 3151a0f. Read the latest TODO for qualification and upload evidence. Keep the separate uncommitted App Store privacy worktrees intact. Publish native locally with [skip ci]. Do not restart historical timers or create agents.

Navigation and the new identity were released locally as TestFlight 0.1.0 (19) on 2026-09-16. Independent reads confirm VALID / IN_BETA_TESTING in Hackathon Internal. Native source is f184e8674c7509a5d34c4366811b50e5dbb11db2. Qualification has 266 latest per-test passes, four explicit skips and current-hash coverage for all 30 changed product Swift files, minimum 88.27% and aggregate 95.53%. Physical-device and human visual acceptance remain separate. Do not repeat the completed release or resume expired timers.

## Delivered navigation continuation (2026-09-16)

Work in /Users/haichang/Worktrees/Pocket-Explorer-UI-jacky-navigation, branch hai/jacky-navigation. Follow docs/plans/jacky-navigation.md and the newest TODO checkpoint. P40-P45 implementation and local delivery are complete. Follow the next user feedback or physical-device acceptance findings. The user says to proceed independently without waiting for teammate assignments. Keep the original primary-checkout drafts intact. No new timer or subagent is authorized. Preserve correct-answer unlocks, protected settings, ten languages, real services and private-demo isolation. Native publication remains local with [skip ci]. Older delivered checkpoints are historical. See docs/evidence/navigation-identity.json and docs/testing/navigation-journey.md for current evidence and physical acceptance.

## Verified roadshow delivery (2026-09-16 04:17 AEST)

TestFlight **0.1.0 (18)** is independently VALID and IN_BETA_TESTING in Hackathon Internal, published from this Mac. IPA source is d8d4114b9471b2e537d6d3ae24905e1523e8ac41, including upstream 906e743. Signature, tested runtime source and ten 542-entry catalogs are verified. External distribution is not verified.

Backend aafd4fe is deployed through successful workflow 34998228931. Production acceptance passes 81 requests. Backend tests pass 246 checks, with 34 Chromium and 34 WebKit scenarios. All 60 Marketing packages, 66 assets and 60 Vectorize records are independently verified.

Native qualification has 248 latest per-test passes, four gated skips and no unresolved failure across full and targeted runs. All 40 changed Swift files meet exact-hash coverage, minimum 89.28% and aggregate 96.24%. This is not a claim of one passing full final-source invocation.

Tests, release processes, owned fixtures and continuous simulated location have ended. The temporary signing keychain is removed. No native GitHub build ran. Preserve old checkpoints as history, not pending instructions. Physical iPhone microphone, camera, headphones, interruptions and listening acceptance remain open. Commercial billing is disabled. See the UI docs/evidence/pitch-native.json and docs/reviews/pitch-native-integration.md for evidence.


## Continuation after delivery

The roadshow implementation and both releases are verified. Do not resume historical failed runs, imports, uploads or expired timers. Use the shipped baseline and the user's next priorities. Native source is d8d4114, Backend runtime aafd4fe. Preserve primary checkouts' unrelated drafts. Remaining human/physical acceptance and commercial scope are explicit above.

## Active roadshow implementation (2026-09-15)

The eight roadshow slides now govern conflicting product decisions. The user explicitly requests all described product features this iteration. Follow docs/plans/pitch-alignment.md and the active TODO checkpoint. Parent controls, correct-answer unlocks, personalized exploration, event/location discovery, evolving cards, real friendships and text chat are in scope. Preserve old cards and links, ten languages, live AI, prepared content and private demo isolation.

Proceed through the complete acceptance matrix without treating an increment as overall completion. Update TODO after implementation and verification. Use the new hai/pitch-alignment worktrees. Native publishing is local with [skip ci], Backend through its workflow. Do not restart expired timers. Commercial transaction scope awaits the user's answer.

The earlier checkpoints and exclusions below are historical. Build 18 is the latest independently verified release for this iteration.

## Current delivery: cached-answer presentation and private demo (2026-09-15 20:28 AEST)

This is the current state. Older dated checkpoints below are historical and must not trigger another release or resume expired automation.

- TestFlight **0.1.0 (17)** is independently VALID and IN_BETA_TESTING in Hackathon Internal. Native source: bd75c0cea853b97912b989bd9b22f08a394d9ad9. Published from this Mac using Xcode 27 RC 27A266a, with [skip ci]. External distribution of this build is not verified.
- Cached and new answers use progressive text and automatic narration. Text can be expanded immediately. Prepared answers, illustrations and audio remain reused. History stays quiet. Backgrounding, dismissal, Reduce Motion and VoiceOver have explicit behavior. Narration is not word-synchronized highlighting.
- Private Studio is live at https://pocket.changhai.me/studio. Backend source ac493873a30d4c12341752c1fcd123ae753e2fa4 deployed through successful workflow 34954953344. Migration 0008 and deployment 280b53b4-470c-4f0e-956b-f1f7eec69f17 are independently verified. Exact authored text, original art, real Azure audio, one-use activation, privacy, sharing and revocation pass online. Test shares and phones were revoked, and the sample draft was unpublished.
- Native qualification passes 139 unit and 25 UI checks across matching-source runs. The host-microphone case remains a physical-device check. Changed executable coverage is 334/344 (97.09%), with every changed file at least 85.37%. Backend passes 188 checks, 26 Chromium, 26 WebKit and four artwork tests, including every-file 80% line/branch gates.
- Visual review reproduced and corrected overflowing collection art. Final cards have 20pt outside margins, a 14pt gap and equal heights. A matching interaction shape keeps taps inside each card. Home fades now follow the image bounds. Final screenshots are reviewed. Miro and Marketing source details are recorded in the native docs/design/miro-updates-20260915.md.
- Independent IPA reads confirm signing, build 17, all ten 346-entry catalogs, custom app activation scheme and unchanged tested source. The temporary signing keychain is removed. This task's fixture on port 4235 is stopped. No release, test, heartbeat or agent remains running.

Use Backend docs/demo-studio.md for organizer instructions and docs/reviews/private-demo-20260915.md for limitations. Local Chinese reviews are ~/tmp/review/pocket-demo-studio.zh.md and ~/tmp/review/pocket-demo-review.zh.md. The R2 report at ~/tmp/review/pocket-explorer-r2-usage.zh.md was refreshed at 20:24 AEST, recording 142.83 MB and 142 objects from a delayed snapshot, 144 Class A and 274 Class B operations, with estimated R2 charges still zero.

Remaining acceptance: real iPhone microphone, camera, listening quality and interruptions. Event/social mock flows, full map/settings reference restyling, accounts and friend chat remain deferred. The new Miro screenshots were thumbnail-limited, so pixel-exact reproduction is not claimed. Further development should start from this delivered baseline and the user's next priorities.

## Current checkpoint: prepared-answer presentation and private demo (2026-09-15)

This checkpoint supersedes historical release and allowance statements below. Daily discovery is released: Backend d38080a through workflow 34946507042 and native c16eb46 as TestFlight 0.1.0 (16), independently VALID and IN_BETA_TESTING in Hackathon Internal. Build 16 does not include the new local demo or visual changes. Use Xcode 27 RC 27A266a for subsequent local native releases. No native release is currently running.

The user now requests identical presentation for cached and live answers, including progressive text and narration. The prepared-question path currently opens an existing record and returns before starting speech. Add a shared, skippable text reveal, start narration only for an explicitly opened discovery or newly answered question, preserve quiet history viewing, respect Reduce Motion and VoiceOver, and stop work on dismissal/backgrounding. Reuse prepared audio without generating it again. Verify a failing baseline, cached/offline playback, live playback, replay, saving and accessibility.

Private demo code is implemented locally but not deployed. Six native DemoTests pass. Backend has 182 passing checks and one existing integration test timeout under concurrent builds, so full acceptance is pending. New Studio frontend coverage, native demo UI checks, live privacy verification and release remain required. Additive migration 0008 is local only. Do not claim demo availability yet.

Miro App Suggestion and IOS App View were refreshed. Marketing main 87a1be5 supplies 13 backgrounds, three event scenes and six card illustrations. One backdrop and six Studio samples are integrated locally. Card fill, corner clipping and equal-height refinements await screenshot verification. Event flows, real accounts and friend chat are not implemented. Preserve the source images and original Figma baseline. The new Miro screenshot exports are thumbnail-limited, so pixel-exact review is not claimed.

Next: verify the prepared-answer baseline, implement and test the shared presentation, then finish demo/visual acceptance and release through the established channels. Keep all unfinished work and evidence. Native publishes from this Mac with [skip ci], Backend through its workflow. No expired heartbeat or subagent is started.

## Private demonstration content (2026-09-15)

The user approved author-prepared questions, answers and card illustrations with explicit priority, available only in an intentionally enabled demo mode. They accepted private single-use links that authorize specific phones. Ordinary users must have no demo entry. Follow the Backend docs/plans/private-demo-mode.md plan. This is the next implementation task, separate from the completed daily-discovery source. No demo feature is implemented yet.


## Azure and Cloudflare policy amendment (2026-09-15)

The user clarified that Azure API capacity is effectively unlimited for this project while Cloudflare resources remain constrained. This supersedes historical instructions preserving the 120-question, 18-image and 200,000-speech-character Azure caps. Use explicit `unlimited` policies and retain the existing usage ledger, actual provider failures, deadlines and retry controls.

Cloudflare protections remain separate: request and installation limits, six-hour scheduling with at most three new topics daily, queue concurrency two, bounded retries, caching and asset-size validation. Workers AI embeddings retain 1,000 daily and 10,000 cumulative reservations. These workload controls do not establish a US$10 account-level billing hard stop.

Reservations must be atomic across every applicable bucket. Rejection before a provider call consumes no other allowance, while attempted calls remain counted. All 177 backend tests and every changed-file 80% line/branch gate passed, and the production build passed. The old accounting behavior was reproduced by the same failing regression before the atomic fix. Validation deployment b9f676dc-13f2-4270-b3ca-2e278dfbc7c7 independently reports all three Azure policies as unlimited. Preparation is resumed with two corrected ten-language drafts under independent qualification. Inventory is still 10/12 and TestFlight remains 0.1.0 (14). Finish qualification, deploy production through its existing workflow and upload native locally with [skip ci].


## Current continuation checkpoint (2026-09-15)

Read the newest TODO checkpoint first. Implementation, avatar alignment, final local tests and visual review are complete. Content launch remains blocked at ten of twelve qualified topics per language/age slice, with 118/120 question calls and 18/18 image calls consumed. Preparation is paused, production flags remain false and TestFlight remains 0.1.0 (14). No feature commit or release occurred.

Do not repeat completed provider evaluations or tests without a changed input or unresolved failure. Resolve the specific inventory/allowance decision before generating more content or enabling production. Preserve unchanged cumulative limits unless explicitly revised by the user. Follow the operations runbook for Queue handover, Backend workflow deployment and local native publication with [skip ci]. Physical-device and warning limitations remain in the review. The old heartbeat stays paused.

## Implementation started (2026-09-15)

The user approved implementation. The active worktree is /Users/haichang/Worktrees/Pocket-Explorer-UI-daily-discovery. B10.0 is in progress. Integrate from current origin/main, preserve existing narration, then implement and verify the continuous supply plan. Earlier planning-only statements are historical. No expired timer is resumed.

## Continue the planned content pipeline (2026-09-15)

The user requires continuous backend content replenishment before periodic client activation can work. The detailed [implementation plan](../Pocket-Explorer-Backend/docs/plans/daily-discovery-pipeline.md) owns supply cadence, package verification, immutable versions, native activation, Vectorize reuse and acceptance. This is the newest planning checkpoint and supersedes older task ordering below. Build 14 narration remains the released baseline. No runtime change or publication is part of this planning turn.

Read the detailed plan and TODO before implementation. Start B10.0 from fresh worktrees under ~/Worktrees based on current remote main, preserving the primary checkouts' unpublished drafts. Integrate the released narration source before selecting useful draft code. Inspect migration history before choosing additive migration numbers after deployed 0005.

Implement supply before claiming dynamic recommendations. A static JSON import or daily reshuffle is insufficient. Cron must reconcile and enqueue bounded jobs independently of app visits, validate complete packages, atomically publish catalog revisions and keep adding fresh topics at healthy inventory. Preserve existing allowances and record paused_by_allowance when exhausted.

Native downloads do not replace the active daily snapshot. Prepared opens call no generation or semantic verifier. Free-form reuse uses eligibility, exact/alias fast paths, model-versioned embeddings, Vectorize candidates and authoritative D1 verification. Keep private questions out of shared content. Implement the plan's offline, expiry, correction and failure behavior.

Use meaningful dependency and lifecycle tests, per-file coverage gates, actual screenshots and written review. Verify real scheduled events as well as client rollover. Backend publication retains its Cloudflare workflow. Native commits use [skip ci] and TestFlight publication remains local. Keep expired thread automations paused.

## Completed isolated narration release (2026-09-15)

The user approved hai managed identity, Xiaoxiao gentle Chinese and Emma Dragon HD English. Backend source 9004928 is deployed through workflow 34924912737. Native source 65b3084 was published locally as TestFlight 0.1.0 (14). Independent Apple reads confirm VALID, IN_BETA_TESTING and Hackathon Internal. IPA, signing, ten 322-entry catalogs and unchanged application source are verified. Final runtime tests passed 108 unit and three narration UI checks at 97.12% changed executable-line coverage, and a settled playback screenshot was inspected. UI evidence commit f2e3880 and Backend evidence commit 89f97bb are pushed to main. No GitHub iOS build was started. Test fixtures 4213 and 4215 are stopped, and the expired heartbeat remains paused.

Current release evidence and guides are in ~/Worktrees/Pocket-Explorer-UI-speech and ~/Worktrees/Pocket-Explorer-Backend-speech. Physical iPhone playback, microphone and interruptions remain unverified. Preserve this checkout's unpublished Vectorize/content and design drafts. Prepared daily recommendation audio and semantic reuse remain unfinished and are not part of build 14. Merge the verified narration main changes carefully before resuming those drafts. Earlier authentication proposals below are historical.

## Azure Speech resource created (2026-09-15)

Authentication probe: the Azure CLI Entra user token for haichang@microsoft.com was denied GET /tts/cognitiveservices/voices/list because the Speech frontend data action is missing. This is not a missing resource. The existing claude-proxy-copilot Container App has identity type None. Proposed integration uses an Azure-hosted adapter with managed identity and a resource-scoped Cognitive Services Speech User role, keeping the existing authenticated Cloudflare entry point and R2 audio cache. No identity or role changes have been made.

The user explicitly requested creation in subscription 4496e94c-b276-44d5-8809-1233f334e678 and selected Standard S0. Azure CLI validation and incremental deployment succeeded. Independent resource readback confirms pocket-explorer-speech, resource group hai, eastus, SpeechServices, S0 and disableLocalAuth=true. Endpoint: https://pocket-explorer-speech.cognitiveservices.azure.com/. See [creation evidence](../Pocket-Explorer-Backend/docs/evidence/azure-speech-resource.json).

The earlier DeploymentNotFound probes concerned other model routes. This new resource exists, but its Entra ID data-plane access, voice quality and application integration are still unverified. No role assignments were added and no API keys were retrieved. Next verify the caller identity and Speech permissions, render multilingual samples, then integrate server-side synthesis and R2 audio caching. Resource creation alone does not complete the speech work.

## Current Vectorize continuation (2026-09-15)

The user selected Cloudflare Vectorize. Read the [accepted design](../Pocket-Explorer-Backend/docs/research/semantic-cache-vectorize.md) and follow semantic candidate retrieval plus reuse verification in this iteration. Exact matching remains a fast path. Do not revert to the older exact-only recommendation or introduce another cache provider without new evidence.

Next evaluate a multilingual embedding model and false-hit tests, then integrate with authoritative D1 content and R2 artwork. Current drafts remain unverified and unpublished. The prior research-first correction has been addressed by [research](docs/research/daily-discoveries.md) and this design decision. The timed refinement and heartbeat remain closed.

## Daily discoveries and reusable knowledge (2026-09-15)

The user requests a larger cached recommendation bank, three stable daily selections, prepared answers and illustrations, and long-lived reuse across matching questions. This is new implementation work. The previous timed refinement remains closed and its heartbeat remains paused.

- T22/B10.1 DONE: primary-source research, cache boundaries and the preferred Vectorize design are recorded.
- T22/B10.2 NEXT: server-owned prepared multilingual bank and immutable artwork, with no provider call when opened.
- T22/B10.3 NEXT: persistent native bank, daily selection and background refresh. Freeze the day's selection, including across relaunch and successful bank downloads. Keep typed, spoken and photographic exploration available.
- T22/B10.4 NEXT: exact fast path plus Vectorize semantic candidates and complete-answer verification, following the [design](../Pocket-Explorer-Backend/docs/research/semantic-cache-vectorize.md). Scope by language, validated age applicability and policy revision. Preserve content versions, separate personal records, bounded expiry and generation coordination.
- T22/B10.5 NEXT: meaningful reproductions, actual local D1/R2 integration, changed-file coverage, native UI and persistence tests, written critique and release verification. Backend delivery uses its workflow. Native delivery remains local with [skip ci].

Preserve existing data, private keys, 120/18 safeguards, ten languages, Miro design, untracked design/miro-sync and old public links. Do not revive the earlier eight-hour timer. Do not extend into accounts, friends, chat or unrelated sharing fixes.

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

TestFlight 0.1.0 (13) is independently verified VALID / IN_BETA_TESTING in Hackathon Internal. Source commit: 339ff9e5832fb4cc8fa24cde30aa2f72a811e581. Evidence: docs/evidence/sharing-reentry.json. External group availability has not been confirmed. Backend runtime 5dac559 is independently deployed, with deployment evidence at 08b7558.

Released build 13 fixes pending share creation and revocation across sheet reentry, preserves the exact public snapshot, adapts published controls for accessibility text sizes, and uses neutral keepsake art for terminal illustration failure. Ten UI catalogs have 322 entries.

An earlier complete regression passed 150 tests with no failures and two explicit skips. It predates final revocation, accessibility layout and keepsake changes. Final complete regression passed 154 tests with no failures and two explicit skips. Three independent iOS 27 sharing checks passed. Changed executable-line coverage is 133/133, each file at 100%. Actual screenshots, manual critique and source-freeze verification are complete. Apple, IPA, signing, ten catalogs and temporary-keychain cleanup were independently verified. Evidence, physical-device acceptance guidance and document pushes are complete. Next work is physical acceptance and the reproduced lost-response correction, following TODO.

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

Physical microphone, camera, premium narration, VoiceOver and Safari remain open. Available simulator voices rendered non-silent audio in ten languages, but Arabic used a male voice and French a Canadian French voice. Do not describe every locale as natural female narration. Earlier cloud TTS probes failed. A new Azure Speech S0 resource now exists as recorded above, with data-plane integration still pending.

The five-minute heartbeat pocket-explorer-5 was paused through the automation tool after the deadline and independently read back. No tests, uploads or automatic continuation remain active. Preserve this evidence and continue according to the user’s next instructions.

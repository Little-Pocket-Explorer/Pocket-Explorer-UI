# Sharing continuity and accessibility review

Status: final-source verification complete, awaiting local publication. Artifact directory: ~/tmp/review/pocket-polish-20260915. Base: d7cdec643b4eea6a6b57d1fe34d05da975fd96f1.

## Reproductions and behavior

- Closing and reopening a pending sharing sheet generated two POSTs and two active links. Revoking the visible link left another available. The baseline failed four assertions.
- A follow-up baseline lost the selected first name from the pending preview. SharePublisher now retains one in-flight operation and its exact public snapshot, then persists and independently reads its receipt before clearing the operation.
- Closing and reopening during revocation reenabled sharing/revocation controls and retained a stale URL after completion. Three baseline assertions failed. Revocation now continues across views, coalesces waiting callers and removes the local receipt after a successful DELETE. A failed request retains the receipt and supports an explicit retry.
- At maximum French text, success/revocation text was visibly truncated on 375pt even though the controls were hittable. share-footer-audit-before.xcresult failed the targeted textClipped check. Published actions now scroll at accessibility sizes, with vertically arranged secondary controls and state-change positioning. Ordinary text retains the sticky controls.
- When an illustration is permanently unavailable, the card now uses the existing neutral keepsake compass. The separate explanatory panel remains, and saved words, reading and sharing stay available. Waiting and active generation retain their progress states.

## Tests and visual inspection

The earlier complete native-sharing-13.xcresult passed 150 tests with no failures and two explicit skips. It predates final revocation, accessible-layout and keepsake changes. Its changed-line coverage was 46/46.

The isolated revocation correction passed 18 unit and two delayed-HTTP UI checks, with 77/77 changed executable lines against its worktree base dbadd25. That denominator does not represent the final primary source.

The final accessibility correction passed its focused French maximum-text test on 375pt. Final integrated source also passed all three independent iOS 27 sharing checks in native-sharing-ios27-13.xcresult. Actual pending, completed, revoking, revoked and large-text screenshots were inspected, including the preserved complete revoke label.

Final complete native-final-13.xcresult passed 154 tests with zero failures and two explicit skips: 98 unit and 56 UI passes. Changed Swift executable-line coverage is 133/133, with all three files at 100%. Source stayed unchanged during regression. Final original screenshots and native-final-13-visual-review.jpg were inspected. Live production sharing creation, independent reads and revocation passed. Skips are the unrepeated live AI call and the simulator microphone check that also fails on the released baseline. Publication remains pending in TODO.md.

## Critique and corrections

The first maximum-text test checked that buttons were hittable, which missed visible clipping. A ScrollView frame-height experiment also passed despite obscured content. Actual small-screen screenshots and a textClipped audit supplied the useful reproduction. The final focused audit checks revoke-share and share-message rather than claiming a clean whole-screen audit.

Apple's audit can move the viewport. One corrected-source run failed a subsequent tap check after the audit moved the previously visible action. The test now repositions the control after auditing, with the original clipping check retained. The first AnyLayout expression also failed compilation because its conditional branches had different concrete layout types. Type erasure now wraps each branch, and the subsequent source compiled and passed.

Manual review covered actor isolation, operation lifetime, cancellation of waiting views, exact snapshot preservation, receipt persistence, failed create/revoke retry, separate card/trip identities and accessible control transitions. Source and test changes are scoped to those paths and neutral terminal artwork.

A bounded read-only Opus 5 invocation returned error_max_budget_usd without a usable review. It is not counted as an independent pass. The raw result is opus-sharing-review.json. No further invocation is planned for this increment.

## Delivery limits

The final source preserves ten catalogs with 322 entries, existing journals, public links and the current 120/18 safeguards. No new live AI question or image generation is required. Public sharing checks use fictional data with independent readback and revocation.

This change preserves requests across sheet navigation, not process termination. A share request whose server response is lost still lacks durable server/client idempotency. Record this as later reliability work rather than claiming exactly-once publication under every network failure.

Physical iPhone microphone, camera, premium voice, VoiceOver, Safari and human visual acceptance remain open. Available voices vary by installation. These changes do not establish natural female narration in every language or instant illustration generation.

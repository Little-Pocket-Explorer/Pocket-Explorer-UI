# Parent Verification Decision

Date: 2026-09-16. The owner's latest direction supersedes the earlier KWS selection.

## First release

Epic KWS is deferred. Do not require Epic sign-in, create an account, configure its production service or wait for its review before this release. Apple does not mandate this provider.

Retain the existing family PIN, explicit cloud AI data permission and withdrawal, account deletion and accurate public privacy disclosures. A PIN protects settings. It does not verify adulthood or a parental relationship. Deferring a vendor is not a finding that all children's privacy obligations have been met. Record actual Apple validation or review requirements separately.

## Preserved experiment

Eleven KWS-specific source, migration, fixture and test files were preserved outside the release worktree, with shared-file snapshots and SHA256 checks, at `~/tmp/review/pocket-app-store-release/kws-deferred-20260916/`. The KWS routes, page, migration and deletion dependencies were removed from the first-release runtime. No KWS configuration or user data was deployed.

Earlier local callback tests qualified only the experiment. They did not exercise a real verification provider, prove guardianship or complete direct notice and consent requirements. The previous KWS implementation sequence is no longer a release dependency.

## Continue publication

1. The existing browser AI permission entry and account deletion are implemented and tested.
2. Qualify the native release and reconcile Apple declarations with actual behavior.
3. Deploy Backend through its workflow, archive and upload native 1.0 from this Mac, then submit review.

The formal release is READY_FOR_REVIEW but remains unsubmitted. TestFlight 1.0 (21) and the updated Backend are published and verified. Only the mainland China availability choice remains before final submission.

References: [Apple guidelines](https://developer.apple.com/app-store/review/guidelines/), [KWS notice and consent boundary](https://dev.epicgames.com/docs/kids-web-services/parent-verification-service/pv-service-flow).

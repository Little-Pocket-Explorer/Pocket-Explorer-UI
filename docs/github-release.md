# GitHub builds and TestFlight

Repository: https://github.com/Little-Pocket-Explorer/Pocket-Explorer-UI.
Workflow: [iOS CI and TestFlight](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-UI/actions/workflows/ios.yml).

## Daily workflow

1. Run native unit, UI, integration and coverage checks on the Mac using [the native guide](../ios/README.md), and record results for the source revision in TODO. Pull requests run workflow/script lint without signing secrets.
2. Update ios/fastlane/TESTFLIGHT_NOTES.md when the test instructions change.
3. Merge into main. Changes to iOS, native shared resources or CI trigger the workflow. After workflow/script lint passes, the release job archives, signs, uploads, waits for Apple processing and assigns Hackathon Internal. Native tests are not repeated on GitHub.
4. Update Pocket Explorer in TestFlight. Uploading does not force installation on an iPhone. TestFlight's own automatic-update setting controls installation.

The workflow can also be started from Actions → iOS CI and TestFlight → Run workflow. Choose main and leave publish enabled to release. Disable publish to run workflow/script lint only. Documentation-only pushes do not publish a build. Release jobs are serialized and are never canceled by a newer push. This policy supersedes the earlier quota-based local-only release restriction. A green workflow verifies delivery, not local test completion. Keep failures and unverified checks explicit in TODO.

## Reproducible build

The macos-26 runner explicitly selects /Applications/Xcode_26.6.app. XcodeGen 2.46.0 is downloaded from its official release and checked against its SHA-256 digest. Fastlane 2.239.0 and its dependencies are locked in ios/Gemfile.lock. Actions are pinned to commits. The web toolchain and lockfile live in Pocket-Explorer-Backend.

Xcode 27 GitHub images currently contain a beta that is unsuitable for the established upload path. The app supports iOS 17 and does not require an iOS 27 API. A newer local Xcode remains usable. Change the pinned CI Xcode only after confirming the runner image and Apple upload support.

Native testing uses an installed local simulator with ad hoc signing for Keychain access. Preserve the 80% native coverage requirements and run all fixture services described in the native guide. Backend CI is unchanged and owns web, isolated database and browser tests plus Cloudflare deployment. Native live checks use their own installation credential with fictional data. The legacy `scripts/ci/test-ios.sh` is no longer invoked by the workflow and is not the complete local setup: it pins a runner-specific runtime and omits the pitch fixture.

## Signing and authentication

The testflight GitHub environment accepts only the main branch. Its encrypted secrets are ASC_KEY_ID, ASC_ISSUER_ID, ASC_PRIVATE_KEY, DISTRIBUTION_P12_BASE64, DISTRIBUTION_P12_PASSWORD and PROVISIONING_PROFILE_BASE64. No signing secret is available to pull-request jobs. The dedicated Apple API key has App Manager access. Apple team keys apply to all apps in that Apple account, so repository administrators must be trusted.

The distribution certificate and matching App Store profile expire on September 11, 2027. Renew both and replace the corresponding environment secrets before expiry. The API key remains valid until revoked. Never put signing material, API keys, local databases or archives into Git or workflow artifacts. Cleanup removes the temporary runner keychain and profile even after a failure.

## Build numbers and recovery

Each serialized release reads all current Apple builds and assigns the next integer above both Apple's maximum and the initial baseline 5. A rerun uses a fresh query rather than reusing github.run_number. The marketing version comes from ios/project.yml. Keep integer build numbers and avoid overlapping manual uploads from Xcode or another CI publisher.

If an upload times out after Apple accepts it, inspect TestFlight processing before rerunning. The workflow waits up to 30 minutes for processing. Failed workflow lint, compilation, signing or upload prevents successful delivery. Keep native result bundles and coverage reports with local evidence. Web reports belong to the Backend workflow. A successful release-result.json records version, build ID, internal state, source commit and workflow URL for 30 days.

## External testing

Internal distribution is automatic. External testing still follows Apple's Beta App Review rules. This workflow does not submit, cancel or replace an external review, expire existing builds, or send invitations. Build 2 was independently confirmed IN_BETA_TESTING on September 11, 2026, and public enrollment is available. The external group still serves build 2. Choose an eligible later build for Hackathon External in App Store Connect when ready. The existing public TestFlight invitation remains https://testflight.apple.com/join/83Jzf4WB.

Current verification evidence and any unresolved prerequisites belong in TODO.md and docs/evidence/github-setup.json.

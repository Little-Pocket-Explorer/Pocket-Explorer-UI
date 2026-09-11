# GitHub builds and TestFlight

Repository: https://github.com/Little-Pocket-Explorer/pocket-explorer-ios-ui.
Workflow: [iOS CI and TestFlight](https://github.com/Little-Pocket-Explorer/pocket-explorer-ios-ui/actions/workflows/ios.yml).

## Daily workflow

1. Create a feature branch and open a pull request. Native regression, isolated sharing integration, coverage, web tests, browser tests and workflow lint run without signing secrets.
2. Update ios/fastlane/TESTFLIGHT_NOTES.md when the test instructions change.
3. Merge into main. Changes to iOS, shared resources, web or CI trigger the workflow. After every check passes, the release job signs, uploads, waits for Apple processing and assigns Hackathon Internal.
4. Update Pocket Explorer in TestFlight. Uploading does not force installation on an iPhone. TestFlight's own automatic-update setting controls installation.

The workflow can also be started from Actions → iOS CI and TestFlight → Run workflow. Choose main and leave publish enabled to release. Disable publish to run checks only. Documentation-only pushes do not publish a build. Release jobs are serialized and are never canceled by a newer push.

## Reproducible build

The macos-26 runner explicitly selects /Applications/Xcode_26.6.app. XcodeGen 2.46.0 is downloaded from its official release and checked against its SHA-256 digest. Fastlane 2.239.0 and its dependencies are locked in ios/Gemfile.lock. Actions are pinned to commits. Node 24 uses the public npm registry and web/package-lock.json.

Xcode 27 GitHub images currently contain a beta that is unsuitable for the established upload path. The app supports iOS 17 and does not require an iOS 27 API. A newer local Xcode remains usable. Change the pinned CI Xcode only after confirming the runner image and Apple upload support.

Native tests create an isolated iPhone SE simulator with iOS 26.5 and a local sharing service. They retain ad hoc simulator signing for Keychain access and require at least 80% app line coverage. The web suite requires at least 80% per-file lines and branches. Production Cloudflare deployment is separate from this workflow.

## Signing and authentication

The testflight GitHub environment accepts only the main branch. Its encrypted secrets are ASC_KEY_ID, ASC_ISSUER_ID, ASC_PRIVATE_KEY, DISTRIBUTION_P12_BASE64, DISTRIBUTION_P12_PASSWORD and PROVISIONING_PROFILE_BASE64. No signing secret is available to pull-request jobs. The dedicated Apple API key has App Manager access. Apple team keys apply to all apps in that Apple account, so repository administrators must be trusted.

The distribution certificate and matching App Store profile expire on September 11, 2027. Renew both and replace the corresponding environment secrets before expiry. The API key remains valid until revoked. Never put signing material, API keys, local databases or archives into Git or workflow artifacts. Cleanup removes the temporary runner keychain and profile even after a failure.

## Build numbers and recovery

Each serialized release reads all current Apple builds and assigns the next integer above both Apple's maximum and the initial baseline 5. A rerun uses a fresh query rather than reusing github.run_number. The marketing version comes from ios/project.yml. Keep integer build numbers and avoid overlapping manual uploads from Xcode or another CI publisher.

If an upload times out after Apple accepts it, inspect TestFlight processing before rerunning. The workflow waits up to 30 minutes for processing. A failed check prevents upload. A failed upload never reports successful delivery. Native result bundles and web reports are retained for seven days. A successful release-result.json records version, build ID, internal state, source commit and workflow URL for 30 days.

## External testing

Internal distribution is automatic. External testing still follows Apple's Beta App Review rules. This workflow does not submit, cancel or replace an external review, expire existing builds, or send invitations. Build 2's existing external review is preserved. Once eligible, choose the desired build for Hackathon External in App Store Connect. The existing public TestFlight invitation remains https://testflight.apple.com/join/83Jzf4WB.

Current verification evidence and any unresolved prerequisites belong in TODO.md and docs/evidence/github-setup.json.

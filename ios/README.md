# Run Pocket Explorer on iPhone

The verified local release toolchain is Xcode 27 RC build 27A266a. The project also requires XcodeGen 2.46.0 and targets iOS 17 or later. Xcode projects are generated from project.yml and are not committed. Native tests run locally. GitHub archives, signs and uploads without running simulator tests.

## Physical-device development

```sh
cd ios
xcodegen generate
open PocketExplorer.xcodeproj
```

In Xcode, select the PocketExplorer target, choose your development team under Signing & Capabilities, and select the connected, unlocked iPhone. Enable Developer Mode if prompted, then run the PocketExplorer scheme. A paired-device entry alone does not prove connectivity or installation.

Existing TestFlight users should update directly in TestFlight to preserve their journal. Do not replace the user's installation with a UI-test build using reset arguments. See [TODO](../TODO.md) for latest delivery and open physical checks, and [the five-minute iPhone check](../docs/device-check.md) for the user journey.

The previously inspected development certificate expires on 2026-11-30. Also inspect the selected provisioning profile expiry before the demonstration. Renew expired development signing in Xcode and reinstall. TestFlight distribution uses the separate local release process.

## Local simulator checks

Run these commands from the repository root in separate terminals. These loopback services avoid upstream AI calls. If this project's fixtures already own the default ports, reuse them instead of starting a second server on those ports.

```sh
node scripts/testing/serve-ai-fixture.mjs
```

```sh
node scripts/testing/serve-share-fixture.mjs
```

The AI fixture uses 4197 and the sharing-reentry fixture uses 4201. Family, social, event and related tests also require the current Backend repository's pitch fixture on 4236. With Backend dependencies installed, run from its `web` directory:

```sh
POCKET_PITCH_FALLBACK=http://127.0.0.1:4197 npx tsx testing/pitch-fixture.ts
```

Do not run the full suite with only the first two services: the missing pitch fixture causes connection failures. Stop only the services you started when finished. Independent UI runs need separate simulators, DerivedData and mutable fixtures. Disable parallel testing by default.

First list the installed simulators:

```sh
xcodebuild -version
xcrun simctl list devices available
```

Choose an actual available iPhone UDID, then run from ios. The result directory must be new:

```sh
export POCKET_SIMULATOR_ID="<available-iPhone-simulator-UDID>"
xcodebuild -project PocketExplorer.xcodeproj -scheme PocketExplorer \
  -destination "platform=iOS Simulator,id=$POCKET_SIMULATOR_ID" \
  -derivedDataPath "$HOME/tmp/review/pocket-explorer-build" \
  -resultBundlePath "$HOME/tmp/review/pocket-explorer-tests.xcresult" \
  -parallel-testing-enabled NO -collect-test-diagnostics never \
  DEVELOPMENT_TEAM=5B858997A3 test
```

Keep DerivedData outside Documents to avoid the previously observed resource-fork signing problem. TODO records the complete regression, explicit skips and coverage. Simulator microphone initialization also fails on the released baseline. It does not establish physical recording success or a new application crash.

## Data and sharing

The initial journal contains three fictional sample adventures. User discoveries use actual input and persist in Application Support. New questions use the deployed live backend, and generated illustrations arrive asynchronously. Recording, transcription, speech playback and camera input use native iPhone frameworks.

Sharing needs no manual setup or parental approval. Before creating the first link, the app saves its random installation credential in Keychain. Production is https://pocket.changhai.me. A matching credential is required to revoke a share, while anyone with the public URL can read it. Debug UI tests can override POCKET_SHARE_BASE_URL with loopback HTTP.

Private signing keys, developer credentials and service keys do not belong in this repository. Do not commit generated local signing configuration.

See [GitHub release operations](../docs/github-release.md) for cloud publication and [local release operations](../docs/local-release.md) for the fallback. Keep full native results, explicit skips and coverage evidence locally. A successful TestFlight upload does not certify those tests.

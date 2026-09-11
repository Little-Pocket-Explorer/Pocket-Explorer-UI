# Run Pocket Explorer on iPhone

Requires Xcode 26.6 or a compatible newer Xcode version, XcodeGen 2.46.0 and iOS 17 or later. CI selects Xcode 26.6 on the macos-26 GitHub runner. Xcode projects are generated from project.yml and are not committed.

```sh
cd ios
xcodegen generate
open PocketExplorer.xcodeproj
```

In Xcode, select the PocketExplorer target, choose your development team under Signing & Capabilities, and select the connected, unlocked iPhone. Enable Developer Mode on the iPhone if prompted. Run the PocketExplorer scheme.

The inspected development certificate expires on 2026-11-30. Before the demonstration, inspect the embedded provisioning profile expiry as well. Renew signing in Xcode and reinstall if either has expired. A paired device entry alone does not prove installation or connectivity. The user requested TestFlight distribution. See [release instructions and current Apple prerequisites](../docs/deployment.md).

For simulator tests:

```sh
xcodebuild -project PocketExplorer.xcodeproj -scheme PocketExplorer \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max,OS=26.5' \
  -derivedDataPath "$HOME/tmp/pocket-explorer-build" test
```

Use a DerivedData directory outside Documents. The initial Documents-based build encountered resource-fork metadata that prevented signing.

The first journal contains three fictional sample adventures. User discoveries use actual current text and persist in Application Support. Questions about ducks, leaves or shells receive visibly identified prepared responses. Microphone capture, Speech transcription, speech playback and camera input use native iPhone frameworks.

Sharing works without setup or parental approval. Before creating the first link, the app generates and saves its own random credential in Keychain. The production endpoint is https://pocket.changhai.me. A matching credential is required to revoke a share, while anyone with its public URL can read it. Debug UI tests can override the endpoint with POCKET_SHARE_BASE_URL and use loopback HTTP.

No private signing key or developer credential belongs in this repository. Do not commit generated local signing settings.

GitHub builds and uploads to TestFlight without opening Xcode. See [CI and release operations](../docs/github-release.md). The CI build number is assigned during the release and does not modify project.yml.

# Local TestFlight release

The user requires this iteration to release from this Mac because GitHub runner quota is exhausted. Do not dispatch the GitHub TestFlight workflow.

Run the native regression and backend verification first. Confirm the production AI endpoints and generated-image sharing before uploading a build that depends on them. TODO records the current evidence and any outstanding account prerequisite.

The ignored .local/testflight directory contains the existing App Store Connect API key, distribution certificate, password and provisioning profile. Keep each at mode 600. The local lane uses a temporary signing keychain, restores the original keychain search list and preserves a previously installed profile.

Use the installed Homebrew Ruby and existing local bundle:

```sh
DEVELOPER_DIR="/Applications/Xcode-27-RC.app/Contents/Developer" \
PATH="/opt/homebrew/opt/ruby/bin:$PATH" \
  python3 scripts/release/local-testflight.py --expected-xcode-build 27A266a \
  --output "$HOME/tmp/review/pocket-release-archive" --archive-only
```

The output directory must be new. Without either release flag, the script only writes a source manifest. Archive-only mode produces a signed IPA and records uploaded:false. It does not submit a TestFlight build.

After verification, use a new output directory and --publish:

```sh
DEVELOPER_DIR="/Applications/Xcode-27-RC.app/Contents/Developer" \
PATH="/opt/homebrew/opt/ruby/bin:$PATH" \
  python3 scripts/release/local-testflight.py --expected-xcode-build 27A266a \
  --output "$HOME/tmp/review/pocket-release-upload" --publish
```

The lane chooses the next unused Apple build number, archives, exports, uploads, waits for processing and independently verifies VALID plus assignment to Hackathon Internal. It preserves existing builds and does not submit external beta review or notify external testers.

The source manifest records the current commit and actual file hashes, including uncommitted native work. Do not edit source during a release. Archive and release result JSON files remain outside Git with the local evidence. No GitHub environment is impersonated.

The local helper verifies the selected Xcode build before archiving and records toolchain.json. Xcode 27 Beta 1 (27A5194q) was rejected by Apple with 90534 even though package upload succeeded. The installed RC is 27A266a. Confirm the current Apple release information before changing the expected build. Build numbering includes failed uploads so their numbers are not reused. If processing appears stuck, inspect the app buildUploads resource for errors before waiting longer or uploading again.

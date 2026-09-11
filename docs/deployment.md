# Pocket Explorer deployment and operation

Updated: 2026-09-11.

## Published website

- Public origin: https://pocket.changhai.me.
- Example story: https://pocket.changhai.me/s/DmprLZx_BvlA75rki9n7MqFdl1b4U4hn.
- Cloudflare Worker: pocket-explorer.
- D1 database: pocket-explorer.
- Assets and API use one origin without a local server or temporary tunnel.
- Reading stories requires no account. The app automatically saves an installation credential to create and revoke its own shares, without parental approval or manual configuration.
- D1 stores only allowlisted public fields. Revocation clears the snapshot and retains a tombstone returning HTTP 410.

## App connection

The app defaults to https://pocket.changhai.me. Before its first creation request, it generates a random 256-bit credential and saves it in the iPhone Keychain. The sharing interface has no parental restriction or key settings.

The current demonstration workspace key exists only in the local .local/cloudflare-owner-key file and the Cloudflare Worker secret OWNER_KEY. It is absent from the app, web assets, Git and URLs.

Each new share stores the installation credential’s SHA-256 hash. Public URLs authorize reads only. Revocation requires the matching credential. The legacy owner key remains for older versions and administrative maintenance, outside the tester flow. Anonymous installations are not accounts. Losing the credential prevents recovery of revocation rights. Cloudflare limits creation to 20 requests per minute per location, independently by connection IP and credential. Reads and revocation remain available. The local development service does not implement edge rate limiting.

## Website redeployment

Run these commands from web:

```sh
npm ci
npm run build
npm test
npm run migrate:cloudflare
npm run deploy:cloudflare
```

wrangler.jsonc binds the specific Worker, domain and D1 database. It does not modify other projects in the account. Apply migrations before deploying code. Worker deployment does not reset the database.

Cloudflare credentials come from the current terminal environment and stay outside the project. To configure the Worker key again, use standard input with Wrangler secret put so it does not appear in command arguments, logs or chat.

## Live verification

- npm test includes the actual local D1 runtime and verifies persistence by closing and reopening it.
- npm run test:cloudflare uses independent Chrome sessions to verify deployed creation, memory playback, card reversal, 390px and 1440px layouts, and revoked stories.
- The live suite generates a temporary installation credential and checks ownership isolation, the legacy example and the public viewer. It creates fictional stories and revokes its own links afterward.
- Browser captures: design/key-screens/cloudflare-390.png and cloudflare-1440.png.
- HTTP evidence: docs/evidence/cloudflare-live.json.
- D1 reads use the primary to preserve revocation behavior if replicas are enabled later.

The zone's existing browser integrity check rejected Python's default User-Agent. Verification passed with the truthful PocketExplorerDeployment/0.1 identifier without changing zone security settings. Native app creation, independent read, copy and revocation passed in /Users/haichang/tmp/pocket-cloudflare-share-2.xcresult.

## TestFlight preparation

- Bundle ID: com.haichang.pocketexplorer.
- Version: 0.1.0, current uploaded build number 5. Use a new build number for later uploads.
- Minimum iOS 17, iPhone only.
- App icon and microphone, speech recognition and camera purpose strings are included.
- The privacy manifest declares app-owned UserDefaults access with reason CA92.1.
- The app uses system encryption only and declares ITSAppUsesNonExemptEncryption as false.
- ios/ExportOptions.plist uses app-store-connect distribution and uploads symbols.

## TestFlight upload

Agreement acceptance was independently verified and App Store Connect is authenticated. The app is Pocket Explorer (6810920731), bundle ID com.haichang.pocketexplorer, under paid team 5B858997A3.

Generate the project from ios, open Xcode and select the paid development team:

```sh
xcodegen generate
open PocketExplorer.xcodeproj
```

In Xcode, select Any iOS Device and use Product → Archive. In Organizer, select the archive and use Distribute App → App Store Connect → Upload.

Alternatively, use xcodebuild archive, then pass the signed archive to xcodebuild -exportArchive -exportOptionsPlist ExportOptions.plist. Supply the team and credentials through local configuration. Keep DerivedData and archives under ~/tmp to avoid the Documents extended-attribute issue.

After upload, independently confirm the version, build number and processing state in App Store Connect → Pocket Explorer → TestFlight. Archiving does not prove upload, and upload does not prove tester availability.

## Current release limits

Final build 0.1.0 (5) is independently confirmed Testing in Hackathon Internal. The user can update through TestFlight. Phone sharing acceptance, actual speech/camera and other human checks remain open. Apple disables the external group for build 5 while build 2 remains Waiting for Review.

All 39 native regression checks passed, with 91.78% aggregate changed-file Swift line coverage. Both production-sharing/Chinese-UI checks and the final build 5 copy check passed. See docs/evidence/sharing-build5.json.

No public App Store release or teammate invitations were sent. Prepared responses remain in use. Parental restrictions and manual key setup are removed. Builds, archives and website deployment use the command line. Upload uses the authenticated Xcode 27 RC Organizer because earlier account-backed CLI exports failed. That failure does not imply another login is required.

## External testing continuation

- External group: Hackathon External, ID eddab1cd-de9f-434a-b3b7-9d90af7951d6.
- Internal group: Hackathon Internal, ID 61f0eb50-fc33-4ee4-93fd-2844342c7584.
- Build 5 What to Test is saved and independently verified. It covers sharing without setup and discloses prepared responses.
- The user completed review information and submitted build 2. The external group Builds page shows Waiting for Review, one build and zero testers. The submitted phone number and review text were not reread.
- Enter the telephone number only in the Apple review form, not in the repository. Do not include the workspace owner key in public metadata.
- Wait for Beta App Review approval before teammates can install. Add Testers offers Public Link, Email, Existing and Import. The Email name and address form was inspected without adding testers or sending invitations.
- The user switched to Public Link: https://testflight.apple.com/join/83Jzf4WB. It is open to link holders with a limit of three testers and no additional device criteria. Email invitations and redemption codes are unnecessary.
- Build 2 installation was confirmed earlier. Build 5 phone acceptance awaits the user updating.

- Public-link verification: after reload, App Store Connect still shows https://testflight.apple.com/join/83Jzf4WB and 0 of 3, with Testers cannot join public link until this group has an approved build. A separate public-page visit shows This beta isn't accepting any new testers right now. Evidence: docs/evidence/testflight-public-link.png.

T14 verification: all 39 native regression checks passed with 91.78% aggregate changed-file Swift line coverage. Both additional native checks for production Cloudflare sharing and Chinese UI passed, as did the build 5 Chinese copy check. All 18 web tests and the live browser test passed. See docs/evidence/sharing-build5.json.

Latest release: final build 0.1.0 (5) is Testing in Hackathon Internal, independently verified with its saved testing notes. Update to that build for sharing without parental restrictions. Apple currently disables the external group for build 5 while build 2 remains in review. Build 4 was superseded before group distribution.

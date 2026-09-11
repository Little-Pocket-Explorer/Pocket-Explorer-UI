# Device setup status

Inspected: Xcode 27.0 (27A5194q), minimum target iOS 17, and paired iPhone 17 Pro Max running iOS 27.0 with Developer Mode enabled. The inspected Apple Development certificate expires on 2026-11-30.

The current device detail command cannot establish an actual connection and returns cached pairing information. USB connection and an unlocked device have been requested.

The signing build reports No Accounts and no matching development provisioning profile for com.haichang.pocketexplorer. Xcode's Settings > Accounts needs the user's Apple Developer sign-in. No password has been requested or copied into the project.

After sign-in and connection, select the user's team, generate the profile, inspect its expiry, build, install and independently confirm launch. Follow ios/README.md. The unsigned Release build is only a compilation check and is not an installed app.

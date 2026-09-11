# Initial native verification

Date: 2026-09-11

Xcode 27.0 built the initial iOS app and passed 11 core XCTest cases with zero failures on an iPhone 17 Pro Max simulator running iOS 26.4.

Result bundle: `/Users/haichang/tmp/pocket-core-tests-1.xcresult`.
Build and test log: `core-tests.log` (local, ignored).

The checks cover independent disk reads, stable records, failed writes, private photo rollback, invalid input, corrupt-store preservation, guide matching, actual text preservation, memory ordering, playback state and reminder boundaries.

These results do not verify real microphone/camera hardware, final UI quality, cross-device sharing or final coverage. The paired physical iPhone could be listed but a detail connection failed. That check remains pending.

Build output under Documents acquired metadata rejected by codesign. Use `/Users/haichang/tmp/pocket-explorer-build` for DerivedData.

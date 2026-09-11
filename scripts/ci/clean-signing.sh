#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_TEMP:?Run this script on a GitHub macOS runner.}"
if [[ -f "$RUNNER_TEMP/pocket-signing/profile-path" ]]; then
  profile_path="$(cat "$RUNNER_TEMP/pocket-signing/profile-path")"
  case "$profile_path" in
    "$HOME/Library/Developer/Xcode/UserData/Provisioning Profiles/"*.mobileprovision)
      rm -f -- "$profile_path" ;;
    *) echo 'Unexpected provisioning profile path.' >&2; exit 1 ;;
  esac
fi
if [[ -f "$RUNNER_TEMP/pocket-signing.keychain-db" ]]; then
  security delete-keychain "$RUNNER_TEMP/pocket-signing.keychain-db"
fi
rm -rf -- "$RUNNER_TEMP/pocket-signing"

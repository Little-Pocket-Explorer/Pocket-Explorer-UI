#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_TEMP:?Run this script on a GitHub macOS runner.}"
repo_dir="$(cd "$(dirname "$0")/../.." && pwd)"
simulator_id=""
cleanup() {
  if [[ -n "$simulator_id" ]]; then
    xcrun simctl shutdown "$simulator_id" || true
    xcrun simctl delete "$simulator_id" || true
  fi
}
trap cleanup EXIT

share_base_url="${POCKET_SHARE_BASE_URL:-https://pocket.changhai.me}"
curl --fail --silent --show-error --retry 3 \
  --retry-delay 1 --max-time 5 "${share_base_url%/}/health"

cd "$repo_dir/ios"
xcodegen generate
simulator_id="$(xcrun simctl create PocketExplorer-CI \
  com.apple.CoreSimulator.SimDeviceType.iPhone-SE-3rd-generation \
  com.apple.CoreSimulator.SimRuntime.iOS-26-5)"
xcrun simctl boot "$simulator_id"
xcrun simctl bootstatus "$simulator_id" -b

TEST_RUNNER_POCKET_RUN_LIVE_SHARE=1 \
  TEST_RUNNER_POCKET_SHARE_BASE_URL="$share_base_url" \
  xcodebuild -project PocketExplorer.xcodeproj -scheme PocketExplorer \
  -destination "platform=iOS Simulator,id=$simulator_id" \
  -derivedDataPath "$RUNNER_TEMP/ios-derived-data" \
  -resultBundlePath "$RUNNER_TEMP/ios-tests.xcresult" \
  -parallel-testing-enabled NO -collect-test-diagnostics never \
  DEVELOPMENT_TEAM=5B858997A3 test 2>&1 | tee "$RUNNER_TEMP/ios-tests.log"

xcrun xccov view --report --json "$RUNNER_TEMP/ios-tests.xcresult" > "$RUNNER_TEMP/ios-coverage.json"
jq -e '[.targets[] | select(.name == "PocketExplorer.app") | .lineCoverage] |
  (length == 1 and .[0] >= 0.8)' "$RUNNER_TEMP/ios-coverage.json"

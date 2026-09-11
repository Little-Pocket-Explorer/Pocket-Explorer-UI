#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_TEMP:?Run this script on a GitHub macOS runner.}"
: "${GITHUB_PATH:?GitHub Actions path file is required.}"
tools_dir="$RUNNER_TEMP/xcodegen-2.46.0"
mkdir -p "$tools_dir"
cd "$tools_dir"
curl --fail --location --silent --show-error --retry 3 --max-time 120 \
  https://github.com/yonaskolb/XcodeGen/releases/download/2.46.0/xcodegen.zip \
  --output xcodegen.zip
printf '%s\n' '4d9e34b62172d645eed6457cac13fc222569974098ef4ee9c3368bedf0196806  xcodegen.zip' \
  | shasum -a 256 --check
unzip -q xcodegen.zip
echo "$tools_dir/xcodegen/bin" >> "$GITHUB_PATH"
"$tools_dir/xcodegen/bin/xcodegen" --version

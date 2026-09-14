#!/usr/bin/env python3
"""Prepare source evidence and optionally run the local TestFlight lane."""
import argparse
import base64
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]


def source_snapshot():
    paths = subprocess.check_output([
        "git", "ls-files", "--cached", "--others", "--exclude-standard", "-z", "--", "ios", "shared", "scripts"
    ], cwd=ROOT).decode().split("\0")
    files = {}
    for name in sorted(set(paths) - {""}):
        path = ROOT / name
        if path.is_file():
            files[name] = hashlib.sha256(path.read_bytes()).hexdigest()
    digest = hashlib.sha256(json.dumps(files, sort_keys=True).encode()).hexdigest()
    commit = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT).decode().strip()
    return {"base_commit": commit, "source_sha256": digest, "files": files}


def private_file(path):
    if path.stat().st_mode & 0o077:
        raise ValueError(f"Private file requires mode 600: {path.name}")
    return path.read_bytes()


def validate_toolchain(expected_build):
    version = subprocess.check_output(["xcodebuild", "-version"], text=True).strip()
    if not expected_build or f"Build version {expected_build}" not in version.splitlines():
        raise ValueError("Select the reviewed Xcode with DEVELOPER_DIR and provide its --expected-xcode-build. Found: " + version)
    return {"developerDir": os.environ.get("DEVELOPER_DIR"), "version": version, "expectedBuild": expected_build}


def release_environment(output, snapshot):
    private = ROOT / ".local/testflight"
    env = dict(os.environ)
    env.update({
        "POCKET_RELEASE_DIR": str(output),
        "POCKET_RELEASE_SOURCE": snapshot["base_commit"] + ":" + snapshot["source_sha256"],
        "APP_STORE_CONNECT_APP_ID": "6810920731", "APPLE_TEAM_ID": "5B858997A3",
        "ASC_KEY_ID": "W3386DYB8V", "ASC_ISSUER_ID": "69a6de75-bfdc-47e3-e053-5b8c7c11a4d1",
        "ASC_PRIVATE_KEY": private_file(private / "AuthKey_W3386DYB8V.p8").decode(),
        "DISTRIBUTION_P12_BASE64": base64.b64encode(private_file(private / "distribution.p12")).decode(),
        "DISTRIBUTION_P12_PASSWORD": private_file(private / "p12-password").decode().strip(),
        "PROVISIONING_PROFILE_BASE64": base64.b64encode(private_file(private / "PocketExplorer.mobileprovision")).decode(),
        "BUNDLE_GEMFILE": str(ROOT / "ios/Gemfile"),
        "BUNDLE_PATH": str(ROOT / ".local/bundle"),
        "FASTLANE_SKIP_UPDATE_CHECK": "1", "FASTLANE_OPT_OUT_USAGE": "1",
    })
    return env


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--expected-xcode-build", help="Reviewed Xcode build identifier required for archive or publication")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--publish", action="store_true", help="Archive, upload and verify internal TestFlight distribution")
    mode.add_argument("--archive-only", action="store_true", help="Build a signed IPA without uploading it")
    args = parser.parse_args()
    toolchain = validate_toolchain(args.expected_xcode_build) if args.publish or args.archive_only else None
    output = args.output.expanduser().resolve()
    output.mkdir(parents=True, exist_ok=False, mode=0o700)
    snapshot = source_snapshot()
    (output / "source-snapshot.json").write_text(json.dumps(snapshot, indent=2) + "\n")
    if toolchain is not None:
        (output / "toolchain.json").write_text(json.dumps(toolchain, indent=2) + "\n")
    print(f"Source evidence saved to {output / 'source-snapshot.json'}", flush=True)
    if not args.publish and not args.archive_only:
        return
    env = release_environment(output, snapshot)
    if args.archive_only:
        env["POCKET_ARCHIVE_ONLY"] = "1"
    subprocess.run(["xcodegen", "generate"], cwd=ROOT / "ios", check=True)
    subprocess.run(["bundle", "exec", "fastlane", "ios", "beta_local"], cwd=ROOT / "ios", env=env, check=True)
    if source_snapshot() != snapshot:
        raise RuntimeError("Source changed during release. Inspect the recorded snapshot before reporting delivery.")


if __name__ == "__main__":
    main()

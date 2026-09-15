import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("release", Path(__file__).with_name("local-testflight.py"))
release = importlib.util.module_from_spec(spec)
spec.loader.exec_module(release)


class LocalReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        self.root_patch = patch.object(release, "ROOT", self.root)
        self.root_patch.start()

    def tearDown(self):
        self.root_patch.stop()
        self.temp.cleanup()

    def test_source_manifest_changes_with_actual_source_and_ignores_deleted_files(self):
        (self.root / "ios").mkdir()
        path = self.root / "ios/App.swift"
        path.write_text("first")
        def output(args, **kwargs):
            return b"ios/App.swift\0ios/Deleted.swift\0" if args[1] == "ls-files" else b"abc123\n"
        with patch.object(release.subprocess, "check_output", side_effect=output):
            first = release.source_snapshot()
            path.write_text("second")
            self.assertNotEqual(first["source_sha256"], release.source_snapshot()["source_sha256"])
            self.assertEqual(first["base_commit"], "abc123")
            self.assertEqual(list(first["files"]), ["ios/App.swift"])

    def test_private_credentials_are_not_accepted_with_broad_permissions(self):
        path = self.root / "credential"
        path.write_text("fixture-secret")
        path.chmod(0o644)
        with self.assertRaises(ValueError):
            release.private_file(path)
        path.chmod(0o600)
        self.assertEqual(release.private_file(path), b"fixture-secret")

    def test_environment_uses_private_files_without_github_impersonation(self):
        folder = self.root / ".local/testflight"
        folder.mkdir(parents=True)
        for name in ["AuthKey_W3386DYB8V.p8", "distribution.p12", "p12-password", "PocketExplorer.mobileprovision"]:
            path = folder / name
            path.write_text("fixture-only")
            path.chmod(0o600)
        with patch.dict(os.environ, {}, clear=True):
            env = release.release_environment(self.root, {"base_commit": "abc", "source_sha256": "hash"})
        self.assertEqual(env["POCKET_RELEASE_SOURCE"], "abc:hash")
        self.assertEqual(env["ASC_PRIVATE_KEY"], "fixture-only")
        self.assertNotIn("GITHUB_ACTIONS", env)

    def test_prepare_mode_records_evidence_without_starting_release(self):
        with patch("sys.argv", ["release", "--output", str(self.root / "output")]), patch.object(release, "source_snapshot", return_value={"files": {}}), patch.object(release.subprocess, "run") as run:
            release.main()
        run.assert_not_called()
        self.assertEqual(json.loads((self.root / "output/source-snapshot.json").read_text()), {"files": {}})

    def test_toolchain_requires_the_reviewed_build_and_rejects_the_old_beta(self):
        with patch.object(release.subprocess, "check_output", return_value="Xcode 27.0\nBuild version 27A5194q\n"):
            for expected in [None, "27A266a"]:
                with self.assertRaises(ValueError):
                    release.validate_toolchain(expected)
        with patch.object(release.subprocess, "check_output", return_value="Xcode 27.0\nBuild version 27A266a\n"):
            self.assertEqual(release.validate_toolchain("27A266a")["expectedBuild"], "27A266a")

    def test_publish_invokes_the_local_lane_and_rejects_source_changes(self):
        first = {"base_commit": "abc", "source_sha256": "hash", "files": {}}
        with patch("sys.argv", ["release", "--publish", "--output", str(self.root / "output")]), patch.object(release, "validate_toolchain", return_value={}), patch.object(release, "source_snapshot", side_effect=[first, {"changed": True}]), patch.object(release, "release_environment", return_value={}), patch.object(release.subprocess, "run") as run:
            with self.assertRaisesRegex(RuntimeError, "Source changed"):
                release.main()
        self.assertEqual(run.call_args_list[1].args[0], ["bundle", "exec", "fastlane", "ios", "beta_local"])


if __name__ == "__main__":
    unittest.main()

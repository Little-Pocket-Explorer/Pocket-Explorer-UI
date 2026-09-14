# Pocket Explorer

[![iOS CI and TestFlight](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-UI/actions/workflows/ios.yml/badge.svg)](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-UI/actions/workflows/ios.yml)

An iPhone-first exploration prototype with a public family story viewer. A child's question becomes an observation, a collectible card, a place in their journal and a replayable memory.

The native app uses SwiftUI, actual iPhone Speech/AVFoundation and camera adapters, and an atomic local journal. The React website reads versioned public snapshots from an owner-authenticated Cloudflare Worker with D1 storage. Node/SQLite remains available for local development.

The public website is https://pocket.changhai.me. See [deployment and TestFlight setup](docs/deployment.md) for current release status and operations.

On first launch, choose device language, Simplified Chinese or English. The saved choice controls both the interface and voice. Start exploring from home, ask or try a sample, record an observation, then continue directly from the new card to a memory and the family sharing preview.

## Start here

- [PLAN.md](PLAN.md): accepted design and implementation tasks.
- [PROMPT.md](PROMPT.md): complete continuation context.
- [TODO.md](TODO.md): current state, evidence and outstanding work.
- [ACCEPTANCE.md](ACCEPTANCE.md): product acceptance contract.
- [iPhone setup](ios/README.md).
- [Sharing service setup](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend/blob/main/web/README.md).
- [Visual direction and asset origins](design/visual-direction.md).
- [Demonstration script](docs/demo.md).

The project uses the local codex-project skill. Keep implementation, tests and TODO current within the same Codex task.

This iteration releases TestFlight from the Mac because GitHub quota is exhausted. See [local release operations](docs/local-release.md).

## Repository and releases

This repository owns the native iOS UI and its native shared resources. [Pocket-Explorer-Backend](https://github.com/Little-Pocket-Explorer/Pocket-Explorer-Backend) owns the website, Worker API, D1 migrations and web tests. Backend main pushes automatically update Cloudflare after checks.

Pull requests run workflow checks, native regression and integration with the deployed Cloudflare sharing API. A successful push to `main` also uploads a new TestFlight build and assigns the internal testing group. Run the workflow manually with `publish` disabled for checks only. See [GitHub release operations](docs/github-release.md) for credentials, toolchain, reruns and external testing.

## What is real

The journal, camera adapter, microphone adapter, transcription, speech playback, card collection, trip map, memory playback, reminder policy, sharing API, SQLite persistence, revocation and web viewer are implemented. The current code uses real GPT-6 answers, asynchronous generated illustrations and persisted recall quizzes. The live Cloudflare rollout is verified. Current TestFlight delivery and remaining physical-device checks are recorded in TODO.

Simulator and browser verification do not constitute real-iPhone acceptance. Check TODO for actual signing, device, hosting and human visual-review status before presenting this as a completed demo.

## Test

Native tests and installation steps are in [ios/README.md](ios/README.md). CI tests the deployed Cloudflare service using fictional data and its own installation credential, then revokes the test share. Backend CI owns web, browser and isolated SQLite/D1 tests.

For local service work, clone Pocket-Explorer-Backend beside this checkout and follow its web setup. Set TEST_RUNNER_POCKET_SHARE_BASE_URL when running xcodebuild to test another origin. The native sharing integration is enabled by TEST_RUNNER_POCKET_RUN_LIVE_SHARE=1.

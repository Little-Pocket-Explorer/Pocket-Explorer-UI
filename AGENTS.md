# Pocket Explorer

## Current release policy (2026-09-21)

The owner resumed GitHub TestFlight publication and moved all native regression, UI, integration and coverage checks to this Mac. GitHub runs workflow/script lint, then archives, signs, uploads and verifies internal TestFlight distribution. Do not add simulator tests to the cloud release dependency chain. Record local test results and unresolved failures independently of upload success. This supersedes the earlier local-only release and mandatory `[skip ci]` restrictions. Local publication remains available as a fallback.

## Current product authority (2026-09-15)

The user explicitly made the eight roadshow slides authoritative for conflicting product decisions and requested all described product features in this iteration. Follow docs/plans/pitch-alignment.md. This supersedes earlier restrictions against parent controls, correct-answer unlocks, accounts/profiles, friends and text chat. Miro remains the compatible visual reference. Preserve legacy data, ten languages and private demo isolation. Backend releases use the existing workflow. Older design-authority text below is historical where it conflicts.

## Current design authority (2026-09-14)

The user confirmed that [the Miro board](https://miro.com/app/board/uXjVHn9F6EQ=/) is the source of truth for UI design and flows. Figma Review 01 is an interaction example only. This decision supersedes conflicting visual baselines and Figma continuation instructions below, while explicit user decisions still take precedence over board content. The current phase is native implementation with live AI, authorized on 2026-09-14. Earlier design-only restrictions are superseded. Accounts and friend chat are deferred. Any new clickable prototype must follow Miro, and the existing Figma example does not establish completion of that work.


The iPhone app is the primary product. Preserve the approved cream-paper, forest-green, sculptural visual direction. The website is the public story viewer and its implementation lives in the sibling Pocket-Explorer-Backend repository.

Use the `codex-project` skill when installed. Otherwise follow the durable workflow in PLAN.md, PROMPT.md and TODO.md directly. Read PROMPT.md and TODO.md when resuming. PLAN.md owns the design and ACCEPTANCE.md owns the 79 product criteria. TODO.md owns current progress and evidence.

Implement within this directory. Do not modify the sibling gaokao-kg project. Keep code, comments and repository documents in English. Maintain substantial Chinese review copies in `/Users/haichang/tmp/review` with the `pocket-explorer-` prefix and update those first when applying review feedback.

SwiftUI is the app interface. Keep domain behavior separate from audio, camera, persistence and networking adapters. Keep the native public-story fixture and artwork compatible with the TypeScript website in Pocket-Explorer-Backend. Use original or appropriately licensed art instead of placeholder emoji.

Changed Swift code requires at least 80% line coverage. Changed TypeScript requires at least 80% line and branch coverage. Verify writes with independent reads. Real-device checks and human visual approval remain distinct from automated tests.

Keep signing identities, owner credentials and service keys outside tracked files. Generated projects may use local signing configuration. Do not send messages, publish, purchase services, commit, push or create release tags without existing authorization for that action. Do not spawn subagents unless the user or an applicable prior instruction explicitly authorizes them.

Update TODO after meaningful implementation and verification. Continue with actionable required work rather than stopping at task boundaries. Do not relax required app, actual speech, persistence or sharing criteria to declare completion.

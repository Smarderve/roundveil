# ROUNDVEIL — Development plan and approval gates

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Operating principle
Build vertical slices and finish them. Every phase ends with demonstrable working code and a test report; no claiming complete based on generated files.

## Current rebuild milestones — directive received 2026-10-11

This sequence supersedes the short Phase 0–4 roadmap below for current execution; the earlier phases remain historical context. It preserves the existing Flutter project and requires incremental verified commits. Current content counts and architecture gaps are recorded in [`docs/architecture/ROUNDVEIL_REBUILD_AUDIT.md`](docs/architecture/ROUNDVEIL_REBUILD_AUDIT.md).

1. **Architecture and asset audit / renderer proof — BLOCKED, NOT COMPLETE.** Repository and archive inventory/mapping are recorded. Flutter GPU failed to render. Thermion/Filament 0.5.0 resolved and analyzed successfully and compiled for Windows, but Windows Application Control blocked executable launch (`An Application Control policy or security policy has blocked this file.`). The existing emulator reports x86_64 primary ABI, arm64-v8a in its ABI list and `libndk_translation.so`; an ARM64-targeted Android build stalled while Gradle attempted to install SDK Platform 33, before APK creation. User enabled Developer Mode and the Flutter plugin symlink was generated. No actual animated character was verified and no successful-render screenshot exists. Do not mark complete, select a renderer or begin production avatars until the same real character, skeletal animation, camera orbit and material change are visibly verified on both platforms.
2. **Main game shell — NOT STARTED.** Integrate the approved brand references, opening/home and functional navigation, with Windows/Android layout, theme and locale foundations.
3. **3D avatars — NOT STARTED.** After the renderer proof, build actual model loading, camera, skeletal animation, customization and local appearance storage. No 2D substitute can be described as 3D.
4. **Session systems — NOT STARTED.** Single/mixed configuration, editable Quick Game templates, drafts, player management, shared runtime and local persistence/recovery.
5. **Core game modules — NOT STARTED.** Quiz, Word Play, Guess the Character, Riddles, Memory and corrected spoken-answer Guess the Country, integrated through the common runtime.
6. **Content expansion — NOT STARTED.** Audited/licensed offline content and validation pipeline; report exact reviewed playable counts only.
7. **Localization and settings — NOT STARTED.** The 12 requested UI locales, RTL, persistent themes, audio/graphics and accessibility options.
8. **Final integration — NOT STARTED.** Recovery, host controls, scoring/results, performance and Windows/Android gameplay QA.

Milestone 1 next action: obtain a policy-approved test environment that allows execution of the isolated Windows proof and has Android SDK Platform 33 available, then rerun the bounded Thermion proof. Do not bypass Application Control or restart broad SDK troubleshooting. The existing Khronos RiggedSimple proof asset is CC BY 4.0 (SHA-256 `3A79DABB67BB0CD598A18D08B954D9D357C27C30672F82EF5D3F4E7FE6CA3401`). If either platform/capability is not visibly verified, Milestone 1 stays incomplete and production avatar work remains stopped.

### Phase 0 — Documentation and repository preparation
- Import this pack and review `AGENTS.md`.
- Record repository/toolchain status in `PROJECT_STATUS.md`.
- Confirm Flutter/Windows/Android toolchain with `flutter doctor`.
- Do **not** treat the old Felix/Overwatch HTML prototypes as approved game UX.
**Done when:** docs links pass, repository state is recorded and no game implementation has begun.

### Phase 1 — Flutter foundation
- Generate the Flutter/Dart project for Windows and Android without replacing documentation.
- Establish the pure-Dart domain, module, persistence and platform-service boundaries.
- Add the Paper Stage and Hero Arena token infrastructure without selecting a product UX or recreating prototype navigation.
- Configure linting and meaningful smoke tests.
**Done when:** the project analyzes and tests successfully, and the Windows foundation build passes where tooling is available.

### Phase 1.1 — Android readiness and foundation verification
- **Status:** COMPLETE (verified 2026-10-09; development-only Codex Java workaround documented).
- Verify the existing Android Studio and SDK installation, licenses, emulator and Flutter device discovery.
- Repair missing Android prerequisites only with explicit user approval.
- Run Android build and emulator launch verification after prerequisites are healthy.
- Record actual Android and Windows verification results in `PROJECT_STATUS.md`.
**Done when:** Flutter doctor reports a healthy Android toolchain, a debug APK builds, and the foundation launches on the approved emulator where available. **Verified:** `flutter doctor -v`, analyzer and tests pass; debug APK builds; `com.example.roundveil` installs and starts on `emulator-5554`. See `docs/architecture/ANDROID_BUILD_ENVIRONMENT.md` for the temporary Codex process setting used during Android build commands.

### Phase 2 — Game UX redesign and approval
- **Status:** PRE-MATCH LOBBY CANDIDATE RETURNED FOR REVIEW (2026-10-10); not approved or complete.
- The pre-match setup is now an immersive Guess the Country lobby with a visual player lineup, compact match brief, one rules overlay and a prominent readiness-aware start action. All settings remain explicit and editable; the existing content-pool validation and game runtime remain in place. No gameplay screens were redesigned.
- Automated tests cover the lobby, rules overlay, player add/remove, eligible content, challenge rendering and outcomes. Windows debug compilation passed; desktop visual capture was blocked by a foreground Windows Setup window and failed native-window activation. Android captures document the lobby and rules overlay; emulator play-through completed through the existing scored winner screen.
- Resolve `docs/design/UX_OPEN_QUESTIONS.md`: host session UX, game placement, in-game controls, player-ready and interruption treatment.
- Approve functional flows separately from visual style.
**Done when:** specific wireflow/state decisions have explicit user approval and date. The current candidate is a review artifact and does not authorize a Phase 3 implementation.

### Phase 3 — First playable game
- Complete the shared Dart domain: immutable session/round/turn models, timer service, GameRuntime and one approved reference module.
- Add local profiles, host settings, presets, session snapshots and recovery in `user.db`, separated from official content data.
- Wire only the approved UX to one complete offline playable session, including the immediate Win Countdown and interruption recovery.
- Add command, state-machine, persistence and platform verification tests.
**Done when:** one complete offline session can be configured, played, interrupted and resumed on Windows and Android.

### Phase 4 — Additional approved game modules and production development
- Add only approved modules against the shared GameRuntime contract.
- Guess the Country (Flags) may be implemented only after its gameplay UX is approved; include licensed offline SVG pack validation, territory-policy review, answer-validation and no-repeat tests.
- Expand local content packs, accessibility validation, release preparation and platform QA.
- Keep Mystery/investigation games, cloud backends, payment systems and unapproved UX out of scope.
**Done when:** approved modules, release checklist and acceptance criteria pass on both platforms.

## Scope control
A single Codex task should contain objective, involved files, acceptance checks, permitted side effects, and the definition of done. Defer speculative cloud systems. Update status with *what was tested*, not what was assumed.

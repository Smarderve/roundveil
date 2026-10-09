# ROUNDVEIL — Development plan and approval gates

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Operating principle
Build vertical slices and finish them. Every phase ends with demonstrable working code and a test report; no claiming complete based on generated files.

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
- Resolve `docs/design/UX_OPEN_QUESTIONS.md`: host session UX, game placement, in-game controls, player-ready and interruption treatment.
- Approve functional flows separately from visual style.
**Done when:** specific wireflow/state decisions have explicit user approval and date.

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

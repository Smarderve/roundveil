# ROUNDVEIL — Verified project status

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **As of 2026-10-11: Phase 1/1.1 remain verified, and the avatar squad lobby remains an unapproved candidate. A new complete-platform rebuild directive is active. Its repository/reference audit is recorded; Milestone 1 is not complete because the cross-platform 3D renderer proof has not been run. No broad rebuild feature is claimed complete.**

## Completed phases
- **Phase 1 — Flutter foundation: COMPLETE.** The Android/Windows Flutter scaffold, pure-Dart boundaries, visual token infrastructure, linting and smoke tests were established; Windows release build and the current Dart validation passed.
- **Phase 1.1 — Android readiness and foundation verification: COMPLETE.** Android SDK/licenses, NDK, Gradle diagnostic, debug APK build, installation and emulator launch were verified with the documented process-only Codex Java workaround.

## Confirmed by conversation
- The local clone was inspected and had one initial README before documentation integration.
- Product name ROUNDVEIL selected as a working name (formal trademark clearance pending).
- Windows + Android Flutter/Dart shared product direction agreed.
- Felix-inspired and Overwatch-inspired **visual** references liked; UX/gameplay mockups rejected.
- Mystery mode removed entirely.
- Guess the Country (Flags) is an approved game specification with offline-content and outcome rules; its gameplay UX remains unapproved.
- User requested complete Markdown documentation before development.

## Implementation evidence
| Area | Status | Evidence |
|---|---|---|
| Repo state | FLUTTER FOUNDATION WITH ONE PHASE 2 CANDIDATE | Documentation/scaffold plus a single Guess the Country candidate; not a multi-game platform |
| Flutter scaffold | CREATED | Flutter 3.47.6 / Dart 3.13.5; Android and Windows only |
| Android readiness | PASSED | Command-line Tools 23.0 installed under the existing SDK; `flutter doctor -v` validates Android SDK 36.0.0, platform 37.0, emulator 37.2.12.0 and all licenses |
| Android build | PASSED | With the temporary Codex-process Java setting, `flutter build apk --debug` exited 0 and produced `build\\app\\outputs\\flutter-apk\\app-debug.apk` (152,691,994 bytes at verification) |
| Android emulator | PASSED, APP LAUNCHED | `Medium_Phone_API_37.0` is `emulator-5554`; the APK installed with exit 0 and `com.example.roundveil/.MainActivity` became the top-resumed activity with PID 13657 and no inspected AndroidRuntime/FATAL startup error |
| Flutter validation | PASSED (Phase 2 lobby candidate) | Latest recorded result: `flutter analyze` reports no issues; `flutter test` passes 23 tests, including lobby rules, player add/remove, 320 px phone and tablet layouts, scoped distractors, pool validation, challenge rendering, countdown and winner summary. The new rebuild's broader requirements are not covered yet. |
| Java/Gradle diagnosis and workaround | PASSED IN CODEX WITH TEMPORARY SETTING | Original JBR 25.0.3 `Selector.open()` failure is bypassed by `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`; `SelectorProbe.java` printed `SELECTOR_OK` (exit 0) and `android\\gradlew.bat help --stacktrace` exited 0 |
| Native PowerShell comparison | NOT RUN | A directly launched non-Codex PowerShell control remains unverified; do not generalize the Codex workaround to all Windows terminals |
| Windows Phase 2 build/render | BUILD PASSED; LOBBY CAPTURE BLOCKED | `flutter build windows --debug` succeeded and the app opened in a responsive native `ROUNDVEIL` window. A foreground Windows Setup window obscured the app; fresh-window activation failed twice in the approved capture helper, so no clean lobby/rules screenshot was captured and Windows lobby rendering is not claimed as visually verified. |
| Android Phase 2 verification | PASSED, INTERACTIVE CANDIDATE FLOW VERIFIED | Current debug APK built with the process-only Java workaround and installed on `emulator-5554`. The latest avatar lobby, editor, rules, Brazil challenge, Win Countdown and Player 2-ready state were captured from the actual Android emulator under `docs/evidence/phase_2_avatar_squad_lobby/`. This verifies the existing Guess the Country candidate, not the new spoken-answer target. |
| GameRuntime | CONTRACTS ONLY | Interfaces and snapshot boundary created; no game module or progression implementation |
| Guess the Country (Flags) | LEGACY PHASE 2 CANDIDATE; REBUILD TARGET CHANGED | A bounded, local seven-SVG review slice currently has choice/typed paths, aliases, timer/hints and countdown. The 2026-10-11 directive supersedes that answer flow with flag-only spoken answers and host reveal/judgement. This implementation has not been migrated. |
| Flag asset provenance | DOCUMENTED REVIEW SLICE | Seven locally bundled source-ratio SVGs from `hampusborgos/country-flags`, source snapshot inspected 2026-10-10, with retained pack notice at `assets/app/flags/LICENSE.md`. The prototype hides unsupported scope/difficulty combinations; worldwide, Expert, Mixed, Oceania and territory policy selection remain deferred. |
| Gameplay UX | AVATAR LOBBY CANDIDATE; NOT FINAL PLATFORM UX | The setup dashboard was replaced by a Guess the Country lobby with character figures, a look editor, compact rules summary and readiness-aware start. The new platform directive requires true 3D avatars and a general home/game shell; this candidate is not those deliverables. |
| Paper Stage/Hero Arena style | VISUAL REFERENCE ONLY | Screenshots provided in package |
| UI implementation | SINGLE-GAME CANDIDATE ONLY | The app bootstrap opens the bounded Hero Arena Guess the Country candidate only; there is no general navigation, game library, production session runtime, or any other playable module. |
| Complete rebuild audit | MILESTONE 1 IN PROGRESS | `docs/architecture/ROUNDVEIL_REBUILD_AUDIT.md` records the inspected repository baseline, safe temporary extraction of the 2,000-screen archive, the 25-chapter/2,000-unique-ID mapping, brand references, content gaps and renderer candidates. No archive screenshots were copied into the production app. Renderer selection/proof remains open. |
| Rebuild content baseline | NOT PRODUCTION-READY | Seven Guess the Country review-slice records exist. No verified production playable counts are established for Quiz, Word Play, Guess the Character, Riddles or Memory; no counts are claimed toward 1,000 characters, 5,000 words or 10,000 quiz questions. |
| Rebuild platform gaps | OPEN | The current app is one Guess the Country flow, uses 2D Flutter avatar figures, has only interface-level runtime/repository contracts and lacks local persistence, general navigation, the five other playable modules, full localization and complete settings. |

## Current blockers
- Milestone 1 needs a real Flutter-integrated 3D proof on both Windows and Android (rigged model, camera input, skeletal animation, runtime material change and measured performance) before a renderer can be selected. No production 3D avatar model or its asset license/provenance is present.
- The current Guess the Country choice/typed-answer candidate conflicts with the new directive; target mechanics are now flag-only, spoken answer and host reveal/judgement. The implementation and its old tests have not yet been migrated.
- The new platform's modules, persistent session/profile/draft stores, recoverable runtime, 12 UI locales, RTL, light/dark settings and verified content targets have not been implemented. See the rebuild audit for exact baseline and milestone sequence.
- The prior avatar-lobby candidate is not approved as final platform UX. Its historical native Windows screenshot gap remains unverified; it does not block the newly authorized rebuild.
- Windows gameplay-state rendering remains unverified; only the native opening state was exercised and captured on Windows. Android gameplay and desktop/mobile widget renders passed.
- Exact future game variants/scoring defaults, family-friendly age settings and hosting model still need decisions.
- The Android SDK and licenses are healthy. The required NDK r28c (`28.2.13676358`) and Android Platform 36 were installed into the existing SDK during verification. Flutter/Dart executables remain outside the persistent PATH, but the verified local Flutter SDK is used directly; this is a convenience warning, not a build prerequisite.
- Codex Windows builds require a **temporary, command-process-only** Java setting: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`. It was not made permanent. See `docs/architecture/ANDROID_BUILD_ENVIRONMENT.md` for exact use/removal instructions and limits.
- The required outside-Codex PowerShell control has not been run. It remains useful to confirm whether the setting is unnecessary in a normal terminal; it is not a blocker for the verified Codex build/emulator result.
- Guess the Country needs product resolution for its default inclusion policy, any curated-extension membership, and the eventual gameplay UX before production implementation. An official complete flag pack must be legally/source reviewed and visually audited before assets ship.

## Next task
Continue rebuild Milestone 1 by building and measuring the isolated cross-platform 3D renderer proof described in `docs/architecture/ROUNDVEIL_REBUILD_AUDIT.md`. Do not begin production avatar integration or declare a renderer until the proof passes on both targets. The previous lobby remains a candidate and is not the final platform UX.

## Update record
2026-10-10 | Phase 2 candidate correctness, setup UX, gameplay presentation and platform verification | `guess_country_controller.dart`, `country_flag.dart`, `hero_arena_page.dart`, visual/logic tests, goldens, emulator/native evidence, this status and `PLANS.md` | `flutter analyze`, `flutter test` (18/18), Windows debug build and opening render capture, Android debug APK build/install and interactive correct-answer-to-winner flow | Windows gameplay states not interactively exercised; Phase 2 not approved | Return corrected candidate for design review | Recorded in this task's Git commit
2026-10-10 | Phase 2 pre-match lobby redesign | `hero_arena_page.dart`, player-removal setup behavior, lobby widget tests/golden, Android lobby/rules/gameplay evidence, `PROJECT_STATUS.md`, `PLANS.md` | `flutter analyze`, `flutter test` (21/21), Windows debug build, Android debug APK build/install, configured emulator challenge-to-winner flow | Clean Windows lobby/rules capture blocked by foreground Windows Setup window and capture-helper activation failure; candidate awaits approval | Review lobby candidate; capture Windows evidence when desktop is available | Recorded in this task's Git commit
2026-10-11 | Complete rebuild directive intake and Milestone 1 repo/reference audit | `docs/architecture/ROUNDVEIL_REBUILD_AUDIT.md`, source-of-truth/product/test/roadmap/status docs | `dart format --output=none --set-exit-if-changed .` (0 changed); `flutter analyze` (no issues); `flutter test` (23/23); prior candidate Windows/Android debug builds remain the only build evidence | Cross-platform Flutter-integrated 3D proof is outstanding; spoken-answer flag implementation and remaining platform features not started | Complete renderer proof, then proceed to Milestone 2 | Audit progress commit pending

## Update record template
`Date | Scope | Files changed | Tests run + result | Known limitations | Next task | Commit (only when authorized)`

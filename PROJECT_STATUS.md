# ROUNDVEIL — Verified project status

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **As of 2026-10-10: the documentation starter, Flutter technical foundation, Android readiness/build/emulator verification, and Guess the Country (Flags) specification are complete. The Phase 2 pre-match lobby is an unapproved UX candidate; no Phase 3 work has started.**

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
| Repo state | FOUNDATION READY FOR REVIEWED COMMIT | Documentation plus Flutter scaffold; no gameplay/UI implementation |
| Flutter scaffold | CREATED | Flutter 3.47.6 / Dart 3.13.5; Android and Windows only |
| Android readiness | PASSED | Command-line Tools 23.0 installed under the existing SDK; `flutter doctor -v` validates Android SDK 36.0.0, platform 37.0, emulator 37.2.12.0 and all licenses |
| Android build | PASSED | With the temporary Codex-process Java setting, `flutter build apk --debug` exited 0 and produced `build\\app\\outputs\\flutter-apk\\app-debug.apk` (152,691,994 bytes at verification) |
| Android emulator | PASSED, APP LAUNCHED | `Medium_Phone_API_37.0` is `emulator-5554`; the APK installed with exit 0 and `com.example.roundveil/.MainActivity` became the top-resumed activity with PID 13657 and no inspected AndroidRuntime/FATAL startup error |
| Flutter validation | PASSED (Phase 2 lobby candidate) | `flutter analyze` reports no issues; `flutter test` passes 21 tests, including explicit lobby rules, add/remove, 320 px phone and tablet layouts, scoped distractors, pool validation, actual challenge rendering, countdown and winner summary. |
| Java/Gradle diagnosis and workaround | PASSED IN CODEX WITH TEMPORARY SETTING | Original JBR 25.0.3 `Selector.open()` failure is bypassed by `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`; `SelectorProbe.java` printed `SELECTOR_OK` (exit 0) and `android\\gradlew.bat help --stacktrace` exited 0 |
| Native PowerShell comparison | NOT RUN | A directly launched non-Codex PowerShell control remains unverified; do not generalize the Codex workaround to all Windows terminals |
| Windows Phase 2 build/render | BUILD PASSED; LOBBY CAPTURE BLOCKED | `flutter build windows --debug` succeeded and the app opened in a responsive native `ROUNDVEIL` window. A foreground Windows Setup window obscured the app; fresh-window activation failed twice in the approved capture helper, so no clean lobby/rules screenshot was captured and Windows lobby rendering is not claimed as visually verified. |
| Android Phase 2 verification | PASSED, INTERACTIVE GAMEPLAY VERIFIED | Current debug APK built with the process-only Java workaround and installed on `emulator-5554`. The lobby and rules interface were captured from the actual Android emulator. The host explicitly set one player, one round, Mixed/worldwide, multiple choice, timer Off, hints Off, 3-second countdown and scoring On; the Brazil flag challenge accepted the correct answer, reached Win Countdown, and finished with Player 1 winning. The app remained resumed and inspected logs contained no Flutter/Android crash. Evidence is in `docs/evidence/phase_2_pre_match_lobby/`. |
| GameRuntime | CONTRACTS ONLY | Interfaces and snapshot boundary created; no game module or progression implementation |
| Guess the Country (Flags) | PHASE 2 UX CANDIDATE READY FOR REVIEW | A bounded, local seven-SVG review slice supports explicit host choices, multiple-choice/typed paths, optional timer/hints/scoring, answer aliases, immediate correct-answer countdown and no countdown for wrong/timeout. It is not a production content pack or a Phase 3 session architecture. |
| Flag asset provenance | DOCUMENTED REVIEW SLICE | Seven locally bundled source-ratio SVGs from `hampusborgos/country-flags`, source snapshot inspected 2026-10-10, with retained pack notice at `assets/app/flags/LICENSE.md`. The prototype hides unsupported scope/difficulty combinations; worldwide, Expert, Mixed, Oceania and territory policy selection remain deferred. |
| Gameplay UX | PRE-MATCH LOBBY CANDIDATE PENDING APPROVAL | The setup dashboard was replaced by the Guess the Country lobby: centered game identity, visible player lineup, compact rules summary, editable game-style overlay, and readiness-aware start action. All existing rules remain explicit and functional; content-pool validation and the gameplay runtime are unchanged. Candidate not approved; no Phase 3 work began. |
| Paper Stage/Hero Arena style | VISUAL REFERENCE ONLY | Screenshots provided in package |
| UI implementation | PHASE 2 REVIEW CANDIDATE | The app bootstrap opens the bounded Hero Arena Guess the Country candidate only; it does not add general navigation, game selection, a production session runtime, or any other game module. |

## Current blockers
- Phase 2 pre-match lobby needs design review and explicit approval. A clean native Windows lobby/rules screenshot remains outstanding because the desktop capture was obscured by a separate Windows Setup window and the capture helper could not activate Roundveil.
- Windows gameplay-state rendering remains unverified; only the native opening state was exercised and captured on Windows. Android gameplay and desktop/mobile widget renders passed.
- Exact future game variants/scoring defaults, family-friendly age settings and hosting model still need decisions.
- The Android SDK and licenses are healthy. The required NDK r28c (`28.2.13676358`) and Android Platform 36 were installed into the existing SDK during verification. Flutter/Dart executables remain outside the persistent PATH, but the verified local Flutter SDK is used directly; this is a convenience warning, not a build prerequisite.
- Codex Windows builds require a **temporary, command-process-only** Java setting: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`. It was not made permanent. See `docs/architecture/ANDROID_BUILD_ENVIRONMENT.md` for exact use/removal instructions and limits.
- The required outside-Codex PowerShell control has not been run. It remains useful to confirm whether the setting is unnecessary in a normal terminal; it is not a blocker for the verified Codex build/emulator result.
- Guess the Country needs product resolution for its default inclusion policy, any curated-extension membership, and the eventual gameplay UX before production implementation. An official complete flag pack must be legally/source reviewed and visually audited before assets ship.

## Next approved task
Review/approve or reject the Phase 2 pre-match lobby candidate using the Android captures in `docs/evidence/phase_2_pre_match_lobby/`. A clean Windows screenshot can be captured after the unrelated Windows Setup window no longer obstructs the desktop. Do not start Phase 3 or add another game/module until approval.

## Update record
2026-10-10 | Phase 2 candidate correctness, setup UX, gameplay presentation and platform verification | `guess_country_controller.dart`, `country_flag.dart`, `hero_arena_page.dart`, visual/logic tests, goldens, emulator/native evidence, this status and `PLANS.md` | `flutter analyze`, `flutter test` (18/18), Windows debug build and opening render capture, Android debug APK build/install and interactive correct-answer-to-winner flow | Windows gameplay states not interactively exercised; Phase 2 not approved | Return corrected candidate for design review | Recorded in this task's Git commit
2026-10-10 | Phase 2 pre-match lobby redesign | `hero_arena_page.dart`, player-removal setup behavior, lobby widget tests/golden, Android lobby/rules/gameplay evidence, `PROJECT_STATUS.md`, `PLANS.md` | `flutter analyze`, `flutter test` (21/21), Windows debug build, Android debug APK build/install, configured emulator challenge-to-winner flow | Clean Windows lobby/rules capture blocked by foreground Windows Setup window and capture-helper activation failure; candidate awaits approval | Review lobby candidate; capture Windows evidence when desktop is available | Recorded in this task's Git commit

## Update record template
`Date | Scope | Files changed | Tests run + result | Known limitations | Next task | Commit (only when authorized)`

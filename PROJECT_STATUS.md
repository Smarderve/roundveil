# ROUNDVEIL — Verified project status

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **As of 2026-10-10: the documentation starter, Flutter technical foundation, Android readiness/build/emulator verification, and Guess the Country (Flags) specification are complete. The Phase 2 Hero Arena UX candidate has focused correctness and presentation corrections under review; its gameplay UX is not approved.**

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
| Flutter validation | PASSED (Phase 2 corrections) | `flutter analyze` reports no issues; `flutter test` passes 18 tests including scoped distractors, unique-flag pool limits, player setup, actual challenge rendering, immediate countdown, and winner summary. |
| Java/Gradle diagnosis and workaround | PASSED IN CODEX WITH TEMPORARY SETTING | Original JBR 25.0.3 `Selector.open()` failure is bypassed by `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`; `SelectorProbe.java` printed `SELECTOR_OK` (exit 0) and `android\\gradlew.bat help --stacktrace` exited 0 |
| Native PowerShell comparison | NOT RUN | A directly launched non-Codex PowerShell control remains unverified; do not generalize the Codex workaround to all Windows terminals |
| Windows Phase 2 build/render | OPENING RENDER VERIFIED; GAMEPLAY NOT EXERCISED | `flutter build windows --debug` succeeded. The native executable launched with a responsive `ROUNDVEIL` window; a real desktop screenshot confirms the opening screen renders. The full Windows gameplay flow was not interactively exercised. Evidence is in `docs/evidence/phase_2_corrections/windows_opening.png`. |
| Android Phase 2 verification | PASSED, INTERACTIVE GAMEPLAY VERIFIED | Corrected debug APK built with the process-only Java workaround (171,427,876 bytes), installed on `emulator-5554`, and replayed interactively. ADB captures show setup, Player Ready, an undistorted Brazil flag with in-scope answers and timer, immediate 3-second Win Countdown after the correct option, and completion with Player 1 at 1 point. The first emulator run exposed an infinite-width assertion in the challenge timer; it was corrected and the rebuilt APK rendered and completed the flow without an app crash. Evidence is in `docs/evidence/phase_2_corrections/`. |
| GameRuntime | CONTRACTS ONLY | Interfaces and snapshot boundary created; no game module or progression implementation |
| Guess the Country (Flags) | PHASE 2 UX CANDIDATE READY FOR REVIEW | A bounded, local seven-SVG review slice supports explicit host choices, multiple-choice/typed paths, optional timer/hints/scoring, answer aliases, immediate correct-answer countdown and no countdown for wrong/timeout. It is not a production content pack or a Phase 3 session architecture. |
| Flag asset provenance | DOCUMENTED REVIEW SLICE | Seven locally bundled source-ratio SVGs from `hampusborgos/country-flags`, source snapshot inspected 2026-10-10, with retained pack notice at `assets/app/flags/LICENSE.md`. The prototype hides unsupported scope/difficulty combinations; worldwide, Expert, Mixed, Oceania and territory policy selection remain deferred. |
| Gameplay UX | CORRECTED CANDIDATE PENDING APPROVAL | Setup requires explicit choices, scopes distractors, rejects configurations exceeding the unique eligible pool, and shows selected states with accessible contrast. Correct/incorrect/time-out outcomes preserve their rules; correct answers immediately enter the animated Win Countdown. Session completion identifies a scoring winner. This remains review-only and does not approve the UX. |
| Paper Stage/Hero Arena style | VISUAL REFERENCE ONLY | Screenshots provided in package |
| UI implementation | PHASE 2 REVIEW CANDIDATE | The app bootstrap opens the bounded Hero Arena Guess the Country candidate only; it does not add general navigation, game selection, a production session runtime, or any other game module. |

## Current blockers
- Phase 2 needs design review and explicit approval before the candidate can become the approved gameplay UX or any Phase 3 work starts.
- Windows gameplay-state rendering remains unverified; only the native opening state was exercised and captured on Windows. Android gameplay and desktop/mobile widget renders passed.
- Exact future game variants/scoring defaults, family-friendly age settings and hosting model still need decisions.
- The Android SDK and licenses are healthy. The required NDK r28c (`28.2.13676358`) and Android Platform 36 were installed into the existing SDK during verification. Flutter/Dart executables remain outside the persistent PATH, but the verified local Flutter SDK is used directly; this is a convenience warning, not a build prerequisite.
- Codex Windows builds require a **temporary, command-process-only** Java setting: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`. It was not made permanent. See `docs/architecture/ANDROID_BUILD_ENVIRONMENT.md` for exact use/removal instructions and limits.
- The required outside-Codex PowerShell control has not been run. It remains useful to confirm whether the setting is unnecessary in a normal terminal; it is not a blocker for the verified Codex build/emulator result.
- Guess the Country needs product resolution for its default inclusion policy, any curated-extension membership, and the eventual gameplay UX before production implementation. An official complete flag pack must be legally/source reviewed and visually audited before assets ship.

## Next approved task
Review/approve or reject the corrected Phase 2 Hero Arena UX candidate using the screenshots in `docs/evidence/phase_2_corrections/`. Do not start Phase 3 or add another game/module until that approval. Windows opening rendering is verified; interactive Windows gameplay remains optional follow-up verification.

## Update record
2026-10-10 | Phase 2 candidate correctness, setup UX, gameplay presentation and platform verification | `guess_country_controller.dart`, `country_flag.dart`, `hero_arena_page.dart`, visual/logic tests, goldens, emulator/native evidence, this status and `PLANS.md` | `flutter analyze`, `flutter test` (18/18), Windows debug build and opening render capture, Android debug APK build/install and interactive correct-answer-to-winner flow | Windows gameplay states not interactively exercised; Phase 2 not approved | Return corrected candidate for design review | Recorded in this task's Git commit

## Update record template
`Date | Scope | Files changed | Tests run + result | Known limitations | Next task | Commit (only when authorized)`

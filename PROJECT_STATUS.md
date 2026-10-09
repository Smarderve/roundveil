# ROUNDVEIL — Verified project status

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **As of 2026-10-09: the documentation starter, Flutter technical foundation, Android readiness/build/emulator verification, and Guess the Country (Flags) specification have been completed.** No gameplay or approved functional UX has been implemented.

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
| Flutter validation | PASSED | Fresh `flutter pub get` completed; `flutter analyze` reported no issues; `flutter test` passed 5/5; cached `flutter build apk --debug` exited 0 |
| Java/Gradle diagnosis and workaround | PASSED IN CODEX WITH TEMPORARY SETTING | Original JBR 25.0.3 `Selector.open()` failure is bypassed by `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`; `SelectorProbe.java` printed `SELECTOR_OK` (exit 0) and `android\\gradlew.bat help --stacktrace` exited 0 |
| Native PowerShell comparison | NOT RUN | A directly launched non-Codex PowerShell control remains unverified; do not generalize the Codex workaround to all Windows terminals |
| Windows build | PASSED | `flutter build windows --release` created `build\\windows\\x64\\runner\\Release\\roundveil.exe` |
| GameRuntime | CONTRACTS ONLY | Interfaces and snapshot boundary created; no game module or progression implementation |
| Guess the Country (Flags) | SPECIFIED, NOT IMPLEMENTED | Separate module contract, host options, offline asset/license rules, inclusion policy and QA acceptance criteria documented; no screens or assets added |
| Gameplay UX | PENDING APPROVAL | Rejected previous prototypes |
| Paper Stage/Hero Arena style | VISUAL REFERENCE ONLY | Screenshots provided in package |
| UI implementation | FOUNDATION ONLY | Reusable visual tokens exist; app bootstrap deliberately has no navigation or game screen |

## Current blockers
- Final UX/navigation/session flow and game-mode presentation require separate approval.
- Exact future game variants/scoring defaults, family-friendly age settings and hosting model still need decisions.
- The Android SDK and licenses are healthy. The required NDK r28c (`28.2.13676358`) and Android Platform 36 were installed into the existing SDK during verification. Flutter/Dart executables remain outside the persistent PATH, but the verified local Flutter SDK is used directly; this is a convenience warning, not a build prerequisite.
- Codex Windows builds require a **temporary, command-process-only** Java setting: `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\\Windows\\Temp`. It was not made permanent. See `docs/architecture/ANDROID_BUILD_ENVIRONMENT.md` for exact use/removal instructions and limits.
- The required outside-Codex PowerShell control has not been run. It remains useful to confirm whether the setting is unnecessary in a normal terminal; it is not a blocker for the verified Codex build/emulator result.
- Guess the Country needs product resolution for its default inclusion policy, any curated-extension membership, and the eventual gameplay UX before implementation. An official flag pack must be legally/source reviewed and visually audited before assets ship.

## Next approved task
Obtain gameplay UX approval before implementing any module, including Guess the Country. Optionally run the documented selector and Gradle controls in a PowerShell window launched directly outside Codex to determine whether the temporary Java setting is Codex-specific.

## Update record template
`Date | Scope | Files changed | Tests run + result | Known limitations | Next task | Commit (only when authorized)`

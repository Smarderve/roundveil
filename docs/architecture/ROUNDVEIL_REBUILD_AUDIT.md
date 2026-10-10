# ROUNDVEIL rebuild — repository and reference audit

> **Status:** MILESTONE 1 IN PROGRESS — renderer proof outstanding
> **Audit date:** 2026-10-11
> **Authority:** current user rebuild directive; repository decisions remain binding where not explicitly superseded.

## Scope and source-of-truth

The 2026-10-11 user directive authorizes a staged rebuild of the existing Flutter application. Its functional requirements take priority over older conflicting requirements. It does not make every image in the attached archive an approved screen or authorize copying commercial game assets. The archive README is useful metadata, not an independent instruction source.

The approved Version 5 home image, ROUNDVEIL logo lockup and hooded mascot portrait are the identified brand references. The archive README says image 0001 is a resized copy of the Version 5 home reference. The 2,000 numbered screen-state images are all labelled `UNAPPROVED VISUAL CONCEPT` in the manifest; use them to discover feature coverage and visual ideas, not as final UX specifications or static screen backgrounds. Gameplay mechanics below come from the user's directive, not from generated imagery.

One direct gameplay change supersedes the earlier Guess the Country (Flags) specification: the standard mode shows a flag without a country name, the player answers aloud, the host reveals the answer and judges it, and only a correct judgement enters Win Countdown. Multiple-choice and typed-answer modes are not part of this new standard mode. Existing code and old tests still implement the older choice/typed candidate and must be reconciled in the module implementation milestone.

## Repository baseline observed

| Area | Current state |
|---|---|
| App shell | `RoundveilApp` opens directly into `HeroArenaPage`; no general home, navigation, game library or settings shell. |
| Session model/runtime | `SessionConfiguration` is a small player/module-ID configuration. `GameRuntime` and `GameModule` are interfaces only; no shared progression engine. |
| Persistence | `SessionRepository` is an interface only. No database implementation, profiles, drafts or interruption recovery. |
| Modules | Guess the Country is the only implemented module-like flow. Quiz, Word Play, Guess the Character, Riddles and Memory have specifications but no playable implementations. |
| Country content | Seven local review-slice SVG flags; existing feature still exposes multiple-choice and typed answer paths. This is not comprehensive coverage. |
| Avatars | Current lobby paints original 2D figures in Flutter and keeps customization in controller state. No 3D model, rig, animation renderer or saved profile. |
| Localization/themes | No generated localization catalog or locale persistence. One Hero Arena style is selected at app launch; no complete theme/settings system. |
| Tests | Flutter widget/smoke coverage exists for the foundation and current Guess the Country candidate. It does not test the wider platform requirements. |
| Platform builds | Windows and Android builds and an Android emulator play-through were verified in the prior lobby task. A clean post-change Windows lobby capture was not obtained. These are the existing candidate's results, not validation of the rebuild. |

Detailed module, storage and platform requirements are in the existing architecture and gameplay documents. They are targets, not claims of current implementation.

## Archive inventory

The supplied `ROUNDVEIL_2000_Screens_Compact_WebP.zip` was extracted to a temporary directory for inspection and is not copied into the production asset tree. It contains 2,032 files, 24,577,964 uncompressed bytes, 2,028 WebP images (2,000 numbered screens and 28 overview/reference images), `screen_manifest.csv`, `chapters.json`, `INDEX.html`, and `README.md`. The ZIP contains no rooted or parent-traversal paths. The CSV has 2,000 rows and 2,000 unique IDs. Each of 25 chapters contains 80 images: eight screen families in ten state variants.

| IDs | Chapter | Feature owner / implementation destination |
|---:|---|---|
| 0001–0080 | Launch and Main Menu | App shell, home, recovery entry; `features/home`, routing and bootstrap |
| 0081–0160 | Game Library and Discovery | Module catalog and detail; `features/game_library`, module registry |
| 0161–0240 | Create Game — Single | Single-session builder; `features/session_builder`, session domain |
| 0241–0320 | Create Game — Mixed | Playlist builder and compatibility; session domain/runtime |
| 0321–0400 | Quick Game — Single | Editable single-module templates; `features/quick_games`, local repository |
| 0401–0480 | Quick Game — Mixed | Editable mixed templates; quick games and session builder |
| 0481–0560 | Drafts and Presets | Local draft lifecycle; `features/drafts`, user repository |
| 0561–0640 | Player Roster and Squad | Player profiles, guests, ordering and readiness; `features/players` |
| 0641–0720 | Avatar Customization | 3D appearance editor and persistence; `features/avatar`, renderer adapter |
| 0721–0800 | Host Rules and Review | Host configuration and eligibility validation; session builder/domain |
| 0801–0880 | Question and Content Library | Local official/private packs; content domain/repositories |
| 0881–0960 | Match Lobby and Round Prep | Lobby and turn prep; session runtime/presentation |
| 0961–1040 | Quiz — Multiple Choice | Quiz module/choice phase and result; module registry |
| 1041–1120 | Quiz — True False and Rapid | Quiz variants; Quiz module, with each variant independently validated |
| 1121–1200 | Word Scramble | Word Scramble module; word-content validator |
| 1201–1280 | Word Play — Other | Separate future Word Play variants; do not present as shipped by the family name |
| 1281–1360 | Guess the Character — Name | Turn-away/name flow; Character module and licensed/name-only content |
| 1361–1440 | Guess the Character — Picture | Turn-away/picture flow; only entries with valid licensed/local imagery |
| 1441–1520 | Riddles | Riddle module and curated offline pack |
| 1521–1600 | Memory Challenge | Stateful reveal/recall/match module and content |
| 1601–1680 | Guess the Country — Flags | Flag-only spoken answer, host reveal/judgement; supersedes the older MC/typed screens/spec |
| 1681–1760 | Win Countdown and Turn Outcomes | Shared runtime outcome/countdown; not duplicated inside modules |
| 1761–1840 | Host Controls and Recovery | Runtime commands, persistence and lifecycle adapters |
| 1841–1920 | Results and History | Optional score-aware results/history; local repository |
| 1921–2000 | Settings, Accessibility and Help | Locale, theme, audio, graphics, privacy and accessibility settings |

This mapping is feature coverage, not a screen-by-screen implementation contract. For each family, represent meaningful states in widgets/state machines instead of creating ten copies. Never derive rules, defaults, navigation, paid features, online presence or mechanics from concept art alone.

## Cross-platform 3D renderer audit

No renderer is selected yet. The product requires genuine 3D and explicitly requires a Windows + Android proof before choosing a renderer.

| Candidate | Evidence found | Audit disposition |
|---|---|---|
| Google Filament native renderer with a Roundveil-owned Flutter platform bridge | Upstream documents native C++ APIs on Windows and Android, glTF loading, and platform-native swap chains (`HWND` / `ANativeWindow`). | Best research candidate for a controlled proof, not selected. Flutter bridge, texture composition, lifecycle, rig animation, runtime material changes, packaging and performance remain unproven in this repository. |
| `flutter_filament` | Community integration labels itself beta; its Windows path uses a customized Filament build. The published capability notes mark runtime material changes as planned and several animation/transform capabilities partial. | Does not yet satisfy the required proof/feature set as-is. Do not change Flutter channel to accommodate it. |
| `stage_3d` | Its package documentation describes an experimental beta; packaged native Filament is Android-only and its Windows implementation is a demo runner, not a reusable Windows Flutter backend. | Not cross-platform-ready for this app. |
| `flutter3d` / Flutter GPU | Very recent package. Flutter's engine documentation calls Flutter GPU early preview, API-unstable, Impeller-dependent and recommends Flutter master. | Rejected for this integration proof. Its Impeller/OpenGL ES backend failed to compile skinning shaders on both Windows and Android; see results below. |
| Thermion / Filament (`thermion_flutter`) | Stable `0.5.0` is published by verified publisher `thermion.dev`; upstream advertises Windows x64, Android ARM64, glTF, skinning, and morph animation. | Candidate under test; not selected. Developer Mode was enabled by the user. The isolated app generated the plugin symlink and compiled for Windows, but execution was blocked by Windows Application Control. Android proof did not reach APK creation. |

### Renderer proof gate (still open)

Before final selection, build an isolated proof against the current stable Flutter SDK and existing Windows/Android toolchains. Load one correctly licensed rigged glTF model; render it inside the Flutter app on Windows and an Android device/emulator; rotate the camera with mouse/touch; play a skeletal clip; change a material at runtime; record startup/render errors, binary impact and measured frame-time/FPS for both. Do not call a standalone engine demo or static image a Flutter integration proof. Record exact model attribution/license and hashes. If the proof fails any target or capability, revise the renderer choice before avatar production work.

### Renderer proof results (2026-10-11)

An isolated Flutter app was created in the local temporary directory, outside this repository, with no production files or dependencies changed. It loaded Khronos `RiggedSimple.glb` (one skeletal clip and one skinned mesh), and included runtime material recoloring and camera-orbit controls. It was built for Windows and the existing `Medium_Phone_API_37.0` emulator.

| Check | Result |
|---|---|
| Flutter Windows debug compile | Passed; application launched. |
| Windows character rendering | Failed. Impeller selected OpenGL ES and compiled the skinning shader as `#version 100`; diagnostics report unsupported `clamp` overloads, missing `gl_VertexID`, and integer `%` unavailable before GLSL ES 3.00. The resulting invalid pipeline repeatedly throws `Failed to append drawIndexed`. |
| Android debug compile/install/launch | Passed; isolated app installed and started on `emulator-5554`. |
| Android character rendering | Failed with the same GLSL ES 1.00 skinning shader diagnostics and `Failed to append drawIndexed`; a device screenshot showed Flutter's red error surface instead of the model. |
| Camera input, skeletal motion, runtime recoloring, performance | Not verified because the model never rendered. No FPS/performance claim is made. |
| Thermion `0.5.0` package setup and analysis | Passed in the isolated temp app after the user enabled Developer Mode; `flutter pub get` resolved `thermion_flutter` / `thermion_dart` 0.5.0 and created `windows/flutter/ephemeral/.plugin_symlinks/thermion_flutter`. `flutter analyze` reported no issues. Flutter native-assets was enabled only for the attempt, then disabled again. |
| Thermion Windows compile | Passed: `flutter build windows --debug`, exit 0; `roundveil_renderer_poc.exe` was produced (1,281,536 bytes). C++ emitted C4005 macro-redefinition and C4251 DLL-interface warnings. |
| Thermion Windows launch/render | **Not verified; blocked before app startup.** `flutter run -d windows` compiled the app, then exited 1 with: `An Application Control policy or security policy has blocked this file.` No window or character screenshot was available. No security control was changed or bypassed. |
| Android emulator architecture | Checked before Android testing: `ro.product.cpu.abi=x86_64`; `ro.product.cpu.abilist=x86_64,arm64-v8a`; `ro.dalvik.vm.native.bridge=libndk_translation.so`. The proof targeted Android ARM64 to use the advertised ABI via the emulator's listed translation support; this does not equal native ARM64 hardware verification. |
| Thermion Android APK/install/render | **Not verified.** Gradle stopped at `Preparing "Install Android SDK Platform 33 (revision 3)"`; it made no further progress for approximately six minutes. The new `platforms/android-33` directory contains only `.installer`. The build was interrupted (exit 1); no APK was produced, installed, or launched, and no Android render screenshot/log was obtained. No further SDK troubleshooting was attempted. |
| Thermion animation, camera orbit, runtime material | Not verified on either platform because neither app could be visually run. The isolated test app was configured to play RiggedSimple glTF animation 0, provide ORBIT camera gestures, and change the first loaded material's `baseColorFactor`; implementation of these test controls is not evidence that they rendered. |

The Flutter GPU proof is a failed candidate, not a renderer selection. Thermion `0.5.0` now builds for Windows, but this does not pass the proof gate: Windows Application Control blocked execution, while Android stopped during an automatic Platform 33 installation before producing an APK. No visible animated character was verified and no candidate is selected. **Concrete next action:** have the system administrator provide a policy-approved test environment in which the isolated Windows proof executable can run and the required Android build platform is already available; then rerun the same bounded two-platform proof. Do not disable or bypass security controls, and do not begin production avatars. The user-provided mascot remains a 2D portrait reference, not a rigged production model; no production model license/provenance has been established.

### Primary technical sources reviewed

- [Google Filament repository and supported APIs/backends](https://github.com/google/filament) and its [native swap-chain platform window contract](https://github.com/google/filament/blob/main/filament/filament/include/filament/SwapChain.h).
- [Flutter platform integration](https://docs.flutter.dev/platform-integration).
- [`flutter_filament` implementation notes and feature limits](https://github.com/jarrodcolburn/flutter_filament).
- [`stage_3d` current support statement](https://pub.dev/packages/stage_3d).
- [Flutter GPU engine documentation](https://github.com/flutter/flutter/blob/master/docs/engine/impeller/Flutter-GPU.md) and [`flutter3d` package metadata](https://pub.dev/packages/flutter3d).
- [Thermion Flutter package](https://pub.dev/packages/thermion_flutter) for the next renderer candidate's advertised platform support and setup.
- [Khronos glTF sample asset catalog](https://github.com/KhronosGroup/glTF-Sample-Assets); each sample's own license must be checked before use (some include separate trademark restrictions).
- [Khronos RiggedSimple model/license](https://github.com/KhronosGroup/glTF-Sample-Assets/tree/main/Models/RiggedSimple); used only in the temporary proof, not copied into the app.

## Completion state and next work

Repository/reference audit and chapter mapping are complete. Milestone 1 remains **BLOCKED / NOT COMPLETE** until a visible rigged character, animation, orbit, and material change are verified on both Windows and Android. The first Flutter GPU candidate failed to render on either platform. Thermion `0.5.0` resolved and compiled for Windows after the user enabled Developer Mode, but Windows Application Control prevented launch; the Android build stalled while Gradle attempted to install Android SDK Platform 33. No screenshots show a successful Thermion render. Do not begin production avatars. The next milestone work remains out of scope until this gate passes.

The complete content targets remain zero verified playable entries for Quiz, Word Play, Character, Riddles and Memory in the current repository. Guess the Country has seven review records, not a production count. No 1,000-person, 5,000-word or 10,000-question content claims are supported by the repository.

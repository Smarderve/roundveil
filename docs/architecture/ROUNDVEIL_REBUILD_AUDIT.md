# ROUNDVEIL rebuild — repository and reference audit

> **Status:** MILESTONE 1 BLOCKED — cross-platform renderer proof outstanding
> **Audit date:** 2026-10-12
> **Authority:** current user rebuild directive; repository decisions remain binding where not explicitly superseded.

> **Product roster update (2026-10-12):** The active roster is now exactly Quiz, Word Play / Guess the Word, Guess the Character and Guess the Country (Flags). The archive's Riddles (1441–1520) and Memory Challenge (1521–1600) chapters are obsolete references and excluded from implementation; the source ZIP and its manifest were not regenerated or modified. See ADR 0005.

## Scope and source-of-truth

The 2026-10-11 user directive authorizes a staged rebuild of the existing Flutter application. Its functional requirements take priority over older conflicting requirements. It does not make every image in the attached archive an approved screen or authorize copying commercial game assets. The archive README is useful metadata, not an independent instruction source.

The approved Version 5 home image, ROUNDVEIL logo lockup and hooded mascot portrait are the identified brand references. The separately approved full-resolution Version 5 home is authoritative for the main menu. Per the user's 2026-10-11 strict visual-source correction, the extracted `ROUNDVEIL_2000_Screens_Compact_WebP.zip` is the primary visual source for the rest of the game and must be consulted against actual screen images, not just filenames. Its 25 chapter boards and 2,000 image states guide composition, characters, color, graphics, navigation, typography, animation cues and interactive affordances. The manifest's `UNAPPROVED VISUAL CONCEPT` status means individual screens are not user-approved and cannot authorize gameplay behavior; it does not reduce their role as the mandated visual source. Gameplay mechanics come from approved specifications and direct user requirements, never generated image content.

One direct gameplay change supersedes the earlier Guess the Country (Flags) specification: the standard mode shows a flag without a country name, the player answers aloud, the host reveals the answer and judges it, and only a correct judgement enters Win Countdown. Multiple-choice and typed-answer modes are not part of this new standard mode. Existing code and old tests still implement the older choice/typed candidate and must be reconciled in the module implementation milestone.

## Repository baseline observed

| Area | Current state |
|---|---|
| App shell | Implemented 2026-10-11: branded V5 home, adaptive Windows/Android navigation, game catalog and settings entry. The Guess the Country prototype is no longer the opening/primary identity. |
| Session model/runtime | `SessionConfiguration` now carries players, selected modules, single/mixed format and rounds. Create/Quick Game can assemble configurations. `GameRuntime` and `GameModule` are still interfaces only; no shared progression engine. |
| Persistence | `LocalDraftRepository` saves and reloads configuration drafts in application-local storage. SQLite/Drift, profiles, active-session recovery and migrations remain unimplemented. |
| Modules | The active roster is exactly four modules. Guess the Country has a legacy prototype; Quiz, Word Play and Guess the Character do not yet have complete playable implementations. |
| Country content | Seven local review-slice SVG flags; existing feature still exposes multiple-choice and typed answer paths. This is not comprehensive coverage. |
| Avatars | Current lobby paints original 2D figures in Flutter and keeps customization in controller state. No 3D model, rig, animation renderer or saved profile. |
| Localization/themes | Flutter ARB localization covers the shell in the 12 requested app locales, including script-correct Simplified Chinese and Arabic/Urdu RTL. Version 5-inspired light/dark themes switch at runtime. Locale/theme persistence and complete gameplay translation coverage remain open. |
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
| 1441–1520 | Riddles | **OBSOLETE — excluded from implementation by ADR 0005** |
| 1521–1600 | Memory Challenge | **OBSOLETE — excluded from implementation by ADR 0005** |
| 1601–1680 | Guess the Country — Flags | Flag-only spoken answer, host reveal/judgement; supersedes the older MC/typed screens/spec |
| 1681–1760 | Win Countdown and Turn Outcomes | Shared runtime outcome/countdown; not duplicated inside modules |
| 1761–1840 | Host Controls and Recovery | Runtime commands, persistence and lifecycle adapters |
| 1841–1920 | Results and History | Optional score-aware results/history; local repository |
| 1921–2000 | Settings, Accessibility and Help | Locale, theme, audio, graphics, privacy and accessibility settings |

This mapping is the required visual-reference map for implementation: compare each implemented screen against its matching chapter images and meaningful state variants. Reconstruct real Flutter components and interactions; don't embed reference screenshots as fake interfaces. Represent meaningful states in widgets/state machines rather than creating ten copies. Navigation/affordance styling may follow the source image, but behavior, rules, defaults, paid features, online presence or game mechanics must come from approved product specifications. Screen approval remains with the user after actual Windows and Android visual comparison.

## Cross-platform 3D renderer audit

No renderer is selected yet. The product requires genuine 3D and explicitly requires a Windows + Android proof before choosing a renderer.

| Candidate | Evidence found | Audit disposition |
|---|---|---|
| Google Filament native renderer with a Roundveil-owned Flutter platform bridge | Upstream documents native C++ APIs on Windows and Android, glTF loading, and platform-native swap chains (`HWND` / `ANativeWindow`). | Best research candidate for a controlled proof, not selected. Flutter bridge, texture composition, lifecycle, rig animation, runtime material changes, packaging and performance remain unproven in this repository. |
| `flutter_filament` | Community integration labels itself beta; its Windows path uses a customized Filament build. The published capability notes mark runtime material changes as planned and several animation/transform capabilities partial. | Does not yet satisfy the required proof/feature set as-is. Do not change Flutter channel to accommodate it. |
| `stage_3d` | Its package documentation describes an experimental beta; packaged native Filament is Android-only and its Windows implementation is a demo runner, not a reusable Windows Flutter backend. | Not cross-platform-ready for this app. |
| `flutter3d` / Flutter GPU | Very recent package. Flutter's engine documentation calls Flutter GPU early preview, API-unstable, Impeller-dependent and recommends Flutter master. | Rejected for this integration proof. Its Impeller/OpenGL ES backend failed to compile skinning shaders on both Windows and Android; see results below. |
| Thermion / Filament (`thermion_flutter`) | Stable `0.5.0` is published by verified publisher `thermion.dev`; upstream advertises Windows x64, Android ARM64, glTF, skinning, and morph animation. | Candidate under test; not selected. Developer Mode and CMake 3.22.1 are approved/installed. Windows runtime is blocked by Code Integrity; the ARM64 APK builds but x86_64 AVD translation crashes at surface creation. See the dated retry below. |

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
| Thermion Android APK/install/render | **Blocked before APK.** With owner authorization, official Android CLI installed `platforms;android-33` revision 3 into the existing SDK; `flutter doctor -v` reports Android toolchain healthy and all licenses accepted. Native build hooks compiled (upstream C-linkage warnings), then Gradle requested Android SDK CMake 3.22.1. It is not installed and falls outside the specific Platform 33 authorization, so the attempt was stopped before CMake installation. No fresh APK was produced, installed, or launched. No Thermion render screenshot/log exists. |
| Thermion animation, camera orbit, runtime material | Not verified on either platform because neither app could be visually run. The isolated test app was configured to play RiggedSimple glTF animation 0, provide ORBIT camera gestures, and change the first loaded material's `baseColorFactor`; implementation of these test controls is not evidence that they rendered. |

The Flutter GPU proof is a failed candidate, not a renderer selection. The preceding initial result predates CMake approval; the current Thermion result is in the authorized retry below. Thermion `0.5.0` compiles for Windows but Enterprise Code Integrity blocks runtime; its ARM64 Android APK builds but crashes under translated AVD execution before visible rendering. No visible animated character is verified and no renderer is selected. Continue independent four-game development. Do not disable or bypass security controls or begin production avatars. The user-provided mascot remains a 2D portrait reference, not a rigged production model; no production model license/provenance has been established.

### Cross-platform parity and renderer blocker recheck — 2026-10-12

> Historical pre-CMake-approval snapshot. The current outcome is in “CMake-authorized Thermion retry” below.

- The isolated proof remains at `%LOCALAPPDATA%\Temp\roundveil_renderer_poc`; it is not part of the production app. It resolves `thermion_flutter 0.5.0` and contains Khronos `RiggedSimple.glb`, looped glTF animation 0, an ORBIT viewer, and a runtime `baseColorFactor` change. These are configured test actions, not proof that the model rendered. Any retained `android-proof.png` is from the earlier Flutter GPU attempt, not this Thermion attempt; it must not be presented as a Thermion render. No new Thermion screenshot exists.
- `thermion_flutter 0.5.0` remains the latest stable published package checked for this recheck. Its publisher advertises Windows x64 and Android ARM64, glTF, skinning/morph animation and desktop/mobile camera interaction; package capability claims do not override the failed local proof. See the [package metadata](https://pub.dev/packages/thermion_flutter) and [0.5.0 changelog](https://pub.dev/packages/thermion_flutter/changelog).
- The owner authorized Android SDK Platform 33 installation. Official Android CLI installed `platforms;android-33` revision 3 at the existing SDK path `C:\Users\Smarderve\AppData\Local\Android\Sdk`; existing API 36/37 packages were preserved. `flutter doctor -v` reports the Android toolchain healthy and all Android licenses accepted. The existing `Medium_Phone_API_37.0` AVD booted; `ro.product.cpu.abi=x86_64`, `ro.product.cpu.abilist=x86_64,arm64-v8a`, and `ro.dalvik.vm.native.bridge=libndk_translation.so` identify x86_64 with ARM64 translation, not native ARM64.
- During the isolated Android build, Thermion's native assets hooks compiled, then Gradle requested Android SDK CMake 3.22.1. SDK package inventory showed it is not installed. The current authorization covered Platform 33 only, so the process was stopped before the extra SDK package could be installed. No current Thermion APK, install, launch, screenshot or runtime log resulted. The previous APK in the temporary proof directory predates this run and is not evidence.
- Windows Application Control was confirmed from `Microsoft-Windows-CodeIntegrity/Operational`: event IDs **3077** and **3033** state the test executable does not meet Enterprise signing requirements under policy ID `{0283ac0f-fff1-49ae-ada1-8a933130cad6}`. The events cover both `roundveil_renderer_poc.exe` and the production `roundveil.exe`; related prior events also identify `flutter_windows.dll` and `gen_snapshot.exe`. AppLocker EXE/DLL had no matching events. Do not alter or bypass the policy. Windows execution requires an IT-approved test environment or an approved enterprise signing/policy route; no signing certificate was accessed or requested for secrets.
- Windows isolated proof verification: `flutter analyze` passed and `flutter build windows --debug` exited 0, producing the proof executable. Runtime remains blocked by Code Integrity events 3077/3033 and Enterprise signing policy ID `{0283ac0f-fff1-49ae-ada1-8a933130cad6}`. Events identify the isolated proof executable, production `roundveil.exe`/`flutter_windows.dll`, and `gen_snapshot.exe`. `CiTool -lp` returned access denied (`0x80070005`) for the current user, so the applied policy definition could not be enumerated. No security control was altered; supported remediation is IT-provisioned enterprise signing/allowlisting for the complete executable and DLL set or a dedicated policy-approved Windows test/build environment.
- This attempt verified Windows compilation only; Windows runtime and all visual/interaction criteria remain unverified. Android Platform 33 is ready, but the isolated render proof is blocked before APK creation by the additional CMake SDK prerequisite. No 3D implementation was added to production; real 3D remains blocked until both targets visibly pass rendering, skeletal animation, camera control and appearance change.

**Next actions (superseded by the approved retry below):** the original note requested CMake approval; the owner has since approved it and the package is installed. The retry result follows.

### CMake-authorized Thermion retry — 2026-10-13

- Installed official SDK Manager package `cmake/3.22.1` into the existing SDK at `C:\Users\Smarderve\AppData\Local\Android\Sdk`; verified `Pkg.Revision = 3.22.1`. Existing SDK versions and emulator configuration were preserved. `flutter doctor -v` reports Android toolchain healthy and all licenses accepted. Flutter `enable-native-assets` is `false` outside the isolated proof build.
- The isolated proof stayed under `%LOCALAPPDATA%\Temp\roundveil_renderer_poc`. It uses Thermion 0.5.0 and Khronos RiggedSimple. Because the package pins compileSdk 33 while transitive AndroidX dependencies require API 34+, a local vendor copy in this temporary project was overridden to installed compileSdk 36. Gradle had stale Kotlin output and skipped the plugin class; `:thermion_flutter:compileDebugKotlin --rerun-tasks` succeeded and generated the missing class. These changes did not touch production files.
- `flutter build apk --debug --target-platform android-arm64` then passed and produced `build/app/outputs/flutter-apk/app-debug.apk` in the temporary proof project. The artifact contains ARM64 Flutter and Thermion libraries but not an x86_64 Flutter engine. Normal AVD install selected x86_64 and failed with `UnsatisfiedLinkError: libflutter.so is for EM_AARCH64 instead of EM_X86_64`; explicit `adb install --abi arm64-v8a` installed the APK using the AVD's ARM translation.
- The translated process logged `THERMION_PROOF: asset loaded; animation 0 loop started` and `child material instances=1`, then `Creating SurfaceTexture 2400x249` and a SIGSEGV in `Thread-4`. Tombstone details: x86_64 system ABI, ARM64 guest, `libndk_translation.so` frames `berberis_HandleNoExec`/`ExecuteGuest`/`RunGuestThread`, and a `libgui.so` frame. The surface crash occurred before a frame with the character was visually verified. Do not count the asset/animation/material logs as a render pass. There is no successful Thermion character screenshot, nor verified orbit, visible animation, or appearance change.
- A production Windows debug build passed. A fresh launch attempt on 2026-10-13 12:12:11 (+03:00) was blocked before app startup. New Code Integrity Operational events 3077 and 3033 identify `roundveil.exe` as failing Enterprise signing-level requirements under policy `{0283ac0f-fff1-49ae-ada1-8a933130cad6}`. No Windows security policy was changed. Supported next step is IT-provisioned signing for the complete runtime or an organization-managed policy-approved test environment.
- **Android conclusion:** the AVD's ARM64 translation is not a reliable proof runtime for this native renderer/surface path. One concrete next step is to install/run the same isolated ARM64 proof on a native ARM64 Android device/runtime. If that target is not available, leave Android rendering blocked rather than trying arbitrary emulator changes.
- **Windows conclusion:** production `flutter build windows --debug` passed, but a fresh executable launch was blocked. At 2026-10-12 15:57:38 (+03:00), Code Integrity events 3077/3033 named the debug `roundveil.exe` and policy `{0283ac0f-fff1-49ae-ada1-8a933130cad6}`, with Enterprise signing-level requirements as cause. The approved remediation is an IT-provisioned signing certificate/process for the complete EXE/DLL set or an organization-managed test/build environment permitted by the policy. `CiTool -lp` had returned access denied; do not try to alter the security policy.
- **Milestone 1 remains BLOCKED / NOT COMPLETE.** No rendering success is claimed on either platform; production avatar integration remains stopped. The CMake issue is resolved, not a current blocker. Windows/Android environment blockers do not stop four-game gameplay/content work.

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

Repository/reference audit and chapter mapping are complete. Milestone 1 remains **BLOCKED / NOT COMPLETE** until visible rendering, animation, orbit and appearance changes are verified on both Windows and Android. Flutter GPU failed to render. Thermion `0.5.0` compiles for Windows but Enterprise Code Integrity blocks execution; its ARM64 Android APK compiles, but ARM translation on the x86_64 AVD crashes at surface creation before a character frame is verified. Android CMake 3.22.1 is installed; SDK licenses are accepted. No successful Thermion screenshot exists. Continue four-game development, but do not begin production avatars before both platform gates pass.

The checked-in starter packs contain 10 Quiz records, 10 Word Play records, 10 Guess the Character Name Mode records and seven Country flag review records. These counts are not source-audited production libraries; Character Picture Mode has zero licensed images. Requested production targets (12,000 quiz questions, 10,000 English words, 760 character/personality entries and 195 flags) remain unmet. Riddles and Memory are discontinued and are not active content targets.

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
| `flutter3d` / Flutter GPU | Very recent package. Flutter's engine documentation calls Flutter GPU early preview, API-unstable, Impeller-dependent and recommends Flutter master; Windows support is not established by this app's own proof. | Do not base the production app on it without substantial stability evidence; not selected. |

### Renderer proof gate (still open)

Before final selection, build an isolated proof against the current stable Flutter SDK and existing Windows/Android toolchains. Load one correctly licensed rigged glTF model; render it inside the Flutter app on Windows and an Android device/emulator; rotate the camera with mouse/touch; play a skeletal clip; change a material at runtime; record startup/render errors, binary impact and measured frame-time/FPS for both. Do not call a standalone engine demo or static image a Flutter integration proof. Record exact model attribution/license and hashes. If the proof fails any target or capability, revise the renderer choice before avatar production work.

No proof was attempted in this audit. A full 3D production asset is also absent; the user-provided mascot is a 2D portrait reference, not a rigged model. No supplied asset license/provenance file was present in the archive.

### Primary technical sources reviewed

- [Google Filament repository and supported APIs/backends](https://github.com/google/filament) and its [native swap-chain platform window contract](https://github.com/google/filament/blob/main/filament/filament/include/filament/SwapChain.h).
- [Flutter platform integration](https://docs.flutter.dev/platform-integration).
- [`flutter_filament` implementation notes and feature limits](https://github.com/jarrodcolburn/flutter_filament).
- [`stage_3d` current support statement](https://pub.dev/packages/stage_3d).
- [Flutter GPU engine documentation](https://github.com/flutter/flutter/blob/master/docs/engine/impeller/Flutter-GPU.md) and [`flutter3d` package metadata](https://pub.dev/packages/flutter3d).
- [Khronos glTF sample asset catalog](https://github.com/KhronosGroup/glTF-Sample-Assets); each sample's own license must be checked before use (some include separate trademark restrictions).

## Completion state and next work

Repository/reference audit and chapter mapping are complete. Milestone 1 remains **IN PROGRESS** until the renderer proof gate passes and a documented architecture decision is made. The next implementation task is the isolated Filament bridge proof, not replacement of the current renderer with an unverified package and not the complete avatar editor. After that, proceed through the user's milestones in order: app shell; verified 3D; session builder/storage; modules; validated content; localization/settings; integration and platform QA.

The complete content targets remain zero verified playable entries for Quiz, Word Play, Character, Riddles and Memory in the current repository. Guess the Country has seven review records, not a production count. No 1,000-person, 5,000-word or 10,000-question content claims are supported by the repository.

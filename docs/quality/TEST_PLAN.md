# Roundveil test strategy

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Test pyramid
1. **Pure Dart unit:** GameRuntime state transitions, module reducers, timing/deadline service, seeded order, config validation.
2. **Storage/repository:** Drift migration, transaction atomicity, restore snapshots, private-vs-official content isolation.
3. **Flutter widget/golden:** visual tokens, theme variants, Windows/Android responsive compositions, focus/touch states (UX-approved screens only).
4. **Integration/device:** configure, play, interrupt, resume and complete sessions on Windows and Android.
5. **Simulation:** tens of thousands of deterministic player/round scenarios for deadlocks, fairness and repetition policy.

## Mandatory behavioral cases
| ID | Test |
|---|---|
| T-001 | One correct answer starts Win Countdown in same logical result transition |
| T-002 | Wrong result never starts countdown |
| T-003 | Challenge timeout never starts countdown |
| T-004 | Repeated Correct/timeout callbacks do not cause duplicate countdown |
| T-005 | Guess Character hidden before reveal, visible during clues and final guess |
| T-006 | Player physically turned away is instructed to stay away through judgement |
| T-007 | Image mode never renders identifying name; name mode doesn't require image |
| T-008 | Host configuration rejects module/category/content incompatibility |
| T-009 | Offline session plays to completion with network disabled |
| T-010 | Pause/recovery preserves correct phase and time, including Win Countdown |
| T-011 | Removing/migrating official content doesn't delete user data |
| T-012 | Both platforms run same sample event trace to same domain state |
| T-013 | All active docs/game/module registries exclude Mystery mode |
| T-014 | No copy of old rejected UX reaches functional app as 'approved' |
| T-015 | Guess the Country validates canonical names and curated aliases, while rejecting alias collisions and unconstrained fuzzy matches |
| T-016 | Guess the Country honors configured difficulty, region/worldwide scope and versioned inclusion policy |
| T-017 | Guess the Country avoids repeated eligible flags until the unseen pool is exhausted; insufficient-pool validation is explainable |
| T-018 | Guess the Country shows no country name before spoken response; host reveal follows the response and host judgement gates the outcome |
| T-019 | Installed flag assets are licensed, hashed, available offline, preserve audited aspect ratios/colors and are never emoji-rendered |
| T-020 | Guess the Country correct result starts one immediate Win Countdown; wrong/timeout starts none, including after pause/restore |
| T-021 | Guess the Country does not show choices or text entry and does not use automatic speech recognition to award success |
| T-022 | Platform shell Home -> Create Game navigation and responsive compact home |
| T-023 | Single/mixed module constraints, explicit player/round setup and saved session creation |
| T-024 | Quick Game templates are editable configuration seeds, not fake gameplay screens |
| T-025 | Local drafts survive repository reload and support edit/duplicate/delete operations |
| T-026 | App locale list contains the 12 requested locales, including RTL languages and `zh-Hans` |
| T-027 | Active catalog, Create Game, Quick Game and mixed templates expose exactly Quiz, Word Play, Guess the Character and Guess the Country |
| T-028 | Legacy drafts containing retired module IDs remain stored and flagged; editing filters only retired IDs while preserving other draft values |
| T-029 | Player callsign and appearance edits update the durable local profile and remain available to the pre-match player picker |
| T-030 | One game/category/format is shared by all players within a round; challenges are unique; change occurs only at round boundary |
| T-031 | Quiz-only schedules rotate among MCQ, True/False, Fill Blank and Short Answer without introducing guessing modules |
| T-032 | Guessing Games can select Character, Country or both while remaining a single-family session; enabled formats are round-scheduled |
| T-033 | Word Play-only schedules stay within Word formats; only Mixed Games crosses game families |
| T-034 | Unknown/unavailable draft formats are preserved and flagged; host can remove the unsupported entry and choose a valid format |
| T-035 | Hint debit uses the active saved player's stable ID and does not affect other players' balances |
| T-036 | A complete 3-player × 4-round Mixed session keeps module and format common within each round, draws distinct player challenges, applies correct/wrong outcomes, persists hint rewards, and produces deterministic rankings |
| T-037 | All four Word Play formats accept typed answers; Guess the Word's optional hint is distinct from its visible clue; scramble contents match the answer letters |
| T-038 | A duplicate callsign create/rename is rejected case/whitespace-insensitively, existing profiles remain unchanged, and the serialized repository accepts a later valid operation |
| T-039 | Pause exposes Resume, Restart and Leave Match; restarting reuses the same configuration; results expose Play Again and Home; Windows additionally exposes Quit Game |
| T-040 | Android alpha debug runtime installs over the existing app, reaches a visible landscape home, accepts a real Word Play answer, and shows the configured correct-answer countdown |
| T-041 | Guessing Games exposes Character Name/Picture, Country Name/Flag and Object Name/Picture as distinct formats without adding a top-level game family |
| T-042 | Object Name turns the active player away, shows clue-givers the name/category/use context, uses the shared hint and judgement flow, and starts countdown only after Correct |
| T-043 | Object Picture only selects valid bundled/private offline images, filters by selected category, never falls back to metadata-only records, and displays image before host judgement |
| T-044 | Object Name and Picture use distinct object IDs without repeats; insufficient selected-category capacity is explained; both quick templates and Create Game can start their explicit format |
| T-045 | Metadata-only summary used by the Guessing Games picker does not copy or seed the full bundled photo library; full image validation remains part of match setup |

## Tool commands when Flutter scaffold exists
```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test # only after integration tests and supported devices configured
```
Run on Windows/Android as applicable; never report success if commands were not executed. Capture tool versions, OS/device and command exit codes in `PROJECT_STATUS.md`.

## Visual QA
Screenshots reference *styling* only, not interactions; compare real Flutter widgets at representative resolutions to Paper Stage/Hero Arena source images. Audit contrast, scaling and focus separately.

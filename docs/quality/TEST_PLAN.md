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
| T-018 | Multiple-choice country options are distinct canonical IDs and contain one eligible correct answer |
| T-019 | Installed flag assets are licensed, hashed, available offline, preserve audited aspect ratios/colors and are never emoji-rendered |
| T-020 | Guess the Country correct result starts one immediate Win Countdown; wrong/timeout starts none, including after pause/restore |

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

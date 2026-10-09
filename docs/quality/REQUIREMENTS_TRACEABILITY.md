# Requirements-to-tests traceability

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Why this exists
Protect non-negotiable product rules from accidental rewriting by a coding agent. Update mappings when automated tests are written. The **test IDs are planned**, not claims about existing files.

| Requirement | Authoritative doc | Proposed test | Current evidence |
|---|---|---|---|
| Host config before start | `HOST_CONFIGURATION.md` | T-008 + builder integration | NOT IMPLEMENTED |
| Correct -> immediate Win Countdown | `TIMERS_AND_WIN_COUNTDOWN.md` | T-001, T-004 | NOT IMPLEMENTED |
| Wrong/timeout skips countdown | `TIMERS_AND_WIN_COUNTDOWN.md` | T-002, T-003 | NOT IMPLEMENTED |
| Guess Character stays visible through final guess | `games/GUESS_THE_CHARACTER.md` | T-005, T-006 | NOT IMPLEMENTED |
| Name/image only presentation | `games/GUESS_THE_CHARACTER.md` | T-007 | NOT IMPLEMENTED |
| Guess Country modes and answer validation | `games/GUESS_THE_COUNTRY.md` | T-015, T-018 | DOCUMENTED ONLY |
| Guess Country policy, scope, difficulty and no-repeat selection | `games/GUESS_THE_COUNTRY.md` | T-016, T-017 | DOCUMENTED ONLY |
| Licensed offline flags and native proportions | `games/GUESS_THE_COUNTRY.md` | T-019 | DOCUMENTED ONLY |
| Guess Country Win Countdown result rules | `games/GUESS_THE_COUNTRY.md` | T-020 | DOCUMENTED ONLY |
| Category/module compatibility | `CATEGORIES_AND_DIFFICULTY.md` | T-008 | NOT IMPLEMENTED |
| Offline & recovery | `OFFLINE_AND_RECOVERY.md` | T-009, T-010 | NOT IMPLEMENTED |
| Separate data stores | `DATA_MODELS_AND_STORAGE.md` | T-011 | NOT IMPLEMENTED |
| Both OS engines agree | `WINDOWS_ANDROID_BEHAVIOR.md` | T-012 | NOT IMPLEMENTED |
| Mystery removed | `SCOPE_AND_NON_GOALS.md` | T-013 | DOCUMENTED ONLY |
| Visual only approved / UX rejected | `UI_APPROVAL_STATUS.md` | T-014, manual approval | DOCUMENTED ONLY |

## Maintenance
Add source-code and actual test-file links when they exist. Keep statuses truthful; do not mark tests PASSED because documentation says what to test.

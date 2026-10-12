# Game module catalog

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Implement only explicitly approved modules
- [`QUIZ.md`](QUIZ.md) — multiple choice/true-false reference module.
- [`WORD_PLAY.md`](WORD_PLAY.md) — word games family; Word Scramble first reference.
- [`GUESS_THE_CHARACTER.md`](GUESS_THE_CHARACTER.md) — correct physical turn-away reveal mechanics.
- [`GUESS_THE_COUNTRY.md`](GUESS_THE_COUNTRY.md) — offline flag-only, spoken answer with host reveal/judgement under the current rebuild directive.

Riddles and Memory were removed from the active product by ADR 0005. Their prior specs are retained as superseded historical records only; their 2,000-screen archive references are obsolete and excluded from implementation.

**Excluded forever unless user explicitly reverses decision:** Mystery, detective/investigation, case files, evidence and suspect deduction games.

Every module should link the common [`GAME_MODULE_INTERFACE.md`](../GAME_MODULE_INTERFACE.md) and [`TIMERS_AND_WIN_COUNTDOWN.md`](../TIMERS_AND_WIN_COUNTDOWN.md). The catalog lists *types*, not pre-made sessions.

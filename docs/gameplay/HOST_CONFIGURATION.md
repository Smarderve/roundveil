# Host configuration contract

> **Status:** ACTIVE requirements / UX BLOCKED<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Host responsibility
A session **must** derive from a host-reviewed `SessionConfig`. The host chooses/accepts all meaningful settings prior to play: active players, game type(s), topic/category pools, rounds, difficulty options, module-specific rules, timer durations, scoring choice and Win Countdown duration.

## Conceptual configuration model
```yaml
session:
  mode: mixed # or single
  player_ids: [player_1, player_2, player_3]
  rounds:
    - game_module_id: quiz
      category_ids: [animals]
      difficulty: medium
      module_options: {question_format: multiple_choice}
    - game_module_id: guess_character
      category_ids: [fictional_characters]
      module_options: {presentation: image, final_guess_only: true}
    - game_module_id: guess_country_flags
      category_ids: [worldwide]
      difficulty: mixed
      module_options: {answer_mode: multiple_choice, inclusion_policy: un_members_only, hints_enabled: false}
  rules:
    player_order_policy: balanced_random # proposal, configurable
    scoring_enabled: false # illustration only; NOT an approved default
    win_countdown_seconds: null # HOST MUST resolve or accept a default before starting
```
**This YAML is illustrative schema only; not an approved preset, timer value or mandatory flow.** Use typed Dart configs and validation in implementation.

## Validation
Before start: at least one active player, at least one configured round, every module installed, each module compatible with requested categories/language, enough eligible content to satisfy repeat rules, nonnegative/valid timer bounds, no contradictory options. Guess the Country additionally requires a resolved inclusion policy, installed licensed flag assets, a non-empty scope/difficulty pool, and curated names/aliases for host judgement. Its current target is spoken-answer/host-reveal, not typed or multiple-choice. Give understandable corrections rather than secretly substituting modes or filling fake content.

## Host control lifecycle
- Pre-session: change, cancel, save personal preset, preview and explicitly start.
- During session: pause/resume, judge manual answers, skip/restart/undo actions where safe, and end game with confirmation.
- Hostless play or handoff to clue-givers is a **candidate requiring approval**; don't invent it.
- Presets are **host-saved configurations**, not built-in playable matches.

## UX status
**BLOCKED:** the previously shown wizard and premade game tiles were rejected. This file specifies *capabilities and data integrity*, not the approved placement/order of controls. Await UX decisions for the concrete builder experience.

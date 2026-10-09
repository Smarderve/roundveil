# Modular game type contract

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Goal
New modules should plug into GameRuntime with no central `if (module == ...)` logic. Each game type contributes a descriptor, supported configuration, challenge phases, presentation data and a pure action reducer/evaluator.

## Suggested Dart-facing interfaces (PROPOSAL)
```dart
abstract interface class GameModule {
  GameModuleDescriptor get descriptor;
  ValidationResult validateConfig(ModuleConfig config);
  ModuleState prepareTurn(ModuleContext context, ContentItem content);
  ModuleTransition handleAction(ModuleState state, ModuleAction action);
  ModuleTransition onDeadline(ModuleState state, DeadlineId expired);
}

class ModuleTransition {
  final ModuleState next;
  final List<ModuleEffect> effects;
  final TurnOutcome? outcome; // success, failure, skip, timeout
}
```
Types are architectural pseudocode: implement after reviewing exact source tech spec, selected packages and Dart language/version.

## Module owns
- Supported content types and category compatibility.
- Validatable game-specific settings, phase names, allowed actions and presentation data.
- Rules for solution evaluation or requesting human judgement.
- Deadline requests for clue/question/final-guess phases.
- Deterministic selection/evaluation rules for module content, including alias and asset-integrity checks where the module requires them.

## GameRuntime owns
- Player order, turn identity, round progression, shared pause/recovery, event durability, Win Countdown, scoring policy and host command authorization.
- A module reports success; **it must not start the Win Countdown or directly control app navigation**.
- The module cannot perform networking, write directly to user.db, or display Flutter widgets in pure-domain implementation.

## Error boundaries
Unknown actions rejected without corrupting session; duplicate answer idempotent; stale timer events ignored; missing content produces a recoverable host-visible error; manual judgement only accepted during appropriate phase. Version module state for recovery.

## Required contract tests
`prepare->start->correct`, `wrong`, `timeout`, `pause->resume`, `duplicate action`, `expired stale timer`, `invalid config`, `missing asset`, `restore mid-turn`; Guess the Character adds a never-hide identity assertion. Guess the Country adds canonical/alias validation, policy/scope eligibility, no-repeat selection where enough content exists, multiple-choice uniqueness, native-ratio asset verification and no-countdown-after-failure assertions.

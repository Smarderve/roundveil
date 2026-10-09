# Technical architecture — Flutter shared game platform

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Authority and supersession
Based on the 2026-10-08 technical architecture planning draft for Windows+Android. It retains shared runtime, modular game types, two local stores, timer safety and platform adapters. **Supersedes its Mini Mystery reference module and any desktop-first rollout assumptions.** See scope ADRs.

## Conceptual layers
```text
Flutter Presentation (Windows layout / Android layout)
    -> Application/controllers (Riverpod) + approved UX actions
        -> Pure Dart GameRuntime and GameModule contracts
        -> Content selection/domain services
            -> Drift repositories: user.db + content.db
        -> Platform adapters: audio, window, lifecycle, media
```
The GameRuntime is authoritative within one local session. It coordinates configured rounds, turns, module states, host actions, timer arbitration and immediate Win Countdown. Presentation observes immutable state and dispatches typed actions; it never acts as the only source of game truth.

## Initial technology direction
| Concern | Decision |
|---|---|
| Framework | Flutter/Dart shared Windows + Android source |
| State | Riverpod providers/controllers (exact version later) |
| Storage | SQLite with Drift mapping and migrations |
| Routing | `go_router` candidate only when UX approved |
| Media | Local images/audio with preload/cache |
| Game engine | Pure Dart state machine and module reducers |
| Testing | `flutter_test`, Dart unit tests, integration tests |

## Suggested packages/workspace (not a mandated final tree)
```text
lib/
  app/                   # bootstrap, routing, dependency wiring
  core/                  # error types, clocks, IDs, localization
  domain/runtime/        # session/round/turn/outcomes, pure Dart
  domain/modules/        # quiz, word_play, guess_character, ...
  domain/content/        # content selection and compatibility
  data/                  # Drift stores and repository implementations
  features/              # approved UI flows only
  design_system/         # Paper Stage / Hero Arena tokens + controls
  platform/              # Windows/Android adapters
assets/design_references/ # DO NOT ship with production binary
```

## Runtime command pattern
`Command + Context -> Validation -> New immutable State + Effects/Events`, durable checkpoint after meaningful transition. Module result `correct` causes countdown *within same transition*; no UI callback should be responsible for starting it.

## Scale wisely
No backend, API, accounts, WebSockets or CMS necessary for first offline playable. Design for adding locally downloadable content later; do not build cloud plumbing yet.

## Platform guarantee
Windows and Android share all gameplay semantics. Differences limited to adaptive presentation, file picker, haptics, wake lock, window management and interruption handling.

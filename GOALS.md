# ROUNDVEIL — Product goals

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Product promise
Create an unmistakably **premium game-like** social experience for players who are physically together, on one Windows or Android device. The host controls what they play; the system manages turns, content, judgement routing and clocks.

## Success criteria
1. **Fun before complexity:** usable by a host who has never opened a technical settings dashboard. Precise final UX awaits approval.
2. **Full host authority:** all materially relevant configuration is chosen or explicitly accepted before the session; no surprise default premade match.
3. **Multi-module system:** Quiz, Word Play, Guess the Character, Guess the Country (Flags) and later-approved games run on the same GameRuntime; no Mystery.
4. **Fast result:** correct resolution switches straight to Win Countdown, not a separate success page.
5. **Offline-first:** a session completes with networking disabled after necessary content is installed.
6. **Windows/Android parity:** same rules, saves, content and timers; layouts and input mechanisms adapt.
7. **Trust:** autosave, interruption recovery, deterministic turn history, permission-gated host actions.
8. **Identity:** Paper Stage/Felix-inspired and Hero Arena/Overwatch-inspired visual language without copying old UX.

## How we measure
- Functional state-machine and timer tests pass, including correct/wrong/timeout branches.
- A new reference module can be added without editing GameRuntime core to add game-specific `if` chains.
- Manual Windows keyboard/mouse and Android touch QA both succeed.
- UX sign-off is recorded as a decision before implementation; no guessed gameplay UX shipped.
- A host can replay with different settings and locally stored/compatible content.

## Non-goals
Online accounts, multiplayer networking, public content marketplace, cloud backend, monetization, game-shop UI, microtransactions, physical-food features and Mystery/investigation games are not initial goals. See [`docs/product/SCOPE_AND_NON_GOALS.md`](docs/product/SCOPE_AND_NON_GOALS.md).

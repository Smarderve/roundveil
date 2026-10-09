# Game module: Memory and matching

> **Status:** PROVISIONAL — MODULE CONTRACT ONLY<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **PROVISIONAL.** The user wants Memory among available game types; exact game mechanics/visual arrangement are still undecided.

## Candidate mechanics
Pattern recall, flipped-pair matching, timed object recall and short sequence memory. These are alternative designs, not confirmed modes to ship automatically.

## Shared contract
A module prepares a validated set of local media/text stimuli, declares reveal and response phases, tracks selections and emits success/failure. Timer variants should use the shared timer service. Correct triggers the shared Win Countdown immediately.

## UX safety/accessibility
Provide non-drag alternatives, don't rely solely on color matching, account for touch targets and screen size, preload images/audio, and preserve revealed/hidden state across interruptions.

## Decisions required
Board sizes; time allowed to memorize; whether players view the full board simultaneously; scoring; solo vs group turns; accepted response methods; penalties after mistakes. Mark these pending before Codex builds interaction screens.

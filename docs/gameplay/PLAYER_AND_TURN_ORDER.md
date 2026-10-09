# Players, rounds and fair turn order

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Player model
Stable ID, display name, avatar reference, optional custom image, saved/guest status, and optional participation stats. Initial demo labels must be **Player 1**, **Player 2**, **Player 3**, etc.; replace only when host edits them. Never seed invented personal names.

## Turn assignments
Each configured round specifies eligible players and a turn-order policy. Candidate modes: balanced seeded shuffle, manual order, fixed order and constrained random order. The host must choose/accept a policy; defaults are product decisions. Keep a record of generated permutations and seed for replay/recovery.

## Balanced random intent
Reduce repeated first-player advantage over many rounds without biasing gameplay by identity. Fairness constraints must be observable and testable; don't claim uniform randomness if positional smoothing is active. For small N and large R, simulate distributions and define tolerated variance.

## Changes mid-session
Add/remove/skip a player only via authorized host commands; update future assignments while preserving completed event history. If a player is removed during an active turn, define deterministic cancellation/skip without accidentally counting a win.

## Presentation requirements
Prominent active-player identity, visible next-player cue if approved, readable at room distance on Windows and phone close-up on Android. Visual roster layouts themselves are **pending UX approval**.

## Tests
1 player edge case; duplicate display names; long names; add/remove in paused session; stable save/restore order; fairness simulations (1000+ rounds); no player skipped from persisted ordering unexpectedly.

# ADR-0004 — Local-first runtime and separate data stores

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

- **Status:** ACCEPTED ARCHITECTURAL DIRECTION
- **Decision date:** 2026-10-08

## Context
A group must be able to play even when internet service is unavailable. Private custom family information should not be mixed into distributable official content packs.

## Decision
Authoritative GameRuntime runs on-device. Separate household/user state (`user.db`) from official content (`content.db`) and use versioned migrations. Network update services and accounts are deferred. Correct result transitions to Win Countdown must not wait on remote systems.

## Consequences
Better offline behavior and privacy; requires reliable snapshot transactions, local media preparation and cross-platform file-path handling. SQLite/Dart storage choices should be validated with tests as implementation proceeds.

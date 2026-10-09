# ADR-0002 — Remove Mystery/investigation game modes

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

- **Status:** ACCEPTED — HARD EXCLUSION
- **Decision date:** 2026-10-09

## Context
An early feature brainstorm and source technical specification included a Mini Mystery investigation module, case data and suspect/evidence UI. The user explicitly instructed: **“Remove the mysteries game shit.”**

## Decision
Exclude Mystery/investigation games and assets from ROUNDVEIL active scope, future UI navigation, Dart modules, data schemas, content packs, documentation requirements, unit tests and planned release phases. The old reference screenshots depicting those layouts remain historical evidence only and **are not shipping product references**.

## Consequences
Remove the old Mini Mystery architecture as authoritative; no `mystery` module or `case/evidence/suspect` persistence in active implementation. If user ever reverses this decision, require explicit approval/new ADR first.

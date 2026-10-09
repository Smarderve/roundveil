# ADR-0001 — Shared Flutter/Dart application

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

- **Status:** ACCEPTED (architectural direction)
- **Decision date:** 2026-10-08

## Context
ROUNDVEIL must function on Windows desktop and Android while sharing rules, content selection and timing. Maintaining two independent apps would risk inconsistent game results and duplicated engineering.

## Decision
Use Flutter/Dart for shared presentation and domain, with a **pure Dart GameRuntime** independent of Flutter widgets, and platform adapters for OS-specific interactions. Local SQLite/Drift and Riverpod are the initial architecture choices. iOS would require macOS/Xcode if added later.

## Consequences
Consistent cross-platform semantics, a single module contract and one release-focused codebase; Android/Windows device testing and adaptive UI design still required. UI approval is a separate process; this ADR does not approve old HTML flows.

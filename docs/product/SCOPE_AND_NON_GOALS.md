# Scope, exclusions and supersession

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## The active scope
One-device host-configured multiplayer sessions; game types including Quiz, Word Play, Guess the Character, Guess the Country (Flags), Riddles and Memory; shared GameRuntime, robust clocks, Win Countdown, profiles, local content, settings, recovery and responsive visual themes. The 2026-10-11 user directive authorizes the staged platform rebuild. Guess the Country's current target is flag-only, spoken answer and host reveal/judgement; the old multiple-choice/typed candidate must be replaced.

## Hard exclusions
1. **Mystery/investigation**: no “Solve the Mystery”, crime cases, suspects, evidence boards, detective content, mystery assets, module registration, tests or navigation.
2. **Physical consumption/reward**: no in-app food, permission-to-eat mechanic, eating countdown interpretation, tokens, rewards or tracking physical actions.
3. **Premade sessions as core UX**: selectable game *types* and host-saved presets are allowed, but the app must not replace host setup with manufacturer-provided ready-made matches.
4. **Rejected UX**: do not copy flows, menus, game placement, or interactions from Felix/Overwatch HTML demos; visual language only is liked.
5. **Unapproved networking**: no required backend, cloud account, online real-time multiplayer or payment/store in initial build.

## Deferred candidates (not permissions to build)
Future iOS/macOS, multiplayer mobile controllers, downloading official packs, automated speech assessment, public profiles and cloud backup require separately approved specs.

## Superseded historical material
Product spec v0.2 and technical architecture v0.1 previously described a Mini Mystery; that content is obsolete. Some older functional text described desktop-first rollout; the active target is **Windows AND Android** via one Flutter codebase. This file and `docs/decisions/0002-remove-mystery-mode.md` take precedence.

## Scope-change procedure
A previously excluded mode or feature may be reintroduced only with a direct, explicit user decision, updated ADR, impact analysis, and tests. Agents cannot infer consent from old screenshots or archive documents.

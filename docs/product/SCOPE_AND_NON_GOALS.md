# Scope, exclusions and supersession

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## The active scope
One-device host-configured multiplayer sessions with exactly four core game types: Quiz, Word Play / Guess the Word, Guess the Character, and Guess the Country (Flags); shared GameRuntime, robust clocks, Win Countdown, profiles, local content, settings, recovery and responsive visual themes. By the 2026-10-12 approved decision, Riddles and Memory are removed from the active product. Guess the Country's target is flag-only, spoken answer and host reveal/judgement; the old multiple-choice/typed candidate must be replaced.

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

The 2,000-screen design archive remains unchanged. Riddles and Memory concepts in that archive are obsolete references and excluded from implementation; see ADR 0005.

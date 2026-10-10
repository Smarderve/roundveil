# ROUNDVEIL — Codex working instructions

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## What you are building
ROUNDVEIL is an offline-first, host-configured, shared-screen, multi-game family party platform for **Windows desktop and Android**, using one Flutter/Dart codebase. During a turn the app acts as the referee. Physical actions happen in the room. A successful turn triggers the **Win Countdown immediately**; no in-app food, reward or eating tracking exists.

## Never violate these product boundaries
- **No Mystery or investigation game**, evidence, crime, detective, suspect-case or mystery module. Historical sources may mention these: they are superseded.
- Never use invented sample names; use `Player 1`, `Player 2`, `Player 3` and so forth until the host customizes them.
- The **host configures** players, selected game types, categories, rounds, applicable rules, challenge timers and Win Countdown. A game *type* is not a premade game session.
- Guess the Character: **active player physically turns away before reveal**; name-only or image-only is shown to the other people and **stays visible during clues AND final guess**; player stays turned away until judgement; correct -> immediate Win Countdown.
- Guess the Country (Flags): a separate offline module; the current rebuild target is flag-only, spoken answer, then host reveal and judgement (no multiple-choice, typed-answer UI or speech-recognition award). Keep host-selected difficulty/scope/timer/hints and versioned territory policy. Use only licensed local flag assets with audited native proportions; never emoji flags or live flag APIs. Correct judgement -> immediate Win Countdown; wrong/timeout -> none. See `docs/architecture/ROUNDVEIL_REBUILD_AUDIT.md` for the migration gap.
- Visual styling of the user-provided **Felix-inspired Paper Stage** and **Overwatch-inspired Hero Arena** prototypes is liked; their navigation, UX flow and game presentations are **rejected**. Treat screenshots as visual-only references.
- Do not invent pending UX decisions or call a draft/placeholder an approved screen. Do not ship copyrighted assets from other games.

## Document loading — read only what applies
1. `docs/00_DOCS_INDEX.md` for authority, statuses and links.
2. Gameplay tasks: `docs/gameplay/GAME_DESIGN_SPECIFICATION.md` plus one specific module document.
3. UI tasks: `docs/design/UI_APPROVAL_STATUS.md`, `docs/design/UI_COMPONENT_LIBRARY.md` and relevant visual references. **Don't infer flow from images.**
4. Architecture tasks: `docs/architecture/TECHNICAL_ARCHITECTURE.md` and applicable storage/platform docs.
5. Work planning: `PLANS.md`; then specific testing: `docs/quality/TEST_PLAN.md`.

## Software engineering rules
- Pure Dart game domain independent of Flutter UI and platform APIs. Modules receive actions/state and emit outcomes; **GameRuntime** controls turn/round progression and the Win Countdown.
- Offline gameplay must not depend on cloud or account login. Keep custom family photos/content local by default.
- Use typed models, small cohesive files, dependency injection and automated tests; do not create giant controller classes or hard-code demo content in screens.
- Update documentation only to reflect approved changes or verified implementation; preserve decision history in ADRs.
- Before changes: inspect git status and relevant files; do not overwrite unrelated user work. After changes: run `dart format`, `flutter analyze`, relevant tests, and state failures truthfully.
- Do not commit, push, deploy, delete user files or install costly services unless directly authorized by the user's task. Avoid unnecessary token-intensive broad scans; finish requested scope.

## Status handling
`ACTIVE` = approved principle/specification; `PROVISIONAL` = a candidate that still needs host/product approval; `BLOCKED` = do not implement functional UX until decided. `PROJECT_STATUS.md` records verified reality, not aspirational progress.

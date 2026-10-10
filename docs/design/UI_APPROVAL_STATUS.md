# Visual approval boundary — READ FIRST

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Locked decision
The user **liked only the visual/UI styling** of the uploaded Felix-inspired (`FamilyGame_Felix.html`, Paper Stage) and Overwatch-inspired (`FamilyGame_Overwatch.html`, Hero Arena) prototypes. The user **did not like their UX, navigation, game placement, session building or gameplay**. This distinction is binding.

| Area | Status | Meaning |
|---|---|---|
| Felix-inspired colors, typography attitude, edges/texture, component visual direction | VISUAL REFERENCE LIKED | style source; adapt, don't copy app functionality |
| Overwatch-inspired colors, typography attitude, slants, high-impact hierarchy, HUD aesthetic | VISUAL REFERENCE LIKED | style source; adapt, don't copy app functionality |
| Exact visual assets (screenshots/HTML) | REFERENCE ONLY | do not ship copyrighted external game assets or prototype logic |
| Old HTML navigation, screen order and game cards | REJECTED | never adopt as UX specification |
| Old HTML session-builder screens | REJECTED | host configuration capability approved, **not** that UI flow |
| Old HTML playable module screens | REJECTED | do not copy quiz/word/character demos as game design |
| Mystery screen/content in old references | EXCLUDED | no functional Mystery module or visuals in product |
| Final game visual theme selection and mixing | PENDING | preserve two alternatives; don't merge unasked |
| Actual UX for desktop and Android | REBUILD DIRECTIVE ACTIVE; individual concept images remain unapproved | implement direct user requirements; do not copy old rejected HTML or infer mechanics from art |

## 2026-10-11 rebuild directive reconciliation
The user has explicitly authorized a complete staged product implementation against the new master requirements. This supersedes the earlier blanket stop on building new functional flows, to the extent the direct requirements define them. It does **not** approve the 2,000 exported screen concepts individually: the archive manifest labels all 2,000 `UNAPPROVED VISUAL CONCEPT`. Use them for feature/state coverage and visual exploration only. Preserve the approved V5 home, logo and mascot references; implement the directly specified product flows without copying rejected HTML behavior or treating concept images as finished screens. See `../architecture/ROUNDVEIL_REBUILD_AUDIT.md`.

## Safe use of screenshots
Screenshots under `assets/design_references/` illustrate **visual properties only**: spatial hierarchy, border style, palette, high/low emphasis, button silhouette, typography feeling, atmospheric surfaces. Even if a screenshot shows a setting or game control, it does not authorize that control's location, behavior or data.

## Rule for Codex
Before implementing a complete interactive UI: find the active, approved UX spec and `GAME_DESIGN_SPECIFICATION.md`. If the UI specification is absent, implement design-system widgets/storybook previews only, or seek approval; do not resurrect the old HTML JS. See `docs/decisions/0003-ui-approved-ux-pending.md`.

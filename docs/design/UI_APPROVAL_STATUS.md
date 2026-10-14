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

## 2026-10-11 visual-source correction
The user has explicitly designated `ROUNDVEIL_2000_Screens_Compact_WebP.zip` as the primary visual design source for the entire game. Implementations must use the archive's actual screen imagery to guide composition, character placement, palette, graphics, navigation, typography, motion and interactive affordances; do not substitute generic Flutter/Material layouts. The separately approved full-resolution Version 5 home is authoritative for the main menu and must not be redesigned. The archive's 2,000 screens remain labeled `UNAPPROVED VISUAL CONCEPT` individually: this does not authorize copying their gameplay behavior or declaring a screen approved. Treat the archive as visual authority and approved gameplay specifications/direct user requirements as behavior authority. The 2026-10-11 direct correction also supersedes the prior advice to use those screens only as general visual exploration. See `../architecture/ROUNDVEIL_REBUILD_AUDIT.md` for chapter mapping and review limits.

## Safe use of screenshots
Screenshots under `assets/design_references/` illustrate **visual properties only**: spatial hierarchy, border style, palette, high/low emphasis, button silhouette, typography feeling, atmospheric surfaces. Even if a screenshot shows a setting or game control, it does not authorize that control's location, behavior or data.

## Rule for Codex
Before implementing a complete interactive UI: find the active, approved UX spec and `GAME_DESIGN_SPECIFICATION.md`. If the UI specification is absent, implement design-system widgets/storybook previews only, or seek approval; do not resurrect the old HTML JS. See `docs/decisions/0003-ui-approved-ux-pending.md`.

## 2026-10-11 Version 5 reconstruction candidate
The live Flutter home candidate has Android runtime evidence at `../evidence/v5_reconstruction_2026-10-11/`. The approved V5 source is a flattened screenshot: the environment/hero plate is a generated reconstruction, while the squad portraits and game artwork use crops from the supplied reference. This candidate is **not approved** and must be reviewed against the full-resolution source before any approval status changes.

## 2026-10-13 layered home/player-art candidate
The current implementation now uses separate Flutter controls over a standalone arena environment and distinct 2D player-character artwork. The four active game tiles use their own original art assets; none of the source screenshot is embedded as a fake interactive screen. A saved appearance selects/tints a 2D illustration and can overlay an accessory. This remains a static 2D candidate, not genuine 3D or source-exact art reconstruction.

Evidence: `../evidence/v5_lobby_character_rebuild_2026-10-13/v5_side_by_side.png`, Android runtime `../evidence/v5_lobby_character_rebuild_2026-10-13/android_home_final.png`, and Windows runtime `../evidence/v5_lobby_character_rebuild_2026-10-13/windows_home.png`. The comparison documents meaningful differences: the supplied logo asset has a black backing, the central avatar/composition does not match the V5 hooded hero, the reference squad has four players while the captured lobby has two saved players plus an add slot, and the captured Windows view clips the right actions and does not show the bottom game rail. Android shows the four illustrated modes but includes system bars and differs in aspect ratio. The candidate is **not approved**; do not mark it visually faithful or approved until these gaps are reviewed and addressed.

## 2026-10-14 responsive Home lobby candidate
The Home composition now uses responsive side zones for squad and profile/actions, a centered static 2D character, and three enlarged interactive game-entry panels for Quiz, Word Play, and Guessing Games (the latter preserves the existing Character/Country route). In compact landscape, the third player/add slot is visible after removing the redundant remove-last action; individual player removal remains available. This work does not change game state or routes.

Actual runtime evidence: `../evidence/home_lobby_rebuild_2026-10-14/windows_home.png`, `../evidence/home_lobby_rebuild_2026-10-14/android_home.png`, and Android Quiz entry `../evidence/home_lobby_rebuild_2026-10-14/android_quiz_entry.png`. Desktop capture was 1267×713; Android was 2400×1080 physical / 915×412 logical landscape. The Windows Add Player slot was clicked and the player count advanced; Windows and Android Quiz selections opened the existing Quiz round-entry screen.

**Still unapproved and not source-exact.** Compared with `assets/brand/approved_home_v5_scene_source.webp`, the runtime has a simpler dark indoor stage instead of the bright layered city arena, a static 2D woman character rather than the large hooded ROUNDVEIL mascot, and a baked dark rectangle behind the supplied logo. Android system bars remain visible. The candidate is a functioning responsive layout iteration, not a faithful reconstruction or a verified 3D character experience. Do not change approval status until the owner reviews these runtime images and the remaining art-source gaps are resolved.

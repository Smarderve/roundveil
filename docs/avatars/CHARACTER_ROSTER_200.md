# ROUNDVEIL character roster target (200 total)

**Status: IN PROGRESS.** The target is 200 total unique, selectable characters. This page inventories registered characters only; target-only slots are intentionally not represented as fake records.

## Verified repository inventory — 2026-10-15

- **38** stable IDs are registered by `PlayerAvatarCatalog`.
- Those entries reference **68** distinct still-image paths: one image for each of the first eight entries, and full-body plus portrait art for the remaining 30.
- A filesystem audit found all 68 referenced paths present and 68 distinct SHA-256 file hashes. This proves path/file presence and byte-level distinction only; it is not proof that every character is visually unique or acceptable.
- The catalog has **0** idle-animation video paths and **0** individual background-video paths.
- Windows and Android media playback has not yet been runtime-verified.
- Two IDs currently share the display label `UNIVERSITY STUDENT`; display names are role labels, not sufficiently distinct character identities. Review and distinguish these before calling the roster 38 genuinely unique characters.
- `test/player_avatar_catalog_test.dart` verifies file existence, Flutter asset-bundle availability and PNG signatures for every referenced path. It does not fully decode every large image or verify visual distinctness/video playback.

## Current registered entries

| Stable ID | Current label | Still art |
|---|---|---|
| `operator_scout` | SCOUT | one image |
| `operator_striker` | STRIKER | one image |
| `operator_vanguard` | VANGUARD | one image |
| `operator_winterguard` | WINTERGUARD | one image |
| `operator_fieldmedic` | FIELD MEDIC | one image |
| `operator_engineer` | ENGINEER | one image |
| `operator_pathfinder` | PATHFINDER | one image |
| `operator_aeroguard` | AEROGUARD | one image |
| `prince` | PRINCE | full-body + portrait |
| `princess` | PRINCESS | full-body + portrait |
| `king` | KING | full-body + portrait |
| `queen` | QUEEN | full-body + portrait |
| `doctor` | DOCTOR | full-body + portrait |
| `surgeon` | SURGEON | full-body + portrait |
| `nurse` | NURSE | full-body + portrait |
| `professor` | PROFESSOR | full-body + portrait |
| `executive` | EXECUTIVE | full-body + portrait |
| `businesswoman` | BUSINESSWOMAN | full-body + portrait |
| `male_student` | UNIVERSITY STUDENT | full-body + portrait |
| `female_student` | UNIVERSITY STUDENT | full-body + portrait |
| `young_man` | YOUNG MAN | full-body + portrait |
| `young_woman` | YOUNG WOMAN | full-body + portrait |
| `streetwear` | STREETWEAR | full-body + portrait |
| `older_man` | OLDER MAN | full-body + portrait |
| `muslim_man` | MUSLIM MAN | full-body + portrait |
| `muslim_woman` | MUSLIM WOMAN | full-body + portrait |
| `tanzanian_kitenge` | KITENGE | full-body + portrait |
| `nigerian_agbada` | AGBADA | full-body + portrait |
| `south_asian_saree` | SAREE | full-body + portrait |
| `east_asian_formal` | EAST ASIAN FORMAL | full-body + portrait |
| `chef` | CHEF | full-body + portrait |
| `firefighter` | FIREFIGHTER | full-body + portrait |
| `mechanic` | MECHANIC | full-body + portrait |
| `construction_worker` | CONSTRUCTION WORKER | full-body + portrait |
| `footballer` | FOOTBALLER | full-body + portrait |
| `basketball_player` | BASKETBALL PLAYER | full-body + portrait |
| `musician` | MUSICIAN | full-body + portrait |
| `dj` | DJ | full-body + portrait |

## Completion rule

A character counts toward the 200 only after a stable ID, distinct reviewed character art, usable portrait, working selectable profile, offline playback of its own character-idle video, offline playback of its own background video, and Windows + Android runtime verification are all recorded. No character is counted merely because a future ID or path was reserved. Religious attire remains limited to Islamic religious clothing; cultural clothing must not be mislabeled as religious attire.

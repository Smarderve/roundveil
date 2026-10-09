# Visual tokens, palettes and typography

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Source traceability
Tokens below are **extracted from the two liked HTML UI concepts** and supported by captured screenshots. They are not intended as license to copy the prototypes' UX. Fine-tune for accessible contrast and cross-platform rendering **only with an explained review**.

| Semantic role | Paper Stage / Felix-inspired | Hero Arena / Overwatch-inspired |
|---|---|---|
| `canvas` | `#E6DEC9` | `#E8EDF4` |
| `surface` | `#F9EFDB` | `#F3F7FC` |
| `panel` | `#F6EDD8` | `#F8FBFFDE` |
| `panelRaised` | `#E9DCC2` | `#F8FBFF` |
| `textPrimary` | `#27251F` | `#263449` |
| `textSecondary` | `#625B50` | `#50647D` |
| `textMuted` | `#817768` | `#6D8093` |
| `primaryAction` | `#B7332D` | `#F4A62C` |
| `secondaryAccent` | `#252822` | `#2879BA` |
| `danger` | `#B13634` | `#D74E52` |
| `border` | `#A99B81` | `#A3B5C6` |

## Font system
- Original Paper Stage: display `Impact/Arial Black`, UI `Arial Narrow/Arial`, body `Georgia`.
- Original Hero Arena: display `Impact/Arial Narrow`, UI `Arial Narrow/Trebuchet`, body `Trebuchet MS/Arial`.
- These are historical CSS fallback stacks, not actual embedded fonts, so Flutter font selection/licensing/testing remains pending. Prior generic playful fonts (Baloo/Lilita) are not approved replacements.
- Preferred hierarchy to test: title 42–96sp desktop or 30–55sp Android; stage question adjusts to content; body 16sp or higher; countdown digits scale within bounds. Exact sizes are **provisional QA starting points**, not source-measured constants.

## Token engineering
Never scatter hex literals across widgets. Create typed per-style palettes, typography, shadow, spacing, stroke/geometry and motion token groups. Maintain corresponding light/texture modes as drawn from sources; do not automatically darken Hero Arena or invent a third style.

## Contrast and readability
Audit both on-screen and from across a room. Red accent on cream, orange on white and small muted text require measured contrast and/or dark ink text. Ensure overlay dimming doesn't drop text below WCAG-informed targets. Screenshot fidelity never overrides readable gameplay.

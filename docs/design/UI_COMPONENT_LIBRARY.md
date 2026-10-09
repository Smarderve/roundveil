# UI components and visual contracts

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Purpose
Provide reusable **visual primitives** reflecting Paper Stage and Hero Arena. A component's visual styling is independent of where it appears in the final UX; old screenshots do not authorize layout/flow.

| Component | Visual responsibilities | Behavior authority |
|---|---|---|
| `RvActionButton` | primary/secondary/danger style; hover/pressed/focus/disabled; tactile depth | click action supplied by approved UX |
| `RvGameTitle` | condensed display hierarchy, safe text bounds | text from app state |
| `RvPlayerIdentity` | numbered player, optional avatar, selected state | selection behavior requires approved UX |
| `RvCountdownDigits` | large tabular clock, warning palette, reduced-motion treatment | GameRuntime timer service only |
| `RvChoiceControl` | tactile selection, clear active/focus state | config schema determines values |
| `RvGameSurface` | atmospheric stage framing, category emphasis | module renderer provides content |
| `RvOverlay` | layered pause/interruption visual surface | host permission and UX contract |
| `RvProgress` | legible stage/round progression | runtime or host config state |
| `RvMediaStage` | character image/name emphasis, fallback state | Guess Character visibility rules |
| `RvErrorPrompt` | readable explanation, next action | appropriate recovery command |

## States for each interactive component
`default`, `hover` (mouse only), `keyboardFocused`, `pressed`, `selected` if choice, `disabled`, `loading` only for async operations, `invalid` for validation. No state may depend solely on hue or sound. Focus contrast cannot be lower than base border contrast.

## Asset & font rules
Use original/cleared graphics only, scalable icons, and explicitly bundled fonts. The old browser CSS stacks are evidence, not a set of redistributable font files. Replace only after review; do not fabricate official Overwatch/Felix fonts.

## Code architecture
`ThemeTokens -> SharedVisualComponent -> Desktop/Android responsive composition -> approved feature UX`. Business state, rules and timing never live inside visual components. Component demos may use artificial labels (`Player 1`) but must be tagged as *visual preview*, not production behavior.

## Acceptance
Theme hot-switch leaves button hitboxes, state machine and accessibility intact; Android minimum touch size and Windows visible keyboard focus verified; reference screenshots and accessible fallbacks reviewed side by side.

# Settings, presets and override resolution

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Settings layers
`App Defaults -> Saved Host Preset -> Active Session -> Round Override -> Module Phase Parameters (when declared)`. Each layer may override only supported keys. Log effective provenance to explain what the host actually selected.

## Typed groups
`GeneralSettings`, `AppearanceSettings`, `AudioSettings`, `AccessibilitySettings`, `PlayerOrderSettings`, `ContentSelectionSettings`, `ScoringSettings`, `ChallengeTimerSettings`, `WinCountdownSettings`, plus module-specific options. Guess the Country options include answer mode, difficulty, regional/worldwide scope, territory-inclusion policy, hint policy, challenge timer and repeat policy. Unknown keys must fail validation/migration rather than silently change behavior.

## Presets
A preset is a **host-created saved configuration**, never a manufacturer-defined ready-made match. Loading a preset is followed by host review/explicit start. Store preset schema version, visible title, and supported version constraints; cloning a preset must not modify the original.

## Effective-value algorithm
Apply layers deterministically, validate final set, and record resolved values in the SessionConfig snapshot at Start. Later global preference changes should not silently rewrite an active match. Pause/interruption behavior may follow global accessibility options where appropriate.

## UX undecided
Which settings are surfaced first, visual slider style, host shortcut locations and choice controls are **not approved** by the historical HTML prototypes. Setting **capability** is agreed; exact interaction design requires review.

## Validation examples
Timer must be finite, integer/precise per schema and inside supported min/max; only modes with an image can choose image-based character prompts; cannot select modules with no content; no conflicting gameplay rules. Exact default values are pending.

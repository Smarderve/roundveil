# Product functional requirements

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Requirements format
`MUST` indicates an agreed functional necessity; `SHOULD` indicates a strong candidate; `PENDING` requires product approval for exact interaction/design.

### Session and host
- **PR-001 MUST:** A host can create a Single Game or Mixed Games session with selected players, game types, compatible categories/topics, rounds, difficulty (when supported) and applicable timers/rules.
- **PR-002 MUST:** Game type and content category are independent; filter out incompatible content rather than silently substituting.
- **PR-003 MUST:** Selected game modules are **not** premade matches; the host's configuration determines the session.
- **PR-004 MUST:** A session can advance through rounds and turns; player order may be randomized within agreed fairness rules.
- **PR-005 MUST:** Supported live host commands include pause/resume, result judgement where necessary and recovery; exact control placement PENDING UX approval.

### Players and content
- **PR-010 MUST:** Placeholder names `Player 1`, `Player 2`, ...; rename/avatar customization by host.
- **PR-011 MUST:** Saved and temporary guest participants; changes must not corrupt active session history.
- **PR-012 MUST:** Offline local content and ability to select categories/difficulty; prevent repeated content according to selected policy.
- **PR-013 SHOULD:** Private custom family questions/character photos and content packs; local by default.

### Turn outcomes and timers
- **PR-020 MUST:** A successful result starts Win Countdown **immediately**, without a blocking congratulation screen; when it expires play advances.
- **PR-021 MUST:** Wrong/timeout skips Win Countdown.
- **PR-022 MUST:** Challenge timer and Win Countdown are independent clocks; game modules can specify additional local phases.
- **PR-023 MUST:** Timers handle pause, lifecycle interruption, deadline expiry and process recovery deterministically.

### Guess the Character
- **PR-030 MUST:** Player physically turns away **before** any identity is revealed.
- **PR-031 MUST:** Name Mode shows name only; Image Mode shows image only. Keep displayed identity visible through clue phase and final guess; player remains turned away until judgement.
- **PR-032 MUST:** Clue timer then final-guess timer (for default Final Guess mode); host or clue-givers judge spoken answer.
- **PR-033 MUST:** Correct judgement starts Win Countdown immediately; failed judgement or final-guess timeout does not.

### Guess the Country (Flags)
- **PR-034 MUST:** Register Guess the Country (Flags) as a separately configurable game module for both Single Game and Mixed Games sessions.
- **PR-035 MUST:** Standard Guess the Country shows a flag without its country name; the player answers aloud, then the host reveals the name and judges Correct or Wrong. It does not offer multiple-choice or typed-answer controls.
- **PR-036 MUST:** Support Easy, Medium, Hard, Expert and Mixed difficulty; regional and worldwide scopes; host-configured challenge timers; and optional hints.
- **PR-037 MUST:** Select from offline, licensed, versioned flag assets and avoid repeated flags in a session whenever enough eligible unseen records exist. Emoji flags and remote live lookups are prohibited.
- **PR-038 MUST:** Apply an explicit, configurable, versioned inclusion policy for UN members, observer states, dependent territories and any curated extension; never imply a recognition position from the policy.
- **PR-039 MUST:** Preserve each shipped flag's audited native proportions and colors. Host judgement of a correct spoken answer starts the shared Win Countdown immediately; Wrong or timeout does not.

### Platforms, accessibility and recovery
- **PR-040 MUST:** Windows and Android share gameplay semantics; adaptive layouts and input.
- **PR-041 MUST:** Offline gameplay; retain critical state after interruption.
- **PR-042 MUST:** Text/contrast scaling and mouse/keyboard/touch paths; clear pause/resume.
- **PR-043 MUST:** No Mystery module or physical reward/eating tracking.

## Explicitly unapproved
Old HTML prototype navigation, builder stages, game-mode placement, game HUD positions, example question timings, animations, scoring defaults and player-judgement controls are **not** accepted UX specs. Track these in `docs/design/UX_OPEN_QUESTIONS.md`.

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
- **PR-010 MUST:** Placeholder names `Player 1`, `Player 2`, ...; hosts can rename saved player profiles and select complete stable-ID characters from the verified offline gallery. Do not expose the rejected hair/skin/clothing/accessory appearance editor.
- **PR-011 MUST:** Saved and temporary guest participants; changes must not corrupt active session history.
- **PR-012 MUST:** Offline local content and ability to select categories/difficulty; prevent repeated content according to selected policy.
- **PR-013 SHOULD:** Private custom family questions/character photos and content packs; local by default.
- **PR-014 MUST:** Option A is the v1.0.0 character-presentation direction: target 200 genuinely unique characters, each with its own visibly moving character-idle video and unique animated environment video, selectable as a functional profile and playable offline on Windows and Android. Never substitute static-image motion or describe video as 3D; true 360-degree interaction is deferred. Counts must come from validated manifest records and real runtime evidence; see `docs/avatars/`.

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
- **PR-044 MUST:** The active catalog contains exactly Quiz, Word Play / Guess the Word, Guess the Character, and Guess the Country. Riddles and Memory are not selectable, routable, templated or included in content packs. Mixed sessions may select any two or more of the four active modules.
- **PR-045 MUST:** Guessing Games exposes six distinct formats: Character Name, Character Picture, Country Name, Country Flag, Object Name and Object Picture. Object Name and Object Picture use one shared object catalog under the existing Guessing Games family; they are not a fifth top-level game.
- **PR-046 MUST:** Object Name uses unique object identities with accurate category, use-description, aliases and difficulty. Object Picture includes only valid offline images mapped to the correct object; category selection, no-repeat pool capacity and the existing turn-away, host judgement, hint, scoring and Win Countdown flow apply. The 10,000 distinct-object content target remains open and counts must distinguish metadata identities from image-backed challenges.

## Explicitly unapproved
Old HTML prototype navigation, builder stages, game-mode placement, game HUD positions, example question timings, animations, scoring defaults and player-judgement controls are **not** accepted UX specs. Track these in `docs/design/UX_OPEN_QUESTIONS.md`.

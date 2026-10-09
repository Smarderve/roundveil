# Motion, effects and audio design

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Motion personality by visual style
- **Paper Stage:** paper flips, offsets, stamping, registration mark transitions, tactile click effects. Keep movement brief and precise rather than cartoon bounce.
- **Hero Arena:** sharp directional sweeps, angled selection glides, strong short focus illumination, energetic but controlled HUD transitions.
- Avoid copying motion clips or sound design from Felix the Reaper or Overwatch; create original effects with proper rights.

## Gameplay-invariant constraints
- No animation may delay Win Countdown start after a correct result. Immediate engine state takes precedence; visual effects run concurrently.
- Timers calculate from deadlines, never from animation frames; avoid audio cue drift.
- Guess the Character identity appears promptly after the player has turned around, and remains visible during Final Guess. Do not transition through a hidden identity state at clue expiry.

## Suggested interaction budget (design candidate)
Hover/focus 100–160ms, menu change 180–300ms, round intro up to 500ms **only if no time-critical phase is active**. These are not final sign-off requirements.

## Audio channels
Master, music, effects, countdown/buzzer and accessibility muting. Distinct cues: menu select, reveal, correct (inside active countdown), incorrect, challenge expiry, timer warning and final buzzer. Critical events must also show visible feedback.

## Reduced-motion/performance
Provide minimal-motion mode, reduced particles, optional silent mode. Don't rely on heavy blur/shaders for usable controls on midrange Android hardware.

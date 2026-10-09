# Challenge timers and Win Countdown

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Two fundamental timer families
**Challenge timers** belong to the current game module or phase (quiz, clue time, final guess, etc.). **Win Countdown** is a globally shared successful-turn phase; it is not an in-app reward or physical-action tracker. The host configures applicable durations before play, potentially through presets or per-round overrides.

## Timing contract
- Use monotonic time for elapsed intervals and absolute deadline model for UI rendering; don't decrement an integer every second.
- Timer state: `idle`, `running`, `paused`, `finished`, `cancelled` with unique deadline IDs, pause/resume offsets and lifecycle policy.
- The visible display is a projection of the engine's time; animations/sounds must never be authoritative clocks.
- Prevent stale timer callbacks from resolving already-completed turns; duplicate callbacks cannot create multiple wins.

## Win Countdown invariant
```text
human or automatic judgement = CORRECT
        ↓ SAME LOGICAL EVENT
runtime state = WIN_COUNTDOWN
        ↓ start configured countdown immediately
countdown reaches zero -> final buzzer -> turn completes
```
No separate success page, congratulatory modal, food animation, extra reward-selection screen or manual 'start reward countdown' step. A tiny acknowledgement may be displayed **inside** the active countdown scene without delaying it.

## Failure path
Wrong/timeout -> no Win Countdown -> turn resolution/next turn. A host action to undo Wrong must not accidentally spawn two countdowns; define rollback transaction semantics.

## Pause and interruptions
On Android backgrounding or Windows sleep, policy is to suspend gameplay timers and require explicit resume unless separately approved. Persist remaining duration and monotonic reference; on restore do not silently expire the countdown. Audio honors mute/reduced-effects settings.

## Open questions
Exact default durations, whether countdown can be extended during gameplay, audible tick cadence and how pause is requested are **not yet locked**. No agent should hard-code 10, 15 or 30 seconds as product law based on demo HTML.

# Offline gameplay, autosave and recovery

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Reliability guarantee
Installed compatible content plus the local GameRuntime must suffice to configure, start, advance and finish a session with **Wi-Fi/mobile data disabled**. No login, remote clock or server acknowledgement may block a turn or Win Countdown.

## Meaningful save events
Game configured/started; next player chosen; round started; content selected; answer/result resolved; Win Countdown state started/completed; pause/resume; player changes; session complete. Persist in an atomic snapshot and optionally append idempotent events for audit/undo.

## Interruption handling
Android: lifecycle pause, phone calls, screen lock and process death. Windows: sleep, minimize, unexpected close and power changes. Use monotonic timestamps while process is active; on restore present reliable **paused/continue** state with persisted remaining duration rather than pretending a countdown continued while no one watched.

## Win Countdown recovery
On `CORRECT`, persist `WIN_COUNTDOWN` with player/remaining value *as part of the resolution*. App may be killed before first frame; on next launch restoring the session enters paused Win Countdown. A single logical win must never be awarded or sounded twice.

## Idempotency and concurrency
Timer deadline ID + active turn ID must match before callback applies; actions carry sequence/event IDs where necessary. Once a turn is terminal, duplicate answer or timeout commands have no effect. Persist atomic transaction results before showing transition success when durability matters.

## Safety/corruption
Check migrations, database health, media paths and snapshot version; preserve recoverable user data. User-facing messages should explain what remains safe and which actions are possible; never instruct user to blindly delete app data.

## Acceptance scenarios
Offline startup; process killed at clue expiry; interrupted Win Countdown; clock changes; repeated answer click; unavailable custom photo; corrupt optional content pack; Windows sleep; Android rotation; undo result without double win.

# Platform behavior and input adapters

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## One game, two device environments
Use identical rules and session persistence. Platform code should implement capability interfaces rather than leak Windows/Android APIs into `domain/` modules.

| Concern | Windows | Android |
|---|---|---|
| Display | window/fullscreen, multi-monitor deferred | phone/tablet, portrait/landscape, system insets |
| Input | mouse, keyboard, optional touchscreen | touch, soft keyboard, hardware keyboard as present |
| Interruption | sleep/close/minimize policies | lifecycle, phone call, app switching |
| Media | local file picker | scoped file/photo picker and runtime permission when needed |
| Haptics | optional/no-op | opt-in haptic effects |
| Keep-awake | idle inhibition where permitted | Android wake-lock flag while needed |
| Distribution | Windows installer/package | signed APK for testing, AAB for Play if published |

## Adapter interfaces (suggestion)
`AppLifecycleService`, `KeepAwakeService`, `GameAudioService`, `WindowModeService`, `MediaPicker`, `HapticFeedbackService`, `PermissionService`, `LocalFileService`. Domain dependencies use abstract ports; DI resolves implementations.

## Input actions
Convert touch/mouse/keys into typed game actions, e.g. `ChooseAnswer(id)`, `StartTurn`, `PauseRequested`, `HostJudgeCorrect`. The module should not differentiate OS. Avoid global keyboard shortcuts that interfere with text-entry modules.

## QA matrix
Windows resized 1366x768/1920x1080/2560x1440, Android narrow phone and tablet, portrait/landscape, UI text scale, large player names, content with images, interrupted timers and accessibility focus. Exact responsive breakpoints require live testing.

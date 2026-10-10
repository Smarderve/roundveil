# Phase 2 Candidate Correction Evidence

Captured from the installed debug APK on the existing `Medium_Phone_API_37.0` emulator (`emulator-5554`, Android 17 / API 37, 1080 × 2400). The match used one explicitly added player, one round, worldwide/mixed content, multiple choice, a 30-second challenge timer, hints enabled, a 3-second Win Countdown, and scoring enabled.

The opening/setup screenshots document the candidate only; they do not indicate UX approval. `android_setup_initial.png` shows the intentionally unselected initial setup; `android_valid_configuration.png` shows the explicit selected options that fit the review pack.

## Interactive match

1. [Host setup — all required values explicitly selected](android_valid_configuration.png)
2. [Player ready](android_player_ready.png)
3. [Live challenge — Brazil flag, in-scope distractors, timer, and player HUD](android_challenge.png)
4. [Immediate Win Countdown after selecting Brazil](android_win_countdown.png)
5. [Session completion — Player 1 wins with 1 point](android_complete.png)

The Brazil artwork retained its native flag proportions. No crash occurred during the correct-answer-to-completion path. A reproduced Flutter infinite-width layout assertion in the challenge timer was corrected; widget tests now assert the challenge contents and countdown rather than allowing an invalid configuration to leave the screen on setup.

## Other device captures

- [Opening](android_opening.png)
- [Initial setup](android_setup_initial.png)
- [Windows native desktop opening screen](windows_opening.png)

The Windows debug build succeeded and the native executable launched with a responsive `ROUNDVEIL` window. The screenshot verifies actual desktop rendering of the opening state; the full gameplay flow was exercised on Android and in widget tests, not interactively on Windows.

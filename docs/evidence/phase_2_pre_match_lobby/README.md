# Phase 2 — Pre-match lobby candidate

These are real captures from the current debug APK installed on the existing
`Medium_Phone_API_37.0` emulator (`emulator-5554`, 1080 × 2400). They show an
unapproved UX candidate, not final product approval.

- [Android lobby — one player and all rules explicitly selected](android_lobby.png)
- [Android Match Rules — top of the scrollable overlay](android_match_rules.png)
- [Android Match Rules — lower options, including scoring](android_match_rules_lower.png)
- [Android session completion — Player 1 wins](android_match_complete.png)

The tested configuration was one player, one round, Mixed difficulty,
Worldwide scope, multiple choice, timer Off, hints Off, a 3-second Win
Countdown, and scoring On. The Brazil flag challenge accepted the correct
answer and completed the existing countdown and winner-summary flow.

## Windows capture limitation

The latest Windows debug build succeeded and its native `ROUNDVEIL` window
opened. A separate foreground Windows Setup window obscured the app. The
approved native capture helper failed to activate the freshly reselected
Roundveil window on both attempts, so a clean Windows lobby or Match Rules
screenshot could not be captured. The Windows build is verified; Windows
visual correctness is not claimed as verified. No interaction with Windows
Setup was performed.

# ROUNDVEIL — Project overview

> **Status:** ACTIVE
> **Authority:** ROUNDVEIL project decisions
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## ROUNDVEIL

A premium, offline-first family/party game for **Windows and Android**. A single shared-screen device runs host-configured mixed or single-game sessions. The device coordinates participants and time-sensitive challenges, not physical-world activities.

### Product rules

- No Mystery game; the prior concept has been explicitly removed.
- The host selects players, game types, categories, round plan and applicable rules before the session starts.
- One game night can mix Quiz, Word Play, Guess the Character, Guess the Country (Flags) and other later-approved game types.
- Correct -> **immediate Win Countdown**, then next turn; Wrong/timeout -> next turn without Win Countdown.
- In Guess the Character the player turns around first, the identity stays on screen through the final verbal guess, and a human judges.
- Guess the Country uses offline licensed flag assets, canonical names plus curated aliases, host-selected country scope/policy and no emoji flags; its gameplay screen UX is not yet approved.
- Placeholder display names: `Player 1`, `Player 2`, ...

### Implementation direction

Flutter/Dart; Windows desktop and Android targets; Riverpod state management; SQLite/Drift locally; app-local authoritative GameRuntime; official content separated from private family records. Platform-dependent services behind interfaces; no backend required for V1 gameplay. These are technical architecture decisions; exact package versions must be verified when installation begins.

### Clone-ready documentation

1. Begin with [`AGENTS.md`](AGENTS.md) and [`docs/00_DOCS_INDEX.md`](docs/00_DOCS_INDEX.md).
2. Follow [`PLANS.md`](PLANS.md); do not start writing all game screens at once.
3. Visual references are in `assets/design_references/` and documented under `docs/design/`; **their old UX is rejected**.
4. UX interactions not yet approved are listed in [`docs/design/UX_OPEN_QUESTIONS.md`](docs/design/UX_OPEN_QUESTIONS.md).

### Setup after Flutter and platform toolchains installed

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter devices
flutter run -d <android-device-id>
```

The Flutter foundation now includes Android and Windows platform projects. Do not add other platform targets or regenerate platform files without explicit approval and a conflict review.

### Foundation verification

After Flutter and Dart are available on `PATH`, verify the generated Android and Windows project with:

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build windows --release
```

Run `flutter doctor -v` before building Android. Do not attempt an Android build until its command-line tools and SDK licenses are healthy; then use `flutter build apk --debug` for the first local verification.

### Security and release

No embedded secrets, private family photos in Git, or unlicensed game imagery. Use `docs/quality/SECURITY_PRIVACY.md` and `docs/release/RELEASE_PLAN.md`.

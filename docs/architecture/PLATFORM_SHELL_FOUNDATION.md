# Platform shell and session-entry foundation

> **Status:** IMPLEMENTED FOR THE 2026-10-11 EXECUTION SLICE<br>
> **Authority:** Current ROUNDVEIL rebuild directive and approved Version 5 brand references

## Delivered scope

- ROUNDVEIL now opens to a branded, responsive Version 5 home instead of opening directly into the Guess the Country prototype.
- The app includes adaptive desktop navigation and compact phone/tablet navigation for Home, Create Game, Quick Game, Saved Drafts and Game Modes, with Settings available from both layouts.
- The approved logo lockup and mascot portrait are bundled as branding. The approved home screenshot and the 2,000 unapproved concept screens are not bundled or presented as interactive screens.
- The approved 2026-10-12 catalog contains exactly Quiz, Word Play / Guess the Word, Guess the Character and Guess the Country (Flags). Riddles and Memory have been removed from registrations, routes and templates; legacy drafts are preserved and flagged for editing.
- Create Game supports a single game or a mixed set. Hosts choose the game(s), players and round count; there are no silent setup defaults for these Create Game choices.
- Quick Game offers editable single/mixed templates. A template's player/module/round configuration is visible and can be changed before saving or creating the session.
- Session configurations are typed and JSON-serializable. Saved drafts are stored locally, can be reloaded, edited in place, duplicated and deleted.
- Version 5-inspired dark/light theme switching and generated Flutter ARB localization are available for the 12 requested UI locales: `en`, `sw`, `ar`, `hi`, `zh-Hans`, `ko`, `pt`, `es`, `fr`, `ja`, `ur`, `tr`. Arabic and Urdu use Flutter's locale-driven RTL direction.

## Session and gameplay boundary

Creating a session persists its configuration. This does not imply that a gameplay engine exists for every selected module. Only the existing Guess the Country prototype can open gameplay today, and it remains a legacy candidate whose answer flow has not yet been reconciled with the current spoken-answer/host-judgement requirement. A mixed session that includes unimplemented modules is saved but is not falsely launched as playable. `GameRuntime` and `GameModule` remain contracts; shared turn progression, module reducers, session recovery and production database storage are still pending.

The app's 2D brand mascot remains an approved brand portrait. It is not a player avatar and is not described as 3D. Production 3D avatars remain blocked until the isolated renderer proof passes visible rendering, skeletal animation, camera control and appearance-change checks on both platforms.

## Active catalog and legacy drafts (2026-10-12)
Create Game and Quick Game use only the four approved IDs. The built-in mixed template selects all four and can be edited. On loading a saved draft, unknown/discontinued IDs make `SessionDraft.needsEditing` true; the draft remains unchanged in storage and is shown with an edit warning. Opening the editor filters retired IDs while retaining players, rounds, title and active modules. The host can then complete the selection and explicitly save. No draft is automatically deleted.

## Local draft storage

The current lightweight adapter uses one application-private JSON file, a flushed temporary copy and a backup/restore replacement path:

- Windows: `%APPDATA%\ROUNDVEIL\roundveil_drafts.json` (falling back to `%LOCALAPPDATA%` if `APPDATA` is unavailable).
- Android: `files/ROUNDVEIL/roundveil_drafts.json` beneath the app-private package directory, derived from Android's app-scoped temporary directory. Drafts are not exported or uploaded.

This is an entry-flow foundation, not the planned SQLite/Drift `user.db`; schema migrations, encrypted private media, active-session recovery and cross-version migration are not implemented here.

## Verification record

Updated after execution checks on 2026-10-11:

- `flutter analyze`: see `PROJECT_STATUS.md` for the verified result.
- `flutter test`: see `PROJECT_STATUS.md` for the verified count and retained Guess the Country regression results.
- Windows and Android debug builds: see `PROJECT_STATUS.md`; compilation is reported separately from UI execution.
- Android emulator installation/launch and shell-flow evidence: `../evidence/platform_shell_2026-10-11/`.
- The widget tests exercise Home → Create Game navigation, mixed-game selection, player/round configuration, session creation, quick templates, JSON draft reload/delete and the requested locale set.

## Renderer status carried forward

Thermion/Filament remains an unverified candidate; Milestone 1 is **BLOCKED / NOT COMPLETE**. Owner-authorized Android SDK Platform 33 revision 3.0.0 is installed in the existing SDK and `flutter doctor -v` reports licenses accepted. The existing API 37 AVD is x86_64 with ARM64 translation, not native ARM64. The isolated Android proof stops before APK creation because Gradle requested the separate CMake 3.22.1 SDK package; obtain approval before installing it. Windows proof compilation succeeds, but Code Integrity Enterprise signing policy blocks execution; continue with an IT-approved signing path or test environment. No production avatar integration was performed.

# Platform shell and session-entry foundation

> **Status:** IMPLEMENTED FOR THE 2026-10-11 EXECUTION SLICE<br>
> **Authority:** Current ROUNDVEIL rebuild directive and approved Version 5 brand references

## Delivered scope

- ROUNDVEIL now opens to a branded, responsive Version 5 home instead of opening directly into the Guess the Country prototype.
- The app includes adaptive desktop navigation and compact phone/tablet navigation for Home, Create Game, Quick Game, Saved Drafts and Game Modes, with Settings available from both layouts.
- The approved logo lockup and mascot portrait are bundled as branding. The approved home screenshot and the 2,000 unapproved concept screens are not bundled or presented as interactive screens.
- The game catalog registers Quiz, Word Play, Guess the Character, Riddles, Memory and Guess the Country (Flags). The unfinished five modules are selectable for configuration and explicitly labelled as foundation work, not playable games. Mystery is absent.
- Create Game supports a single game or a mixed set. Hosts choose the game(s), players and round count; there are no silent setup defaults for these Create Game choices.
- Quick Game offers editable single/mixed templates. A template's player/module/round configuration is visible and can be changed before saving or creating the session.
- Session configurations are typed and JSON-serializable. Saved drafts are stored locally, can be reloaded, edited in place, duplicated and deleted.
- Version 5-inspired dark/light theme switching and generated Flutter ARB localization are available for the 12 requested UI locales: `en`, `sw`, `ar`, `hi`, `zh-Hans`, `ko`, `pt`, `es`, `fr`, `ja`, `ur`, `tr`. Arabic and Urdu use Flutter's locale-driven RTL direction.

## Session and gameplay boundary

Creating a session persists its configuration. This does not imply that a gameplay engine exists for every selected module. Only the existing Guess the Country prototype can open gameplay today, and it remains a legacy candidate whose answer flow has not yet been reconciled with the current spoken-answer/host-judgement requirement. A mixed session that includes unimplemented modules is saved but is not falsely launched as playable. `GameRuntime` and `GameModule` remain contracts; shared turn progression, module reducers, session recovery and production database storage are still pending.

The app's 2D brand mascot remains an approved brand portrait. It is not a player avatar and is not described as 3D. Production 3D avatars remain blocked until the isolated renderer proof passes visible rendering, skeletal animation, camera control and appearance-change checks on both platforms.

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

Thermion/Filament remains an unverified candidate; Milestone 1 is **BLOCKED / NOT COMPLETE**. Windows proof execution requires a policy-approved execution environment. Android proof still requires completion of SDK Platform 33 setup and a compatible ARM64 runtime. No renderer investigation or production avatar integration was performed as part of this shell task.

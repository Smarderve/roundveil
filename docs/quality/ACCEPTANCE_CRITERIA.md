# Acceptance criteria and definitions of done

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## System-wide release gates
**AC-01 Host-configured:** Host can choose/accept all meaningful session settings; session never silently starts a premade match.
**AC-02 Cross-platform:** One shared engine produces same outcomes on Windows and Android; both support setup/play/save/restore.
**AC-03 Offline:** Disabled network doesn't block a configured installed-content session.
**AC-04 Game modules:** Quiz, Word Play and Guess Character share generic runtime; no game-specific global `if` spaghetti.
**AC-05 Win Countdown:** Correct -> immediate timer state, Wrong/Timeout -> no win timer, pause/restoration consistent.
**AC-06 Physical visibility:** Guess Character remains shown to clue-givers through final guess; player turned away; judge resolves.
**AC-07 Privacy:** Custom family content isn't uploaded; permissions on demand.
**AC-08 UX approval:** no implementation of previously rejected prototype navigation/game designs without new user signoff.
**AC-09 Removed feature:** no Mystery game or evidence/suspect module in product navigation/code/content.
**AC-10 Source control:** changes scoped and tested; no unauthorized commits/deployment.
**AC-11 Guess Country registration:** Guess the Country is a separate module available to validated single and mixed configurations without game-specific runtime branching.
**AC-12 Flag content integrity:** Every shipped flag is a locally available licensed, version-pinned and hashed asset with an audited native ratio/colors; no emoji or live content dependency.
**AC-13 Country evaluation:** Typed and multiple-choice modes use canonical names plus curated non-colliding aliases and respect configured difficulty, geographic scope, inclusion policy and repeat avoidance.
**AC-14 Guess Country outcomes:** Correct answer enters one immediate shared Win Countdown; wrong answer and timeout enter none.

## Feature-specific definition of done
A feature is *done* only when requirements are linked, implemented, tests are added/executed, relevant platform checks recorded, accessibility behavior reviewed and unresolved defects declared. Generated files or passing compile alone are not completion.

## Build/documentation gate
Mark UX decisions with actual approval before removing BLOCKED status. Check docs path links and screenshots; check `AGENTS.md` remains short and navigational; compare `PROJECT_STATUS.md` to real repo evidence.

# Unapproved UX and game presentation decisions

> **Status:** BLOCKED — USER UX APPROVAL REQUIRED<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **BLOCKER: FINAL UX IS NOT APPROVED.** The user rejected both HTML prototypes' navigation/session-builder/gameplay arrangements. This file lists decisions that must be resolved before wiring complete gameplay screens.

## Decisions requiring direct approval
| ID | Decision to settle | Why it matters | Do not assume |
|---|---|---|---|
| UX-001 | Lobby vs immediate host setup entry and secondary navigation | identity and ease of starting | screenshot main menu structure |
| UX-002 | How host organizes game types and categories | game types are modular, not premade sessions | old mode tiles/catalog hierarchy |
| UX-003 | How host configures mixed rounds and rule overrides | must not become technical form or auto-filled game | old wizard/order |
| UX-004 | Player roster management and active-player readiness | physical group interaction | mock squad visual flow |
| UX-005 | Quiz interaction/host judgement vs player tapping | screen position and control authority | old HTML answer-grid flow |
| UX-006 | Word Play entry modality on shared phone vs PC | tap/keyboard/physical turn needs agreement | demo drag tiles |
| UX-007 | Guess Character reveal trigger and host buttons placement | privacy/physical facing-away rule | source HTML control placement |
| UX-008 | Pause, undo, skip, dangerous action confirmation | safety and fairness | old modal behavior |
| UX-009 | How to configure optional scores/teams | not every session competitive | always-on score HUD |
| UX-010 | How to present results/round completion | avoid unnecessary wait before Win Countdown | old result screens |
| UX-011 | Which visual styles are offered at launch and how users switch | both visually liked | assume one default/auto hybrid |
| UX-012 | What qualifies as accessible child/adult room display | differing reading distances | desktop screenshot at phone size |
| UX-013 | Riddles/Memory actual rules | user concept is broad | implement unapproved rules |
| UX-014 | Module-specific content selection when pool is insufficient | host must remain in control | silent game/category replacement |

## How to close a question
Record alternatives, a minimal functional test, chosen behavior, user approval/date and screenshots/wireflow specifically representing the **new approved UX**. Only then change status from BLOCKED to ACTIVE. A Codex-generated proposal alone never constitutes approval.

## What *is* settled
Host control, offline-first, modular game type/content separation, Player 1 naming, immediate Win Countdown, Guess Character orientation/visibility, no Mystery mode. These are behavioral constraints despite visual UX uncertainty.

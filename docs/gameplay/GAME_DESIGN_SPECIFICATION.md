# Game Design Specification

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Definition
ROUNDVEIL is a **host-configured multi-game social challenge platform**. The application does not replace real participants with online avatars or prescribe physical actions. It referees the session: player order, selected game modules, prompts, applicable deadlines, host judgement and the shared Win Countdown.

## Session hierarchy
`Session -> configured Rounds -> one or more player Turns -> module-owned challenge phases -> TurnOutcome`. A single-game session uses one selected module; mixed-game sessions choose an approved assignment of modules across rounds. Round grouping, players-per-round and playlist editing require final UX approval, not copied prototype mechanics.

## Rules at the session level
- Host has final authority over options before play and over permitted mid-session commands.
- Eligible module/category/content combinations must be validated before the first turn.
- A selected game type is an engine, **not a ready-made game session**.
- Game modules implement their own interactions but never replace the central player/round lifecycle.
- Correct -> **enter Win Countdown immediately**; Wrong/ChallengeTimeout -> turn ends or approved retry behavior, without Win Countdown.
- Scores, streaks, ranks and team rules are **optional and host-configured**, not presumed always-on.
- Balanced shuffle is a target for fairness: avoid consistently privileging the same player while preserving genuine randomization.

## What the audience experiences
- Group can see which player is active, what type of challenge is current, the phase and timer.
- Challenge content visually dominates the display; host actions should not distract from live play.
- In some modes (e.g. Guess the Character) the player physically faces away while others read the clue. That is a *real-world visibility rule*, not a software hide-and-reveal mechanism.
- Physical-room interactions are not scored by sensing food or monitoring players.

## Module families
| Family | Status | Typical resolution |
|---|---|---|
| Quiz, True/False, MCQ | reference module to build | automatic or host-confirmed correctness |
| Word Play / Word Scramble | reference module to build | typed/arranged answers or human judgement |
| Guess the Character | core reference | verbal final guess; host/clue-giver judgement |
| Guess the Country (Flags) | specified; gameplay UX pending | validated multiple-choice or typed answer against installed flag content |
| Riddles | module candidate, exact UX pending | host judgement or valid typed answer |
| Memory / matching | module candidate, exact UX pending | module-defined success/timeout |
| Visual, charades, sound/logic | future candidates | module-specific |

## Decisions NOT yet approved
The latest user explicitly rejected prior navigation UX, how games were put into screens, and game presentation. The state/result principles here are active; screen sequences, placements, timings and transitions not separately agreed remain proposals. See `docs/design/UX_OPEN_QUESTIONS.md` and `docs/gameplay/GAMEPLAY_FLOW.md`.

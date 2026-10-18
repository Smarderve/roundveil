# Game Design Specification

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Definition
ROUNDVEIL is a **host-configured multi-game social challenge platform**. The application does not replace real participants with online avatars or prescribe physical actions. It referees the session: player order, selected game modules, prompts, applicable deadlines, host judgement and the shared Win Countdown.

## Session hierarchy
`Session -> configured Rounds -> one or more player Turns -> format-owned challenge phases -> TurnOutcome`. A single-game session stays within one game family. Each round has one scheduled game/category/format shared by every player; each player receives a different eligible challenge. Mixed Games is the only session that crosses game families. The complete format schedule is generated and stored when the match starts.

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
| Quiz | Multiple Choice, True or False, Fill in the Blank, Short Answer; format changes only between rounds | automatic or host-confirmed correctness |
| Word Play | Word Scramble, Missing Letters, Word Completion, Guess the Word | typed/arranged answers or human judgement |
| Guessing Games | Character Name/Picture, Country Name/Flag, Object Name/Picture | verbal final guess; host/clue-giver judgement |
The active game catalog is limited to the four rows above. Riddles and Memory were discontinued by the approved 2026-10-12 product decision; archive images depicting them are obsolete visual references and must not be implemented.

Within a round, all players receive the same family, selected guessing category (where applicable), and format. Only the challenge item changes by player. Enabled formats are shuffled at round boundaries with no unnecessary adjacent repetition; challenge IDs are shuffled and unique within the match. Single Guessing Games may include Character, Country, or both categories without becoming Mixed Games. Quiz formats never enter Guessing Games or Word Play sessions. Personal hint credits are keyed by stable saved-player ID and only the active player's balance is charged for a successfully revealed hint.

Current implementation data is not production-complete: Quiz 12, Word Play 10, Character Name 10, Country Flags 249 ISO-marked SVG entries, and zero bundled Character Picture images. Character Picture Mode accepts offline user-imported images and validates pool capacity at match launch. Guess the Item adds 100 distinct object-name metadata records, of which 8 have bundled offline photos for Object Picture. These are starter counts, not the 10,000-object target (9,900 additional object identities remain). See [`games/GUESS_THE_ITEM.md`](games/GUESS_THE_ITEM.md). Seven country entries have curated difficulty tags and 242 remain `unrated` (included only by `Mixed` difficulty). Country-entry classification and configurable territory policy remain unfinished. A legacy draft containing unavailable or unknown formats is preserved, flagged for editing, and must not silently substitute another format.

## Decisions NOT yet approved
The 2026-10-11 user rebuild directive now authorizes implementing the listed platform flows and module behaviors. Older Felix/Overwatch HTML navigation, placements and gameplay remain rejected. The 2,000-screen reference archive is unapproved visual concept material except for the explicitly approved V5 home and brand references; it does not set mechanics. See `docs/design/UX_OPEN_QUESTIONS.md` and `docs/architecture/ROUNDVEIL_REBUILD_AUDIT.md`.

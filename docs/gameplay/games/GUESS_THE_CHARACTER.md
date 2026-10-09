# Game module: Guess the Character

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Non-negotiable core mechanic
This is a physical-room social game: **active player turns away from screen BEFORE character appears**. The character name or picture is displayed to the clue-givers and stays visible **through the clue timer AND final-guess timer**. The player remains turned away until the spoken result is judged. The app **does not hide** the character between phases.

## Phases
1. `TurnAround`: identify Player 1 (or active player), instruction to turn away; character remains unrevealed.
2. `Reveal`: after host/clue-giver confirms orientation or optional configured safety delay, show character immediately.
3. `Clues`: clue-givers verbally describe while ClueTimer runs; character stays visible.
4. `FinalGuess`: when clue time expires, FinalGuessTimer starts; active player still turned away; **same character stays visible**.
5. `Judgement`: host or authorized clue-giver marks Correct or Wrong; Correct immediately enters Win Countdown, Wrong/Timeout finishes turn. Only after judgement can active player turn back.

## Presentation
**Name Mode:** name only, huge readable text. **Image Mode:** image only, no identity caption; useful labels must not spoil the answer. Other modes (including image+name, guess anytime) have appeared as historical options but must be separately approved before shipping.

## Content
`displayName`, aliases/accepted variants, group/category, difficulty, optional licensed image, source, suitable-audience tagging and user-owned local family photo flag. No remote search during live reveal.

## Host settings
Clue duration, final-guess duration, presentation mode, clue restrictions, permission to reveal, outcome judge, skip behavior, forbidden hints. Exact defaults and control UX pending; ability to configure them is required.

## Invariants/tests
Never display identity in TurnAround; never blank identity on ClueTimer expiry; never prompt player to look back before judgement; human judgement correctly gates win; duplicate Correct cannot start two Win Countdowns; image-only never displays identifying caption; timer interruption recovery preserves visibility and stage.

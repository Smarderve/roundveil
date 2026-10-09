# Game module: Riddles

> **Status:** PROVISIONAL — MODULE CONTRACT ONLY<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **PROVISIONAL game-family requirements.** User has expressed interest in riddles, but final interaction mechanics have not been approved.

## Purpose
Present short verbal or written puzzles to challenge reasoning; can use host-judged spoken answers or typed answers when deterministic validation is possible.

## Proposed module contract
Content fields: riddle prompt, accepted solutions/variants, difficulty, category, optional clue/hint, audience restrictions, language. Suggested phases: `Ready -> RiddleDisplayed -> AnswerOrHostJudgement -> Outcome` with optional challenge deadline. Correct outcome triggers shared Win Countdown.

## Rules needing approval
Number of permitted attempts; whether hints cost time; whether other people may answer; whether the riddle remains visible during answers; how to handle subjective solutions. Default choices should **not** be invented from earlier Quiz UI.

## Quality tests
Ambiguous correct answers, multilingual aliases, timer edge conditions, host judgement workflow and no repetition.

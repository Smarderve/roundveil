# Game module: Quiz

> **Status:** REFERENCE MODULE / UX PENDING<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **Gameplay semantics are provisional where not explicitly approved.** Do not treat old prototype screens as approved.

## Purpose
Challenge the active player with host-selected topical questions. Supports Multiple Choice and True/False; rapid-fire, short answer, picture/audio prompts are candidate variants that require separate module validation.

## Inputs
Host-selected categories, audience/difficulty, format, challenge duration, correctness policy, optional explanations and scoring. Select an eligible validated question whose accepted answers are known.

## Candidate phases
`Ready -> QuestionVisible + ChallengeTimer -> AnswerSubmitted OR Timeout -> Correct/Incorrect`. For human-judged short answer, `AwaitHostJudgement` is an internal phase. A Correct result is delivered immediately to GameRuntime for shared countdown.

## UI contract
Question dominates. Answer controls large and accessible to mouse, keyboard and touch. Avoid reproducing the old HTML's exact button positions, completion screens or auto-next logic. All visual details require approved new UX.

## Content
`prompt`, `locale`, `questionType`, `choices[]` if applicable, `correctAnswerKey`, `acceptedVariants[]` as applicable, optional media, category/difficulty metadata, rationale if host enables it.

## Tests
Choice selection, incorrect choice, deadline tie, empty choices, duplicate options, oversized text, single-option invalid question, repeated content selection, immediate Win Countdown and no countdown after failure.

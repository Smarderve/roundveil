# Game module: Quiz

> **Status:** REFERENCE MODULE / UX PENDING<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **Gameplay semantics are provisional where not explicitly approved.** Do not treat old prototype screens as approved.

## Purpose and round formats
Quiz is an independent game. A Quiz-only session remains Quiz for its entire duration; the host selects one or more round formats, and the scheduler changes format only at a round boundary. Supported formats are Multiple Choice, True or False, Fill in the Blank, and Short Answer. Every player in a round receives the same format and a different question. Character/Country formats are never part of Quiz. Mixed Games is the only cross-family session type.

## Inputs
Host-selected categories, audience/difficulty, format, challenge duration, correctness policy, optional explanations and scoring. Select an eligible validated question whose accepted answers are known.

## Phases
`Ready -> QuestionVisible + ChallengeTimer -> AnswerSubmitted OR Timeout -> Correct/Incorrect`. Multiple Choice and True/False provide selectable answers; Fill in the Blank and Short Answer accept typed answers. A Correct result is delivered immediately to the shared Win Countdown; wrong answers/timeouts do not enter it.

## UI contract
Question dominates. Answer controls large and accessible to mouse, keyboard and touch. Avoid reproducing the old HTML's exact button positions, completion screens or auto-next logic. All visual details require approved new UX.

## Content
`prompt`, `locale`, `questionType`, `choices[]` if applicable, `correctAnswerKey`, `acceptedVariants[]` as applicable, optional media, category/difficulty metadata, rationale if host enables it.

The current verified offline pack contains 12 questions (10 existing records plus two reviewed additions). The latest additions cover the Pacific as the largest ocean ([NOAA](https://oceanservice.noaa.gov/facts/biggestocean.html)) and gold's chemical symbol Au ([USGS](https://pubs.usgs.gov/gip/gold/gold.pdf)). This is a starter pack, not the requested production library. The four UI formats currently render from these questions; do not infer that the requested target library has been met.

## Tests
Choice selection, incorrect choice, deadline tie, empty choices, duplicate options, oversized text, single-option invalid question, repeated content selection, immediate Win Countdown and no countdown after failure.

# Game module family: Word Play

> **Status:** MODULE FAMILY / UX PENDING<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

> **Do not present all word variants as already-shipped modules.** This is a module-family specification.

## Candidate variants
Word Scramble (first reference), Spelling, Word Chain, Word Builder, Missing Letters, Sentence Reorder, Anagrams, pronunciation by host judgement and vocabulary challenges. Each variant gets its own phase logic/config and compatible content; do not merge into one monolithic mode controller.

## Word Scramble reference
Input: validated word, category/difficulty, accepted spellings, timer. `Ready -> ScrambledTiles -> CandidateBuilt -> Submit -> Correct/Incorrect/Timeout`. Input mechanisms: tap-to-order on Android and keyboard/mouse on Windows; accessibility alternatives to dragging. Correct -> shared Win Countdown immediately.

## Spelling/pronunciation
Typed spelling can compare canonical and accepted variants; spoken pronunciation should use **host judgement** initially, since generic speech recognition is not reliable pronunciation assessment. Permission to use a microphone is not implied.

## Data
Localized word, display casing, accent/diacritic treatment, aliases, invalid words, candidate hints, word-length bounds, optional audio that can be used offline.

## UX boundary
The existing HTML letter-tile demo is a visual-only sample. Gameplay input, error feedback, rearrangement UX and Win Countdown transitions need review before final screen implementation.

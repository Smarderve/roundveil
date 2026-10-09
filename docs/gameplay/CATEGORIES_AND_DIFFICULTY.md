# Categories, topics and difficulty

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Mental model
**Game Type** = mechanics (Quiz, Guess the Character, Word Play). **Category** = content topic (Animals, Vegetables, Sports, Science, etc.). Each module declares support for content types; a category is displayed only if eligible content exists for that module and requested difficulty/language.

## Category schema
`id`, `parentId`, `titleKey`, `descriptionKey`, `sortOrder`, `audienceRules`, `status`. Hierarchy is open-ended: e.g. `Science > Biology > Human Body` or `Sports > Football > World Cup`. IDs must not depend on translated display strings.

## Difficulty
Difficulty is **per content type and audience**, with shared labels only where meaningful. Do not pretend a spelling word, memory pattern and quiz question have directly comparable difficulty numbers without calibration. Host can choose per session or per round when module supports it.

## Compatibility index
| Module | Example eligible categories | Eligibility constraints |
|---|---|---|
| Quiz | Science, Sports, Geography, Food | validated question pool |
| Word Scramble | Animals, Vegetables, Countries | minimum eligible words/length bounds |
| Guess the Character | Animals, Fictional Characters, Musicians, Family | suitable name/image available |
| Guess the Country (Flags) | worldwide, Africa, Americas, Asia, Europe, Oceania, installed subregions | valid policy/scope record, licensed local flag asset, canonical answer set and difficulty band |
| Riddles | Objects, Logic, Nature | riddle prompts tagged for topic |
| Memory | Animals, Shapes, Images | valid pair sets/assets |

## Availability UX rule
Show unavailable combinations as unavailable with a reason or omit based on the **approved UX**. Never silently swap to a different category or mode. Count sufficient eligible content before Start.

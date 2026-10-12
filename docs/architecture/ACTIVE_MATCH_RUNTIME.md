# Active match runtime — bounded starter implementation

This note records the playable slice added during the 2026-10-12 emergency recovery. It does not declare ROUNDVEIL release-ready or complete the approved content targets.

## Launch and persistence boundary

- `Save Draft` serializes a configuration through the local draft repository.
- `Start Match` validates the selected players, module set, round count, timers and per-module eligible content capacity, then passes that configuration directly to `ActiveMatchPage`.
- Quick Game's primary action launches the selected template directly. The edit action remains optional. Session creation never delegates to draft saving.
- Single sessions consume a unique challenge for each player-turn; mixed sessions consume one challenge per selected module for each configured round, in selected-module order. An undersized eligible content pool blocks launch rather than silently repeating a flag or record.

## Shared turn behavior

- Quiz: offline question and multiple choice. The selected response is checked against the record answer.
- Word Play: offline scrambled word, typed answer and answer validation.
- Guess the Character: Name Mode only in this slice. The active player turns away; the clue-giver sees the character name; the host judges the spoken guess as correct or wrong. No Picture Mode image content exists yet.
- Guess the Country: a bundled SVG flag is shown without choices or a typed-answer field. The host reveals the country and judges the spoken guess.
- Correct answers immediately enter the configured Win Countdown. Incorrect answers and challenge timeout advance without it. The controller rotates players, applies round/module order, supports hints and pause/resume, tracks optional scores, and produces a result summary.

## Counted local content (not production verified)

Unique record counts currently present in `active_match_content.dart`:

| Module | Local records | Important limitation |
| --- | ---: | --- |
| Quiz | 10 | Starter records; not an independently source-audited or category-balanced production bank |
| Word Play | 10 | Starter words, not the requested 10,000-entry dictionary |
| Guess the Character | 10 | Name Mode text records only; zero licensed pictures; not the requested 760 personalities |
| Guess the Country | 7 | Existing SVG review slice; not the requested 195 flags; limited territories and regions |

The flag SVGs retain their source view boxes/proportions and local source license. Territory policy remains UN-member-only in this slice; a configurable policy and broader licensed dataset are still required. Quiz, word and character starter data require editorial/source review before being represented as verified production content.

## Verification limits

Flutter analysis/tests and an Android debug APK are separate evidence from a complete device playthrough. Android was used to complete a ten-turn Quick Quiz and progress through all four modules of a one-round mixed match to its return-to-editor action. The mixed score screen itself was not retained as a screenshot. Country reveal/judgement, next turn, and local flag loading with Wi-Fi disabled were exercised on device. Standalone typed Word input was not verified because the emulator handwriting guide intercepted the field; Character Picture Mode cannot be tested because no licensed images are present. Android release packaging and Windows gameplay execution remain blocked by Windows Application Control; do not weaken or bypass that policy.

Production implementation of 3D avatars remains separately blocked pending a real cross-platform renderer proof. No claims in this note approve the UI or mark release acceptance complete.

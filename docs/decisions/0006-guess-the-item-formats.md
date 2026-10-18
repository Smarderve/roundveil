# ADR 0006: Add Object Name and Object Picture formats

- **Status:** Accepted
- **Date:** 2026-10-18
- **Decision owner:** ROUNDVEIL project owner

## Decision

Add **Object Name** and **Object Picture** as separate formats within the
existing Guessing Games family (`guess_objects`). They do not add a fifth
top-level game family and do not alter the four-family product roster from ADR
0005.

Both formats use the shared saved-player turn order, turn-away confirmation,
clue-giver presentation, host Correct/Wrong judgement, existing player-specific
hints, scoring, challenge timer, pause/resume, Win Countdown, result, Play Again
and Home behavior. Correct judgement starts the existing countdown immediately;
wrong and timeout do not.

Object Name can use verified metadata-only identities with a clear category and
accurate free use-description. Object Picture is restricted to a genuine,
valid, correctly mapped offline photo. Image-backed records are deduplicated
across both object formats in a mixed-format Guessing Games session. Category
and repeat-pool limits must be validated before play, with an explanation
rather than substitution.

## Content baseline

The current starter implementation contains 100 distinct metadata records and 8 bundled
offline photos. The approved 10,000-object target remains active and unfinished.
This ADR does not represent the content target as complete and does not set a
separate 10,000-photo target. Sources and licenses for bundled photos are
recorded in `assets/app/objects/manifest.json` and `assets/app/objects/CREDITS.md`.

## Consequences

- The Guessing Games picker, Create Game, Quick Game, shared runtime and module
  tests recognize both new formats.
- Picture mode reports image-backed pool size and will not fall back to
  metadata-only records or another category.
- Future content expansion must count distinct object identities and usable
  photos separately.
- Riddles, Memory and Mystery remain excluded.

# Guess the Item — Object Name and Object Picture

> **Status:** Implemented starter slice; content target incomplete<br>
> **Family:** Guessing Games (`guess_objects`)<br>
> **Platforms:** Windows and Android debug runtime exercised; full content/acceptance target remains incomplete

## Formats

Guess the Item is one shared object catalog with two separate round formats. It
is not a new top-level game family and it does not make a session Mixed Games.

- **Object Name:** the active player turns away. Clue-givers see the object's
  name, category and a free factual `Used for` description, then describe it
  verbally. That free context is not a paid hint. The host judges the spoken
  answer.
- **Object Picture:** the active player turns away. Clue-givers see a large
  offline photograph and describe the pictured object. The image is the primary
  challenge; this is not multiple choice. The host judges the spoken answer.

For both formats, the player remains turned away until host judgement. Correct
starts the existing Win Countdown immediately; wrong and timeout do not. The
existing session controller owns round/turn progression, scoring, pause/resume,
personal hint credits, results, Play Again and return-home behavior. An object
identity may occur at most once in a match deck. When both formats are in one
session, image-backed identities are kept out of the Object Name deck so the
same object is not repeated across formats.

## Configuration and eligibility

Both formats are directly selectable from the six-entry Guessing Games chooser,
before saved-player selection. Object Picture can be filtered by an image
category. The chooser reports its eligible image count and limits rounds to the
number of distinct images divided by the number of players. It does not silently
substitute a different category or format. A category with insufficient images
is unavailable for the requested roster/round count.

Object Name may use metadata-only records. Object Picture may only use records
with a declared bundled or locally installed image. The match controller checks
eligible-pool capacity before play; the deck uses unique challenge IDs. Aliases
are accepted for typed testing and future host answer confirmation.

Difficulty labels are `easy`, `medium`, `hard` and `expert`; the starter set is
intentionally weighted toward familiar everyday objects. Host selection of an
individual difficulty is not yet exposed in the Object chooser.

## Starter content and provenance

The shared starter catalog contains **108 distinct object identities**. As of
2026-10-18, 86 have bundled offline photos and are eligible for Object Picture;
the remaining 22 identities are metadata-only and are eligible only for Object
Name. This is a starter corpus, not a claim that the current 500-pair owner
target is complete. There are 86 complete identity/photo pairs; 414 more pairs
are needed, including photos for the 22 current name-only identities and 392
additional distinct identities with photos.

The bundled photos are credited in [`assets/app/objects/CREDITS.md`](../../../assets/app/objects/CREDITS.md),
with source, creator, license, and modification details in
[`assets/app/objects/manifest.json`](../../../assets/app/objects/manifest.json).
All 86 images are decoded in the content test. They are bundled for offline
runtime use. The Open Images V7 validation photos include per-image source,
creator, title, license, dataset ID, dimensions and checksum records. This
follow-up integrates eight visually reviewed items (apple, candle, light bulb,
suitcase, sunglasses, door, coin and watermelon), excluding a candidate that
read primarily as a wheel instead of the proposed tire identity. Open Images
metadata is discovery data rather than the image copyright grant; each source
record and CC BY 2.0 attribution travels with its image. The existing 50-image
acquisition batch has an individually attributed manifest and human-readable
credits; actual-pixel review sheets and the Android runtime capture are in
[`docs/evidence/open_images_object_batch_2026-10-18/`](../../evidence/open_images_object_batch_2026-10-18/).
The hammer photo is lower-resolution than the other starter photographs and
should be replaced only with a verified, better-quality asset.

## 2026-10-18 runtime check

On the API 37 x86_64 Android emulator, the current debug APK entered a real
two-player Object Picture match. The clue-giver view showed the actual remote
control photo after the player turn-away confirmation; marking it correct
awarded one point, immediately entered the configured 10-second Win Countdown,
and advanced to Player 2 (turn 2 of 8). Screenshots are in
[`docs/evidence/final_day_content_2026-10-18/`](../../evidence/final_day_content_2026-10-18/).
This is a partial match-path check, not full-match/results acceptance. Windows
was build-verified only; no Windows gameplay claim is made.

The Open Images batch was separately installed with `adb install -r` over the
existing `com.example.roundveil` test installation. The actual Android
Object Picture challenge rendered the newly bundled tablet-computer photograph
after the turn-away confirmation; the process remained alive. The screenshot
is `android_object_revealed.png` in the batch evidence folder. Bundled-image
decoding and manifest/hash checks passed offline-content tests; the emulator's
network setting was not explicitly disabled for this runtime capture.

## Acceptance criteria for future expansion

- A metadata record has a stable unique ID, canonical everyday name, category,
  accurate `Used for` clue, accepted aliases, difficulty and source/provenance
  where applicable.
- Synonyms do not inflate the distinct-object count.
- An image record maps to the depicted object, decodes successfully, works
  offline, has suitable resolution/composition, and carries source/license
  attribution when bundled.
- Picture categories never fall back to unrelated images; missing/insufficient
  content is explained before match start.
- Regression tests cover no repeats, shared format by round, turn-away, hidden
  answer, host judgement, correct-only immediate countdown, hints, pause/resume,
  full match completion and image-load failure.
- Windows and Android each complete real category-specific matches before the
  module can be marked platform-verified.

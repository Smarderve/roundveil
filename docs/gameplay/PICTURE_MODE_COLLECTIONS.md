# Picture Mode offline collection format

> **Status:** ACTIVE implementation format<br>
> **Product:** Guess the Character — local/private Picture Mode

Picture collections are maintained on the user's device. ROUNDVEIL does not
download, synchronize, or upload these files. A collection package is a ZIP
containing one `manifest.json` and the referenced image files. Images may be
inside subfolders; manifest image names are basenames, so package paths are
never written directly into app storage.

```json
{
  "schemaVersion": 1,
  "items": [
    {
      "id": "stable-content-id",
      "name": "Correct subject name",
      "category": "Marvel Characters",
      "imageFilename": "subject-image.webp",
      "aliases": ["Accepted spoken answer"],
      "hint": "Optional clue shown to clue-givers",
      "source": {
        "title": "Source or collection name",
        "url": "https://example.invalid/item",
        "license": "Per-file use note"
      }
    }
  ]
}
```

Import validates IDs, metadata, file mapping, image decoding and minimum
dimensions in a batch. Exact image bytes are SHA-256 hashed for deduplication;
visual near-duplicate detection is not implemented. Invalid entries are
reported and skipped; valid records are copied to app-private storage. Imports
merge with existing entries and do not erase unrelated records. Export creates
the same portable ZIP so a collection can be transferred offline between the
Windows library and Android.

Picture Mode automatically draws from all valid imported records for the
selected session format. The active player turns away before the image appears;
the image stays visible for the clue/guess phases, the subject name remains
hidden until host judgement, and the existing Correct/Wrong flow decides
whether Win Countdown starts.

## Verified inventory

As of 2026-10-15, the repository contains **2 bundled, authentic picture
challenges** in `assets/brand/character_pictures/`: George Washington (Charles
Willson Peale's 1772 portrait) and Abraham Lincoln (Alexander Gardner's 1863
Library of Congress photograph). The sources identify the subjects and indicate
public-domain/no-known-publication-restrictions status. Source URLs, attribution,
license notes, clue context and aliases are in `manifest.json`; image dimensions
and SHA-256 are calculated and validated when the collection is installed into
the app-private offline library. The portraits are copied locally on first load,
so game-time display does not require a network connection. See the [Washington
Commons file page](https://commons.wikimedia.org/wiki/File:Washington_1772.jpg)
and the [Lincoln Commons file page](https://commons.wikimedia.org/wiki/File:Abraham_Lincoln,_Sunday,_November_8,_1863_LCCN2008680252.jpg).

The 760-entry requested target is still **incomplete**. Only two distinct
subjects are bundled and both are in Historical Presidents; no Marvel, DC,
Indian/Hollywood actor, Disney/DreamWorks, cartoon, footballer, or anime
collection has been bundled by this batch. The previously imported emulator
library also contained the same two identities; it is device-local evidence and
is not counted as additional unique content. Tests use synthetic images only for
importer processing and never count them as game content. Anime is proposed as
an additional **100-entry** target (total proposed target: 860), pending product
owner confirmation; it is not an approved count and has no bundled entries.

### 2026-10-15 content-production attempt

This batch did **not** reach the 50-image milestone. Nineteen possible
actor-photo records were identified from Commons; metadata queries returned
their file pages, dimensions and license labels, but their images were not
visually inspected, attribution was not finalized, and **zero** new image
files were downloaded or added to the manifest. Wikimedia Commons returned HTTP 429
(`Too many requests`) for direct image-file downloads, including a spaced
retry; its response specifically requested use of thumbnail images rather
than original files. Candidate subjects are therefore not included in any
inventory or playable count. No restriction was bypassed and no alternate
mirror was used. Resume only after the service's request window permits it,
using Commons' documented thumbnail endpoint with conservative pacing; then
decode each downloaded file and verify the output dimensions/hash before
counting it. The available verified total remains **2**.

| Collection | Current target | Bundled distinct subjects | Verified playable |
|---|---:|---:|---:|
| Indian actors and actresses | 100 | 0 | 0 |
| Marvel characters | 100 | 0 | 0 |
| DC characters | 100 | 0 | 0 |
| Hollywood actors and movie characters | 100 | 0 | 0 |
| Disney and DreamWorks characters | 200 | 0 | 0 |
| Cartoon characters | 100 | 0 | 0 |
| Footballers | 10 | 0 | 0 |
| Historical presidents | 50 | 2 | 2 |
| Anime (proposed) | 100 (not approved) | 0 | 0 |

The package importer continues to support owner-supplied/private collections
and retains source, attribution, subject type, franchise, description, clue,
dimensions and content hash metadata. Future bundled packs must have per-file
identity and reuse-rights verification; a category label or working URL alone
is not rights clearance. Do not bundle recognizable copyrighted franchise
artwork into publicly downloadable builds without permission.

Android runtime evidence (2400x1080 landscape emulator captures) from the
previous private-import batch is stored at
`docs/evidence/picture_collections_avatars_2026-10-14/`. It shows the imported
two-entry library, the turn-away phase, Lincoln displayed to clue-givers,
Washington displayed for the next player, and advancement after host Correct.
Windows debug compilation and app launch succeeded, but the desktop window was
not exposed to the computer-use capture session; no Windows import/gameplay
visual result is claimed.

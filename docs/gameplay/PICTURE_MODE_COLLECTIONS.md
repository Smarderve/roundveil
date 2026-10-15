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

As of 2026-10-15, the repository contains **12 bundled, distinct picture
challenges** in `assets/brand/character_pictures/`: George Washington and
Abraham Lincoln (Historical Presidents); Sylvester Stallone, Bruce Willis,
Tina Fey, Charlie Hunnam, Garrett Hedlund, Charlie Day, Andy Whitfield, Zoe
Saldana and Karen Gillan (Hollywood Actors); and Stone Cold Steve Austin
(Athletes and Entertainers). The ten new images are direct Flickr-hosted
photographs by Gage Skidmore at 1024 × 683. Each Flickr photo page was checked
individually and states CC BY-SA 2.0; creator attribution and per-image links
are recorded in `manifest.json`. See [Gage Skidmore's Flickr photo of Sylvester
Stallone](https://www.flickr.com/photos/22007612@N05/4840620570) and the
[Creative Commons BY-SA 2.0 terms](https://creativecommons.org/licenses/by-sa/2.0/).
Openverse was used to discover Flickr entries, not as a license authority;
Openverse explicitly cautions that license metadata may be inaccurate, so the
underlying Flickr pages were checked individually. These original Flickr
variants were bundled without edits. The two earlier portraits retain their
public-domain/no-known-publication-restrictions source records. All source URLs,
attributions, license notes, clues, dimensions and SHA-256 hashes are kept in
the manifest; the existing first-install path copies bundled images into the
device-private offline library.

The 760-entry requested target is still **incomplete**: 748 additional entries
are needed. The first 50-image milestone is also incomplete: 38 additional
distinct entries are needed. No footballers, Indian actors, Marvel, DC, Disney/DreamWorks,
cartoon or anime entries are included. The ten new faces make Picture Mode more
usable but do not satisfy the requested 50-image first milestone. The earlier
19 Wikimedia Commons candidates remain unqualified and uncounted: Commons
returned HTTP 429 and asked for thumbnail requests, which this batch did not
retry. The previously imported emulator library only repeated the two original
subjects and is not counted. Synthetic test images are not game content. Anime
remains a proposed additional **100-entry** target (proposed total 860), pending
owner approval; it is not approved or populated.

### 2026-10-15 content-production attempt

The Commons attempt delivered zero images: nineteen possible actor-photo
records were identified, but their images were not visually inspected or added.
Direct image downloads returned HTTP 429 even after a spaced retry; the response
asked for Commons thumbnails. No workaround or alternate mirror was used.
These candidates remain unqualified and uncounted. Collection development
continued through Flickr, an independent source, and yielded the ten verified
images listed above. Return to Commons only when its request window permits,
using its documented thumbnails and conservative pacing.

| Collection | Current target | Bundled distinct subjects | Verified playable |
|---|---:|---:|---:|
| Indian actors and actresses | 100 | 0 | 0 |
| Marvel characters | 100 | 0 | 0 |
| DC characters | 100 | 0 | 0 |
| Hollywood actors and movie characters | 100 | 9 | 9 |
| Disney and DreamWorks characters | 200 | 0 | 0 |
| Cartoon characters | 100 | 0 | 0 |
| Footballers | 10 | 0 | 0 |
| Historical presidents | 50 | 2 | 2 |
| Athletes and entertainers (additional) | Not set | 1 | 1 |
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
### 2026-10-15 Android gameplay verification

The complete Flutter analysis passed and the full Flutter test suite passed.
The test output reported all tests passed (104 tests). A fresh debug APK built
successfully, was installed on `emulator-5554`, and the foreground
`com.example.roundveil/.MainActivity` process remained alive. The emulator is
x86_64 with ARM64 translation; no native ARM64 device was tested. Android
captures in `docs/evidence/picture_collections_2026-10-15/` show the live
Guessing Games session setup, player-turn-away prompt, a real bundled Karen
Gillan photograph shown to clue-givers, and the next player's turn after
timeout. The verified image was a bundled offline file, not a network-loaded
photo. The test suite also exercises bundle seeding, all 12 unique image
records, no-repeat assignment while the eligible pool lasts, turn-away/reveal,
host judgement, countdown and progression.

Windows debug compilation succeeded and the launched executable process
remained alive during the check. A visible desktop screenshot/gameplay check
was not completed: the computer-use capture session was stopped with the
physical Escape key. This is process-level launch evidence only, not visual
verification of the Windows Picture Mode screen.

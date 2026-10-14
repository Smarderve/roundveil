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

As of 2026-10-14, **2 real subject images** were imported into the existing
Android emulator's app-private library and used in a live Picture Mode session:
Abraham Lincoln (1863 Library of Congress photograph) and George Washington
(1772 Charles Willson Peale portrait). Both were high-resolution public-domain
images from Wikimedia Commons and are kept in the user's local private package,
not bundled in this repository. Repository-bundled Picture Mode subject count
remains **0**. The remaining requested 758 entries are not populated; the
760-entry target is incomplete. Tests use synthetic images only for importer
processing and never count them as game content. Retain correct names, aliases,
category and source notes in all package manifests. Do not bundle downloaded
third-party collections in the public source repository without permission.

Android runtime evidence (2400x1080 landscape emulator captures) is stored at
`docs/evidence/picture_collections_avatars_2026-10-14/`. It shows the imported
two-entry library, the turn-away phase, Lincoln displayed to clue-givers,
Washington displayed for the next player, and advancement after host Correct.
Windows debug compilation and app launch succeeded, but the desktop window was
not exposed to the computer-use capture session; no Windows import/gameplay
visual result is claimed.

# Picture Mode offline collection format

> **Status:** ACTIVE implementation format<br>
> **Product:** Guess the Character — local/private Picture Mode

Picture collections are maintained on the user's device. ROUNDVEIL does not
synchronize or upload these files. A user may choose a local folder or ZIP of
images for a reviewed import; a separate one-image HTTPS option is available
only after the owner confirms source terms allow private offline use. A portable
collection ZIP may also contain one `manifest.json` and referenced image files.
Images may be inside subfolders; archive paths are never written directly into
app storage.

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

Picture Mode draws from all valid local records or the host-selected character
category. The match is blocked if that selected pool lacks enough distinct
images. The active player turns away before the image appears;
the image stays visible for the clue/guess phases, the subject name remains
hidden until host judgement, and the existing Correct/Wrong flow decides
whether Win Countdown starts.

The bundled and private-family collection boundary, source API usage limits,
category filtering behavior and current fictional-character inventory are
recorded in [`PICTURE_MODE_CONTENT_SOURCES.md`](PICTURE_MODE_CONTENT_SOURCES.md).
The Picture Library supports reviewed local-folder and ZIP imports, exact
filename/alias matching against the 60-entry fictional metadata catalog,
preview/correction before install, and explicitly permission-confirmed HTTPS
image imports without requiring a hand-authored JSON manifest. Imported private
images remain outside public app assets. Catalog names alone are not playable;
no fictional artwork is counted until real images are installed and verified.

Local batch imports accept at most 500 images and 500 MB expanded size, validate
PNG/JPEG/WebP decoding and minimum dimensions, skip identical bytes and duplicate
category/identity pairs, and report invalid items. An ambiguous filename is not
automatically assigned; the host must correct it in preview or skip it.

## Verified inventory — 2026-10-17

The repository contains **50 bundled, distinct person-photo challenges**. The
fictional metadata catalog contains 60 entries, 10 per requested fictional
category; currently none has a verified image, so fictional playable counts are
0 in all six categories.
The first 50-image milestone is met by playable records, not candidate URLs or
test fixtures. Category counts are: 17 Indian actors and actresses, 10
footballers, 14 Hollywood actors, 8 historical presidents, and 1 wrestler /
entertainer. The machine-readable records, dimensions, SHA-256 values, source
pages, license notes, hints, aliases and descriptions are in
[`manifest.json`](../../assets/brand/character_pictures/manifest.json); the
complete readable attribution list is in
[`PICTURE_MODE_CREDITS.md`](PICTURE_MODE_CREDITS.md).

The 38 additions use multiple source/creator groups: Bollywood Hungama event
photos and other independent Indian portraits; match and portrait photography
by Fanny Schertzer, Jan S0L0, Antoine Dellenbach, Biser Todorov, Jamie Smed,
Saiflee100, John Mathew Smith, Carlos Delgado and Walterlan Papetti; actor
portraits by Dick Thomas Johnson, David Shankbone, Neon Tommy and Alan Light;
a U.S. Marine Corps photo by Sgt. Valerie C. Eppler; and official White House
photos credited to their recorded creators. Commons file pages were checked
for license labels and restrictions, and images with explicit personality
rights warnings were excluded. CC BY and CC BY-SA terms, creator attribution,
and each original file page are recorded per image. The downloaded portraits
were visually inspected for identity and basic image-to-subject match. Actor
photos are labeled as actor identities; the actor's roles appear only as
optional context and are not misrepresented as the pictured fictional
characters.

Each of the 50 bundled files was decoded and passed the repository's existing
minimum image gate (both dimensions at least 400 pixels and one dimension at
least 640 pixels). The repository test validates that every path is present,
all 50 hashes are unique, and first-install seeding loads the set without a
network. This is a first collection milestone only: 710 further entries are
needed to reach the approved 760-person/character target. The requested Marvel,
DC, Disney/DreamWorks, and cartoon collections remain empty; this batch adds
no licensed fictional-franchise artwork. The proposed anime extension remains
outside the current 760 target unless separately approved. Locally supplied
private packs remain supported for material the owner is permitted to use.

| Collection | Current target | Bundled distinct subjects | Automated playable validation |
|---|---:|---:|---:|
| Indian actors and actresses | 100 | 17 | 17 |
| Marvel characters | 100 | 0 | 0 |
| DC characters | 100 | 0 | 0 |
| Hollywood actors (person identities) | 100 | 14 | 14 |
| Disney and DreamWorks characters | 200 | 0 | 0 |
| Cartoon characters | 100 | 0 | 0 |
| Footballers | 10 | 10 | 10 |
| Historical presidents | 50 | 8 | 8 |
| Wrestlers / entertainers (additional) | Not set | 1 | 1 |
| Anime (proposed) | 100 (not approved) | 0 | 0 |

The 50-image unit test also runs a distinct full-length offline Picture Mode
match, confirming turn-away before reveal, image availability, no duplicate
challenge IDs, Correct -> Win Countdown, Wrong -> no Win Countdown, progression
and final result counts. This is automated controller/repository verification;
it does not substitute for fresh visual gameplay evidence on either platform.

### Platform evidence — 2026-10-17

Android: debug APK was installed on the existing `Medium_Phone_API_37.0`
emulator (`emulator-5554`, x86_64) and ROUNDVEIL was launched in landscape. A
manual two-player, two-round Character Picture Mode match completed all four
turns. The player-turn-away gate appeared before each reveal; two distinct
offline photos rendered for clue-givers; host judgement accepted one Correct
and one Wrong result; Correct showed the Win Countdown, Wrong did not; play
advanced into round 2 and finished on the standings screen. The two other turns
timed out while the test was being operated, and are counted as timeouts in the
actual results rather than being reported as judgements. Screenshots:
[`setup`](../evidence/picture_collections_2026-10-17/android_setup_verified.png),
[`turn-away`](../evidence/picture_collections_2026-10-17/android_picture_turnaway.png),
[`photo reveal`](../evidence/picture_collections_2026-10-17/android_picture_reveal_2.png),
[`correct countdown`](../evidence/picture_collections_2026-10-17/android_win_countdown.png),
[`round progression`](../evidence/picture_collections_2026-10-17/android_round2_progression.png),
and [`final standings`](../evidence/picture_collections_2026-10-17/android_picture_results.png).

Windows: `flutter build windows --debug` succeeded and the resulting
`build/windows/x64/runner/Debug/roundveil.exe` was launched as a visible
`ROUNDVEIL` window. A Quick Game Character Challenge was configured with only
Character Picture Mode, then entered at least two live turns. Windows displayed
real local photos along with Correct/Wrong judgement controls; the screenshot is
[`windows_picture_mode.jpg`](../evidence/picture_collections_2026-10-17/windows_picture_mode.jpg).
This is actual Windows Picture Mode visual/runtime verification, not merely a
build check. A complete Windows match through final standings was not run in
this verification pass.

Offline basis: the 50 source files are bundled and validated locally; the
repository test verifies first-install seeding from the asset bundle without a
network request. The emulator session itself was not run with network radios
disabled, so it is not described as an airplane-mode test.

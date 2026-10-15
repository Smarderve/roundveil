# Character video manifest

**Status: SCHEMA READY, CONTENT EMPTY.** No character video files are currently bundled, so this manifest contains no media records. Do not add paths until the referenced clips exist, decode locally, and have been checked on both target platforms.

## Per-character record

Each real record must include:

| Field | Requirement |
|---|---|
| `characterId` | Existing stable ID from `PlayerAvatarCatalog`; never a display name |
| `idleVideoAsset` | Unique bundled clip in which the character itself visibly moves |
| `backgroundVideoAsset` | Unique bundled environment clip assigned to that character |
| `idleSha256`, `backgroundSha256` | SHA-256 of exact packaged files; both must exist and be different |
| `width`, `height`, `framesPerSecond`, `durationMs` | Measured from the media files, not hand-entered estimates |
| `videoCodec`, `container`, `hasAudio` | Measured media metadata; silence is preferred for idle/environment loops |
| `sourceTitle`, `sourceUrl`, `sourceLicense` | Compact maintenance provenance for each clip |
| `offlineVerified` | True only after playback with network disabled on Windows and Android |

Records are local and shipped with the app. No remote URL is an accepted runtime media source. Each of the 200 characters needs its own idle clip and its own background clip. Reusing, renaming or recoloring one clip does not satisfy uniqueness.

## Current entries

**0.** There are no clip files or playable manifest rows as of 2026-10-15. This is an explicit empty state, not 200 reserved entries.

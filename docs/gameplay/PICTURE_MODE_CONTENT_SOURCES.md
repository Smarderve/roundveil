# Guess the Character picture sources and collections

ROUNDVEIL keeps two separate picture collections:

- **Bundled collection:** reviewed image assets shipped with the public app. A
  per-image reuse grant must cover application redistribution; source attribution
  and any license conditions remain recorded in the manifest and credits.
- **Private Family collection:** files imported by the owner into app-private
  storage. It is excluded from app assets and from public app builds. Imports
  remain local and are never uploaded.

The Picture Library supports individual image selection, folder import, ZIP of
images, and an optional permission-confirmed HTTPS image URL. Bulk imports show
image previews and exact filename/alias matches before installation; the owner
can correct a mapping or skip an image. Import requires one confirmation that
the user has authority to keep the files privately, validates image decoding and
dimensions, then copies accepted images into app-private storage. A JSON manifest
is not needed. Private images must stay outside GitHub releases unless a
redistribution grant is established.

Gameplay configuration can select `All Categories` or a specific category:
Marvel Characters, DC Characters, Anime Characters, Cartoon Characters, Disney
Characters, DreamWorks Characters, other fictional characters, or the supported
real-person categories. A curated 60-identity metadata catalog has 10 entries
per requested fictional category. Catalog-only identities are not playable: the
runtime only draws installed, validated images in the selected category; an
insufficient pool blocks the match with a count and remediation message. Each
image challenge carries its identity, aliases, category, franchise, clue,
difficulty, source/license notes and local image path. The answer is never
rendered in Picture Mode before host judgement.

## Source API boundaries

External metadata and image APIs are discovery or data services, not automatic
copyright licenses for every asset:

- **TMDB:** the current API terms describe a noncommercial API license with
  attribution, require its logo and an in-app notice, cap cache duration at six
  months, and say TMDB does not claim ownership of the images or data. This is
  not blanket underlying-rights clearance or a public-app redistribution grant.
  ROUNDVEIL does not bundle TMDB image files without asset-specific permission
  and does not call TMDB from gameplay.
- **AniList:** its terms prohibit hoarding/mass collection and use of the API as
  a backup or data-storage service. It is not used to build an offline art
  archive.
- **Jikan/MyAnimeList:** Jikan is an unofficial read-only scraper/API. API
  access and image URLs do not establish image redistribution rights; it is not
  used as a rights grant or copied into the bundled collection.
- **Marvel, DC, Disney, DreamWorks and animation-studio sites:** official
  character pages help verify names and context, but webpage access does not
  itself grant rights to redistribute its artwork in the public app. A
  personal-use statement is not treated as GitHub redistribution permission.
- **Fan art and cosplay photography:** the photographer/artist's permission or
  Creative Commons license covers only the rights they control. It does not
  automatically clear the underlying franchise character. A public bundle needs
  documented applicable authorization; a private family collection must be
  limited to material the owner is authorized to use.

Official policy references checked on 2026-10-17:

- [TMDB API FAQ](https://developer.themoviedb.org/docs/faq)
- [TMDB API Terms of Use](https://www.themoviedb.org/api-terms-of-use)
- [AniList API Terms of Use](https://docs.anilist.co/guide/terms-of-use)
- [Jikan API documentation](https://docs.jikan.moe/)
- [DC Terms of Use](https://www.dc.com/terms)
- [Marvel content terms](https://www.marvel.com/corporate/marvel_unlimited_terms)

Official metadata/reference pages used for catalog identity and series fields:

- [Marvel character directory](https://www.marvel.com/characters)
- [DC character directory](https://www.dc.com/characters)
- [Disney character directory](https://characters.disney.com/)
- [Naruto official site](https://naruto-official.com/)
- [One Piece official site](https://one-piece.com/)
- [DreamWorks Animation](https://www.dreamworks.com/)

These pages are identity references only. ROUNDVEIL does not copy their artwork
into the private image collection, and the links are not image-download grants.

## Inventory and next content batch

The bundled collection currently has 50 reviewed, tested images, all of real
people. The metadata catalog has 60 fictional identities, but fictional-image
counts remain **zero** for Marvel, DC, anime, cartoons, Disney and DreamWorks;
none of those categories is playable yet. No character artwork was downloaded
or copied from a website. The direct URL path only acts on a URL explicitly
provided by the owner after the owner confirms source permission. No external API
credential or image asset authorization was present in this task.

The next content batch needs either (a) assets accompanied by permission that
covers the intended public bundle, or (b) owner-supplied images for the Private
Family collection. The catalog and bulk import UI are ready to map, preview and
install those images without editing code or JSON. Until images are installed,
selecting an empty fictional category must not start a match or count as
playable content.

## Rejected cosplay correction — 2026-10-18

The owner rejected convention cosplay as a substitute for original fictional
characters. A one-time repository migration hides pre-existing private imports
from the fictional categories when they carry the prior owner-supplied import
label. It preserves the managed image files and metadata, and does not hide later
imports after the migration marker is written. Hidden entries are reversible in
the library. On this Windows profile the migration was exercised: 6 rejected
imports (Naruto Uzumaki, SpongeBob SquarePants, Batman, Elsa, Toothless and
Spider-Man) are hidden, all 6 image files remain present, and the profile has 47
other saved image records across the real-person categories. This does not mean
any fictional category is approved or playable: the six fictional records are
all rejected cosplay and the count of approved, authentic fictional-character
images remains zero. The Android profile migration is not verified because no
emulator was attached.

The Picture Library cards now reserve more space for the image and full identity,
show category and installed/hidden status, and offer a large Preview dialog.
This is a source/build change only; fresh Windows screenshot review was blocked
by the desktop computer-use helper's unsupported browser URL-policy state.

## Reviewed portrait expansion — 2026-10-19

This batch individually reviewed 16 additional bundled real-person photographs:
Bruce Lee (1 Chinese actor), Shah Rukh Khan, Priyanka Chopra, Hrithik Roshan,
and Madhuri Dixit (4 Indian actors), plus Brad Pitt, Johnny Depp, Leonardo
DiCaprio, Morgan Freeman, Tom Cruise, Julia Roberts, Scarlett Johansson,
Samuel L. Jackson, Will Smith, Keanu Reeves, and Arnold Schwarzenegger
(11 Hollywood actors). These are actor portraits, not images of fictional roles.
The new files are stored offline and linked to manifest records with source,
license, attribution, dimensions, and SHA-256 metadata. The exact originals and
their review sheet are retained in the production evidence folder.

The previously rejected candidate portraits were not automatically restored.
Following visual review, 26 previously unapproved Indian/Hollywood manifest
records were explicitly approved; five rejected legacy candidates remain
excluded. The bundled manifest now contains 70 records: 44 approved, playable
portraits; 26 excluded portraits. Approved counts are Chinese 5, Indian 19,
and Hollywood 20. Two visually reviewed new files (Hrithik Roshan 388x545 and
Johnny Depp 400x550) are retained with source credits but deliberately remain
unapproved because they fail the repository's existing image-dimension gate.
The catalog still has zero approved fictional
character pictures in Marvel, DC, Disney, DreamWorks, Pixar, or Anime, and this
batch does not satisfy the larger production targets.

Wikimedia Commons returned HTTP 429 during the acquisition run. Requests were
stopped at that point; no alternate Commons host or proxy was used. Two planned
Indian-actor downloads (Alia Bhatt and Salman Khan) were not obtained and are
not counted. The current batch therefore adds 14 new playable images (16
acquired and reviewed files, including two below the runtime quality gate),
not a 50-image batch. Further bulk acquisition from that source requires its rate
limit to clear or a separately authorized source/workflow. Contact sheet review
confirms the actual image pixels, but a manifest entry alone is not runtime
gameplay evidence.

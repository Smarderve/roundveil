# Guess the Character picture sources and collections

ROUNDVEIL keeps two separate picture collections:

- **Bundled collection:** reviewed image assets shipped with the public app. A
  per-image reuse grant must cover application redistribution; source attribution
  and any license conditions remain recorded in the manifest and credits.
- **Private Family collection:** files imported by the owner into app-private
  storage. It is excluded from app assets and from public app builds. Imports
  remain local and are never uploaded.

The Picture Library lets the owner choose an image, enter the pictured identity,
category, series/franchise, accepted aliases, useful clue, difficulty, source,
license and attribution, then add it to the private collection. A JSON manifest
is not needed for individual imports. ZIP packages remain supported for moving
already prepared family collections between devices. Private images must stay
outside GitHub releases unless a redistribution grant is established.

Gameplay configuration can select `All Categories` or a specific category:
Marvel Characters, DC Characters, Anime Characters, Cartoon Characters, Disney
Characters, DreamWorks Characters, other fictional characters, or the supported
real-person categories. The runtime only draws records in the selected category;
an insufficient category pool blocks the match with a count and remediation
message. Each image challenge carries its identity, aliases, category, franchise,
clue, difficulty, source/license notes and local image path. The answer is never
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

## Inventory and next content batch

The bundled collection currently has 50 reviewed, tested images, all of real
people. Fictional-character counts remain **zero** for Marvel, DC, anime,
cartoons, Disney and DreamWorks. This implementation adds functional category
filtering and a no-JSON private image import flow, but does not claim that
fictional artwork was sourced or that any of those categories is populated.
No external API credential or rights-holder authorization was present in this
task, and no character images were copied from websites into the public bundle.

The next content batch needs either (a) assets accompanied by permission that
covers the intended public bundle, or (b) owner-supplied images for the Private
Family collection, which can be imported through Picture Library without code
changes. Until images are installed, selecting an empty fictional category must
not start a match or count as playable content.

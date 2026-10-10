# ROUNDVEIL first-slice flag assets

The seven SVGs in this directory are a deliberately small, offline-only
Guess the Country prototype pack. They were copied unchanged from
[`hampusborgos/country-flags`](https://github.com/hampusborgos/country-flags)
at the source snapshot inspected on 2026-10-10.

That project states that it renders flags from Wikimedia Commons and country
legislation, aims to preserve legally described flag geometry, and treats the
flags as public-domain works (while noting that flag-use restrictions can still
apply). Each SVG retains its source `viewBox`; ROUNDVEIL renders it with a
contain fit, never a forced ratio.

Included IDs: `BR`, `CA`, `FR`, `JP`, `KE`, `US`, `ZA`.

Limitations: this is not the production content pack. It supports only the
regions and difficulty records declared in `lib/features/guess_country/domain/country_flag.dart`.
Before release, each flag must receive the full manifest, hash, source-revision,
policy and authoritative visual review specified in `docs/gameplay/games/GUESS_THE_COUNTRY.md`.

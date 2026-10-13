# Offline ISO flag assets

All 249 installed ISO 3166-1 alpha-2 SVGs in this directory are sourced from
[`lipis/flag-icons`](https://github.com/lipis/flag-icons), release `v7.5.0`.
The source `country.json` records the ISO entries; the included files are the
matching `flags/4x3/*.svg` assets. The complete MIT license is retained in
[`LICENSE.flag-icons.txt`](LICENSE.flag-icons.txt).

ROUNDVEIL keeps each SVG's original `viewBox` and renders it with `BoxFit.contain`.
The source set uses a 4:3 viewport; no runtime stretching or emoji rendering is
used. The source's ISO inclusion flag is a geographic identifier, not a claim
that every record is a sovereign country or is covered by the same territorial
policy.

The country/difficulty metadata and territorial-policy review are still
incomplete. Only seven entries currently have curated difficulty bands; the
other 242 are marked `unrated` and appear only in the `Mixed` difficulty pool.

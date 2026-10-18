# Content library and pack system

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Content types
Active official data includes Quiz items, Word Play entries, character identities/images, installed `country_flag` records, and the shared Guess the Item object catalog. Object Name accepts metadata records before a photo exists; Object Picture accepts only a record with a genuine offline image. On 2026-10-18 the catalog contains 100 distinct object-name identities and 23 decoded, offline image-backed challenges (23 complete pairs; 77 names still lack photos). The current owner target is 500 complete object-name/photo pairs, so 477 image-backed pairs remain. No new character images passed the source-status and quality review in this batch; the previously rejected bundled portraits remain excluded, and fictional-character records remain metadata-only. Riddles and Memory content are discontinued and must not be registered, bundled or surfaced. The approved four top-level game families remain fixed by ADR 0005; Object Name/Picture are Guessing Games formats, not a new family.

## Separate concerns
`GameModule` states *how to play*; `ContentItem` supplies *what players see*; `Category` classifies topics. One item may support multiple compatible game families through validated adapters. Content and game type must never be assumed identical.

## Shared metadata contract
`id`, `type`, `schemaVersion`, `locale`, `difficulty`, `categoryIds[]`, `tags[]`, `audience`, `status`, `source`, `packId`, `assetRefs[]`, `contentHash`, `updatedAt`. Each payload is type-specific: Quiz MCQ options/correct answer, Character displayName/aliases/image, Word accepted spellings, Object canonical identity/category/description/uses/aliases and optional offline photo provenance, or Country Flag canonical ID/name/aliases, policy/region metadata, asset ratio, source snapshot and license/hash record. Do not store unrelated optional fields in one schema.

## Local-first and privacy
`content.db` for published official packs; private custom family entries stay separate by ownership in local storage and are never overwritten by official updates. No network or account required to read installed content during gameplay.

## Pack lifecycle (future candidate)
Download/import -> checksum and schema validation -> safe temporary extraction -> compatibility check -> atomic activation/rollback. Signed manifests and remote update vendor are deferred. Never execute code from a content pack.

## Selection constraints
Match active module, host-selected categories/difficulty/language, compatible audience, availability of required media and repeat-avoidance history. Object Picture must filter to image-backed records and decode/validate assets before they enter a match deck. Object Name may use metadata-only objects. If the content pool is too small, report the constraint clearly and let host adjust scope; do not fabricate content.

## Media and copyright
Store optimized local assets/refs and preload imminent images/audio. Human-provided images remain local. No scraped copyrighted characters/assets distributed without proper rights. Country flags must be shipped as licensed, version-pinned local SVG assets with per-asset source/license/hash metadata and native aspect ratios; emoji flags and remote flag APIs are prohibited. See [`games/GUESS_THE_COUNTRY.md`](games/GUESS_THE_COUNTRY.md).

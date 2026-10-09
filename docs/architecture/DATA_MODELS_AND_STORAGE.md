# Domain entities, local databases and migrations

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Domain graph
`PlayerProfile`, `SessionConfig`, `RoundConfig`, `TurnAssignment`, `ModuleConfig`, `ModuleState`, `ChallengeDeadline`, `TurnOutcome`, `WinCountdownState`, `SessionSnapshot`, `GameEvent`, `ContentItem`, `Category`, `ContentPack`. Use opaque stable IDs; separate display labels and localization.

## Two SQLite stores
### user.db (mutable, private)
`players`, `avatars`, `host_presets`, `app_settings`, `session_configs`, `session_snapshots`, `rounds`, `turns`, `session_events`, `seen_content`, `custom_content`, `custom_media`, `game_history`. User-private files stored in app-managed filesystem and referenced by safe paths/IDs. Do not automatically upload.

### content.db (official published content)
`content_packs`, `categories`, `content_metadata`, `quiz_items`, `word_items`, `character_items`, `country_flag_items`, `riddle_items`, `memory_sets`, `media_assets`, `translations`, `compatibility_index`. `country_flag_items` records canonical IDs/names/aliases, regional and inclusion-policy tags, asset ratio/design version and source-license hash linkage. Category tree and content-type payload tables should remain normalized/validated; indexes for game type, categories, locale, difficulty and seen-content eligible query.

**No Mystery, suspects, cases or evidence tables.** Any schema in older drafts suggesting those is obsolete.

## Transaction and recovery design
- Each significant `Command` application updates durable snapshot/event facts consistently; avoid partial turn advancement.
- Long-term event history optional detail, but minimum reliable current snapshot and completed outcomes are required.
- Schema migrations versioned, transactional and backed by tests; never silently delete household data or overwrite user.db on content update.
- Store `schemaVersion`, `engineVersion`, `moduleStateVersion`; older snapshots either migrate or present a safe recovery decision.

## Content selection consistency
Selected/seen content recorded with stable IDs and pack versions. When custom content removed or a pack unavailable on restore, pause with a reason and let host resolve rather than fabricated fallback.

## Open details
Database DDL and Drift annotations are implementation deliverables, not fixed by this abstract model. Choose after actual Flutter project scaffold and unit tests.

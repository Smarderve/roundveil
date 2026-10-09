# ROUNDVEIL — Documentation map and authority

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Who decides what
1. Newest explicit user decisions override historical planning documents.
2. `docs/product/SCOPE_AND_NON_GOALS.md` and accepted ADRs enforce feature exclusions.
3. `docs/gameplay/GAME_DESIGN_SPECIFICATION.md` + specific module + technical architecture determine agreed game mechanics.
4. `docs/design/UI_APPROVAL_STATUS.md` determines what visual references can and cannot authorize.
5. `docs/design/UX_OPEN_QUESTIONS.md` tracks unresolved UX and blocks guessing.
6. Archived HTML screenshots **never** authorize application behavior.

**Current decisions:** ROUNDVEIL; Windows + Android Flutter; local-first host-configured sessions; `Player 1` placeholders; immediate Win Countdown after correct; Guess Character stays visible to clue-givers through final guess; Guess the Country (Flags) mechanics/content policy specified but gameplay UX blocked; Mystery removed; Felix/Overwatch *visuals only* liked and UX rejected.

## Read only task-relevant files
- New agent task -> [`AGENTS.md`](../AGENTS.md), this index.
- Gameplay -> game design specification plus specific module/constraints.
- Presentation -> UI approval + theme/style/component/responsive docs, then *approved* UX (not yet available).
- Persistence -> architecture storage/offline docs.
- QA -> test plan, acceptance criteria and traceability.

## Full documentation file map

- [`docs/00_DOCS_INDEX.md`](00_DOCS_INDEX.md) — this document.

### Foundations
- [`AGENTS.md`](../AGENTS.md)
- [`CHANGELOG.md`](../CHANGELOG.md)
- [`CONTRIBUTING.md`](../CONTRIBUTING.md)
- [`GOALS.md`](../GOALS.md)
- [`PLANS.md`](../PLANS.md)
- [`PROJECT_STATUS.md`](../PROJECT_STATUS.md)
- [`README.md`](../README.md)
- [`SECURITY.md`](../SECURITY.md)

### Product
- [`docs/product/PRODUCT_REQUIREMENTS.md`](product/PRODUCT_REQUIREMENTS.md)
- [`docs/product/PRODUCT_VISION.md`](product/PRODUCT_VISION.md)
- [`docs/product/SCOPE_AND_NON_GOALS.md`](product/SCOPE_AND_NON_GOALS.md)

### Gameplay
- [`docs/gameplay/CATEGORIES_AND_DIFFICULTY.md`](gameplay/CATEGORIES_AND_DIFFICULTY.md)
- [`docs/gameplay/CONTENT_SYSTEM.md`](gameplay/CONTENT_SYSTEM.md)
- [`docs/gameplay/GAMEPLAY_FLOW.md`](gameplay/GAMEPLAY_FLOW.md)
- [`docs/gameplay/GAME_DESIGN_SPECIFICATION.md`](gameplay/GAME_DESIGN_SPECIFICATION.md)
- [`docs/gameplay/GAME_MODULE_INTERFACE.md`](gameplay/GAME_MODULE_INTERFACE.md)
- [`docs/gameplay/HOST_CONFIGURATION.md`](gameplay/HOST_CONFIGURATION.md)
- [`docs/gameplay/PLAYER_AND_TURN_ORDER.md`](gameplay/PLAYER_AND_TURN_ORDER.md)
- [`docs/gameplay/SETTINGS_AND_PRESETS.md`](gameplay/SETTINGS_AND_PRESETS.md)
- [`docs/gameplay/TIMERS_AND_WIN_COUNTDOWN.md`](gameplay/TIMERS_AND_WIN_COUNTDOWN.md)
- [`docs/gameplay/games/GUESS_THE_CHARACTER.md`](gameplay/games/GUESS_THE_CHARACTER.md)
- [`docs/gameplay/games/GUESS_THE_COUNTRY.md`](gameplay/games/GUESS_THE_COUNTRY.md)
- [`docs/gameplay/games/MEMORY.md`](gameplay/games/MEMORY.md)
- [`docs/gameplay/games/QUIZ.md`](gameplay/games/QUIZ.md)
- [`docs/gameplay/games/README.md`](gameplay/games/README.md)
- [`docs/gameplay/games/RIDDLES.md`](gameplay/games/RIDDLES.md)
- [`docs/gameplay/games/WORD_PLAY.md`](gameplay/games/WORD_PLAY.md)

### Design
- [`docs/design/MOTION_AND_AUDIO.md`](design/MOTION_AND_AUDIO.md)
- [`docs/design/RESPONSIVE_UI.md`](design/RESPONSIVE_UI.md)
- [`docs/design/UI_APPROVAL_STATUS.md`](design/UI_APPROVAL_STATUS.md)
- [`docs/design/UI_COMPONENT_LIBRARY.md`](design/UI_COMPONENT_LIBRARY.md)
- [`docs/design/UI_TOKENS_AND_TYPOGRAPHY.md`](design/UI_TOKENS_AND_TYPOGRAPHY.md)
- [`docs/design/UI_VISUAL_STYLE_FELIX.md`](design/UI_VISUAL_STYLE_FELIX.md)
- [`docs/design/UI_VISUAL_STYLE_OVERWATCH.md`](design/UI_VISUAL_STYLE_OVERWATCH.md)
- [`docs/design/UX_OPEN_QUESTIONS.md`](design/UX_OPEN_QUESTIONS.md)

### Architecture
- [`docs/architecture/DATA_MODELS_AND_STORAGE.md`](architecture/DATA_MODELS_AND_STORAGE.md)
- [`docs/architecture/OFFLINE_AND_RECOVERY.md`](architecture/OFFLINE_AND_RECOVERY.md)
- [`docs/architecture/TECHNICAL_ARCHITECTURE.md`](architecture/TECHNICAL_ARCHITECTURE.md)
- [`docs/architecture/WINDOWS_ANDROID_BEHAVIOR.md`](architecture/WINDOWS_ANDROID_BEHAVIOR.md)
- [`docs/architecture/ANDROID_BUILD_ENVIRONMENT.md`](architecture/ANDROID_BUILD_ENVIRONMENT.md) — verified Android toolchain notes and the temporary Codex-only Java workaround.

### Quality
- [`docs/quality/ACCEPTANCE_CRITERIA.md`](quality/ACCEPTANCE_CRITERIA.md)
- [`docs/quality/REQUIREMENTS_TRACEABILITY.md`](quality/REQUIREMENTS_TRACEABILITY.md)
- [`docs/quality/SECURITY_PRIVACY.md`](quality/SECURITY_PRIVACY.md)
- [`docs/quality/TEST_PLAN.md`](quality/TEST_PLAN.md)

### Release
- [`docs/release/RELEASE_PLAN.md`](release/RELEASE_PLAN.md)

### Decisions
- [`docs/decisions/0001-use-flutter.md`](decisions/0001-use-flutter.md)
- [`docs/decisions/0002-remove-mystery-mode.md`](decisions/0002-remove-mystery-mode.md)
- [`docs/decisions/0003-ui-approved-ux-pending.md`](decisions/0003-ui-approved-ux-pending.md)
- [`docs/decisions/0004-offline-first.md`](decisions/0004-offline-first.md)

## Historical document reconciliation
Older functional/technical Word documents described a Mystery module and a partly desktop-first sequence. Those details have been **superseded** and are excluded from active Markdown specs. See `docs/decisions/0002-remove-mystery-mode.md`.

## Asset note
`assets/design_references/` contains captured screenshots from the user's original Felix and Overwatch HTML studies. **Internal development references only.** Some images portray rejected UX/game content; do not implement their behaviors. The original commercial games' copyright assets must not ship.

## Status legend
- `ACTIVE`: accepted requirements or engineering plan.
- `PROVISIONAL`: candidate; implementation details not yet approved.
- `BLOCKED`: do not build final functional UX until the missing decision is explicit.

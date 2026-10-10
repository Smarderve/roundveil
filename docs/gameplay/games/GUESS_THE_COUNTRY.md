# Game module: Guess the Country (Flags)

> **Status:** SPECIFIED / GAMEPLAY UX BLOCKED<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file defines game semantics and content integrity. It does not approve a game-selection layout, a play screen, or any former prototype UX.

## Purpose
Display one real national flag from installed offline content and ask the active player to identify the corresponding country. The module is registered as `guess_country_flags` and may be used as the only module in a Single Game session or as one validated round type in a Mixed Games session.

## Turn mechanics
1. GameRuntime assigns a player and requests an eligible, not-yet-seen flag item.
2. The module enters `FlagPresented` and accepts exactly one configured answer path: `multiple_choice` or `typed_answer`.
3. If hints are enabled, an eligible hint may be revealed without replacing the flag or changing the canonical answer.
4. A validated correct answer emits `success` to GameRuntime. GameRuntime enters the shared Win Countdown in the same logical result transition.
5. A wrong answer, an exhausted challenge timer, or a host-confirmed failure emits failure/timeout. It must not start the Win Countdown.

The visual composition, answer-control placement, hint presentation, host control placement, feedback treatment, and transition design remain blocked pending gameplay UX approval.

## Host-configurable options
| Option | Allowed values / validation |
|---|---|
| Answer mode | `multiple_choice` or `typed_answer`; a round uses one explicit mode. |
| Difficulty | `easy`, `medium`, `hard`, `expert`, or `mixed`. `mixed` selects only from the selected concrete bands. |
| Geographic scope | One or more installed regions, or `worldwide`; scope is intersected with the selected inclusion policy and asset availability. |
| Inclusion policy | `un_members_only`, `un_members_plus_observers`, `un_members_observers_plus_dependencies`, or a named, versioned curated extension. The host must resolve the policy before start; no unapproved screen default is implied. |
| Challenge timer | Disabled or a valid module deadline selected by the host/preset. Exact defaults and control design remain unapproved. |
| Hints | Disabled or an allowed hint budget/type. Hints never reveal a competing country name or alter correctness. |
| Multiple-choice options | Valid count and one canonical correct option; all distractors must be eligible country records, distinct after display-name normalization, and compatible with the chosen policy/scope. |
| Repeat policy | Avoid all session-seen item IDs while enough eligible unseen content remains. If the requested rounds exceed the eligible pool, configuration must explain the limit and require host resolution; it must not silently repeat a flag. |

## Difficulty and selection
Difficulty is a reviewed content attribute, not an automatic judgment about a country or its people. Curators assign bands from documented flag-recognition criteria such as global familiarity within the selected scope, visual distinctiveness, similarity to other eligible flags, and the ambiguity introduced by a regional-only pool. Expert content needs a documented review rationale. A `mixed` round must use a deterministic, recorded composition of the chosen bands.

Regional scope uses a versioned geographic taxonomy stored with the content pack. `worldwide` means every item allowed by the chosen inclusion policy and installed pack; it does not silently add territories or politically disputed entities.

## Country, territory and disputed-status policy
Each record declares `entityKind` (`un_member`, `un_observer`, `dependent_territory`, or `curated_extension`), `inclusionPolicyIds`, `jurisdictionStatus`, `regionIds`, and a source snapshot version. The application presents the pack's selected name neutrally and does not infer diplomatic recognition from inclusion, exclusion, aliases, or flag artwork.

- `un_members_only` includes the 193 UN Member States.
- `un_members_plus_observers` additionally includes the Holy See and the State of Palestine.
- `un_members_observers_plus_dependencies` additionally permits a pack-curated set of dependent territories that have a separate applicable flag record.
- A curated extension must name its policy/version and every included entity in its manifest. It is opt-in, must be reviewed for naming and artwork, and cannot be introduced by a host typo or an unversioned data update.

The exact user-facing policy labels, default selection, and the membership of any curated extension are unresolved product decisions. A content-pack update may change neither an active session nor a saved preset without explicit migration/host review.

## Content record and offline assets
Each `country_flag` record contains at least:

```text
id, schemaVersion, canonicalCountryId, canonicalName, acceptedAliases[], locale,
regionIds[], entityKind, jurisdictionStatus, inclusionPolicyIds[], difficulty,
flagAssetId, flagAspectRatio, flagDesignVersion, sourceSnapshot, assetLicenseId,
assetSha256, contentHash, status
```

`flagAssetId` resolves to a bundled local SVG (with a generated local raster fallback only where platform rendering requires it). No live lookup, remote image, emoji flag, browser font, or platform-dependent glyph is allowed during a turn. SVG `viewBox`, declared `flagAspectRatio`, cryptographic hash, source revision, and license record are validated before a pack activates. Render the artwork with a contain-style fit that preserves the declared ratio; do not crop, stretch, square, or force a universal 4:3/3:2 frame.

### Source and licensing baseline
The small, working Phase 2 UX-candidate pack contains seven offline SVGs from [hampusborgos/country-flags](https://github.com/hampusborgos/country-flags), source snapshot inspected 2026-10-10. Its repository states that flag designs follow Wikimedia Commons and national legislation where available and that the supplied flags are public domain. The retained per-pack notice is [`assets/app/flags/LICENSE.md`](../../../assets/app/flags/LICENSE.md). The candidate uses each source SVG's native `viewBox` ratio and `BoxFit.contain`; it does not normalize to an icon ratio. This is a deliberately incomplete prototype pack, not an official production content pack or a decision on the territory policy.

Flagpack Core was reviewed as a possible source but is not used by this candidate: its core icons use a normalized canvas, which conflicts with the native-ratio rendering requirement. Before any pack beyond this review slice ships, the content pipeline must retain a pinned source revision and per-asset hash, verify design/colors/dimensions against authoritative national/legal or government references where available, record the license, and complete the inclusion-policy review.

Canonical English names and UN-member/observer classification are reviewed against the [United Nations Member States list](https://www.un.org/about-us/member-states) and the [UNGEGN country-name reference](https://unstats.un.org/unsd/geoinfo/ungegn/docs/1st-session/GEGN.2_2019_13_CRP.13_UNGEGN_WG_Country_Names.pdf). Localized display names may use a pinned [Unicode CLDR territory-data release](https://github.com/unicode-org/cldr-json), with its upstream license notice retained. These references classify/name records; they do not replace the flag-artwork license record.

No package is accepted merely because it has a country code. A package that normalizes every flag to a generic icon ratio, lacks a reproducible license/source record, or fails visual comparison to the documented source is rejected for this module.

## Answer validation
The canonical name always validates. Reasonable aliases are curated per country and locale, versioned with the content record, and reviewed to prevent two simultaneously eligible records from accepting the same normalized answer.

For typed answers, normalize Unicode compatibility form, case, surrounding and repeated whitespace, punctuation variants, and diacritics before exact comparison to canonical/approved alias keys. Do not use unconstrained fuzzy matching, guessed transliteration, or an online service to mark an answer correct. A near match that is not a curated alias may be offered to an authorized host for judgement only if that option is enabled by the eventual approved UX; it cannot auto-award success.

For multiple choice, choice labels must map to distinct canonical country IDs. The evaluator compares IDs, not visible strings. Distractors cannot be the correct record, aliases of it, unavailable policy records, or duplicate display labels.

## Module contract and recovery
Suggested state path: `Ready -> FlagPresented -> AnswerSubmitted | HintRevealed | ChallengeTimeout -> Correct | Incorrect | Timeout`. A host-judgement branch, if enabled later, is explicit and only accepts an unresolved submitted answer. Persist selected content ID, pack version, answer mode, effective configuration, remaining deadline, revealed hints, and terminal outcome so pause/recovery cannot draw a different flag or award two wins.

The module never starts a Win Countdown, advances player order, changes navigation, or fetches content. It reports one idempotent `TurnOutcome` to GameRuntime. A stale timer or duplicate submit after a terminal result is ignored.

## Future implementation acceptance criteria
- A locally installed, licensed, hashed flag pack works with networking disabled on Windows and Android.
- Every shipped flag has a recorded source revision, license record, native ratio, and visual/automated geometry validation; no flag is rendered from emoji.
- The Phase 2 candidate exposes only the difficulty and regional combinations represented by its installed seven-flag review slice; `Expert`, `Mixed`, worldwide, Oceania and territory-policy selections remain unavailable until a reviewed production pack can support them.
- Both answer modes honor the same canonical/alias rules and never accept a collision with another eligible record.
- Selection honors difficulty, geographic scope, policy, and repeat avoidance; insufficient content blocks Start with an explainable validation result.
- Correct answer transitions directly to the shared Win Countdown once; wrong answer and timeout never do.
- Pause, restore, stale deadlines, duplicate submissions, missing assets, and changed content-pack versions are safely handled.
- Implementation proceeds only after the functional gameplay UX has explicit approval.

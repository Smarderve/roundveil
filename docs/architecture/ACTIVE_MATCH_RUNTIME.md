# Active match runtime — bounded starter implementation

This note records the playable slice and mixed-round/randomization corrections verified on 2026-10-12. It does not declare ROUNDVEIL release-ready or complete the approved content targets.

## Launch and persistence boundary

- `Save Draft` serializes a configuration through the local draft repository.
- `Start Match` validates the selected players, module set, round count, timers and per-module eligible content capacity, then passes that configuration directly to `ActiveMatchPage`.
- Quick Game's primary action launches the selected template directly. The edit action remains optional. Session creation never delegates to draft saving.
- Single sessions keep the chosen module for every game-wide round. Mixed sessions generate a shuffled module schedule at match creation; each round uses one module for every selected player's turn, and a module is not repeated until a cycle of selected modules has been completed. Each player-turn draws a unique challenge from its eligible shuffled deck. An undersized eligible pool blocks launch rather than silently recycling a flag or record.
- `roundCount` is the number of game-wide rounds. Three players and four mixed rounds therefore produce 12 turns. A fullscreen round introduction announces the module before the first player acts.
- `ChallengeHistoryRepository` persists recently used challenge IDs across matches (bounded to the latest 500 IDs); each new deck prefers eligible IDs outside that history. The in-progress schedule and deck survive in-process pause/resume, but are not serialized as a crash-recoverable session snapshot; process-death recovery remains outstanding.
- Quick Game loads saved profiles before launch and requires selection of the template's exact player count. Selected stable IDs, appearances, statistics and hint balances are preserved instead of being replaced with placeholders.

## Shared turn behavior

- Quiz: offline question and multiple choice. The selected response is checked against the record answer.
- Word Play: offline scrambled word, typed answer and answer validation.
- Guess the Character: Name Mode and local Picture Mode are supported. The active player turns away; the clue-giver sees either the name or the imported subject picture (Picture Mode never substitutes a name); host judgement determines Correct/Wrong. User-imported images and optional source/license notes remain in app-private storage. No curated image library is bundled yet.
- Guess the Country: a bundled SVG flag is shown without choices or a typed-answer field. The host reveals the country and judges the spoken guess.
- Correct answers immediately enter the configured Win Countdown. Incorrect answers and challenge timeout advance without it. The controller rotates players, applies round/module order, supports hints and pause/resume, tracks optional scores, and produces a result summary.

## Counted local content (not production verified)

Unique record counts currently present in `active_match_content.dart`:

| Module | Local records | Important limitation |
| --- | ---: | --- |
| Quiz | 10 | Starter records; not an independently source-audited or category-balanced production bank |
| Word Play | 10 | Starter words, not the requested 10,000-entry dictionary |
| Guess the Character | 10 | Name Mode text records only; zero licensed pictures; not the requested 760 personalities |
| Guess the Country | 249 | ISO-marked offline SVG baseline from lipis/flag-icons v7.5.0; 242 difficulty-unrated; territory classification/policy and artwork review remain open |

The flag SVGs retain the upstream 4:3 viewBoxes, are rendered contain-fit, and include the MIT notice. The ISO list is not a sovereignty classification, and no configurable territory-inclusion policy is implemented yet. Quiz, word and character starter data require editorial/source review before being represented as verified production content.

## Verification limits

Automated controller tests verify 3 players × 4 game-wide rounds = 12 turns, same module for all players in a round, unique challenges, module cycles, 8-round double-cycle behavior, recent-history preference, scoring, hint credits, countdown and final rankings. Android debug build/install/launch and landscape rendering passed. The live Quick Game flow displayed the template and required-player picker; the emulator showed three persisted profiles and the picker accepted profile selections, but the emulator disconnected before the full 12-turn match could be completed. Do not report that playthrough as complete. Evidence: `docs/evidence/mixed_round_scheduler_2026-10-12/android_saved_player_picker.png` and `android_selected_players.png`.

Android profile data is local to the emulator and is not part of the repository. Android release packaging and Windows gameplay execution remain separately blocked/unverified; do not weaken or bypass security policy. Windows debug compilation passes, but the rebuilt executable was again denied at launch by Enterprise Code Integrity policy `{0283ac0f-fff1-49ae-ada1-8a933130cad6}`. Code Integrity Operational events 3077 and 3033 recorded the rejection on 2026-10-12, explicitly stating that the binary did not meet Enterprise signing-level requirements. A supported next step is an IT-approved signing/certificate route or organization-approved build/test environment that permits this executable; no local policy changes were made.

Production implementation of 3D avatars remains separately blocked pending a real cross-platform renderer proof. No claims in this note approve the UI or mark release acceptance complete.

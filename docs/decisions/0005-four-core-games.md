# ADR 0005: Limit the active product to four core games

- **Status:** Accepted
- **Date:** 2026-10-12
- **Decision owner:** ROUNDVEIL product owner

## Decision

ROUNDVEIL's active product has exactly these four core games:

1. Quiz
2. Word Play / Guess the Word
3. Guess the Character
4. Guess the Country (Flags)

Riddles and Memory are removed. They must not appear in the active catalog, Home/Game Modes, Create Game, Quick Game, built-in single/mixed templates, gameplay routes, active module registrations, content manifests or active game-module specs. They are not to be replaced with other games. Shared session, turn, timer, persistence and Win Countdown contracts remain in place for the four games.

The existing 2,000-screen archive is immutable historical design source material. Its Riddles screens 1441–1520 and Memory Challenge screens 1521–1600 are marked obsolete for implementation. Do not edit or regenerate the archive.

## Legacy saved drafts

Do not delete saved drafts or unrelated user data. A loaded draft containing any module ID outside the active four is marked as requiring editing and shown with a warning. Its stored JSON remains unchanged until the host edits and saves it. Opening the editor filters discontinued IDs while retaining the draft ID, name, players, rounds, template reference and any active module selections; normal validation then requires the host to choose a valid configuration. A later explicit save updates only that draft.

## Mixed sessions

Mixed sessions may combine any two or more of the four active modules. Built-in templates contain no discontinued IDs. The editable Party Mix template includes all four active modules; hosts can remove or add any active game using the existing selection behavior.

## Consequences and status

- Remove the Memory route, implementation and tests; remove Riddles/Memory catalog and template registrations.
- Keep the old module documentation paths as short supersession notices so external/local links do not silently lose context; they are not active specifications.
- Exclude old Riddles/Memory archive concepts from implementation without modifying the source archive.
- This product decision does **not** assert that the four remaining game loops or their content libraries are complete. Their playable/content acceptance remains governed by their individual approved specifications.

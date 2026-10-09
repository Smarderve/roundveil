# ROUNDVEIL — Contribution and agent workflow

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Start every task
1. Read root `AGENTS.md` and index; inspect actual Git status and user changes.
2. State a narrow goal, changed-file scope, risk and verification plan.
3. Read the smallest relevant set of specs; do not pre-load the whole corpus for a tiny task.
4. Respect `ACTIVE`, `PROVISIONAL` and `BLOCKED` flags. If unclear, ask or implement a nonfunctional placeholder explicitly labeled as such.

## Implementation standards
- UI doesn't own timers, win transitions, turn fairness or persistence business rules.
- Modular game implementations do not directly navigate, request network, modify global session sequence or display Win Countdown themselves.
- Keep compatible Windows+Android code in shared Dart first, adapt input/lifecycle at platform boundary.
- Follow static analysis and formatter rules after the Flutter toolchain is present; add tests for changed behavior.
- Prefer smaller PR-sized changes and record concrete evidence of done; keep user's unrelated edits untouched.

## Review checklist
- Which specification authorizes this functionality?
- Is this a visual-reference-only feature accidentally being treated as UX authority?
- Could the change reintroduce Mystery mode or app-level food/rewards?
- Did new code create untested data migrations or background service dependencies?
- Was test output collected, and are limitations reported?

## Version control
Never stage unrelated user edits, overwrite local work, push, merge, rebase or deploy without explicit scope/permission. Never commit credentials or family photos.

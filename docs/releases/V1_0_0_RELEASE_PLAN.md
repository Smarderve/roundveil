# ROUNDVEIL v1.0.0 Release Plan (Proposal)

This is a process proposal, not approval to defer requirements, create tags, or publish artifacts. Commit and push authorization is provided by the owner's current per-batch instruction; public release authorization remains separate.

## Principle

Windows and Android artifacts must be produced from one identified revision and tested as packaged apps, not just compiled. `v1.0.0-rc.1` is a test candidate, not a final release. All owner requirements remain in force unless individually deferred with explicit approval and truthful release notes.

## Gate 0 — Freeze v1 scope

Obtain owner decisions for: all 12 formats; 9,000 Quiz/10,000 words/760 pictures/100 animated 3D avatars; import-only Picture Mode vs bundled first-run library; Object Picture's status relative to the exact four games; anime quantity; audio/music; 12 languages versus English-only; final app ID; approved Home UI; minimum Windows/Android versions and package format. Do not infer answers.

## Gate 1 — Gameplay correctness

After scope freeze, add integration coverage for each included format and a three-player/four-round Mixed session. Verify same format for all players within one round, distinct challenge per player, switch only at next round, correct/wrong/timeout, timers, hints, score-once, results, replay and restart. Correct answers now enter Win Countdown synchronously; live platform acceptance remains necessary. Run the current build on Android and Windows; keep results separate.

**Exit:** Automated integration plus fresh live evidence from the current source revision on both platforms; no old pre-fix screenshot as scheduler proof; no major overflow at supported sizes.

## Gate 2 — Content and UX acceptance

In parallel after Gate 0, inventory validated unique content by subject/difficulty, review flag mapping/ratios/territories, curate permitted local Character Picture content, correct clues/aliases, and get owner review of actual Windows/Android screens. Decide language and audio promise. Keep private photos private. Do not substitute unapproved assets.

**Exit:** Owner-approved content counts, first-run empty/import behavior, actual screenshots and explicit remaining deferrals.

## Gate 3 — Android release package

1. Confirm stable app ID and upgrade policy.
2. Configure protected signing; key must not enter Git or reports.
3. Verify version name/code, min/target SDK, ABI, icon/label and landscape.
4. Build release APK from frozen SHA, record tools, size and SHA-256.
5. Install exact APK on clean emulator and physical supported Android; test offline play, lifecycle, upgrade, profiles and migrations.
6. Inspect package identity, permissions, signer and logs.

**Current blockers:** placeholder `com.example.roundveil`; release uses debug signing; release APK not installed/run. **Exit:** approved identity/signer, physical install/upgrade/runtime/offline pass.

## Gate 4 — Windows package

1. Keep Application Control, antivirus, UAC and firewall unchanged. Request organization-approved signer/test host.
2. Build Release from same frozen SHA; include `roundveil.exe`, Flutter DLL, `data/` and native dependencies.
3. Create portable ZIP or signed installer, manifest and SHA-256; do not distribute a bare EXE.
4. Test outside dev checkout on a clean policy-approved Windows VM/user; launch, play offline, resize, keyboard/mouse, persistence, update and uninstall.
5. Record Code Integrity/missing DLL issue exactly; do not bypass policy.

**Current blockers:** no archive/installer or clean runtime test; prior Code Integrity blocks (although debug runtime passed in current dev environment). **Exit:** complete package passes clean approved-machine test.

## Gate 5 — RC and authorized GitHub release

1. Review/test approved source changes; build both artifacts from one SHA.
2. Run analysis/tests/builds and packaged runtime/offline/update matrix.
3. Resolve P0s; any retained P1 needs owner approval and release disclosure.
4. Create `v1.0.0-rc.1` only with explicit authorization; record provenance.
5. Obtain owner content/visual/scope/platform sign-off.
6. Only after explicit publish authorization create `v1.0.0` annotated tag, upload Windows package and Android APK, include checksums, supported OS, install steps, limitations and release notes.
7. Download published artifacts and verify hashes/install again.

At audit time the GitHub Releases API returned zero, there were no local/remote tags, no `.github` workflow was found and `gh` CLI was absent. A local clean-commit candidate build script is now available at [`LOCAL_CANDIDATE_BUILDS.md`](LOCAL_CANDIDATE_BUILDS.md); it does not publish or sign artifacts. An authorized web/API path may be used later; none was used here.

## Proposed milestones (not approved)

| Milestone | Exit gate |
|---|---|
| `v1.0.0-rc.1` | Frozen scope; gameplay/Mixed acceptance; approved UX; signed APK and Windows package tested clean |
| `v1.0.0` | RC P0 closed; owner sign-off; same source SHA; checksums; offline/install gates; authorized release |
| `v1.0.1` | Reproducible release fixes only |
| `v1.1.0` | Explicitly approved content/localization/audio expansion |
| `v1.2.0` | Approved avatar/rendering expansion after genuine proof; Object Picture only after roster decision |

## Critical path

Owner scope decisions → current three-player/multi-round and format acceptance → content/UX acceptance (parallel with signing setup) → same-revision Android and Windows runtime → clean offline/update tests → RC → owner approval → authorized tag/release → download verification. Renderer work is independent unless 3D is explicitly a v1 gate; current renderer has not passed.

## Audit-time verified baseline

- `flutter analyze`: clean.
- `flutter test`: 95 passed after the immediate-countdown source correction (2026-10-15).
- `flutter build windows --release`: passed; 339 files / 143,878,684 bytes; not packaged/runtime-tested.
- `flutter build apk --release`: passed; 168,351,268 bytes; debug-signed config; not installed/run.
- Windows debug and Android emulator debug runtime were separately verified with limitations.
- Local/remote `main` matched `2f897156a6531de48a4da29ea98deb6401cef659`; no release/tag created.

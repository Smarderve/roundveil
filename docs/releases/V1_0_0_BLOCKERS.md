# ROUNDVEIL v1.0.0 Blockers and Acceptance Criteria

Baseline `2f897156a6531de48a4da29ea98deb6401cef659`, audited 2026-10-15. All feature/content/UI reductions require owner approval; none is silently accepted.

## P0 — release blockers

### RLS-01 — Android app identity and signing
- **Evidence:** `android/app/build.gradle.kts` declares `applicationId = "com.example.roundveil"`; release selects debug signing. Release APK build passed, but artifact was not installed/run.
- **Repro:** Inspect Gradle release config; inspect APK signature metadata.
- **Cause:** No production package identity or protected signing configuration.
- **Dependencies:** Owner chooses unique ID; protected key/secret-management and upgrade policy.
- **Work:** Configure stable app ID and secret-managed release signing; never commit key.
- **Acceptance:** Approved ID, version 1.0.0/code, release signature; physical Android fresh install, upgrade, landscape/offline launch and profile migration pass.
- **Test:** `flutter build apk --release`; `apksigner`/`aapt`; install/upgrade/launch via `adb`.
- **Release blocker:** Yes. **Target:** v1.0.0.

### RLS-02 — Windows distributable and policy-approved runtime
- **Evidence:** Release folder has 339 files / 143,878,684 bytes; no archive/installer or clean-machine test. Code Integrity events 3077/3033 named prior blocked `roundveil.exe` attempts under policy `0283ac0f-fff1-49ae-ada1-8a933130cad6`. A later debug app did launch and profile flows were operated.
- **Repro:** Prior event logs contain executable path and policy; no packaged clean test exists.
- **Cause:** No distributable packaging/signing and managed policy acceptance unverified.
- **Dependencies:** Admin/IT-approved signer or test host, clean Windows VM, package-format decision.
- **Work:** Produce ZIP or signed installer with exe, Flutter DLL, data and native dependencies. Do not weaken/bypass security.
- **Acceptance:** Download/extract/install, launch offline, play, persist/restart and uninstall on clean approved Windows; no missing DLL/assets; checksum and SHA recorded.
- **Test:** Release build, package manifest, clean VM runtime, Code Integrity review.
- **Release blocker:** Yes. **Target:** v1.0.0.

### GAME-01 — Current mixed scheduling has no post-fix device proof
- **Evidence:** Current code/tests represent one format per round and distinct challenge per player; historical Oct 12 screenshots predate correction and show different games within a round. Current device verification absent.
- **Repro:** On current build, create three-player, four-round Mixed match and record family/format/challenge by player and round.
- **Cause:** Old evidence is stale; tests are not runtime acceptance.
- **Dependencies:** Current builds and three saved profiles.
- **Work:** Run actual session on Android and Windows; inspect progression, score, hints, results and replay.
- **Acceptance:** All players share same format/policy within a round; each gets a different challenge; format changes only at next round; no unnecessary repeats; session completes.
- **Test:** Automated integration plus live evidence on both platforms.
- **Release blocker:** Yes. **Target:** v1.0.0.

### GAME-03 — Correct-answer Win Countdown timing
- **Prior evidence:** Correct answers passed through a 500 ms `scoreAward` phase before the configured countdown.
- **Correction:** Removed that intermediate phase. The controller now enters `winCountdown` and sets its configured seconds in the same synchronous answer-resolution call. Correct/points feedback is displayed on the countdown screen.
- **Automated verification:** Controller and compact-landscape widget tests pass; full current-turn device timing remains pending.
- **Release blocker:** Closed in source; keep live acceptance under GAME-01/GAME-02. **Target:** v1.0.0.

### GAME-02 — Release-included formats not individually accepted
- **Evidence:** 12 paths exist, but no current acceptance bundle for each mode on both platforms; tests do not prove full playability. Picture Mode has no bundled content.
- **Repro:** Start and finish each included format from players through results/replay.
- **Cause:** Code-path/test presence confused with gameplay acceptance; content scarce.
- **Dependencies:** Scope decision for Picture fresh-install requirement and minimum data.
- **Work:** Per-format walkthrough and integration tests for instructions, answer/judgement, timer, hint, score-once, countdown, progression and results.
- **Acceptance:** Every release-claimed mode works on Windows and Android; empty pool/offline states are intelligible.
- **Test:** One full session per format/platform plus clean-install/offline checks.
- **Release blocker:** Yes for each mandatory format. **Target:** v1.0.0.

### PIC-01 — Picture Mode unavailable on fresh install
- **Evidence:** 0 bundled images; two private Android imports historically used; current private totals UNKNOWN.
- **Repro:** Fresh install → select Picture Mode → no challenge until import.
- **Cause:** Importer exists without starter content.
- **Dependencies:** Owner decides import-dependent vs bundled; permitted image set if bundled.
- **Work:** Add approved offline content or define/label import prerequisite and empty state. Do not transmit private photos.
- **Acceptance:** Explicit scope, real image displayed and judged offline after fresh setup, names match subjects and private data remains local.
- **Test:** Fresh install airplane mode; import and complete match independently on Windows/Android.
- **Release blocker:** Yes if Picture is mandatory at first launch; otherwise owner scope decision. **Target:** v1.0.0.

## P1 — major readiness and quality gaps

| ID | Evidence / cause | Work + dependencies | Acceptance / test | Target |
|---|---|---|---|---|
| DATA-01 Quiz | 12 records vs assumed 9,000; no category/difficulty/source schema | Owner age/quantity policy; tagged, reviewed corpus | Agreed count per subject; answer/hint/fact/difficulty/duplicate review; filter tests | v1 scope decision |
| DATA-02 Words | 10 unique vs 10,000; modes reuse records | Owner minimum; enrich records/meanings/aliases; clarify scramble UI | Agreed unique count, unambiguous prompts, repetition tests | v1 scope decision |
| CHAR-01 Context | 10 generic Name entries, weak verified media context | Source/context review and family category policy | Correct useful clues/context and accepted names | v1.0 |
| FLAG-01 Catalog | 249 SVGs; 7 rated; territory/alias/proportion review incomplete | Owner territory policy and manifest audit | 249 mapping/name/region/difficulty/alias/native-ratio review; visual tests | v1.0 |
| UX-01 Home | UI approval doc marks current Home unapproved and different from V5 | Owner visual approval and assets | Owner accepts real Windows/Android captures; interactive; no major clipping | v1.0 |
| AV-01/02 Avatars | 38 static 2D, 68 files; 0 production 3D/animation/360; new art unaccepted | Owner chooses 2D release or genuine 3D gate | No false 3D claim; if required, visible rig/idle/camera/material on both platforms and roster target | v1 or approved deferral |
| AUDIO-01 | 0 audio assets/playback; cue enum only | Owner selects minimum and permitted assets | Audibly plays, mute/volume persists and passes both platforms | v1 or approved deferral |
| LOCALE-01 | 12 UI locale files, English gameplay | Owner decides language promise; translators/native QA | Every advertised UI/content string reviewed; RTL captures; restart test | v1 or approved deferral |
| SAVE-01 | Profile flows work; full hint/reward/replay matrix partial | Integration tests using persistent data, no reset | Per-player hint, reward-once, fresh replay, restart preserves data | v1.0 |
| OFF-01 | Historic Wi-Fi-off flag test only | Clean-install airplane-mode matrix | Every release mode/assets works offline; graceful Picture empty state | v1.0 |

## Scope and evidence gates

- `SCOPE-01` Object Picture is absent and outside the exact four-game roster. Obtain owner decision; do not implement silently.
- `CONTENT-ANIME-01` Anime image target is unspecified. Obtain count/category decision.
- `SET-01` Theme/locale persistence, accessibility and full resize/keyboard/touch sweep incomplete.
- `WIN-ARM64-01` Android renderer proof was x86_64 translation only; native ARM64 needed only if 3D becomes a gate.
- `EVID-01` `android_mixed_word_finalapk.png` shows Character, and stylus-overlay Word screenshot is not clean QA; regenerate current proof.

# ROUNDVEIL v1.0.0 Gap Matrix

**Baseline:** `2f897156a6531de48a4da29ea98deb6401cef659`, audited 2026-10-15. Status is evidence, not owner approval. `UNKNOWN` is not zero or complete.

## Active games and session behavior

| ID | Requirement / target | Verified actual | Status / gap | System | Priority |
|---|---|---|---|---|---|
| G-01 | Exactly four active games | Quiz, Word Play, Guess Character, Guess Country | Present; Memory/Riddles/Mystery absent per active authority | Registry/docs | P0 |
| G-02 | Quiz MC | 12-item corpus; MC path | Historical device evidence; no current full acceptance | `active_match_content.dart` | P1 |
| G-03 | Quiz True/False | Format path | No separate curated set/runtime acceptance | Quiz mapping | P1 |
| G-04 | Quiz Fill Blank | Format path | Ambiguity not audited per record | Quiz mapping | P1 |
| G-05 | Quiz Short Answer | Normalized typed answer | Sparse aliases risk false rejection | Answer validation | P1 |
| G-06 | 1,000 questions × 9 subjects | 12 unique | 0.13% raw; at least 8,988 below assumed target; no explicit category/difficulty schema | Quiz content | P1 |
| G-07 | Easy mode/filter | No useful difficulty metadata verified | Cannot prove ordinary family-level Easy | Session/content model | P1 |
| G-08 | Word Scramble | Text prompt + typed answer | Not tile/letter reordering; same small records reused | Word UI/content | P1 |
| G-09 | Missing Letters | Generated mask | Not curated; no age/difficulty data | Word builder | P1 |
| G-10 | Word Completion | Prefix/blanks path | Ambiguity/quality not audited | Word builder | P1 |
| G-11 | Guess the Word | Clue/typed-answer path | Hint may duplicate visible clue | Word content | P1 |
| G-12 | 10,000 unique words | 10 unique | 0.1%; 9,990 missing; modes reuse items | Word catalog | P1 |
| G-13 | Character Name context | 10 generic entries | Verified media/character context incomplete | Character catalog | P1 |
| G-14 | Character Picture | 0 bundled; two private Android imports historically used | Fresh-install mode unavailable until import; current private counts UNKNOWN | Picture repository | P0 by scope |
| G-15 | Country Name facts | Format path | Context sparse; no comprehensive acceptance | Country catalog/UI | P1 |
| G-16 | 249 country flags | 249 local SVGs; Brazil shown historically | Seven rated; territory policy/aliases/ratios/color mapping not fully reviewed | Flag assets/data | P1 |
| G-17 | Object Picture, 10,000 | No active module/assets | Absent; outside exact four-module lineup; decision needed | Registry | Scope gate |
| G-18 | Mixed same format per round, different challenge/player | Source + tests updated | Latest device verification absent; historical pre-fix screenshots contradict | Scheduler/runtime | P0 |
| G-19 | Full match/results/replay | Code and widget coverage | No latest device full replay evidence | Results/controller | P1 |
| G-20 | Correct → immediate configured Win Countdown | Controller enters `winCountdown` synchronously and preserves correct/points feedback on that screen | Automated tests pass; Android alpha.1 runtime showed `10` and `+1 POINTS` within 350 ms after answer; Windows execution remains blocked by policy | Match controller/UI | ANDROID VERIFIED; WINDOWS BLOCKED |
| G-21 | Correct scoring/reward once | Controller/repository tests | Full multi-match device acceptance missing | Score/reward repos | P1 |
| G-22 | Per-player useful hints | Default 10; stable IDs | Weak/repeated hint text and incomplete device proof | Hints/content | P1 |
| G-23 | Wrong/timeout progression | Code/tests exist | Cross-format hardware acceptance incomplete | Match controller | P1 |

## Profiles, art, UX and content

| ID | Requirement / target | Verified actual | Status / gap | System | Priority |
|---|---|---|---|---|---|
| P-01 | Permanent profiles | Stable IDs/local JSON/backups | Android restart verified; packaged Windows persistence untested | Profile repo | P1 |
| P-02 | Create/select/rename/remove | Android and Windows debug interactions | Profile outside default two slots selected from Avatars | Home/profile | P1 |
| P-03 | Stats/hints retained | Storage exists | Reward-once, multi-match acceptance partial | Profile/reward | P1 |
| A-01 | 100 selectable avatar designs | 38 static 2D entries, 68 images | 38% count only; latest 30 not owner accepted | Avatar catalog | P1 |
| A-02 | 100 real 3D avatars | 0 | No operational renderer/models | Renderer | P1 if hard v1 gate |
| A-03 | Rig/idle/full motion/360 | 0 verified | No dual-platform proof; no native ARM64 run | Renderer proof | P1/P2 by scope |
| A-04 | 760 picture entries + anime | 0 bundled; two private Android imports historically used | No fresh-install content; anime quantity unknown | Picture manifest | P1 |
| A-05 | 10,000 object pictures | 0 | No active feature; scope decision | Future scope | P1 decision |
| A-06 | Offline flags | 249 MIT-source local SVGs | Exhaustive visual/metadata review absent | Flags | P1 |
| U-01 | Approved Version 5 Home | Interactive candidate exists | Explicitly unapproved, source mismatch; bars/truncation visible | Lobby/UI approval | P1 |
| U-02 | Simple navigation | Several routes/CTAs exist | Quick/Create/Games entry purposes overlap | Shell/session builder | P1 |
| U-03 | Responsive/accessibility | Android landscape and responsive code | Resize, touch, keyboard, reader and layouts not exhaustively checked | All UI | P1 |
| U-04 | Persistent settings | Theme/locale controls exist | Restart persistence not verified; state appears local | Settings | P2 |
| U-05 | Fit small landscape | Current Android screenshot | Some stats/labels truncate | Home | P1 |

## Localization, audio, offline, tests, release

| ID | Requirement / target | Verified actual | Status / gap | System | Priority |
|---|---|---|---|---|---|
| L-01 | 12 UI locales | 12 named ARBs/resources | Keys do not prove professional translations | `lib/l10n` | P2 |
| L-02 | Localized gameplay/data | English prompts/content | Missing | Content/localization | P1/P2 by scope |
| L-03 | Arabic/Urdu RTL | Locale resources | RTL full-screen QA unknown | Flutter localization | P1 if advertised |
| S-01 | Music/SFX/volume | 0 audio assets/playback | Cue enum alone, no playback | Audio subsystem | P1/P2 by scope |
| S-02 | Animations | Partial UI transitions; static characters | No genuine character animation | Avatar system | P1 if hard gate |
| O-01 | Complete offline play | Local content; historic Wi-Fi-off flag test | No full fresh-install airplane-mode suite | App/assets | P1 |
| O-02 | Offline Picture | Private import repository | Fresh install has no images | Picture content | P1 |
| T-01 | Analyze/tests | Clean; 95 tests passed (2026-10-15) | Not full gameplay acceptance; runtime coverage remains separate | Flutter tests | PASS with limitation |
| T-02 | Android debug runtime | v1.0.0-alpha.1 debug APK installed/launched on API37 x86_64 landscape; Quiz answer showed 10-second Win Countdown and +1 points; process remained active and advanced | Not production-signed, physical or ARM64 renderer test; no full session completed | Android | PASS for tested flow |
| T-03 | Windows packaged runtime | Release build and ZIP extraction passed | Launch blocked by fresh Code Integrity 3077/3033 under policy `0283ac0f-fff1-49ae-ada1-8a933130cad6`; approved signer/host still required | Windows | BLOCKED |
| R-01 | Android release APK | Build succeeds; 168,351,268 bytes | Debug signing; not installed/run | Gradle | P0 |
| R-02 | Android app ID | `com.example.roundveil` | Placeholder identity | Gradle | P0 |
| R-03 | Protected Android key | Debug signer used | No release key setup | Signing/CI | P0 |
| R-04 | Android landscape | `sensorLandscape`; alpha.1 debug APK ran in landscape on API37 emulator | Production release runtime still needs test | Manifest | PARTIAL PASS |
| R-05 | Windows release build | Release folder compiled and packaged into a 123,475,368-byte local test ZIP from commit `11b0264` | Extracts successfully; does not run under current Application Control policy | Windows runner | PARTIAL / P0 open |
| R-06 | Approved Windows signing/runtime | Debug run passed here; 3077/3033 historical blocks | Need approved signer/test environment; no bypass | Code Integrity | P0 |
| R-07 | Same-revision artifacts | Local script builds from a clean `git archive HEAD` and writes source SHA, artifact type, size and SHA-256 | Scripted Windows portable Release ZIP and Android debug APK are local test candidates only; no publishing, protected APK signing or packaged runtime certification | Build/release | PARTIAL |
| R-08 | GitHub release | 0 releases, no tags | No downloadable artifacts, workflow or `gh` CLI | GitHub | P0 |
| R-09 | Portable Windows dependencies | ZIP contains executable, Flutter runtime, data and plugin DLLs; archive extraction passed | Packaged app cannot be runtime-tested on this policy-managed host | Packaging | PARTIAL / P0 open |
| R-10 | Native ARM64 renderer | x86_64 translation attempted only | Native device test absent | Isolated renderer | P2 unless v1 gate |

## Counting rules

Count unique records, not format projections; assets in a private import are not bundled content; catalog entries are not validated images; static art is not a 3D model; build success is not runtime acceptance. Picture Mode private counts and quality are **UNKNOWN**. Object Picture is absent from the active product, not a known user-device count.

# Windows video plugin policy recovery — 2026-10-15

## Result

The Windows startup failure was reproduced and traced to `video_player_win_plugin.dll`, not to a broken Flutter executable or an x86/x64 mismatch. The debug DLL was unsigned and AMD64/x64. Code Integrity events 3077 and 3033 at 2026-10-15 12:56:24 report that `roundveil.exe` attempted to load it but it did not meet Enterprise signing level requirements under policy `0283ac0f-fff1-49ae-ada1-8a933130cad6`. Windows error `0xc0e90002` resolves to `STATUS_SYSTEM_INTEGRITY_POLICY_VIOLATION`.

The DLL's PE import table references `flutter_windows.dll`, Windows system libraries (`KERNEL32`, `USER32`, `ole32`, `d3d11`, `MFPlat`, `WINHTTP`) and the Visual C++ debug runtime (`MSVCP140D`, `VCRUNTIME140D`, `VCRUNTIME140_1D`, `ucrtbased`). Those imported files were present on this development host. The policy rejection occurs before plugin initialization; the import scan does not establish that the plugin would otherwise play a video successfully.

## Scoped Windows workaround

- Removed the direct `video_player_win` dependency. Flutter now generates an empty Windows plugin list and an empty Windows plugin registrant for this app.
- `OfflineLoopingVideo` immediately shows its supplied still-image fallback on Windows and does not create a native video controller there.
- Android still resolves and registers `video_player_android`; an Android debug APK built successfully after the Windows-only change.
- The old DLL remains as a stale file in the existing Debug output directory, but the rebuilt executable neither registers nor loads it. Runtime module inspection confirmed no `video_player*` module loaded. Do not copy that stale Debug directory as a distributable.
- The Windows handler for the pause overlay's QUIT GAME action now calls `exit(0)`. The rebuilt app exited when this control was clicked. Alt+F4 also exited the process.

## Verification on this host

- `flutter analyze`: clean.
- `flutter test`: all 101 tests passed.
- `flutter build windows --debug`: succeeded. The rebuilt app opened a visible `ROUNDVEIL` window, remained responsive and showed no `video_player_win_plugin.dll` Code Integrity event on subsequent launch.
- `flutter build windows --release`: succeeded. The release output contains `roundveil.exe` and `flutter_windows.dll`, contains no video-player plugin DLL, and opened a visible `ROUNDVEIL` window; Alt+F4 closed that process.
- Live interaction: home; switching the active player changed the displayed character; game library; Quiz reached the Kenya continent question with answer buttons and timer; Word Play reached Missing Letters and accepted `triangle`, showing the 10-second `CORRECT` countdown and `+1 POINTS`; pause; Leave Match back to the game list; QUIT GAME closed the process.
- `flutter build apk --debug`: succeeded with the temporary Java option `-Djdk.net.unixdomain.tmpdir=C:\Windows\Temp`, restored immediately afterward. Generated plugin metadata still includes `video_player_android`.
- The resulting APK installed over the existing `com.example.roundveil` package on `emulator-5554` (Android API 37, x86_64); the process remained alive and the activity was RESUMED. The sampled log tail showed no fatal exception, MissingPluginException or video-player error. This verifies app startup/backend registration, not actual Android video playback.
- Runtime captures are in [`../evidence/windows_startup_recovery_2026-10-15/`](../evidence/windows_startup_recovery_2026-10-15/): `home.png`, `player_selection.png`, `home_after_nav.png`, `quiz_intro.png`, `quiz_gameplay.png`, `word_play_gameplay.png`, `word_play_answer.png`, `pause.png`, `leave_match.png`, and `release_home.png`.

## Limits and permanent route

Windows character videos are intentionally disabled for now; still-image fallback remains. Re-enable video only after the organization supplies a signing identity and policy-approved trust route for the executable and every native plugin dependency, or provides an approved Windows test environment whose policy permits the selected signed implementation. A self-signed certificate or local policy/security bypass is not an acceptable fix. The app and plugin would need to be rebuilt in the approved signing pipeline and retested under the actual enterprise policy.

No Windows installer compiler (Inno Setup, WiX, or equivalent) is installed in the current environment. A clean Release build and visible runtime launch passed, but no installer was created; the stale Debug DLL must not be packaged. Installer authoring/build is pending an approved packaging tool and the organization's signing/trust requirements for distribution. No software was installed and no security policy was changed.

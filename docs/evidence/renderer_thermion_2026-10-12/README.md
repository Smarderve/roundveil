# Thermion isolated proof — 2026-10-12

No screenshot in this directory shows a Thermion character: the isolated proof did not reach runtime. `production_android_home_final.png` is a separate capture of the production ROUNDVEIL app and is included only as cross-platform app-startup evidence, not as 3D renderer evidence.

## Android

- Owner-authorized SDK change: installed only `platforms;android-33` revision 3.0.0 into `C:\Users\Smarderve\AppData\Local\Android\Sdk`. API 36/37 and existing tools were preserved.
- `flutter doctor -v`: Android toolchain healthy; all Android SDK licenses accepted. Flutter reports SDK 36.0 / platform 37.0 as its primary version, while Platform 33 is installed alongside it.
- Existing AVD `Medium_Phone_API_37.0` booted as `emulator-5554`. Properties: ABI `x86_64`; ABI list `x86_64,arm64-v8a`; native bridge `libndk_translation.so`. This is an x86_64 emulator with ARM64 translation, not native ARM64.
- Thermion `0.5.0` Android native build hooks compiled and emitted upstream C-linkage warnings. Gradle then requested Android SDK CMake 3.22.1. Package inventory reported it not installed. The build was stopped before installing that additional component because the authorization was specifically for Platform 33.
- No APK was produced by the current attempt, installed, or launched. An older `app-debug.apk` in the isolated temp project has a prior timestamp and is not proof for this build. No app log or render screenshot was created.
- Separately, the production `flutter build apk --debug` passed, the project application ID `com.example.roundveil` was installed and launched on the AVD, and `MainActivity` was foregrounded in landscape. After the initial startup interval, the real branded home rendered in `production_android_home_final.png`. The app log had no Flutter fatal exception or asset-load error; it did report skipped frames during startup. This verifies ordinary production app startup, not Thermion integration or full gameplay acceptance.

## Windows

- Isolated `flutter analyze`: exit 0, no issues.
- Isolated `flutter build windows --debug`: exit 0, executable produced.
- Runtime remains blocked by Code Integrity Enterprise signing requirements. Operational log events 3077/3033 cite policy `{0283ac0f-fff1-49ae-ada1-8a933130cad6}` and prior blocked paths include the proof executable, production `roundveil.exe` and `flutter_windows.dll`, and Flutter `gen_snapshot.exe`.
- `CiTool.exe -lp` returned `0x80070005` (access denied) for the current user, so policy enumeration requires an administrator. No policy, AV, firewall, UAC, or security setting was changed.
- Supported next step: IT provides an approved code-signing/allowlisting route for the full executable and DLL set, or a dedicated policy-approved Windows build/test environment. Do not work around Code Integrity.

## Independent four-game regression checks

- Production `flutter analyze`: passed with no issues.
- Production `flutter test`: all 57 tests passed, including the four-module session/runtime tests.
- Production Windows debug build: exit 0. This is compile evidence only; the current Windows Code Integrity restriction still blocks a live run.
- Production Android debug build: exit 0; install/foreground launch and landscape home capture are verified above.

## Gate

Thermion remains an unverified candidate. No visible character, skeletal animation, orbit camera interaction, or appearance change passed on either platform. Do not integrate a production avatar until these are visibly verified on Windows and Android. Android continuation requires explicit approval to install SDK CMake 3.22.1 through the official SDK Manager.

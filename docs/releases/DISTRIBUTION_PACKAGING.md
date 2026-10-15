# ROUNDVEIL distribution packaging

This repository is currently version `1.0.0-alpha.2+2`. The repeatable package builder writes Alpha/pre-release artifacts under the ignored root `dist\` folder; it does not create a GitHub Release, tag, or stable `v1.0.0` release.

## Windows installer

`packaging\windows\roundveil.iss` defines the per-user Inno Setup installer. `scripts\build_distribution.ps1 -SkipAndroid` builds the Flutter Windows Release bundle, verifies the executable/runtime/assets and icon input, and compiles `dist\ROUNDVEIL-Setup-v1.0.0-alpha.2.exe`. The installer copies the complete Flutter Release output, registers ROUNDVEIL in Installed Apps, creates a Start-menu shortcut and offers a post-install launch. The optional Desktop shortcut is available in the wizard. A stable Inno `AppId` supports in-place upgrades.

All durable Windows profile, draft, and challenge-history JSON is stored under `%APPDATA%\ROUNDVEIL`, outside `{app}`. Neither installation nor uninstallation scripts delete that directory. Consequently upgrades and normal uninstall preserve personal data. A future explicit “remove my data” feature would need to be separately implemented and clearly confirmed; the current uninstaller intentionally has no such option.

The builder can Authenticode-sign and verify each bundled `.exe`/`.dll` plus the setup executable when `signtool.exe` is available and `ROUNDVEIL_SIGN_CERT_SHA1` identifies an approved code-signing certificate in the current user's/machine's Windows certificate store. Optional `ROUNDVEIL_SIGN_TIMESTAMP_URL` enables a trusted timestamp. No password or PFX is placed on the command line. In the current environment those signing inputs are not configured, so the generated installer is unsigned. Prior Code Integrity event 3077/3033 evidence documents enterprise rejection of an unsigned native DLL under policy `0283ac0f-fff1-49ae-ada1-8a933130cad6`. A setup that compiles is not evidence that Windows will permit it to run. The organization must approve the signing identity and trust/deployment process for the app executable and every native DLL, or provide an approved test environment. This build does not alter or bypass policy.

## Android release APK

`scripts\build_distribution.ps1` also supports a signed Android release APK when invoked with all four current-process environment variables: `ROUNDVEIL_ANDROID_KEYSTORE`, `ROUNDVEIL_ANDROID_STORE_PASSWORD`, `ROUNDVEIL_ANDROID_KEY_ALIAS`, and `ROUNDVEIL_ANDROID_KEY_PASSWORD`. `android\app\build.gradle.kts` uses only that release key and rejects Release tasks without it; it no longer falls back to the debug key. Keep the keystore and passwords in a protected secret store, never in Git or command-line arguments. Back up the keystore securely and retain it for every future update. `-SkipAndroid` builds only Windows packaging.

The current application ID remains `com.example.roundveil`. It is not suitable as the permanent published identity and has deliberately not been changed without owner approval. Android stores app-private profiles and local content under the package-specific sandbox. A new package ID installs as a separate app and cannot automatically read the existing test install's private files; preserve them by first adding and testing an explicit export/import migration (or keep the current ID). Approve the permanent reverse-domain ID and migration approach before changing it or publishing an APK. No Android signed release APK is currently produced until both signing secrets and the permanent package identity are resolved.

## Build and verification

From the repository root, after Inno Setup and Flutter are available:

```powershell
./scripts/build_distribution.ps1 -SkipAndroid -FlutterPath 'C:\path\to\flutter\bin\flutter.bat'
```

For both packages, configure Android secrets in the current process and run the script without `-SkipAndroid`. Windows signing can be configured through `ROUNDVEIL_SIGNTOOL_PATH`, `ROUNDVEIL_SIGN_CERT_SHA1` and optionally `ROUNDVEIL_SIGN_TIMESTAMP_URL`. The script creates `SHA256SUMS.txt` alongside generated installers/APKs and refuses to overwrite same-version outputs unless `-ReplaceArtifacts` is specified. These files are ignored build artifacts, not source-controlled release files. Validate installation, icon display, upgrade/data preservation, Android package installation and landscape startup on target devices before publication.

Release signing, managed-Windows acceptance, Android package identity, APK signing-key custody, full install/upgrade/uninstall acceptance, and owner approval of a stable release remain open gates.

## Verified local Alpha 2 packaging run — 2026-10-15

- Inno Setup 6.7.3 compiled `dist\ROUNDVEIL-Setup-v1.0.0-alpha.2.exe` (120,977,518 bytes). Current SHA-256: `5f6c9033df74205ec86fd7b6b9f392f8f85a86b6fa836ed65ffc7b58b6b84bcc`.
- An earlier local build of this installer (different SHA) installed into the default per-user directory, created the executable, Start-menu/Desktop shortcuts and HKCU Installed Apps entry, and launched the installed executable and both shortcuts to a live `ROUNDVEIL` window. Silent uninstall removed that install and preserved the pre-existing `%APPDATA%\ROUNDVEIL` folder and both user-data filenames. This did not exercise in-place upgrade or complete game play from the installed copy.
- The **current** setup artifact is `NotSigned` and is blocked before its wizard opens by Windows Application Control. Code Integrity events 3077 and 3033 at 2026-10-15 13:58:42 identify the exact current `dist\ROUNDVEIL-Setup-v1.0.0-alpha.2.exe` path and policy `0283ac0f-fff1-49ae-ada1-8a933130cad6`, requiring the Enterprise signing level. Do not bypass this policy. The earlier artifact's install test does not establish acceptance of the current hash.
- `flutter analyze`: passed with no issues. `flutter test`: passed, 101 tests. `flutter build windows --release` and Inno compile both passed; this is separate from the current install failure.
- Android Release build was attempted with the authorized process-local Java loopback workaround. It reached and failed the intentional guard because no protected release keystore credentials are configured. The current app ID is also still the placeholder `com.example.roundveil`; therefore no APK was packaged or installed in this run.
- The exact requested `app_icon_round.ico` filename is not present in the repository. The existing Windows runner resource `windows\runner\resources\app_icon.ico` was used as the installer icon source; confirm if that differs from the intended approved artwork.

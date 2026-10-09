# Android build environment and Codex Java workaround

> **Status:** ACTIVE — development environment guidance<br>
> **Scope:** Local Android builds only; this does not change product behavior or application code.

## Verified local environment

| Component | Verified value |
|---|---|
| Flutter | 3.47.6 / Dart 3.13.5 (local SDK) |
| Android SDK | `C:\\Users\\Smarderve\\AppData\\Local\\Android\\Sdk` |
| Android Studio JBR | `C:\\Program Files\\Android\\Android Studio\\jbr` (25.0.3) |
| Required NDK | r28c / `28.2.13676358` |
| Emulator | `Medium_Phone_API_37.0` / `emulator-5554` |

All Android SDK licenses were accepted during the 2026-10-09 verification. The NDK was installed into the existing Android SDK; no second SDK or Java installation was created.

## Codex Windows Java NIO workaround

### Original failure

When Gradle ran as a child process of Codex on Windows, Android Studio JBR failed at `Selector.open()` with the loopback chain `PipeImpl -> WEPollSelectorImpl -> UnixDomainSockets.connect0`, reporting an invalid-argument/loopback-connection error. This prevented Gradle from establishing its local daemon connection. A plain TCP loopback control was not affected.

### Temporary application

For a build command started from the Codex PowerShell process, set this environment variable **only for that process** before invoking Java, Gradle, or Flutter:

```powershell
$env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:\Windows\Temp'
```

Use the existing Android Studio JBR for the same command when required:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio\jbr'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
```

Do not add this setting to permanent Windows environment variables, Android Studio settings, project Gradle files, or Codex configuration. A new PowerShell process does not inherit this task-local setting. To remove it from the current process explicitly, run either:

```powershell
Remove-Item Env:JAVA_TOOL_OPTIONS
# or
$env:JAVA_TOOL_OPTIONS = $null
```

### Verification in Codex

On 2026-10-09, with the setting above, the local `SelectorProbe.java` printed `SELECTOR_OK` and exited 0. `android\\gradlew.bat help --stacktrace`, launched from the `android` directory, completed successfully with exit 0. `flutter build apk --debug` then completed successfully with exit 0 and produced the debug APK.

The normal, directly launched PowerShell comparison was **not run in this verification**. Do not infer that this workaround is needed outside Codex; verify a normal PowerShell build separately before documenting it as host-wide behavior.

## Build command

After applying the temporary setting in the current PowerShell process, use the verified local Flutter executable:

```powershell
& 'C:\Users\Smarderve\Downloads\flutter_windows_3.47.6-stable\flutter\bin\flutter.bat' build apk --debug
```

The expected output is `build\\app\\outputs\\flutter-apk\\app-debug.apk`. Flutter and Dart remain outside the persistent `PATH`; using the explicit local executable is intentional and was sufficient for verification.

## Non-blocking warnings

`flutter doctor -v` exits 0 and validates the Android toolchain and all licenses. It still warns that the local Flutter and Dart executables are not on the persistent `PATH`. No persistent PATH change was made because it is a convenience configuration rather than a build prerequisite.

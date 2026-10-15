# Local ROUNDVEIL candidate builds

`scripts/build_local_candidate.ps1` builds test artifacts from a clean Git archive of the current `HEAD`, not from uncommitted files in the checkout. It runs dependency resolution, analysis and the full Flutter test suite before producing either platform artifact. The source SHA is embedded in metadata and recorded alongside SHA-256 checksums.

Run from the repository with Flutter available on `PATH`, or pass its path explicitly:

```powershell
./scripts/build_local_candidate.ps1 -VersionLabel v1.0.0-alpha.1 `
  -FlutterPath 'C:\path\to\flutter\bin\flutter.bat'
```

Outputs go under `build/release-candidates/` by default. The metadata field `runtimeVerifiedByBuildScript` remains false because compilation and packaging are not runtime verification; record any subsequent manual runtime result separately.

- `ROUNDVEIL-Windows-v1.0.0-alpha.1-test.zip`: Windows Release-mode portable folder, including executable, Flutter runtime, bundled assets and plugin DLLs.
- `ROUNDVEIL-Android-v1.0.0-alpha.1-debug.apk`: installable debug APK. It is debug-signed and is not a production release.
- `ROUNDVEIL-v1.0.0-alpha.1-build-metadata.json` and `ROUNDVEIL-v1.0.0-alpha.1-SHA256SUMS.txt`: source revision, artifact type, size and hashes.

The Android build applies the already-approved Java loopback workaround only to the script's current PowerShell process and restores the previous value afterward. It does not persist SDK or environment changes.

These are local test candidates. The script does not install or launch either artifact, certify runtime compatibility, sign a production APK, create a tag, or publish a GitHub release. Windows Application Control must remain unchanged; packaged runtime checks still require an approved Windows execution environment. Use an owner-approved stable Android application ID and protected signing configuration before preparing a distributable release.

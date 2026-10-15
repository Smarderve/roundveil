[CmdletBinding()]
param(
    [switch]$SkipAndroid,
    [switch]$SkipWindows,
    [switch]$ReplaceArtifacts,
    [string]$FlutterPath = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$flutter = $FlutterPath
if ([string]::IsNullOrWhiteSpace($flutter)) {
    $flutterCommand = Get-Command 'flutter.bat' -ErrorAction SilentlyContinue
    if ($flutterCommand) { $flutter = $flutterCommand.Source }
}
if (-not (Test-Path -LiteralPath $flutter)) {
    throw 'Flutter was not found. Set the Flutter path in scripts/build_distribution.ps1 for this machine.'
}

$versionLine = Select-String -Path (Join-Path $repoRoot 'pubspec.yaml') -Pattern '^version:\s*(\S+)'
if (-not $versionLine) { throw 'Could not read version from pubspec.yaml.' }
$pubspecVersion = $versionLine.Matches[0].Groups[1].Value
$versionParts = $pubspecVersion.Split('+')
$version = $versionParts[0]
$buildNumber = if ($versionParts.Count -gt 1) { $versionParts[1] } else { '1' }
$numericVersion = "$($version.Split('-')[0]).$buildNumber"
$dist = Join-Path $repoRoot 'dist'
New-Item -ItemType Directory -Path $dist -Force | Out-Null

function Invoke-CheckedCommand {
    param([string]$Executable, [string[]]$Arguments)
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed ($LASTEXITCODE): $Executable $($Arguments -join ' ')"
    }
}

if (-not $SkipWindows) {
    Invoke-CheckedCommand $flutter @('build', 'windows', '--release')
    $releaseDir = Join-Path $repoRoot 'build\windows\x64\runner\Release'
    $required = @(
        (Join-Path $releaseDir 'roundveil.exe'),
        (Join-Path $releaseDir 'flutter_windows.dll'),
        (Join-Path $releaseDir 'data\flutter_assets\AssetManifest.bin')
    )
    foreach ($path in $required) {
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
            throw "Windows release bundle is incomplete; missing $path"
        }
    }
    $icon = Join-Path $repoRoot 'windows\runner\resources\app_icon.ico'
    if (-not (Test-Path -LiteralPath $icon -PathType Leaf)) {
        throw "ROUNDVEIL Windows icon resource is missing: $icon"
    }

    $signTool = $env:ROUNDVEIL_SIGNTOOL_PATH
    if ([string]::IsNullOrWhiteSpace($signTool)) {
        $signToolCommand = Get-Command 'signtool.exe' -ErrorAction SilentlyContinue
        if ($signToolCommand) { $signTool = $signToolCommand.Source }
    }
    $certificateThumbprint = $env:ROUNDVEIL_SIGN_CERT_SHA1
    if (-not [string]::IsNullOrWhiteSpace($certificateThumbprint) -and [string]::IsNullOrWhiteSpace($signTool)) {
        throw 'ROUNDVEIL_SIGN_CERT_SHA1 is configured, but signtool.exe was not found. Set ROUNDVEIL_SIGNTOOL_PATH.'
    }
    if (-not [string]::IsNullOrWhiteSpace($signTool) -and -not [string]::IsNullOrWhiteSpace($certificateThumbprint)) {
        $nativeBinaries = @(Get-ChildItem -LiteralPath $releaseDir -File -Recurse | Where-Object Extension -in '.exe','.dll')
        foreach ($binary in $nativeBinaries) {
            $signArgs = @('sign', '/fd', 'SHA256', '/sha1', $certificateThumbprint, '/v', $binary.FullName)
            if (-not [string]::IsNullOrWhiteSpace($env:ROUNDVEIL_SIGN_TIMESTAMP_URL)) {
                $signArgs = @('sign', '/fd', 'SHA256', '/sha1', $certificateThumbprint, '/tr', $env:ROUNDVEIL_SIGN_TIMESTAMP_URL, '/td', 'SHA256', '/v', $binary.FullName)
            }
            Invoke-CheckedCommand $signTool $signArgs
            Invoke-CheckedCommand $signTool @('verify', '/pa', '/all', '/v', $binary.FullName)
        }
    } else {
        Write-Warning 'Windows app bundle and installer will be unsigned; managed Windows Code Integrity acceptance is not verified.'
    }

    $iscc = $null
    $isccCommand = Get-Command 'ISCC.exe' -ErrorAction SilentlyContinue
    if ($isccCommand) { $iscc = $isccCommand.Source }
    if (-not $iscc) {
        $localIscc = Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'
        if (Test-Path -LiteralPath $localIscc) { $iscc = $localIscc }
    }
    if (-not $iscc) { throw 'Inno Setup ISCC.exe was not found.' }

    $setupPath = Join-Path $dist "ROUNDVEIL-Setup-v$version.exe"
    if (Test-Path -LiteralPath $setupPath) {
        if (-not $ReplaceArtifacts) { throw "Refusing to overwrite existing release artifact: $setupPath (use -ReplaceArtifacts to rebuild this version)" }
        Remove-Item -LiteralPath $setupPath -Force
    }
    $iss = Join-Path $repoRoot 'packaging\windows\roundveil.iss'
    Invoke-CheckedCommand $iscc @("/DAppVersion=$version", "/DAppNumericVersion=$numericVersion", $iss)
    if (-not (Test-Path -LiteralPath $setupPath -PathType Leaf)) {
        throw "Inno Setup did not produce the expected installer: $setupPath"
    }
    if (-not [string]::IsNullOrWhiteSpace($certificateThumbprint)) {
        $setupSignArgs = @('sign', '/fd', 'SHA256', '/sha1', $certificateThumbprint, '/v', $setupPath)
        if (-not [string]::IsNullOrWhiteSpace($env:ROUNDVEIL_SIGN_TIMESTAMP_URL)) {
            $setupSignArgs = @('sign', '/fd', 'SHA256', '/sha1', $certificateThumbprint, '/tr', $env:ROUNDVEIL_SIGN_TIMESTAMP_URL, '/td', 'SHA256', '/v', $setupPath)
        }
        Invoke-CheckedCommand $signTool $setupSignArgs
        Invoke-CheckedCommand $signTool @('verify', '/pa', '/all', '/v', $setupPath)
    }
    $setupInfo = Get-Item -LiteralPath $setupPath
    if ($setupInfo.Length -lt 1MB) { throw "Windows installer is unexpectedly small: $($setupInfo.Length) bytes" }
    Write-Output "Windows setup: $($setupInfo.FullName) ($($setupInfo.Length) bytes)"
}

if (-not $SkipAndroid) {
    $androidGradle = Get-Content -Raw (Join-Path $repoRoot 'android\app\build.gradle.kts')
    if ($androidGradle -match 'applicationId\s*=\s*"com\.example\.roundveil"') {
        throw 'Android APK not packaged: com.example.roundveil is still a placeholder. Approve the permanent application ID and data migration before changing it or publishing an APK.'
    }
    $signingVariables = @(
        'ROUNDVEIL_ANDROID_KEYSTORE',
        'ROUNDVEIL_ANDROID_STORE_PASSWORD',
        'ROUNDVEIL_ANDROID_KEY_ALIAS',
        'ROUNDVEIL_ANDROID_KEY_PASSWORD'
    )
    $missing = @($signingVariables | Where-Object { [string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($_)) })
    if ($missing.Count -gt 0) {
        throw "Android release APK not built: secure release signing is required. Missing current-process variables: $($missing -join ', '). No debug-signed APK will be packaged."
    }

    Invoke-CheckedCommand $flutter @('build', 'apk', '--release')
    $builtApk = Join-Path $repoRoot 'build\app\outputs\flutter-apk\app-release.apk'
    if (-not (Test-Path -LiteralPath $builtApk -PathType Leaf)) {
        throw "Android release build reported success but APK is missing: $builtApk"
    }
    $apkPath = Join-Path $dist "ROUNDVEIL-v$version.apk"
    if (Test-Path -LiteralPath $apkPath) {
        if (-not $ReplaceArtifacts) { throw "Refusing to overwrite existing release artifact: $apkPath (use -ReplaceArtifacts to rebuild this version)" }
        Remove-Item -LiteralPath $apkPath -Force
    }
    Copy-Item -LiteralPath $builtApk -Destination $apkPath
    $apkInfo = Get-Item -LiteralPath $apkPath
    if ($apkInfo.Length -lt 1MB) { throw "Android APK is unexpectedly small: $($apkInfo.Length) bytes" }
    $sdkRoot = $env:ANDROID_HOME
    if ([string]::IsNullOrWhiteSpace($sdkRoot)) { $sdkRoot = $env:ANDROID_SDK_ROOT }
    if ([string]::IsNullOrWhiteSpace($sdkRoot)) {
        $localProperties = Join-Path $repoRoot 'android\local.properties'
        if (Test-Path -LiteralPath $localProperties) {
            $sdkLine = Select-String -Path $localProperties -Pattern '^sdk\.dir=(.+)$' | Select-Object -First 1
            if ($sdkLine) { $sdkRoot = $sdkLine.Matches[0].Groups[1].Value.Replace('\\', '\') }
        }
    }
    if ([string]::IsNullOrWhiteSpace($sdkRoot)) { throw 'Cannot validate APK signature because Android SDK location was not found.' }
    $buildTools = Get-ChildItem -LiteralPath (Join-Path $sdkRoot 'build-tools') -Directory |
        Where-Object Name -Match '^\d+(\.\d+)+$' |
        Sort-Object { [version]$_.Name } -Descending |
        Select-Object -First 1
    if (-not $buildTools) { throw 'Cannot validate APK signature because Android SDK Build Tools were not found.' }
    $apksigner = Join-Path $buildTools.FullName 'apksigner.bat'
    if (-not (Test-Path -LiteralPath $apksigner)) { throw "APK signature verifier was not found: $apksigner" }
    Invoke-CheckedCommand $apksigner @('verify', '--verbose', '--print-certs', $apkPath)
    Write-Output "Android release APK: $($apkInfo.FullName) ($($apkInfo.Length) bytes)"
}

$artifacts = @(Get-ChildItem -LiteralPath $dist -File | Where-Object Name -Match '^ROUNDVEIL-(Setup-v|v).+\.(exe|apk)$')
if ($artifacts.Count -gt 0) {
    $checksumPath = Join-Path $dist 'SHA256SUMS.txt'
    if (Test-Path -LiteralPath $checksumPath) {
        if (-not $ReplaceArtifacts) { throw "Refusing to overwrite existing checksum file: $checksumPath (use -ReplaceArtifacts to regenerate it)" }
        Remove-Item -LiteralPath $checksumPath -Force
    }
    $lines = foreach ($artifact in $artifacts) {
        $hash = (Get-FileHash -LiteralPath $artifact.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        "$hash  $($artifact.Name)"
    }
    Set-Content -LiteralPath $checksumPath -Value $lines -Encoding ascii
    Write-Output "SHA-256 manifest: $checksumPath"
}

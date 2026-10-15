[CmdletBinding()]
param(
    [Parameter()]
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9._-]*$')]
    [string] $VersionLabel = 'v1.0.0-alpha.1',

    [Parameter()]
    [string] $FlutterPath,

    [Parameter()]
    [string] $OutputDirectory = 'build/release-candidates'
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$commit = (& git -C $repositoryRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or $commit -notmatch '^[0-9a-f]{40}$') {
    throw 'Unable to resolve the source commit. Run this script inside the ROUNDVEIL Git repository.'
}

if (-not $FlutterPath) {
    $flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
    if ($flutterCommand) {
        $FlutterPath = $flutterCommand.Source
    }
}
if (-not $FlutterPath -or -not (Test-Path -LiteralPath $FlutterPath -PathType Leaf)) {
    throw 'Flutter was not found. Pass -FlutterPath with the approved Flutter executable.'
}
$FlutterPath = (Resolve-Path -LiteralPath $FlutterPath).Path

$packageVersionLine = Select-String -LiteralPath (Join-Path $repositoryRoot 'pubspec.yaml') -Pattern '^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$' | Select-Object -First 1
if (-not $packageVersionLine) {
    throw 'pubspec.yaml must contain a version in major.minor.patch+build form.'
}
$buildName = $packageVersionLine.Matches[0].Groups[1].Value
$androidBuildName = $VersionLabel.TrimStart('v')
$buildNumber = $packageVersionLine.Matches[0].Groups[2].Value

$outputPath = Join-Path $repositoryRoot $OutputDirectory
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
$workRoot = Join-Path ([IO.Path]::GetTempPath()) ("roundveil-candidate-" + [guid]::NewGuid().ToString('N'))
$sourceArchive = Join-Path $workRoot 'source.zip'
$sourcePath = Join-Path $workRoot 'source'
$stagingPath = Join-Path $workRoot 'windows-package'
$metadataPath = Join-Path $outputPath "ROUNDVEIL-$VersionLabel-build-metadata.json"
$windowsZip = Join-Path $outputPath "ROUNDVEIL-Windows-$VersionLabel-test.zip"
$androidApk = Join-Path $outputPath "ROUNDVEIL-Android-$VersionLabel-debug.apk"
$javaOptionsBefore = $env:JAVA_TOOL_OPTIONS

function Invoke-CheckedCommand {
    param([string] $Description, [scriptblock] $Command)
    & $Command
    if ($LASTEXITCODE -ne 0) {
        throw "$Description failed with exit code $LASTEXITCODE."
    }
}

try {
    New-Item -ItemType Directory -Path $workRoot | Out-Null
    New-Item -ItemType Directory -Path $sourcePath | Out-Null
    Invoke-CheckedCommand 'Git source archive' { git -C $repositoryRoot archive --format=zip --output=$sourceArchive $commit }
    Expand-Archive -LiteralPath $sourceArchive -DestinationPath $sourcePath

    Push-Location $sourcePath
    try {
        Invoke-CheckedCommand 'Flutter dependency resolution' { & $FlutterPath pub get }
        Invoke-CheckedCommand 'Flutter analysis' { & $FlutterPath analyze }
        Invoke-CheckedCommand 'Flutter tests' { & $FlutterPath test }
        Invoke-CheckedCommand 'Windows release build' { & $FlutterPath build windows --release --build-name $buildName --build-number $buildNumber }

        $windowsBuild = Join-Path $sourcePath 'build/windows/x64/runner/Release'
        $requiredWindowsFiles = @(
            'roundveil.exe',
            'flutter_windows.dll',
            'data/flutter_assets/AssetManifest.bin'
        )
        foreach ($relativePath in $requiredWindowsFiles) {
            if (-not (Test-Path -LiteralPath (Join-Path $windowsBuild $relativePath) -PathType Leaf)) {
                throw "Windows release output is incomplete: missing $relativePath."
            }
        }

        New-Item -ItemType Directory -Path $stagingPath | Out-Null
        Copy-Item -Path (Join-Path $windowsBuild '*') -Destination $stagingPath -Recurse -Force

        $env:JAVA_TOOL_OPTIONS = '-Djdk.net.unixdomain.tmpdir=C:\Windows\Temp'
        Invoke-CheckedCommand 'Android debug APK build' { & $FlutterPath build apk --debug --build-name $androidBuildName --build-number $buildNumber }
        $builtApk = Join-Path $sourcePath 'build/app/outputs/flutter-apk/app-debug.apk'
        if (-not (Test-Path -LiteralPath $builtApk -PathType Leaf)) {
            throw 'Flutter reported success, but app-debug.apk does not exist.'
        }
    }
    finally {
        Pop-Location
        $env:JAVA_TOOL_OPTIONS = $javaOptionsBefore
    }

    $windowsMetadata = [ordered]@{
        product = 'ROUNDVEIL'
        version = $VersionLabel
        sourceCommit = $commit
        artifactType = 'Windows portable test package; Release build'
        runtimeVerifiedByBuildScript = $false
        builtUtc = [DateTime]::UtcNow.ToString('o')
    }
    $windowsMetadata | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $stagingPath 'ROUNDVEIL_BUILD_METADATA.json') -Encoding utf8
    if (Test-Path -LiteralPath $windowsZip) { Remove-Item -LiteralPath $windowsZip -Force }
    Compress-Archive -Path (Join-Path $stagingPath '*') -DestinationPath $windowsZip -CompressionLevel Optimal
    Copy-Item -LiteralPath $builtApk -Destination $androidApk -Force

    $metadata = [ordered]@{
        product = 'ROUNDVEIL'
        version = $VersionLabel
        sourceCommit = $commit
        flutterBuildName = $buildName
        androidVersionName = $androidBuildName
        flutterBuildNumber = $buildNumber
        builtUtc = [DateTime]::UtcNow.ToString('o')
        runtimeVerification = $null
        windows = [ordered]@{
            file = [IO.Path]::GetFileName($windowsZip)
            kind = 'Portable Release-mode test ZIP; not a signed installer'
            runtimeVerifiedByBuildScript = $false
            sha256 = (Get-FileHash -LiteralPath $windowsZip -Algorithm SHA256).Hash.ToLowerInvariant()
            bytes = (Get-Item -LiteralPath $windowsZip).Length
        }
        android = [ordered]@{
            file = [IO.Path]::GetFileName($androidApk)
            kind = 'Debug APK; debug signing; not a production release'
            runtimeVerifiedByBuildScript = $false
            sha256 = (Get-FileHash -LiteralPath $androidApk -Algorithm SHA256).Hash.ToLowerInvariant()
            bytes = (Get-Item -LiteralPath $androidApk).Length
        }
    }
    $metadata | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $metadataPath -Encoding utf8
    @(
        "$($metadata.windows.sha256)  $($metadata.windows.file)",
        "$($metadata.android.sha256)  $($metadata.android.file)"
    ) | Set-Content -LiteralPath (Join-Path $outputPath "ROUNDVEIL-$VersionLabel-SHA256SUMS.txt") -Encoding ascii

    Write-Output "Source commit: $commit"
    Write-Output "Windows test package: $windowsZip"
    Write-Output "Android debug APK: $androidApk"
    Write-Output "Metadata: $metadataPath"
}
finally {
    $env:JAVA_TOOL_OPTIONS = $javaOptionsBefore
    if (Test-Path -LiteralPath $workRoot) {
        Remove-Item -LiteralPath $workRoot -Recurse -Force
    }
}

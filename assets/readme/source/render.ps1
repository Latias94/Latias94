$ErrorActionPreference = 'Stop'

$sourceRoot = [System.IO.Path]::GetFullPath($PSScriptRoot)
$readmeAssetRoot = [System.IO.Path]::GetFullPath((Join-Path $sourceRoot '..'))
$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $sourceRoot '..\..\..'))
$systemTempRoot = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath()).TrimEnd([System.IO.Path]::DirectorySeparatorChar)
$renderTempRoot = [System.IO.Path]::GetFullPath((Join-Path $systemTempRoot ("latias94-readme-" + [System.Guid]::NewGuid().ToString('N'))))

$browserCandidates = @(
    (Get-Command msedge -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
    (Get-Command chrome -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
    'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
    'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
    'C:\Program Files\Google\Chrome\Application\chrome.exe',
    'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

$browserPath = $browserCandidates | Select-Object -First 1
if (-not $browserPath) {
    throw 'A Chromium browser is required. Install Microsoft Edge or Google Chrome.'
}

function Render-Composition {
    param(
        [Parameter(Mandatory)]
        [string] $SourceFile,

        [Parameter(Mandatory)]
        [string] $OutputFile,

        [Parameter(Mandatory)]
        [int] $Width,

        [Parameter(Mandatory)]
        [int] $Height
    )

    $sourcePath = [System.IO.Path]::GetFullPath((Join-Path $sourceRoot $SourceFile))
    $outputPath = [System.IO.Path]::GetFullPath((Join-Path $sourceRoot $OutputFile))

    if (-not $sourcePath.StartsWith($sourceRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Source path escaped the source directory: $sourcePath"
    }

    if (-not $outputPath.StartsWith($readmeAssetRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Output path escaped the README asset directory: $outputPath"
    }

    $compositionName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile)
    $screenshotPath = Join-Path $renderTempRoot ($compositionName + '.png')
    $browserDataRoot = Join-Path $renderTempRoot ('browser-' + $compositionName)
    $sourceUri = ([System.Uri]::new($sourcePath)).AbsoluteUri
    $browserArguments = @(
        '--headless=new',
        '--disable-gpu',
        '--disable-background-networking',
        '--hide-scrollbars',
        '--no-first-run',
        '--force-device-scale-factor=1',
        ("--window-size=$Width,$Height"),
        ("--user-data-dir=$browserDataRoot"),
        ("--screenshot=$screenshotPath"),
        $sourceUri
    )

    & $browserPath @browserArguments | Out-Null
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $screenshotPath)) {
        throw "Chromium failed while rendering $SourceFile"
    }

    & magick $screenshotPath -strip -quality 88 -define webp:method=6 $outputPath
    if ($LASTEXITCODE -ne 0) {
        throw "ImageMagick failed while encoding $OutputFile"
    }
}

try {
    if (-not $renderTempRoot.StartsWith($systemTempRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Render directory escaped the system temporary directory: $renderTempRoot"
    }

    New-Item -ItemType Directory -Force -Path $renderTempRoot | Out-Null

    Render-Composition -SourceFile 'hero.svg' -OutputFile '..\hero.webp' -Width 1200 -Height 520
    Render-Composition -SourceFile 'merman-showcase.svg' -OutputFile '..\merman-showcase.webp' -Width 1200 -Height 560
    Render-Composition -SourceFile 'fret-showcase.svg' -OutputFile '..\fret-showcase.webp' -Width 1200 -Height 620
}
finally {
    if (Test-Path -LiteralPath $renderTempRoot) {
        $resolvedRenderTempRoot = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $renderTempRoot).Path)
        $blockedPaths = @(
            $systemTempRoot,
            $repoRoot,
            [System.IO.Path]::GetFullPath($env:USERPROFILE),
            [System.IO.Path]::GetPathRoot($resolvedRenderTempRoot)
        )

        if ($blockedPaths -contains $resolvedRenderTempRoot) {
            throw "Refusing to remove protected path: $resolvedRenderTempRoot"
        }

        if (-not $resolvedRenderTempRoot.StartsWith($systemTempRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to remove path outside the system temporary directory: $resolvedRenderTempRoot"
        }

        if ([System.IO.Path]::GetFileName($resolvedRenderTempRoot) -notlike 'latias94-readme-*') {
            throw "Refusing to remove an unexpected temporary directory: $resolvedRenderTempRoot"
        }

        Write-Host "Cleaning temporary render directory: $resolvedRenderTempRoot"
        Remove-Item -LiteralPath $resolvedRenderTempRoot -Recurse -Force
    }
}

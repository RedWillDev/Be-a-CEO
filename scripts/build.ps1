$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$localRojo = Join-Path $projectRoot "tools\rojo\rojo.exe"
$outputDirectory = Join-Path $projectRoot "build"
$outputPlace = Join-Path $outputDirectory "Be-a-CEO.rbxlx"
$rojoCommand = Get-Command rojo -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null

if (Test-Path -LiteralPath $localRojo) {
    & $localRojo build (Join-Path $projectRoot "default.project.json") --output $outputPlace
    exit $LASTEXITCODE
}

if ($rojoCommand) {
    & $rojoCommand.Source build (Join-Path $projectRoot "default.project.json") --output $outputPlace
    exit $LASTEXITCODE
}

throw "Rojo est introuvable. Executez d'abord scripts/setup-rojo.ps1."

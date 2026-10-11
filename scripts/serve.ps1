$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$localRojo = Join-Path $projectRoot "tools\rojo\rojo.exe"
$rojoCommand = Get-Command rojo -ErrorAction SilentlyContinue

if (Test-Path -LiteralPath $localRojo) {
    & $localRojo serve (Join-Path $projectRoot "default.project.json")
    exit $LASTEXITCODE
}

if ($rojoCommand) {
    & $rojoCommand.Source serve (Join-Path $projectRoot "default.project.json")
    exit $LASTEXITCODE
}

throw "Rojo est introuvable. Executez d'abord scripts/setup-rojo.ps1."

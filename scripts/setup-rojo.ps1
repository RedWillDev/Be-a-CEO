param(
    [string]$Version = "7.7.1"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent $PSScriptRoot
$toolsRoot = Join-Path $projectRoot "tools\rojo"
$rojoPath = Join-Path $toolsRoot "rojo.exe"

if (Test-Path -LiteralPath $rojoPath) {
    & $rojoPath --version
    exit 0
}

$assetName = "rojo-$Version-windows-x86_64.zip"
$downloadUrl = "https://github.com/rojo-rbx/rojo/releases/download/v$Version/$assetName"
$temporaryRoot = Join-Path $projectRoot "tools\.rojo-download"
$archivePath = Join-Path $temporaryRoot $assetName

New-Item -ItemType Directory -Force -Path $temporaryRoot | Out-Null
New-Item -ItemType Directory -Force -Path $toolsRoot | Out-Null

Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath
Expand-Archive -LiteralPath $archivePath -DestinationPath $temporaryRoot -Force

$downloadedBinary = Get-ChildItem -LiteralPath $temporaryRoot -Filter "rojo.exe" -Recurse | Select-Object -First 1
if (-not $downloadedBinary) {
    throw "Le binaire rojo.exe est absent de l'archive telechargee."
}

Copy-Item -LiteralPath $downloadedBinary.FullName -Destination $rojoPath -Force
Remove-Item -LiteralPath $temporaryRoot -Recurse -Force

& $rojoPath --version

# Build Flutter web (no service worker = refreshes pick up new JS easily), then serve on 127.0.0.1:8080
# Open: http://127.0.0.1:8080/iphone_preview.html
# Stop with Ctrl+C. If 8080 is busy, change $port below.

$ErrorActionPreference = "Stop"
$port = 8080
Set-Location $PSScriptRoot\..
$flutter = "flutter"
if (Test-Path "C:\src\flutter\bin\flutter.bat") { $flutter = "C:\src\flutter\bin\flutter.bat" }
if (Test-Path "$env:LOCALAPPDATA\flutter\bin\flutter.bat") { $flutter = "$env:LOCALAPPDATA\flutter\bin\flutter.bat" }

Write-Host "Building web (pwa-strategy=none)..."
& $flutter build web --pwa-strategy=none
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Set-Location "build\web"
Write-Host "Serving http://127.0.0.1:$port/iphone_preview.html (Ctrl+C to stop)"
python -m http.server $port --bind 127.0.0.1

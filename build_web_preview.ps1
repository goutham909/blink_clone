# Rebuild Flutter web so bundled images + catalog ship in build/web (required for iphone_preview).
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  Write-Host "flutter not found in PATH. Install Flutter SDK and reopen the terminal." -ForegroundColor Red
  exit 1
}

flutter pub get
flutter build web

Write-Host ""
Write-Host "Next: serve the OUTPUT folder (build\web), not web\:" -ForegroundColor Green
Write-Host "  cd build\web" -ForegroundColor Cyan
Write-Host "  python -m http.server 8080" -ForegroundColor Cyan
Write-Host "Then open http://127.0.0.1:8080/iphone_preview.html" -ForegroundColor Cyan

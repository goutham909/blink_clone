# Flutter web dev server with hot reload. Stop any other server on this port first.
# Preview: http://127.0.0.1:8080/iphone_preview.html
# In the terminal: r = hot reload, R = hot restart, q = quit

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..
$flutter = "flutter"
if (Test-Path "C:\src\flutter\bin\flutter.bat") { $flutter = "C:\src\flutter\bin\flutter.bat" }
if (Test-Path "$env:LOCALAPPDATA\flutter\bin\flutter.bat") { $flutter = "$env:LOCALAPPDATA\flutter\bin\flutter.bat" }
& $flutter run -d web-server --web-port=8080 --web-hostname=127.0.0.1

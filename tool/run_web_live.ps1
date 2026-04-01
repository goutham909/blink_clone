# Flutter web dev server with hot reload. Stop any other server on this port first.
# Preview: http://127.0.0.1:7357/iphone_preview.html
# In the terminal: r = hot reload, R = hot restart, q = quit

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..
$flutter = "flutter"
if (Test-Path "C:\src\flutter\bin\flutter.bat") { $flutter = "C:\src\flutter\bin\flutter.bat" }
& $flutter run -d web-server --web-port=7357 --web-hostname=127.0.0.1

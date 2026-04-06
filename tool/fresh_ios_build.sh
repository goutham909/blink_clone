#!/usr/bin/env bash
# Fresh iOS builds from a clean state: simulator (stays in build/ios/) + device IPA on Desktop.
#
# Usage (from repo root or anywhere):
#   ./tool/fresh_ios_build.sh
#
# Simulator output: build/ios/Debug-iphonesimulator/ (and iphonesimulator/) — use: flutter run -d ios
# Device output:    ~/Desktop/ios_apps/blinkit/*.ipa (release) + Runner.app (same build, extracted from that IPA)
#
# Options:
#   --simulator-only   Only simulator build (no device / IPA)
#   --device-only      Only flutter build ipa + copy to ~/Desktop/ios_apps/blinkit (skips simulator)
#   -h, --help         Show this help

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESKTOP_APPS="${HOME}/Desktop/ios_apps/blinkit"

mode=dual
IPA_SRC=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      sed -n '2,16p' "$0"
      exit 0
      ;;
    --simulator-only) mode=simulator ;;
    --device-only) mode=device ;;
    *)
      echo "Unknown option: $1 (use --help)" >&2
      exit 1
      ;;
  esac
  shift
done

cd "$ROOT"

echo "==> flutter clean"
flutter clean

echo "==> flutter pub get"
flutter pub get

if [[ -f ios/Podfile ]]; then
  echo "==> pod install (ios)"
  (cd ios && pod install)
fi

if [[ "$mode" == "dual" || "$mode" == "simulator" ]]; then
  echo "==> flutter build ios --simulator (debug; stays under build/ios/)"
  flutter build ios --simulator
fi

if [[ "$mode" == "dual" || "$mode" == "device" ]]; then
  echo "==> flutter build ipa (release; same Xcode team / signing as Runner target)"
  flutter build ipa

  IPA_SRC=$(find "${ROOT}/build/ios/ipa" -maxdepth 1 -name '*.ipa' -print -quit)
  if [[ -z "$IPA_SRC" ]]; then
    echo "error: no .ipa under ${ROOT}/build/ios/ipa" >&2
    exit 1
  fi

  echo "==> copy IPA + Runner.app -> $DESKTOP_APPS/"
  mkdir -p "$DESKTOP_APPS"
  cp "$IPA_SRC" "$DESKTOP_APPS/"

  TMP=$(mktemp -d)
  unzip -q -o "$IPA_SRC" -d "$TMP"
  APP_IN_PAYLOAD=$(find "$TMP/Payload" -maxdepth 1 -name '*.app' -print -quit)
  if [[ -z "$APP_IN_PAYLOAD" ]]; then
    rm -rf "$TMP"
    echo "error: no .app inside IPA payload" >&2
    exit 1
  fi
  rm -rf "${DESKTOP_APPS}/Runner.app"
  ditto "$APP_IN_PAYLOAD" "${DESKTOP_APPS}/Runner.app"
  rm -rf "$TMP"
fi

echo ""
echo "Done."
[[ "$mode" == "dual" || "$mode" == "simulator" ]] && echo "  Simulator: ${ROOT}/build/ios/ (e.g. iphonesimulator/Runner.app)"
if [[ "$mode" == "dual" || "$mode" == "device" ]]; then
  echo "  Device IPA: ${DESKTOP_APPS}/$(basename "$IPA_SRC")"
  echo "  Device .app: ${DESKTOP_APPS}/Runner.app (same build as IPA)"
fi

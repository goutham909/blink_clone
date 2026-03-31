# Blink Clone

Quick-commerce style **UI clone** with **mock JSON** data (Riverpod + go_router). For local development and automation experiments—not affiliated with any retailer.

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) (stable), Android Studio or VS Code + Android SDK
- After cloning, create `android/local.properties` with your SDK path, or run any Flutter command and let the tool generate it

## Run

```bash
cd blink_clone
flutter pub get
flutter run
```

Use an Android emulator or device. On first open, Flutter writes `android/local.properties` with `flutter.sdk` when you run from the project directory.

## Web + iPhone-style preview

After `flutter run -d web-server` (or your dev URL), open **`/iphone_preview.html`** on the same origin (e.g. `http://127.0.0.1:8080/iphone_preview.html`) for a browser frame that mimics an iPhone around the app.

## iOS

This repo ships with **Android** only. Add iOS with:

```bash
flutter create --platforms=ios .
```

Then configure signing / Codemagic for cloud builds on macOS.

## Mock data

Edit [`assets/mock/catalog.json`](assets/mock/catalog.json). Keys like `product_card_<id>` and `stepper_inc_<id>` support UI automation.

## Debug (profile mode only)

A bug icon FAB appears in **debug** builds: clear cart, clear orders, reload catalog cache.

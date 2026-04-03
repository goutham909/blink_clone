# Blink Clone — Project Guide

This document describes **this repository only**: what Blink Clone is, how it is structured, how mock data drives the UI, and how to run and extend it.

**Universal clone methodology:** For a stack-agnostic playbook aimed at coding agents (any target app, realism standards, phased workflow), use **`AGENT_PLAYBOOK.md`** in the same folder. That file is portable without this codebase; this guide assumes you are inside **blink_clone**.

---

## 1. What this project is

**Blink Clone** is a **Flutter** application that mimics the look and feel of a **quick-commerce** (Blinkit-style) storefront: home feed with category tiles, horizontal product rails, search with filters, cart, checkout, orders with a **simulated delivery timeline**, account settings, and more.

There is **no real backend**. The catalog is **`assets/mock/catalog.json`**, bundled as a Flutter asset. Cart and wishlist are in memory; **orders** are persisted with `shared_preferences` (last few orders). Images are mostly **remote URLs** (e.g. Unsplash) or optional **bundled assets** via an `asset:` prefix (see `CatalogImage`).

The design goal is a **data-driven UI**: editing JSON reshapes banners, categories, rails, products, and navigation targets without changing Dart, while Riverpod, GoRouter, and timers handle state and navigation.

---

## 2. Tech stack

| Piece | Package / choice |
|--------|------------------|
| UI framework | Flutter (Material 3) |
| State | `flutter_riverpod` — `FutureProvider`, `NotifierProvider`, `StateProvider` |
| Routing | `go_router` — shell routes for bottom nav + full-screen routes for search, cart, etc. |
| Fonts | `google_fonts` — DM Sans in `lib/app.dart` |
| Local persistence | `shared_preferences` — orders JSON; provider overridden in `main.dart` |
| SDK | Dart `>=3.5.0 <4.0.0` (`pubspec.yaml`) |

---

## 3. Repository layout

```
blink_clone/
├── lib/
│   ├── main.dart                 # WidgetsFlutterBinding, SharedPreferences, ProviderScope
│   ├── app.dart                  # MaterialApp.router, theme, debug FAB (debug only)
│   ├── core/                     # constants, category_icons, order_delivery_timeline
│   ├── data/
│   │   ├── models/               # JSON ↔ Dart (Product, MockCatalog, rails, deals, …)
│   │   ├── repositories/         # CatalogRepository
│   │   └── sources/              # MockCatalogSource (rootBundle + cache)
│   ├── providers/providers.dart  # catalog, cart, orders, wishlist, toggles, …
│   ├── routing/                  # app_router.dart, app_shell.dart
│   ├── features/                 # one folder per screen / feature
│   └── widgets/                  # shared UI (product_card, catalog_image, debug_panel, …)
├── assets/mock/catalog.json      # Single source of truth for mock catalog
├── web/iphone_preview.html       # Optional phone-frame preview for web
├── tool/*.ps1                    # Windows helpers for web run / build
├── PROJECT_GUIDE.md              # This file
└── AGENT_PLAYBOOK.md             # Generic agent playbook for any app clone
```

---

## 4. Prerequisites and first run

1. Install [Flutter](https://docs.flutter.dev/get-started/install); run `flutter doctor`.
2. Terminal: **`cd`** to the directory that contains **`pubspec.yaml`**.
3. `flutter pub get`
4. `flutter run` (or `flutter run -d chrome`)

### Web (scripts in this repo)

From `tool/` on Windows:

- **`run_web_live.ps1`** — `flutter run -d web-server` on `127.0.0.1:8080`.
- **`build_and_serve_web.ps1`** — `flutter build web --pwa-strategy=none` then `python -m http.server` from `build/web`.

Open **`http://127.0.0.1:8080/iphone_preview.html`** for a framed preview (`web/iphone_preview.html`).

Network images in JSON require connectivity; failures fall back to placeholders from `imageHint` in `lib/widgets/catalog_image.dart`.

---

## 5. Application bootstrap

**`lib/main.dart`:** `ensureInitialized`, await `SharedPreferences.getInstance()`, `ProviderScope` with `sharedPreferencesProvider` override.

**`lib/app.dart`:** `MaterialApp.router`, `buildBlinkTheme` from `appearanceDarkProvider`, debug-only bug FAB → `showDebugPanel` (`lib/widgets/debug_panel_sheet.dart`).

---

## 6. Routing and navigation

**`lib/routing/app_router.dart`**

- **`StatefulShellRoute.indexedStack`** — bottom tabs: `/home`, `/order-again`, `/categories`, `/print`.
- **Pushed routes** (parent root navigator): `/search` (`q`, `category`, `rail`), `/account`, `/wishlist`, `/cart`, `/orders`, `/checkout`, `/product/:id`, `/orders/detail/:orderId`.

**`lib/routing/app_shell.dart`:** `NavigationBar` + `navigationShell.goBranch`.

Deep links into search: `context.pushNamed('search', queryParameters: { ... })`. **`SearchScreen`** reads `GoRouterState.of(context).uri.queryParameters` in `didChangeDependencies`.

---

## 7. Data layer

1. **`catalogProvider`** (`FutureProvider`) → **`CatalogRepository.getCatalog()`**.
2. **`MockCatalogSource.load()`** → `rootBundle.loadString(mockCatalogAssetPath)` → parse → **in-memory cache**.
3. **`MockCatalog.fromJson`** fills `banners`, `categories`, `rails`, `products`, `dealCards`, `shopCategoryTiles`, addresses, etc.

**Debug:** “Reload catalog cache” calls `mockCatalogSource.clearCache()` and `ref.invalidate(catalogProvider)`.

**Repository:** `searchProducts(query)`, `getProduct(id)`.

Asset path constant: **`lib/core/constants.dart`** → `mockCatalogAssetPath`.

---

## 8. `catalog.json` contract (summary)

| Area | Role |
|------|------|
| `schemaVersion`, `datasetId` | Versioning / ID |
| `locationLabel`, `deliveryMinutes`, `currentLocationAddress` | Header / address |
| `recommendationBrand`, `poweredBy` | Home strip (e.g. summer theme); taps → search |
| `banners` | Hero / carousel items |
| `categories` | Chips; `iconName` → `lib/core/category_icons.dart` |
| `shopCategoryTiles` | Grid; `searchQuery` or `categoryId` → search |
| `dealCards` | Promo cards; `targetCategoryId` → scoped search |
| `rails` | `id`, `title`, `productIds[]` → horizontal `ProductCard` lists |
| `products` | Full **Product** rows |
| `recentSearches`, `trendingProductIds` | Search UX |
| `savedAddresses` | Address bottom sheet |

**Product** fields and helpers: see **`lib/data/models/product.dart`** (`discountPercent`, `isSensitiveCategory` for `cat_pharma`, `isLowStock`, …).

**Images:** `https://...` or `asset:path` — **`CatalogImage`**; missing ref → gradient + icon from `imageHint`.

---

## 9. State (`lib/providers/providers.dart`)

| Provider | Role |
|----------|------|
| `catalogProvider` | Async catalog |
| `cartProvider` / `cartTotalsProvider` | Lines and totals |
| `ordersProvider` | Orders + timers + prefs persistence |
| `recentSearchesNotifierProvider` | Session recent queries |
| `selectedAddressProvider` | Mock address selection |
| `wishlistProvider` | Product id set |
| `appearanceDarkProvider` | App theme |
| `hideSensitiveProvider` | Hide pharma on home/search |
| `walletBalanceProvider` | Demo wallet |

**`visibleWithSensitiveFilter`** — shared gating for home rails and search.

---

## 10. Dynamic UI (this app)

- **Festival rotation (`home_screen.dart` + `home_festival_theme.dart`):** Timer every **12s** cycles Summer → Hanuman → Diwali visuals; **`WidgetsBindingObserver`** restarts timer on **resume** (web background throttling).
- **Rotating search hints (`_HomeSearchEntryBar`):** Timer + **`AnimatedSwitcher`** on fake search bar.
- **Orders (`OrdersNotifier` + `order_delivery_timeline.dart`):** Timed status steps; **reconcile** from `placedAt` after restart; progress bar and copy share the same timeline.
- **Cart bar on home:** Shown when `cartTotalsProvider` has items → `/cart`.
- **Scoped search:** `category` and `rail` query params filter results.

---

## 11. Feature files (quick map)

| Area | Path |
|------|------|
| Home | `lib/features/home/home_screen.dart` |
| Header / address | `lib/features/home/widgets/home_header.dart`, `address_bottom_sheet.dart` |
| Shop grid | `lib/features/home/widgets/shop_category_grid.dart` |
| Search | `lib/features/search/search_screen.dart` |
| Product detail | `lib/features/product_detail/product_detail_screen.dart` |
| Cart / checkout | `lib/features/cart/`, `lib/features/checkout/` |
| Orders | `lib/features/orders/` |
| Account | `lib/features/account/account_screen.dart` |

---

## 12. Theming

Global light/dark: **`buildBlinkTheme`** in `app.dart`. Brand colors: **`lib/core/constants.dart`**. Home scroll body uses a **local light `ThemeData`** inside `HomeScreen` for contrast with festival headers.

---

## 13. Debug panel

Debug FAB → clear cart, clear orders, clear recent searches / address, **reload catalog cache**.

---

## 14. Extending content via JSON (no Dart)

1. **Product** — unique `id`, valid `categoryId`.
2. **Rail** — new `rails` entry + `productIds`; link with `queryParameters: {'rail': 'id'}`.
3. **Shop tile** — `shopCategoryTiles` + `imageRef` + `searchQuery` or `categoryId`.
4. **Deal** — `dealCards` + optional `targetCategoryId`.
5. **Category chip** — `categories`; new `iconName` may need **`category_icons.dart`**.

Then debug **Reload catalog cache** or hot restart.

---

## 15. Legal note

Educational UI clone; **not** affiliated with Blinkit or brands in mock data. Replace imagery and trademarks for anything public-facing.

---

## 16. Key file index

| Topic | File |
|--------|------|
| Entry | `lib/main.dart` |
| Theme + router | `lib/app.dart` |
| Routes | `lib/routing/app_router.dart` |
| Providers | `lib/providers/providers.dart` |
| JSON source | `lib/data/sources/mock_catalog_source.dart` |
| Catalog model | `lib/data/models/mock_catalog.dart` |
| Mock data | `assets/mock/catalog.json` |
| Order timeline | `lib/core/order_delivery_timeline.dart` |
| Festival tokens | `lib/features/home/home_festival_theme.dart` |

---

*For building clones of other apps from first principles, follow **`AGENT_PLAYBOOK.md`**.*

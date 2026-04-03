# Images & catalog changes — report

This document summarizes work done to add **visual imagery** to the Blink Clone demo: a **shop-by-category grid** on the home screen and **product photos** across listing and detail flows. It also records **why Blinkit screenshots were not used** as image sources and how to **keep web builds in sync** with mock data.

---

## 1. Why we did not use Blinkit website screenshots

- **Copyright & trademarks:** Blinkit’s UI, product photography, and brand packaging are owned by Blinkit and brand owners. Cropping or reusing those screenshots in a clone would redistribute **third-party IP** and **registered marks** without permission.
- **What we did instead:** The app uses **freely licensed stock photos** (Unsplash) and the existing **`CatalogImage`** pipeline (`https://…` or `asset:…`). Layout and density were **inspired** by quick-commerce patterns (square tiles, soft tile background, labels), not by copying Blinkit’s proprietary artwork.

---

## 2. Shop-by-category grid (home screen)

### Goal

Replace the previous **horizontal row of circular icon chips** with a **Blinkit-style grid**: square cells, light tile background, rounded corners, product-style photo, two-line label, responsive column count (typically 4–5 on phones).

### Data model

| Piece | Location | Role |
|--------|-----------|------|
| `ShopCategoryTile` | `lib/data/models/shop_category_tile.dart` | `label`, `imageRef`, optional `categoryId`, optional `searchQuery` |
| `MockCatalog.shopCategoryTiles` | `lib/data/models/mock_catalog.dart` | Parsed from JSON (defaults to empty list if key missing) |

### UI

| Piece | Location | Role |
|--------|-----------|------|
| `ShopCategoryGrid` | `lib/features/home/widgets/shop_category_grid.dart` | `GridView` + `CatalogImage` per tile |
| Home integration | `lib/features/home/home_screen.dart` | Renders `ShopCategoryGrid` when `shopCategoryTiles` is non-empty; tap opens search with `q` and/or `category` query params |

### Mock data

- **`assets/mock/catalog.json`** — top-level array **`shopCategoryTiles`** (20 tiles): each entry has Unsplash **`imageRef`** URLs and navigation via **`searchQuery`** or **`categoryId`** (existing `cat_*` ids).

### Not changed here

- **`categories`** in JSON remains for search labels, `/categories`, deal `targetCategoryId`, etc.
- **`deal_card_widget.dart`** still uses **`ProductImagePlaceholder`** (hint-based thumbnails from deal JSON, not full product rows).

---

## 3. Product images

### Goal

Show **real thumbnails** wherever a **`Product`** appears in the UI, not only gradient + icon placeholders.

### Model

| Change | Location |
|--------|-----------|
| Optional **`imageRef`** (`String?`) on **`Product`** | `lib/data/models/product.dart` |
| **`fromJson` / `toJson`** | `imageRef` read from JSON; written in `toJson` only when non-null (helps persisted orders stay compact) |

### Mock data

- **`assets/mock/catalog.json`** — each object under **`products`** includes **`imageRef`** with an Unsplash URL appropriate to the item (milk, bread, chips, etc.).

### UI (switched from `ProductImagePlaceholder` to `CatalogImage`)

| Screen / widget | File |
|------------------|------|
| Product cards (rails & grid) | `lib/widgets/product_card.dart` |
| Product detail hero | `lib/features/product_detail/product_detail_screen.dart` |
| Search landing (e.g. top picks / trending thumbs) | `lib/features/search/search_screen.dart` |
| Search autocomplete rows | `lib/features/search/widgets/autocomplete_list.dart` |
| Search history chips (when a product thumb is shown) | `lib/widgets/search_chip.dart` |
| Order again tile thumbnails | `lib/features/order_again/order_again_screen.dart` |

**Shared renderer:** `lib/widgets/catalog_image.dart` — supports **`https://…`** (network) and **`asset:…`** (bundled assets); on failure or missing ref, falls back to the same **hint-based** gradient + icon behavior as before.

---

## 4. Why images sometimes “did not show” on web

Two separate issues came up:

1. **Stale `build/web` copy of `catalog.json`**  
   The running static server serves **`build/web/assets/assets/mock/catalog.json`**, not the source file under **`assets/mock/`** after a one-time build. If **`shopCategoryTiles`** (or new **`imageRef`** fields) existed only in source, the running app saw **empty tiles** or **old products** until the built asset was updated.

2. **Product cards before this work**  
   Even with a correct catalog, **product** rows used **`ProductImagePlaceholder`** only; photos required **`imageRef`** on each product and wiring **`CatalogImage`** in the widgets above.

**Practical fix:** After editing **`assets/mock/catalog.json`**, run **`flutter build web`** (or your usual web pipeline) so **`build/web`** is regenerated. For a quick manual check with `python -m http.server`, you can **copy** `assets/mock/catalog.json` into `build/web/assets/assets/mock/catalog.json` — but that only updates JSON, not compiled Dart; **code changes still need a Flutter rebuild.**

---

## 5. Technical notes

- **CORS:** Unsplash image responses include permissive CORS headers; **`Image.network`** on Flutter web can load them when the app is served normally.
- **Persisted orders:** Older saved **`OrderLine`** JSON may embed **`product`** objects **without** `imageRef`; those lines fall back to placeholders until data is refreshed from the catalog or re-ordered.

---

## 6. File checklist (reference)

| Area | Files |
|------|--------|
| Models | `shop_category_tile.dart`, `mock_catalog.dart`, `product.dart` |
| Category grid UI | `shop_category_grid.dart`, `home_screen.dart` |
| Product imagery | `catalog_image.dart`, `product_card.dart`, `product_detail_screen.dart`, `search_screen.dart`, `autocomplete_list.dart`, `search_chip.dart`, `order_again_screen.dart` |
| Mock data | `assets/mock/catalog.json` |
| Web preview asset (after copy/build) | `build/web/assets/assets/mock/catalog.json` |

---

## 7. Optional next steps (not implemented unless you ask)

- Add **`imageRef`** (or `asset:…`) to **deal** thumbnails and update **`deal_card_widget.dart`**.
- Add small **cart line thumbnails** in **`cart_screen.dart`**.
- Replace Unsplash URLs with **your own** assets under **`assets/`** and `imageRef` values like **`asset:catalog_images/…`**.

---

*Generated to document the image and catalog work on this clone; adjust paths if the project layout changes.*

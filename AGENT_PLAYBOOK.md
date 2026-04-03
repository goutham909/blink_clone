# Agent Playbook: High-Fidelity App Clones

**Purpose:** This document is written so a **coding agent** (or a human following the same steps) can **design and implement a realistic UI clone of almost any consumer mobile app** using **only this guide plus the user’s target description**—without needing access to any particular repository’s source code.

**Related doc:** If you are working **inside this repo**, see **`PROJECT_GUIDE.md`** for Blink Clone–specific structure, `catalog.json`, commands, and file paths. This playbook stays **generic**; Appendix 1 maps concepts to this project.

**Default implementation stack:** Flutter (Material 3), Riverpod, GoRouter, optional `google_fonts` and `shared_preferences`. The methodology is **stack-agnostic**; you may substitute React Native, SwiftUI, or Kotlin Compose if the user requires it, but you must still satisfy the **realism** and **architecture** requirements below.

---

## Part A — How the user should invoke you

When the user says they want a clone of **TARGET_APP** (e.g. a food-delivery, quick-commerce, banking, or social app), treat this document as **mandatory process**. Ask only for what is missing:

| Input | Required? | Notes |
|--------|-----------|--------|
| **TARGET_APP** name / category | Yes | e.g. “instant grocery,” “ride hail,” “fitness tracker.” |
| **Primary platform** | Recommended | Phone portrait first; tablet/web second. |
| **Reference material** | Strongly recommended | Official marketing screenshots, short screen recording, or a list of screens the user cares about. If absent, infer from category best practices and label assumptions in your README. |
| **Brand / trademark policy** | Yes | Never copy logos, wordmarks, or proprietary illustration packs. Use **generic** names, **placeholder** imagery, and **original** copy in the same **tone** and **layout** as the reference. |
| **Backend** | Default | **No real backend.** Use bundled JSON or local DB; simulate latency only if it improves realism. |

**Definition of done (clone quality):** A side-by-side with a blurred logo should convince a casual viewer that the **layout hierarchy, spacing rhythm, motion cadence, and information density** match the reference category—not that it is the official app.

---

## Part B — Legal and ethical guardrails (non-negotiable)

1. **No passing off:** Do not reproduce trademarked names, logos, mascots, or store listing assets as if they were the real product. Use fictional brand names and royalty-free or self-generated imagery.
2. **No scraping behind ToS:** Do not instruct violating a service’s terms to extract private APIs or assets.
3. **Sensitive domains:** For banking, health, or children’s apps, add clear **“demo / simulation”** labeling in-app and avoid storing real credentials.
4. **Third-party images:** Prefer Unsplash/Pexels URLs or bundled assets; always handle load failure with on-brand placeholders.

These rules **increase** perceived quality: a clean fictional brand reads more professional than a sloppy rip-off.

---

## Part C — The realism standard (what “looks like the real app” means)

Real apps feel coherent because of **layers** of detail. Your clone must implement **all applicable** items below for the target category.

### C1. Visual system (extract before coding)

1. **Color roles:** Primary CTA, secondary accent, success/warning/error, background tiers (e.g. canvas vs card vs elevated sheet), divider color, scrim for modals.
2. **Typography:** Font family (closest Google Font or system font), weight steps for title / subtitle / body / caption / button, line height, letter-spacing on labels.
3. **Shape:** Corner radii for cards, chips, bottom sheets, buttons (often 2–3 radius tokens, not one global value).
4. **Elevation / borders:** Shadow vs hairline border; when the reference uses flat color blocks vs lifted cards.
5. **Iconography:** Filled vs outlined icons, tab bar selected state, chevron vs arrow conventions.
6. **Density:** Padding scale (often 4/8/12/16/24), max content width on tablet, horizontal gutter for carousels.

Document these in a short **`DESIGN_TOKENS.md`** or as Dart `ThemeExtension` / CSS variables—agents should **write the tokens first**, then widgets.

### C2. Motion and time

1. **Page transitions:** Match platform (e.g. iOS slide from right vs fade for tabs).
2. **Micro-interactions:** Button press scale or ink splash; chip selection animation; `AnimatedSwitcher` for rotating hints or banner swaps.
3. **Loading:** Skeleton placeholders that mirror final layout—not a single centered spinner for whole feeds.
4. **Periodic UI:** If the real product rotates promos, headlines, or “live” ETA text, use `Timer` + lifecycle resume handling (background tabs throttle timers on web).
5. **Scroll physics:** Bouncing vs clamping; snap on carousels if the reference does.

### C3. Content and copy

1. **Microcopy:** Button labels, empty states, error strings should match **tone** (playful vs formal) and **length** (single line vs two lines).
2. **Numbers:** Currency, minutes-to-deliver, ratings count—use **plausible** ranges for the domain.
3. **Badges:** “New,” “Ad,” “Low stock,” “Veg/Non-veg” where category-appropriate.

### C4. Navigation and state

1. **Tab shell vs stack:** Bottom nav keeps state; pushes use a full-screen route; modals and bottom sheets for filters and pickers.
2. **Deep links:** Encode list filters in route query parameters (`category`, `rail`, `q`) so tiles and cards can open the correct scoped screen.
3. **Cross-screen consistency:** The same filter rules (e.g. “hide sensitive categories”) must apply on home, search, and rails.

### C5. Edge cases (professional polish)

Empty cart, empty search results, image load failure, offline-looking state (even if mocked), very long product titles (2-line clamp + ellipsis), RTL if user requests localization.

---

## Part D — Phased execution plan (agent workflow)

Execute in order. Do not skip “specification” steps— they prevent rework.

### Phase 0 — Freeze scope

Deliverable: **Screen inventory** (bullet list) and **user journeys** (e.g. browse → search → PDP → cart → checkout → order tracking).

- Mark each screen **P0** (must ship) vs **P1** (nice).
- Note which screens are **shell tabs** vs **pushed** vs **modal**.

### Phase 1 — Reference decomposition

Deliverable: **Wireframe notes** (even ASCII) for each P0 screen: sections top-to-bottom, scroll direction, sticky headers, floating bars.

For each section list:

- Data needed (list, carousel, banner, form field).
- Interaction (tap target, swipe, long-press if any).

### Phase 2 — Design tokens

Deliverable: **Token table** (Part C1) implemented in code as theme / constants.

### Phase 3 — Information architecture & routing

Deliverable: **Route map** with paths and parameters.

- Use **indexed stack** (or equivalent) for bottom tabs so each tab preserves scroll position.
- Name routes for testability (`Key('screen_home')`, etc.).

### Phase 4 — Data contract (single source of truth)

Deliverable: **`catalog.json`** (or domain-specific name) + Dart `fromJson` models.

**Principles:**

1. **Schema version** field for future migrations (`schemaVersion`).
2. **Lists drive UI:** Rails, banners, categories, tiles should be **arrays in JSON** so marketers can reshuffle without code changes.
3. **Stable IDs** for entities referenced across lists (`productIds` in rails).
4. **Image policy:** Support `https://` and optional `asset:path/to/file` in one image widget with loading and error fallbacks.
5. **Repository boundary:** UI never parses raw JSON; it calls `Repository` methods (`getCatalog`, `search`, `getById`).

### Phase 5 — Global state

Deliverable: Providers / stores for:

- Async catalog load (`FutureProvider` or equivalent).
- Cart (map id → quantity).
- Wishlist, recent searches, selected address, feature toggles (dark mode, content filters).
- **Simulated orders** with persistence if checkout exists: serialize to local storage; on restart **reconcile** time-based status from timestamps (see Part F).

Keep derived state (totals, filtered lists) in **selectors** so widgets stay dumb.

### Phase 6 — Screen implementation order (recommended)

1. **App shell** + theme + router stubs.
2. **Home / main feed** (largest vertical slice).
3. **Search** (including scoped entry from home).
4. **Detail** screen for primary entity (product, post, ride, etc.).
5. **Cart / bag** and **checkout** if applicable.
6. **Orders / activity** with **time-based** simulation if applicable.
7. **Account / settings** (theme, toggles).
8. **Secondary tabs** (categories, reorder, etc.).

### Phase 7 — Dynamic & “alive” layers

Deliverable: At least **two** of the following appropriate to TARGET_APP:

- Rotating promos or seasonal header themes on a timer + **resume** handling.
- Rotating placeholder hints in search.
- Deterministic **ETA** or **stepper** progress driven by a single timeline module (single source of truth for timers and copy).
- Pull-to-refresh that reloads mock JSON cache (debug) or re-runs FutureProvider.

### Phase 8 — QA pass (comparison discipline)

Checklist:

- [ ] Screenshot P0 screens next to reference (blur logos); compare **section order** and **relative sizes**.
- [ ] No overflow errors on small phone (e.g. 360×800 logical).
- [ ] Dark mode if reference is dark-first (or user asked).
- [ ] Tap targets ≥ 48dp where the reference does chunky buttons.
- [ ] Timers and animations survive app resume.

---

## Part E — Optional “agent self-check” prompts

Before claiming completion, answer:

1. **What did we intentionally *not* clone** (e.g. real payments, maps, chat backend)?
2. **Where is the single JSON (or API) contract** and how do we add a new row to the home feed without Dart?
3. **What makes this feel alive** (timers, animations, skeletons)?
4. **How do we reset demo state** (debug panel: clear cart, orders, reload cache)?

---

## Part F — Pattern: time-based order / task simulation

Use when TARGET_APP shows **tracked progress** (delivery, upload, workout plan).

1. Store **`placedAt` / `startedAt`** ISO timestamp on the entity.
2. Centralize milestones in one module, e.g.:

   - `packedAfterSeconds`, `shippedAfterSeconds`, `deliveredAfterSeconds`.

3. On app start, **recompute status** from `DateTime.now().difference(startedAt)` so timers are not wrong after relaunch.
4. Schedule **short-lived `Timer`s** only for upcoming transitions; cancel on dispose.
5. Drive **both** progress bar math and subtitle copy from the same functions so UI never disagrees.

---

## Part G — Pattern: seasonal / campaign theming

Use when TARGET_APP changes header color, badges, or hero art for events.

1. Define a **token class** (colors, gradients, which child widget tree to show).
2. Keep an ordered list **`rotation = [themeA, themeB, themeC]`**.
3. Advance index on `Timer.periodic`; on **`AppLifecycleState.resumed`**, restart timer (web background throttling).
4. Optionally gate certain JSON-driven strips to a specific theme (e.g. “Powered by” only in default summer look).

---

## Part H — Pattern: search entry from home without focus theft

Real apps use a **non-field** tappable bar that **pushes** the real search route. Implement:

- `InkWell` + fake hint row; **`AnimatedSwitcher`** cycling hints every few seconds.
- Real search screen owns `TextEditingController`, focus, and autocomplete overlay.

Encode **scope** in query parameters: `q`, `category`, `collection`, `rail`, etc. Parse once in `didChangeDependencies` or route listener.

---

## Part I — Project structure template (Flutter)

Use this layout for any clone; rename `features/` entries per domain.

```
lib/
  main.dart                 # binding init, async prefs, root ProviderScope
  app.dart                  # MaterialApp.router, theme, debug-only tools
  core/                     # tokens, constants, timelines, icon maps
  data/
    models/                 # immutable models + fromJson/toJson
    repositories/           # orchestrates sources
    sources/                # mock JSON bundle, future API
  providers/                # riverpod/notifier providers
  routing/                  # go_router + shell
  features/<feature>/       # screens + private widgets
  widgets/                  # shared visual components
assets/mock/<domain>.json
```

**`pubspec.yaml`:** Declare the mock asset directory; pin SDK and packages explicitly.

---

## Part J — Bootstrap checklist (any new clone)

1. `flutter create` → add `flutter_riverpod`, `go_router`, optional `google_fonts`, `shared_preferences`.
2. `WidgetsFlutterBinding.ensureInitialized()`; await `SharedPreferences.getInstance()`; override prefs provider.
3. `MaterialApp.router` + `ThemeData` / `ColorScheme.fromSeed` **tuned to tokens**, not defaults.
4. Shell route + pushed routes; **named** `GoRoute`s for deep linking.
5. `FutureProvider` for bundle JSON; **invalidate** after cache clear in debug.
6. Debug **bottom sheet or FAB**: clear ephemeral state, reload mock cache.

---

## Appendix 1 — Reference implementation: this repo (“Blink Clone”)

This repository is one **concrete** instance of the playbook: a **quick-commerce**–style UI (Blinkit-inspired **layout and rhythm**, not official branding). Full detail lives in **`PROJECT_GUIDE.md`**.

| Playbook concept | Where it lives in this repo |
|------------------|-----------------------------|
| Mock JSON contract | `assets/mock/catalog.json` |
| Parse + cache | `lib/data/sources/mock_catalog_source.dart`, `lib/data/models/mock_catalog.dart` |
| Repository | `lib/data/repositories/catalog_repository.dart` |
| Global state | `lib/providers/providers.dart` |
| Shell + routes | `lib/routing/app_router.dart`, `app_shell.dart` |
| Seasonal header rotation | `lib/features/home/home_festival_theme.dart`, `home_screen.dart` |
| Rotating search hints | `home_screen.dart` (`_HomeSearchEntryBar`) |
| Order timeline | `lib/core/order_delivery_timeline.dart`, `OrdersNotifier` in `providers.dart` |
| Scoped search | `lib/features/search/search_screen.dart` (query params) |
| Images + fallback | `lib/widgets/catalog_image.dart` |

**Run:** From the folder with `pubspec.yaml`, `flutter pub get` then `flutter run`. Web helpers: `tool/run_web_live.ps1`, `tool/build_and_serve_web.ps1`; optional frame: `web/iphone_preview.html`.

---

## Appendix 2 — Example JSON shapes (commerce-style clones)

Agents may adapt field names to the domain but should preserve the **idea**: **arrays feed UI**, **IDs link entities**.

```json
{
  "schemaVersion": 1,
  "datasetId": "demo-v1",
  "locationLabel": "Fictional neighborhood",
  "deliveryMinutes": 12,
  "categories": [{ "id": "cat_all", "label": "All", "iconName": "all" }],
  "rails": [{ "id": "rail_trending", "title": "Trending", "productIds": ["p_1", "p_2"] }],
  "products": [
    {
      "id": "p_1",
      "name": "Example item",
      "mrp": 99,
      "salePrice": 79,
      "unit": "1 pc",
      "categoryId": "cat_snacks",
      "imageHint": "snacks",
      "imageRef": "https://example.com/image.jpg",
      "inStock": true
    }
  ],
  "shopCategoryTiles": [
    { "label": "Snacks", "imageRef": "https://...", "searchQuery": "chips" }
  ]
}
```

For non-commerce apps, replace `products`/`rails` with `posts`, `workouts`, `transactions`, etc., but keep **the same architectural role**: JSON lists → widgets.

---

## Appendix 3 — When the target is *not* Flutter

Translate Part D phases unchanged. Swap:

- **Riverpod** → Redux, MobX, Bloc, Zustand, ViewModel, etc.
- **GoRouter** → React Navigation, Next.js routes, SwiftUI `NavigationStack`, Compose Navigation.
- **rootBundle JSON** → `fetch` of static JSON in web, or bundled file in native.

**Do not drop:** token-first styling, repository boundary, deep-linkable filters, time reconciliation for simulated progress, skeleton loading, and legal guardrails.

---

*End of playbook. If you only have this file: infer TARGET_APP from the user message, state your assumptions explicitly, then execute Phases 0–8 and verify against Part C.*

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/home/home_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/orders/orders_screen.dart';
import '../features/product_detail/product_detail_screen.dart';
import '../features/search/search_screen.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                name: 'search',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                name: 'cart',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const CartScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const OrdersScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/product/:id',
        name: 'product',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/checkout',
        name: 'checkout',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/detail/:orderId',
        name: 'orderDetail',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final id = state.pathParameters['orderId']!;
          return OrderDetailScreen(orderId: id);
        },
      ),
    ],
  );
});

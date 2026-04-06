import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(child: navigationShell),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: kBlinkGold.withValues(alpha: 0.14),
          highlightColor: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            NavigationBar(
              key: const Key('main_nav_bar'),
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 24),
                  selectedIcon: Icon(Icons.home_filled, size: 24),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.replay_outlined, size: 24),
                  selectedIcon: Icon(Icons.replay_rounded, size: 24),
                  label: 'Order Again',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined, size: 24),
                  selectedIcon: Icon(Icons.grid_view_rounded, size: 24),
                  label: 'Categories',
                ),
                NavigationDestination(
                  icon: Icon(Icons.print_outlined, size: 24),
                  selectedIcon: Icon(Icons.print_rounded, size: 24),
                  label: 'Print',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

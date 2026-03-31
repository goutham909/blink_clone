import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../providers/providers.dart';
import '../home/widgets/address_bottom_sheet.dart';

final appearanceDarkProvider = StateProvider<bool>((ref) => true);
final hideSensitiveProvider = StateProvider<bool>((ref) => false);

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  static const _phone = '9177369376';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(appearanceDarkProvider);
    final sensitive = ref.watch(hideSensitiveProvider);

    return Scaffold(
      key: const Key('screen_account'),
      backgroundColor: kBlinkDarkBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFC9A227),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your account',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _phone,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4A3728),
                  kBlinkAmber.withValues(alpha: 0.35),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add your birthday',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          foregroundColor: kBlinkGreen,
                        ),
                        child: const Text('Enter details >'),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.cake_outlined, size: 40, color: Colors.white70),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.shopping_basket_outlined,
                  label: 'Your orders',
                  onTap: () => context.pushNamed('orders'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Blinkit Money',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickCard(
                  icon: Icons.chat_bubble_outline,
                  label: 'Need help?',
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android_outlined),
              title: const Text('App update available'),
              subtitle: const Text('bug fixes and improvements'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: kBlinkDarkSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('v17.87.0', style: TextStyle(fontSize: 11)),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white38),
                ],
              ),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Appearance'),
              trailing: DropdownButton<bool>(
                value: dark,
                underline: const SizedBox.shrink(),
                dropdownColor: kBlinkDarkCard,
                items: const [
                  DropdownMenuItem(value: true, child: Text('DARK')),
                  DropdownMenuItem(value: false, child: Text('LIGHT')),
                ],
                onChanged: (v) {
                  if (v != null) ref.read(appearanceDarkProvider.notifier).state = v;
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.visibility_off_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hide sensitive items.',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Switch(
                        value: sensitive,
                        onChanged: (v) => ref.read(hideSensitiveProvider.notifier).state = v,
                        activeTrackColor: kBlinkGreen.withValues(alpha: 0.5),
                        thumbColor: WidgetStateProperty.resolveWith((s) {
                          if (s.contains(WidgetState.selected)) return kBlinkGreen;
                          return null;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sexual wellness, nicotine products and other sensitive items will be hidden.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: kBlinkGreen,
                    ),
                    child: const Text('Know more'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your information',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Address book'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () async {
                    final cat = await ref.read(catalogRepositoryProvider).getCatalog();
                    if (context.mounted) showAddressBottomSheet(context, cat);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.ramen_dining_outlined),
                  title: const Text('Bookmarked recipes'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Your wishlist'),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../data/models/address.dart';
import '../../../data/models/mock_catalog.dart';
import '../../../providers/providers.dart';

Future<void> showAddressBottomSheet(BuildContext context, MockCatalog catalog) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: kBlinkDarkBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Consumer(
            builder: (context, ref, _) {
              return SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white70),
                        style: IconButton.styleFrom(
                          backgroundColor: kBlinkDarkCard,
                        ),
                      ),
                    ),
                    Text(
                      'Select delivery location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for area, street name...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: kBlinkDarkSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SheetRow(
                      icon: Icons.my_location,
                      iconColor: kBlinkGreen,
                      title: 'Use current location',
                      subtitle: catalog.currentLocationAddress,
                      onTap: () {
                        ref.read(selectedAddressProvider.notifier).select(null);
                        Navigator.pop(ctx);
                      },
                    ),
                    _SheetRow(
                      icon: Icons.add,
                      iconColor: kBlinkGreen,
                      title: 'Add new address',
                      onTap: () => Navigator.pop(ctx),
                    ),
                    _SheetRow(
                      icon: Icons.chat,
                      iconColor: kBlinkGreen,
                      title: 'Request address from someone else',
                      onTap: () => Navigator.pop(ctx),
                    ),
                    _SheetRow(
                      icon: Icons.restaurant,
                      iconColor: const Color(0xFFE23744),
                      title: 'Import your addresses from Zomato',
                      onTap: () => Navigator.pop(ctx),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Your saved addresses',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...catalog.savedAddresses.map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AddressCard(
                          address: a,
                          onSelect: () {
                            ref.read(selectedAddressProvider.notifier).select(a);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? Theme.of(context).colorScheme.primary),
        title: Text(title, style: TextStyle(color: iconColor ?? Colors.white)),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
        onTap: onTap,
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.address, required this.onSelect});

  final SavedAddress address;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kBlinkAmber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.home_outlined, color: kBlinkAmber, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.label,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${address.distanceKm.toStringAsFixed(2)} km away',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.tealAccent,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(address.fullAddress),
              if (address.phoneNumber != null) ...[
                const SizedBox(height: 4),
                Text(
                  address.phoneNumber!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

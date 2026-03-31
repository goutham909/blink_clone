import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product.dart';
import '../../providers/providers.dart';
import '../../widgets/product_card.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

final _searchResultsProvider = FutureProvider<List<Product>>((ref) async {
  final q = ref.watch(_searchQueryProvider);
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.searchProducts(q);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(_searchResultsProvider);

    return Scaffold(
      key: const Key('screen_search'),
      appBar: AppBar(
        title: TextField(
          key: const Key('search_field'),
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search milk, snacks…',
            border: InputBorder.none,
          ),
          onChanged: (v) => ref.read(_searchQueryProvider.notifier).state = v,
        ),
      ),
      body: results.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No items match your search'),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return ProductCard(
                    product: list[i],
                    width: constraints.maxWidth,
                    dense: true,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

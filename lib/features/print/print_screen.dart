import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PrintScreen extends StatelessWidget {
  const PrintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('screen_print'),
      appBar: AppBar(title: const Text('Print')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Document printing'),
              subtitle: const Text('A4 black & white, colour'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pick files — partner print shop (demo)')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Photo prints'),
              subtitle: const Text('Passport, 4×6, posters'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo upload flow (demo)')),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Track print order'),
              subtitle: const Text('View status of past requests'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed('orders'),
            ),
          ),
        ],
      ),
    );
  }
}

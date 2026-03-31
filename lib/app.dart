import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routing/app_router.dart';
import 'widgets/debug_panel_sheet.dart';

class BlinkCloneApp extends ConsumerWidget {
  const BlinkCloneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Blink Clone',
      debugShowCheckedModeBanner: false,
      theme: buildBlinkTheme(Brightness.light),
      routerConfig: router,
      builder: (context, child) {
        var result = child ?? const SizedBox.shrink();
        if (kDebugMode) {
          result = Stack(
            alignment: Alignment.bottomRight,
            children: [
              result,
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: FloatingActionButton.small(
                    key: const Key('debug_panel_fab'),
                    onPressed: () => showDebugPanel(context, ref),
                    child: const Icon(Icons.bug_report_outlined),
                  ),
                ),
              ),
            ],
          );
        }
        return result;
      },
    );
  }
}

ThemeData buildBlinkTheme(Brightness brightness) {
  const primary = Color(0xFF00A651);
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
  );
  return base.copyWith(
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme),
  );
}

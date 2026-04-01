import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants.dart';
import 'providers/providers.dart';
import 'routing/app_router.dart';
import 'widgets/debug_panel_sheet.dart';

class BlinkCloneApp extends ConsumerWidget {
  const BlinkCloneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final dark = ref.watch(appearanceDarkProvider);

    return MaterialApp.router(
      title: 'Blink Clone',
      debugShowCheckedModeBanner: false,
      theme: buildBlinkTheme(dark ? Brightness.dark : Brightness.light),
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
  if (brightness == Brightness.light) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kBlinkGreen,
        brightness: Brightness.light,
        secondary: kBlinkAmber,
      ),
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFFF2F2F7),
        foregroundColor: Colors.black87,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: kBlinkGreen.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: kBlinkGreen, fontWeight: FontWeight.w600, fontSize: 12);
          }
          return const TextStyle(color: Colors.black54, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: kBlinkGreen);
          }
          return const IconThemeData(color: Colors.black45);
        }),
      ),
    );
    return base.copyWith(textTheme: GoogleFonts.dmSansTextTheme(base.textTheme));
  }

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.dark(
      primary: kBlinkGreen,
      onPrimary: Colors.white,
      secondary: kBlinkAmber,
      onSecondary: Colors.black,
      surface: kBlinkDarkSurface,
      onSurface: Colors.white,
      surfaceContainerHighest: kBlinkDarkCard,
      outline: Colors.white54,
      error: const Color(0xFFFF453A),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: kBlinkDarkBg,
    cardTheme: CardThemeData(
      color: kBlinkDarkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: kBlinkDarkBg,
      foregroundColor: Colors.white,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kBlinkDarkSurface,
      indicatorColor: kBlinkGreen.withValues(alpha: 0.35),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: kBlinkGreen, fontWeight: FontWeight.w600, fontSize: 12);
        }
        return const TextStyle(color: Colors.white54, fontSize: 12);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: kBlinkGreen);
        }
        return const IconThemeData(color: Colors.white54);
      }),
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme),
  );
}

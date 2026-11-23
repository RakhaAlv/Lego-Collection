import 'package:flutter/material.dart';

import 'screens/main_navigation.dart';

void main() {
  runApp(const LegoCatalogApp());
}

class LegoCatalogApp extends StatelessWidget {
  const LegoCatalogApp({super.key});

  // Palet warna terang bergaya katalog resmi lego.com.
  static const Color legoRed = Color(0xFFD01012);
  static const Color legoYellow = Color(0xFFF6C90E);
  static const Color legoYellowTint = Color(0xFFFFF4C2);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF555555);
  static const Color borderLight = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: legoRed,
      brightness: Brightness.light,
    ).copyWith(
      primary: legoRed,
      onPrimary: Colors.white,
      secondary: legoYellow,
      onSecondary: textPrimary,
      surface: Colors.white,
      onSurface: textPrimary,
      surfaceContainerHighest: const Color(0xFFF2F2F2),
      outlineVariant: borderLight,
    );

    return MaterialApp(
      title: 'LEGO Catalog',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.3,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: baseScheme,
        scaffoldBackgroundColor: backgroundLight,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: legoRed,
          selectionColor: legoYellowTint,
          selectionHandleColor: legoRed,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: legoYellow,
          foregroundColor: textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: borderLight),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: legoYellow,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(color: selected ? textPrimary : const Color(0xFF666666));
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? textPrimary : const Color(0xFF666666),
            );
          }),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: legoRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        dividerTheme: const DividerThemeData(color: borderLight, thickness: 1, space: 1),
      ),
      home: const MainNavigation(),
    );
  }
}

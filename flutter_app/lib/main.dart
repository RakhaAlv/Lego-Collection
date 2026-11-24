import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

import 'screens/main_navigation.dart';

void main() {
  // Ganti error widget bawaan Flutter dengan tampilan bersih agar user tidak melihat layar error merah.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.info_outline, size: 36, color: LegoCatalogApp.legoRed),
              SizedBox(height: 12),
              Text(
                'Something went wrong while rendering this view.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: LegoCatalogApp.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  };
  runApp(const LegoCatalogApp());
}

// Nonaktifkan animasi transisi route di Web/Desktop agar perpindahan halaman terasa instan.
class _EditorialPageTransitionsBuilder extends PageTransitionsBuilder {
  const _EditorialPageTransitionsBuilder();

  bool get _isDesktopOrWeb =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (_isDesktopOrWeb) return child;
    return const ZoomPageTransitionsBuilder().buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

class LegoCatalogApp extends StatelessWidget {
  const LegoCatalogApp({super.key});

  static const Color legoRed = Color(0xFFD01012);
  static const Color legoYellow = Color(0xFFF6C90E);
  static const Color legoYellowTint = Color(0xFFFFF4C2);
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF666666);
  static const Color borderLight = Color(0xFFE5E5E5);

  static const List<FontFeature> tabularNums = [FontFeature.tabularFigures()];

  @override
  Widget build(BuildContext context) {
    final baseScheme =
        ColorScheme.fromSeed(
          seedColor: legoRed,
          brightness: Brightness.light,
        ).copyWith(
          primary: legoRed,
          onPrimary: Colors.white,
          secondary: legoYellow,
          onSecondary: textPrimary,
          surface: Colors.white,
          onSurface: textPrimary,
          surfaceContainerHighest: Colors.white,
          outlineVariant: borderLight,
        );

    const transitions = _EditorialPageTransitionsBuilder();

    return MaterialApp(
      title: 'LEGO COLLECTION',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      // Izinkan geser carousel memakai mouse maupun touch di desktop/web.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      builder: (context, child) {
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.25,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: baseScheme,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: transitions,
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: transitions,
            TargetPlatform.macOS: transitions,
            TargetPlatform.linux: transitions,
          },
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: legoRed,
          selectionColor: legoYellowTint,
          selectionHandleColor: legoRed,
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: const BorderSide(color: borderLight),
          ),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: const BorderSide(color: textPrimary, width: 1.2),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.white,
          foregroundColor: textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: Border(
            top: BorderSide(color: legoYellow, width: 3),
            bottom: BorderSide(color: borderLight, width: 1),
          ),
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
          iconTheme: IconThemeData(color: textPrimary, size: 21),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
            side: const BorderSide(color: borderLight),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 66,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: legoYellow,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 21,
              color: selected ? textPrimary : textSecondary,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.8,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? textPrimary : textSecondary,
            );
          }),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: textPrimary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: textPrimary,
            side: const BorderSide(color: textPrimary),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: borderLight,
          thickness: 1,
          space: 1,
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

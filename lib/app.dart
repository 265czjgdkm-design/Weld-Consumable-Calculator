import 'package:flutter/material.dart';

import 'l10n/app_locale.dart';
import 'l10n/app_locale_scope.dart';
import 'ui/splash_screen.dart';

class WeldConsumableCalculatorApp extends StatefulWidget {
  const WeldConsumableCalculatorApp({super.key});

  @override
  State<WeldConsumableCalculatorApp> createState() =>
      _WeldConsumableCalculatorAppState();
}

class _WeldConsumableCalculatorAppState
    extends State<WeldConsumableCalculatorApp> {
  final AppLocale _appLocale = AppLocale();

  @override
  void initState() {
    super.initState();
    _appLocale.hydrate();
  }

  @override
  void dispose() {
    _appLocale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF12191B);

    return AppLocaleScope(
      locale: _appLocale,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Varyos Weld',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF3F6F8),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(
              fontSize: 32,
              height: 1.08,
              fontWeight: FontWeight.w800,
              color: Color(0xFF112530),
            ),
            titleLarge: TextStyle(
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF132833),
            ),
            titleMedium: TextStyle(
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: Color(0xFF17303C),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              height: 1.45,
              color: Color(0xFF314955),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF35505C),
            ),
            bodySmall: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: Color(0xFF5D7380),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Color(0xFFE1E8ED)),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: seedColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF17303C),
              side: const BorderSide(color: Color(0xFFD0DCE3)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          chipTheme: ChipThemeData(
            backgroundColor: const Color(0xFFF1F5F7),
            disabledColor: const Color(0xFFE7EDF1),
            selectedColor: const Color(0xFF12191B),
            secondarySelectedColor: const Color(0xFF12191B),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            labelStyle: const TextStyle(
              color: Color(0xFF29414D),
              fontWeight: FontWeight.w600,
            ),
            secondaryLabelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            side: const BorderSide(color: Color(0xFFD6E0E6)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFFBFDFE),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
            labelStyle: const TextStyle(
              color: Color(0xFF536B78),
              fontWeight: FontWeight.w600,
            ),
            floatingLabelStyle: const TextStyle(
              color: seedColor,
              fontWeight: FontWeight.w700,
            ),
            helperStyle: const TextStyle(
              color: Color(0xFF6C8190),
              fontSize: 12.5,
            ),
            helperMaxLines: 3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFD2DCE3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFD2DCE3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: seedColor, width: 1.4),
            ),
            suffixIconColor: const Color(0xFF4B6572),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

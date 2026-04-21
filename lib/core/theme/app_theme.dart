import 'package:flutter/material.dart';

class AppColors {
  static const Color darkGreen = Color(0xFF003228);
  static const Color primaryGreen = Color(0xFF6EC850);
  static const Color lightGreen = Color(0xFFC8F0B4);
  static const Color yellow = Color(0xFFF0DC8C);
  static const Color red = Color(0xFFF01E32);

  static const ColorScheme sggwLightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryGreen,
    onPrimary: Colors.white,
    secondary: darkGreen,
    onSecondary: Colors.white,
    error: red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: darkGreen,
    tertiary: yellow,
    onTertiary: darkGreen,
  );

  static const ColorScheme sggwDarkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryGreen,
    onPrimary: darkGreen,
    secondary: lightGreen,
    onSecondary: darkGreen,
    error: red,
    onError: Colors.white,
    surface: darkGreen,
    onSurface: Colors.white,
    tertiary: yellow,
    onTertiary: darkGreen,
  );

  static ColorScheme dynamicLightScheme = ColorScheme.fromSeed(
    seedColor: primaryGreen,
    brightness: Brightness.light,
  );

  static ColorScheme dynamicDarkScheme = ColorScheme.fromSeed(
    seedColor: primaryGreen,
    brightness: Brightness.dark,
  );
}

class AppTheme {
  static ThemeData light({
    bool useDynamicColors = false,
    bool boldText = false,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: useDynamicColors
          ? AppColors.dynamicLightScheme
          : AppColors.sggwLightScheme,
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    if (!boldText) return base;
    return base.copyWith(textTheme: _applyBold(base.textTheme));
  }

  static ThemeData dark({
    bool useDynamicColors = false,
    bool boldText = false,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: useDynamicColors
          ? AppColors.dynamicDarkScheme
          : AppColors.sggwDarkScheme,
      appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: AppColors.primaryGreen.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    if (!boldText) return base;
    return base.copyWith(textTheme: _applyBold(base.textTheme));
  }

  static TextTheme _applyBold(TextTheme theme) {
    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
      displayMedium: theme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
      displaySmall: theme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
      headlineLarge: theme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
      headlineMedium: theme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: theme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      titleLarge: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      titleMedium: theme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: theme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: theme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyMedium: theme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      bodySmall: theme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: theme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
      labelMedium: theme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
      labelSmall: theme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

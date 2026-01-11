import 'package:flutter/material.dart';

class AppColors {
  static const Color darkGreen = Color(0xFF003228);
  static const Color primaryGreen = Color(0xFF6EC850);
  static const Color lightGreen = Color(0xFFC8F0B4);
  static const Color yellow = Color(0xFFF0DC8C);
  static const Color red = Color(0xFFF01E32);

  static const ColorScheme lightScheme = ColorScheme(
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

  static const ColorScheme darkScheme = ColorScheme(
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
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.darkScheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primaryGreen,
          unselectedItemColor: Colors.grey,
        ),
      );
}

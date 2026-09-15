import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0E27);
  static const surface = Color(0xFF141937);
  static const neonPurple = Color(0xFFB026FF);
  static const neonCyan = Color(0xFF00F5FF);
  static const neonGreen = Color(0xFF39FF14);
  static const neonPink = Color(0xFFFF10F0);
  static const textPrimary = Color(0xFFF2F2FF);
  static const textSecondary = Color(0xFF9BA0C9);
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.neonPurple,
      secondary: AppColors.neonCyan,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      foregroundColor: AppColors.textPrimary,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textPrimary),
      titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.neonCyan,
      unselectedItemColor: AppColors.textSecondary,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.neonPurple,
      foregroundColor: Colors.white,
    ),
  );
}

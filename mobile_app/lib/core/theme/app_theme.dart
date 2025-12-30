import 'package:flutter/material.dart';
import 'package:mobile_app/core/ui/app_typography.dart';

class AppColors {
  // Institutional Colors
  static const Color midnightNavy = Color(0xFF073b4c);
  static const Color strategicGold = Color(0xFFEAB308); // yellow-500
  static const Color goldDark = Color(0xFFCA8A04); // yellow-600

  // Glass System
  static const Color glassWhite = Color(0x1AFFFFFF); // white/10
  static const Color glassBorder = Color(0x33FFFFFF); // white/20

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8); // slate-400

  // --- LEGACY ALIASES (For Compatibility) ---
  static const Color slateGrey = Color(0xFF64748B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color lightGrey = Color(0xFFF1F5F9);
  static const Color paleGold = Color(0xFFFEF08A); // yellow-200
  static const Color deepNavy = midnightNavy;
}

class AppTextStyles {
  // New Styles
  static TextStyle get headerLarge => AppTypography.header1;
  static TextStyle get bodyLarge => AppTypography.bodyLarge;
  static TextStyle get buttonText => AppTypography.labelLarge;

  // --- LEGACY ALIASES (For Compatibility) ---
  static TextStyle get headerMedium => AppTypography.header2;
  static TextStyle get headerSmall => AppTypography.header3;
  static TextStyle get bodyMedium => AppTypography.bodyMedium;
  static TextStyle get bodySmall => AppTypography.bodySmall;
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.midnightNavy,
    scaffoldBackgroundColor: Colors.white,
    textTheme: TextTheme(
      displayLarge: AppTypography.header1.copyWith(color: Colors.black),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.black87),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.strategicGold,
      brightness: Brightness.light,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.midnightNavy,
    scaffoldBackgroundColor: AppColors.midnightNavy,
    textTheme: TextTheme(
      displayLarge: AppTypography.header1.copyWith(color: Colors.white),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: Colors.white70),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.strategicGold,
      brightness: Brightness.dark,
      surface: AppColors.midnightNavy,
    ),
  );
}

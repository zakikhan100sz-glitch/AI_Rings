import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceElevated: AppColors.surfaceElevated,
        border: AppColors.border,
        textPrimary: AppColors.textPrimary,
        textSecondary: AppColors.textSecondary,
        textMuted: AppColors.textMuted,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        surfaceElevated: AppColors.surfaceElevatedLight,
        border: AppColors.borderLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        textMuted: AppColors.textMutedLight,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceElevated,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
  }) {
    final isDark = brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.accentLight,
        onSecondary: Colors.white,
        error: AppColors.risk,
        onError: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
      dividerColor: border,
      cardColor: surface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.accent.withOpacity(0.15),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, color: textMuted),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: surfaceElevated,
        labelStyle: TextStyle(color: textPrimary),
        side: BorderSide(color: border),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.accent,
        textColor: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),
    );
  }
}

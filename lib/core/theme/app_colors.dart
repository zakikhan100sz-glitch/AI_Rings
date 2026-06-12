import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF0D1117);
  static const surface = Color(0xFF161B22);
  static const surfaceElevated = Color(0xFF21262D);
  static const border = Color(0xFF30363D);
  static const accent = Color(0xFF2E6BD6);
  static const accentLight = Color(0xFF4C8DFF);
  static const normal = Color(0xFF00C853);
  static const warning = Color(0xFFFFB300);
  static const risk = Color(0xFFFF3D00);
  static const textPrimary = Color(0xFFF0F6FC);
  static const textSecondary = Color(0xFF8B949E);
  static const textMuted = Color(0xFF6E7681);

  // Light theme
  static const backgroundLight = Color(0xFFF6F8FC);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceElevatedLight = Color(0xFFEEF2F8);
  static const borderLight = Color(0xFFDCE3EE);
  static const textPrimaryLight = Color(0xFF1A2332);
  static const textSecondaryLight = Color(0xFF5A6578);
  static const textMutedLight = Color(0xFF8A94A6);
}

extension AppColorsExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get appBackground => isDark ? AppColors.background : AppColors.backgroundLight;
  Color get appSurface => isDark ? AppColors.surface : AppColors.surfaceLight;
  Color get appSurfaceElevated => isDark ? AppColors.surfaceElevated : AppColors.surfaceElevatedLight;
  Color get appBorder => isDark ? AppColors.border : AppColors.borderLight;

  Color get appTextPrimary => isDark ? AppColors.textPrimary : AppColors.textPrimaryLight;
  Color get appTextSecondary => isDark ? AppColors.textSecondary : AppColors.textSecondaryLight;
  Color get appTextMuted => isDark ? AppColors.textMuted : AppColors.textMutedLight;
}

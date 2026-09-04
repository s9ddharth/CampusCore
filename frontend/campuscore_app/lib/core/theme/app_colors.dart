import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  static const Color primary = Color(0xFF2563EB);

  static const Color primaryDark = Color(0xFF1D4ED8);

  static const Color primaryLight = Color(0xFF60A5FA);

  static const Color secondary = Color(0xFF7C3AED);

  static const Color secondaryDark = Color(0xFF6D28D9);

  static const Color secondaryLight = Color(0xFFA78BFA);

  // ---------------------------------------------------------------------------
  // Light theme
  // ---------------------------------------------------------------------------

  static const Color lightBackground = Color(0xFFF8FAFC);

  static const Color lightSurface = Colors.white;

  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);

  static const Color lightBorder = Color(0xFFE2E8F0);

  static const Color lightDivider = Color(0xFFE2E8F0);

  static const Color lightTextPrimary = Color(0xFF0F172A);

  static const Color lightTextSecondary = Color(0xFF475569);

  static const Color lightTextTertiary = Color(0xFF64748B);

  // ---------------------------------------------------------------------------
  // Dark theme
  // ---------------------------------------------------------------------------

  static const Color darkBackground = Color(0xFF0F172A);

  static const Color darkSurface = Color(0xFF111827);

  static const Color darkSurfaceVariant = Color(0xFF1E293B);

  static const Color darkBorder = Color(0xFF334155);

  static const Color darkDivider = Color(0xFF334155);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);

  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------------
  // Semantic colors
  // ---------------------------------------------------------------------------

  static const Color success = Color(0xFF16A34A);

  static const Color successLight = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFD97706);

  static const Color warningLight = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626);

  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF0284C7);

  static const Color infoLight = Color(0xFFE0F2FE);

  // ---------------------------------------------------------------------------
  // Academic colors
  // ---------------------------------------------------------------------------

  static const Color gradeS = Color(0xFF7C3AED);

  static const Color gradeA = Color(0xFF2563EB);

  static const Color gradeB = Color(0xFF0891B2);

  static const Color gradeC = Color(0xFF16A34A);

  static const Color gradeD = Color(0xFFD97706);

  static const Color gradeE = Color(0xFFEA580C);

  static const Color gradeF = Color(0xFFDC2626);

  // ---------------------------------------------------------------------------
  // Attendance
  // ---------------------------------------------------------------------------

  static const Color present = Color(0xFF16A34A);

  static const Color absent = Color(0xFFDC2626);

  static const Color late = Color(0xFFD97706);

  static const Color excused = Color(0xFF0284C7);

  // ---------------------------------------------------------------------------
  // Fee status
  // ---------------------------------------------------------------------------

  static const Color paid = Color(0xFF16A34A);

  static const Color pending = Color(0xFFD97706);

  static const Color overdue = Color(0xFFDC2626);

  static const Color partial = Color(0xFF0284C7);

  // ---------------------------------------------------------------------------
  // Neutral scale
  // ---------------------------------------------------------------------------

  static const Color neutral50 = Color(0xFFF8FAFC);

  static const Color neutral100 = Color(0xFFF1F5F9);

  static const Color neutral200 = Color(0xFFE2E8F0);

  static const Color neutral300 = Color(0xFFCBD5E1);

  static const Color neutral400 = Color(0xFF94A3B8);

  static const Color neutral500 = Color(0xFF64748B);

  static const Color neutral600 = Color(0xFF475569);

  static const Color neutral700 = Color(0xFF334155);

  static const Color neutral800 = Color(0xFF1E293B);

  static const Color neutral900 = Color(0xFF0F172A);

  // ---------------------------------------------------------------------------
  // Common
  // ---------------------------------------------------------------------------

  static const Color white = Colors.white;

  static const Color black = Colors.black;

  static const Color transparent = Colors.transparent;

  // ---------------------------------------------------------------------------
  // Material color schemes
  // ---------------------------------------------------------------------------

  static ColorScheme get lightColorScheme {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: white,
      primaryContainer: Color(0xFFDBEAFE),
      onPrimaryContainer: Color(0xFF1E3A8A),
      secondary: secondary,
      onSecondary: white,
      secondaryContainer: Color(0xFFEDE9FE),
      onSecondaryContainer: Color(0xFF4C1D95),
      tertiary: info,
      onTertiary: white,
      tertiaryContainer: infoLight,
      onTertiaryContainer: Color(0xFF075985),
      error: error,
      onError: white,
      errorContainer: errorLight,
      onErrorContainer: Color(0xFF7F1D1D),
      surface: lightSurface,
      onSurface: lightTextPrimary,
      surfaceContainerHighest: lightSurfaceVariant,
      onSurfaceVariant: lightTextSecondary,
      outline: lightBorder,
      outlineVariant: Color(0xFFCBD5E1),
      shadow: Color(0x22000000),
      scrim: Color(0x66000000),
      inverseSurface: neutral800,
      onInverseSurface: white,
      inversePrimary: primaryLight,
    );
  }

  static ColorScheme get darkColorScheme {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: Color(0xFF0F172A),
      primaryContainer: Color(0xFF1E3A8A),
      onPrimaryContainer: Color(0xFFDBEAFE),
      secondary: secondaryLight,
      onSecondary: Color(0xFF1E1B4B),
      secondaryContainer: Color(0xFF4C1D95),
      onSecondaryContainer: Color(0xFFEDE9FE),
      tertiary: Color(0xFF38BDF8),
      onTertiary: Color(0xFF082F49),
      tertiaryContainer: Color(0xFF075985),
      onTertiaryContainer: Color(0xFFE0F2FE),
      error: Color(0xFFF87171),
      onError: Color(0xFF450A0A),
      errorContainer: Color(0xFF7F1D1D),
      onErrorContainer: Color(0xFFFEE2E2),
      surface: darkSurface,
      onSurface: darkTextPrimary,
      surfaceContainerHighest: darkSurfaceVariant,
      onSurfaceVariant: darkTextSecondary,
      outline: darkBorder,
      outlineVariant: Color(0xFF475569),
      shadow: Color(0x66000000),
      scrim: Color(0x99000000),
      inverseSurface: neutral100,
      onInverseSurface: neutral900,
      inversePrimary: primaryDark,
    );
  }
}
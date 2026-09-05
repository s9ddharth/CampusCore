import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  // ---------------------------------------------------------------------------
  // Display
  // ---------------------------------------------------------------------------

  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.8,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.6,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.4,
  );

  // ---------------------------------------------------------------------------
  // Headings
  // ---------------------------------------------------------------------------

  static const TextStyle headlineLarge = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  // ---------------------------------------------------------------------------
  // Titles
  // ---------------------------------------------------------------------------

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // ---------------------------------------------------------------------------
  // Labels
  // ---------------------------------------------------------------------------

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  static const TextStyle navigationLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle navigationLabelSelected = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  static const TextStyle dashboardGreeting = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const TextStyle dashboardStatValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle dashboardStatLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  // ---------------------------------------------------------------------------
  // Tables
  // ---------------------------------------------------------------------------

  static const TextStyle tableHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle tableCell = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle tableCellStrong = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ---------------------------------------------------------------------------
  // Forms
  // ---------------------------------------------------------------------------

  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  // ---------------------------------------------------------------------------
  // Buttons
  // ---------------------------------------------------------------------------

  static const TextStyle buttonLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  static const TextStyle status = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle statusLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ---------------------------------------------------------------------------
  // Academic
  // ---------------------------------------------------------------------------

  static const TextStyle grade = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle gradeLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle marks = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle gpa = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle cgpa = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
  );

  // ---------------------------------------------------------------------------
  // Supporting text
  // ---------------------------------------------------------------------------

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.8,
  );

  // ---------------------------------------------------------------------------
  // Error / empty states
  // ---------------------------------------------------------------------------

  static const TextStyle errorTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle emptyStateTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const TextStyle emptyStateMessage = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ---------------------------------------------------------------------------
  // Utility
  // ---------------------------------------------------------------------------

  static TextStyle withColor(
    TextStyle style,
    Color color,
  ) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(
    TextStyle style,
    FontWeight weight,
  ) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(
    TextStyle style,
    double size,
  ) {
    return style.copyWith(fontSize: size);
  }
}
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light Theme
  // ---------------------------------------------------------------------------

  static ThemeData get light {
    final colorScheme = AppColors.lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'Inter',

      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.lightTextPrimary,
          size: AppDimensions.iconSizeLarge,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        margin: EdgeInsets.zero,
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          side: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.inputHorizontalPadding,
          vertical: AppDimensions.inputVerticalPadding,
        ),
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: AppColors.lightTextTertiary,
        ),
        errorStyle: AppTextStyles.inputError.copyWith(
          color: AppColors.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          side: const BorderSide(
            color: AppColors.lightBorder,
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightSmall,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      floatingActionButtonTheme:
          FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.lightSurfaceVariant,
        side: const BorderSide(
          color: AppColors.lightBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: AppTextStyles.status.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        secondaryLabelStyle: AppTextStyles.status.copyWith(
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing8,
          vertical: AppDimensions.spacing4,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral800,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadiusSmall,
          ),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.dialogRadius,
          ),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextSecondary,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadiusSmall,
          ),
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightSurfaceVariant,
        circularTrackColor: AppColors.lightSurfaceVariant,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          side: const BorderSide(
            color: AppColors.lightBorder,
          ),
        ),
        textStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextPrimary,
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.inputRadius,
            ),
          ),
        ),
        menuStyle: MenuStyle(
          elevation: WidgetStateProperty.all(4),
          backgroundColor:
              WidgetStateProperty.all(AppColors.lightSurface),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.cardRadius,
              ),
            ),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
        ),
        minVerticalPadding: AppDimensions.spacing8,
        titleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.lightTextSecondary,
        ),
        iconColor: AppColors.lightTextSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadiusSmall,
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return AppColors.lightTextTertiary;
          },
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.white;
            }

            return AppColors.lightTextTertiary;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }

            return AppColors.lightSurfaceVariant;
          },
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.lightTextSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      textTheme: _lightTextTheme,
    );
  }

  // ---------------------------------------------------------------------------
  // Dark Theme
  // ---------------------------------------------------------------------------

  static ThemeData get dark {
    final colorScheme = AppColors.darkColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Inter',

      visualDensity: VisualDensity.standard,

      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.darkTextPrimary,
          size: AppDimensions.iconSizeLarge,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        margin: EdgeInsets.zero,
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          side: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.inputHorizontalPadding,
          vertical: AppDimensions.inputVerticalPadding,
        ),
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: AppColors.darkTextTertiary,
        ),
        errorStyle: AppTextStyles.inputError.copyWith(
          color: const Color(0xFFF87171),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: AppColors.primaryLight,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: Color(0xFFF87171),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.inputRadius,
          ),
          borderSide: const BorderSide(
            color: Color(0xFFF87171),
            width: 1.5,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          side: const BorderSide(
            color: AppColors.darkBorder,
          ),
          textStyle: AppTextStyles.buttonLarge,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.buttonMinWidth,
            AppDimensions.buttonHeightSmall,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.buttonRadius,
            ),
          ),
          textStyle: AppTextStyles.buttonMedium,
        ),
      ),

      floatingActionButtonTheme:
          FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryDark,
        disabledColor: AppColors.darkSurfaceVariant,
        side: const BorderSide(
          color: AppColors.darkBorder,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: AppTextStyles.status.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        secondaryLabelStyle: AppTextStyles.status.copyWith(
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing8,
          vertical: AppDimensions.spacing4,
        ),
      ),

      tooltipTheme: TooltipThemeData(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing12,
          vertical: AppDimensions.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadiusSmall,
          ),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.neutral900,
        ),
      ),

      dialogTheme: DialogThemeData(
        elevation: 8,
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.dialogRadius,
          ),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadiusSmall,
          ),
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.darkSurfaceVariant,
        circularTrackColor: AppColors.darkSurfaceVariant,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius,
          ),
          side: const BorderSide(
            color: AppColors.darkBorder,
          ),
        ),
        textStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.inputRadius,
            ),
          ),
        ),
        menuStyle: MenuStyle(
          elevation: WidgetStateProperty.all(4),
          backgroundColor:
              WidgetStateProperty.all(AppColors.darkSurface),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppDimensions.cardRadius,
              ),
            ),
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
        ),
        minVerticalPadding: AppDimensions.spacing8,
        titleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        iconColor: AppColors.darkTextSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadiusSmall,
          ),
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }

            return AppColors.darkTextTertiary;
          },
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.darkBackground;
            }

            return AppColors.darkTextTertiary;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }

            return AppColors.darkSurfaceVariant;
          },
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaryLight,
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelLarge,
        indicatorColor: AppColors.primaryLight,
        indicatorSize: TabBarIndicatorSize.label,
      ),

      textTheme: _darkTextTheme,
    );
  }

  // ---------------------------------------------------------------------------
  // Text themes
  // ---------------------------------------------------------------------------

  static TextTheme get _lightTextTheme {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.lightTextSecondary,
      ),
    );
  }

  static TextTheme get _darkTextTheme {
    return TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.darkTextSecondary,
      ),
    );
  }
}
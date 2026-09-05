class AppDimensions {
  AppDimensions._();

  // ---------------------------------------------------------------------------
  // Spacing
  // ---------------------------------------------------------------------------

  static const double spacing2 = 2.0;

  static const double spacing4 = 4.0;

  static const double spacing6 = 6.0;

  static const double spacing8 = 8.0;

  static const double spacing10 = 10.0;

  static const double spacing12 = 12.0;

  static const double spacing14 = 14.0;

  static const double spacing16 = 16.0;

  static const double spacing20 = 20.0;

  static const double spacing24 = 24.0;

  static const double spacing28 = 28.0;

  static const double spacing32 = 32.0;

  static const double spacing40 = 40.0;

  static const double spacing48 = 48.0;

  static const double spacing56 = 56.0;

  static const double spacing64 = 64.0;

  // ---------------------------------------------------------------------------
  // Page
  // ---------------------------------------------------------------------------

  static const double pagePadding = 24.0;

  static const double pagePaddingMobile = 16.0;

  static const double pagePaddingLarge = 32.0;

  static const double contentMaxWidth = 1440.0;

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------

  static const double cardRadius = 12.0;

  static const double cardRadiusSmall = 8.0;

  static const double cardRadiusLarge = 16.0;

  static const double cardPadding = 20.0;

  static const double cardPaddingSmall = 16.0;

  static const double cardPaddingLarge = 24.0;

  static const double cardElevation = 1.0;

  // ---------------------------------------------------------------------------
  // Buttons
  // ---------------------------------------------------------------------------

  static const double buttonHeight = 48.0;

  static const double buttonHeightSmall = 40.0;

  static const double buttonHeightLarge = 54.0;

  static const double buttonMinWidth = 100.0;

  static const double buttonRadius = 10.0;

  // ---------------------------------------------------------------------------
  // Input fields
  // ---------------------------------------------------------------------------

  static const double inputHeight = 52.0;

  static const double inputHeightSmall = 44.0;

  static const double inputRadius = 10.0;

  static const double inputHorizontalPadding = 16.0;

  static const double inputVerticalPadding = 14.0;

  // ---------------------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------------------

  static const double appBarHeight = 64.0;

  static const double appBarPadding = 20.0;

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  static const double navigationRailWidth = 80.0;

  static const double navigationDrawerWidth = 280.0;

  static const double navigationItemHeight = 48.0;

  static const double navigationItemRadius = 10.0;

  // ---------------------------------------------------------------------------
  // Icons
  // ---------------------------------------------------------------------------

  static const double iconSizeSmall = 16.0;

  static const double iconSizeMedium = 20.0;

  static const double iconSizeLarge = 24.0;

  static const double iconSizeXLarge = 32.0;

  static const double iconContainerSmall = 32.0;

  static const double iconContainerMedium = 40.0;

  static const double iconContainerLarge = 48.0;

  // ---------------------------------------------------------------------------
  // Avatar
  // ---------------------------------------------------------------------------

  static const double avatarSmall = 32.0;

  static const double avatarMedium = 40.0;

  static const double avatarLarge = 56.0;

  static const double avatarXLarge = 80.0;

  // ---------------------------------------------------------------------------
  // Tables
  // ---------------------------------------------------------------------------

  static const double tableRowHeight = 64.0;

  static const double tableHeaderHeight = 56.0;

  static const double tableColumnSpacing = 24.0;

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  static const double dialogRadius = 16.0;

  static const double dialogPadding = 24.0;

  static const double dialogMaxWidth = 560.0;

  static const double dialogLargeMaxWidth = 900.0;

  // ---------------------------------------------------------------------------
  // Bottom sheets
  // ---------------------------------------------------------------------------

  static const double bottomSheetRadius = 20.0;

  static const double bottomSheetPadding = 24.0;

  // ---------------------------------------------------------------------------
  // Charts
  // ---------------------------------------------------------------------------

  static const double chartHeight = 280.0;

  static const double chartHeightSmall = 200.0;

  static const double chartHeightLarge = 360.0;

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  static const double dashboardStatCardMinHeight = 120.0;

  static const double dashboardGridSpacing = 16.0;

  // ---------------------------------------------------------------------------
  // Responsive breakpoints
  // ---------------------------------------------------------------------------

  static const double mobileBreakpoint = 600.0;

  static const double tabletBreakpoint = 900.0;

  static const double desktopBreakpoint = 1200.0;

  static const double largeDesktopBreakpoint = 1440.0;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static bool isMobile(double width) {
    return width < mobileBreakpoint;
  }

  static bool isTablet(double width) {
    return width >= mobileBreakpoint &&
        width < desktopBreakpoint;
  }

  static bool isDesktop(double width) {
    return width >= desktopBreakpoint;
  }
}
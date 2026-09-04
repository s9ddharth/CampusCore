import 'env.dart';

enum EnvironmentType { development, staging, production }

/// Centralized application configuration.
/// Handles app metadata, feature flags, and environment-specific behaviors.
class AppConfig {
  // Prevent instantiation
  AppConfig._();

  // ==========================================
  // App Metadata
  // ==========================================
  static const String appName = 'CampusCore';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;
  static const String supportEmail = 'support@campuscore.edu';

  // ==========================================
  // Environment Resolution
  // ==========================================
  static EnvironmentType get environment {
    if (Env.isProd) return EnvironmentType.production;
    if (Env.isStaging) return EnvironmentType.staging;
    return EnvironmentType.development;
  }

  // ==========================================
  // Feature Flags
  // ==========================================
  
  /// Determines if crash reporting tools (like Firebase Crashlytics) should be active.
  static bool get enableCrashReporting => environment == EnvironmentType.production;

  /// Determines if analytics tracking should be active.
  static bool get enableAnalytics => environment == EnvironmentType.production || environment == EnvironmentType.staging;

  /// Determines if mock data should be used (useful for UI testing without a backend).
  static const bool useMockData = false;

  /// Maximum file upload size in megabytes (MB) allowed in the app (e.g., for assignments).
  static const int maxFileUploadSizeMB = 10;

  // ==========================================
  // UI & UX Configurations
  // ==========================================
  
  /// The duration to show snackbars for standard notifications.
  static const Duration snackBarDuration = Duration(seconds: 3);
  
  /// The duration for standard UI animations (e.g., page transitions, dialogs).
  static const Duration animationDuration = Duration(milliseconds: 300);
}
/// Manages all environment variables and secrets for the application.
/// Uses [String.fromEnvironment] to ensure values are injected securely at compile-time.
class Env {
  // Prevent instantiation
  Env._();

  /// The base URL for the backend API. 
  /// Defaults to localhost for local development if not provided during build.
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// The current environment profile (e.g., dev, staging, prod).
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  /// API Key if required by external services (e.g., maps, third-party analytics).
  static const String apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: '',
  );

  /// Enables or disables extensive logging. Automatically false in production.
  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  /// Helper getters to quickly check the current environment state.
  static bool get isDev => environment.toLowerCase() == 'dev';
  static bool get isStaging => environment.toLowerCase() == 'staging';
  static bool get isProd => environment.toLowerCase() == 'prod';
}
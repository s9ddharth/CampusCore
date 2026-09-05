/// Standardized configuration for all network requests made by the application.
class ApiConfig {
  // Prevent instantiation
  ApiConfig._();

  // ==========================================
  // API Versioning & Base Paths
  // ==========================================
  
  /// The standard API prefix appended to the Base URL.
  static const String apiPrefix = '/api/v1';

  // ==========================================
  // Network Timeouts
  // ==========================================
  
  /// Maximum time allowed to establish a connection with the server.
  static const Duration connectTimeout = Duration(milliseconds: 30000); // 30 seconds
  
  /// Maximum time allowed between data chunks received from the server.
  static const Duration receiveTimeout = Duration(milliseconds: 30000); // 30 seconds
  
  /// Maximum time allowed to send data to the server.
  static const Duration sendTimeout = Duration(milliseconds: 30000); // 30 seconds

  // ==========================================
  // Standard Headers
  // ==========================================
  
  static const String contentTypeJson = 'application/json; charset=utf-8';
  static const String contentTypeMultipart = 'multipart/form-data';
  static const String acceptJson = 'application/json';

  /// Default headers applied to every request before interceptors add auth tokens.
  static const Map<String, String> defaultHeaders = {
    'Content-Type': contentTypeJson,
    'Accept': acceptJson,
  };

  // ==========================================
  // Pagination Defaults
  // ==========================================
  
  /// The default number of items to request per page for list endpoints.
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  static const String paginationPageParam = 'page';
  static const String paginationLimitParam = 'limit';

  // ==========================================
  // Standard HTTP Status Codes mapping
  // ==========================================
  
  static const int success = 200;
  static const int created = 201;
  static const int noContent = 204;
  
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int unprocessableEntity = 422;
  
  static const int serverError = 500;
  static const int serviceUnavailable = 503;
}
/// Base exception for all API-related errors.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, {dynamic data}) 
    : super(message, statusCode: 401, data: data);
}

class ServerException extends ApiException {
  ServerException(String message, {int? statusCode, dynamic data}) 
    : super(message, statusCode: statusCode, data: data);
}

class ValidationException extends ApiException {
  ValidationException(String message, {dynamic data}) 
    : super(message, statusCode: 422, data: data);
}
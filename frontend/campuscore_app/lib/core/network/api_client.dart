import 'package:dio/dio.dart';
import '../config/env.dart';
import '../config/api_config.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';
import 'api_interceptors.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient(SecureStorage secureStorage) {
    _dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl + ApiConfig.apiPrefix,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ));

    _dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      if (Env.enableLogging) LoggingInterceptor(),
    ]);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Connection timed out. Please check your internet.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection.');
    }
    
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    final message = (responseData is Map && responseData['message'] != null) 
        ? responseData['message'] 
        : e.message ?? 'An unknown error occurred';

    if (statusCode == 401) {
      return UnauthorizedException(message, data: responseData);
    } else if (statusCode == 422) {
      return ValidationException(message, data: responseData);
    } else if (statusCode != null && statusCode >= 500) {
      return ServerException('Server error. Please try again later.', statusCode: statusCode);
    }

    return ApiException(message, statusCode: statusCode, data: responseData);
  }
}
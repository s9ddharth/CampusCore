import 'package:dio/dio.dart';

import '../network/api_exceptions.dart';
import 'error_state.dart';

class ErrorHandler {
  ErrorHandler._();

  static ErrorState handle(Object error) {
    if (error is ErrorState) {
      return error;
    }

    if (error is ApiException) {
      return ErrorState(
        message: error.message,
        statusCode: error.statusCode,
        type: _mapApiExceptionType(error),
      );
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is FormatException) {
      return const ErrorState(
        message: 'The received data could not be processed.',
        type: ErrorType.parsing,
      );
    }

    if (error is ArgumentError) {
      return ErrorState(
        message: error.message?.toString() ??
            'Invalid value provided.',
        type: ErrorType.validation,
      );
    }

    return const ErrorState(
      message: 'Something went wrong. Please try again.',
      type: ErrorType.unknown,
    );
  }

  static ErrorState _handleDioException(
    DioException exception,
  ) {
    final response = exception.response;
    final statusCode = response?.statusCode;

    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return const ErrorState(
        message:
            'The request timed out. Please check your connection and try again.',
        type: ErrorType.timeout,
      );
    }

    if (exception.type == DioExceptionType.connectionError) {
      return const ErrorState(
        message:
            'Unable to connect to the server. Please check your internet connection.',
        type: ErrorType.network,
      );
    }

    if (exception.type == DioExceptionType.cancel) {
      return const ErrorState(
        message: 'The request was cancelled.',
        type: ErrorType.cancelled,
      );
    }

    if (statusCode == 401) {
      return const ErrorState(
        message:
            'Your session has expired. Please log in again.',
        statusCode: 401,
        type: ErrorType.unauthorized,
      );
    }

    if (statusCode == 403) {
      return const ErrorState(
        message:
            'You do not have permission to perform this action.',
        statusCode: 403,
        type: ErrorType.forbidden,
      );
    }

    if (statusCode == 404) {
      return const ErrorState(
        message: 'The requested resource was not found.',
        statusCode: 404,
        type: ErrorType.notFound,
      );
    }

    if (statusCode == 422) {
      return ErrorState(
        message: _extractServerMessage(response) ??
            'Please check the entered information.',
        statusCode: 422,
        type: ErrorType.validation,
      );
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ErrorState(
        message: _extractServerMessage(response) ??
            'The request could not be completed.',
        statusCode: statusCode,
        type: ErrorType.client,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ErrorState(
        message: _extractServerMessage(response) ??
            'The server encountered an error. Please try again later.',
        statusCode: statusCode,
        type: ErrorType.server,
      );
    }

    return const ErrorState(
      message:
          'Unable to complete the request. Please try again.',
      type: ErrorType.network,
    );
  }

  static ErrorType _mapApiExceptionType(
    ApiException exception,
  ) {
    final statusCode = exception.statusCode;

    if (statusCode == 401) {
      return ErrorType.unauthorized;
    }

    if (statusCode == 403) {
      return ErrorType.forbidden;
    }

    if (statusCode == 404) {
      return ErrorType.notFound;
    }

    if (statusCode == 422) {
      return ErrorType.validation;
    }

    if (statusCode != null && statusCode >= 400 && statusCode < 500) {
      return ErrorType.client;
    }

    if (statusCode != null && statusCode >= 500) {
      return ErrorType.server;
    }

    return ErrorType.unknown;
  }

  static String? _extractServerMessage(
    Response<dynamic>? response,
  ) {
    final data = response?.data;

    if (data == null) {
      return null;
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map<String, dynamic>) {
      final detail = data['detail'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }

      if (detail is List && detail.isNotEmpty) {
        final messages = detail
            .map(_extractValidationMessage)
            .whereType<String>()
            .where((message) => message.isNotEmpty)
            .toList();

        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }

      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }

      final error = data['error'];

      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }
    }

    return null;
  }

  static String? _extractValidationMessage(
    dynamic item,
  ) {
    if (item is String && item.trim().isNotEmpty) {
      return item.trim();
    }

    if (item is Map<String, dynamic>) {
      final message = item['msg'];

      if (message is String && message.trim().isNotEmpty) {
        final location = item['loc'];

        if (location is List && location.isNotEmpty) {
          final field = location.last.toString();

          if (field.isNotEmpty && field != 'body') {
            return '$field: ${message.trim()}';
          }
        }

        return message.trim();
      }
    }

    return null;
  }

  static String message(Object error) {
    return handle(error).message;
  }

  static bool isUnauthorized(Object error) {
    return handle(error).type == ErrorType.unauthorized;
  }

  static bool isForbidden(Object error) {
    return handle(error).type == ErrorType.forbidden;
  }

  static bool isValidationError(Object error) {
    return handle(error).type == ErrorType.validation;
  }

  static bool isNetworkError(Object error) {
    final type = handle(error).type;

    return type == ErrorType.network ||
        type == ErrorType.timeout;
  }
}
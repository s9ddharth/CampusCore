class ErrorState {
  const ErrorState({
    required this.message,
    this.statusCode,
    this.type = ErrorType.unknown,
    this.details,
  });

  final String message;
  final int? statusCode;
  final ErrorType type;
  final String? details;

  bool get hasStatusCode => statusCode != null;

  bool get isNetworkError =>
      type == ErrorType.network ||
      type == ErrorType.timeout;

  bool get isAuthenticationError =>
      type == ErrorType.unauthorized ||
      type == ErrorType.forbidden;

  bool get isClientError =>
      type == ErrorType.client ||
      type == ErrorType.validation ||
      type == ErrorType.notFound;

  bool get isServerError => type == ErrorType.server;

  bool get isRetryable =>
      type == ErrorType.network ||
      type == ErrorType.timeout ||
      type == ErrorType.server;

  ErrorState copyWith({
    String? message,
    int? statusCode,
    ErrorType? type,
    String? details,
    bool clearStatusCode = false,
    bool clearDetails = false,
  }) {
    return ErrorState(
      message: message ?? this.message,
      statusCode:
          clearStatusCode ? null : statusCode ?? this.statusCode,
      type: type ?? this.type,
      details: clearDetails ? null : details ?? this.details,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('ErrorState(')
      ..write('message: $message')
      ..write(', type: $type');

    if (statusCode != null) {
      buffer.write(', statusCode: $statusCode');
    }

    if (details != null && details!.isNotEmpty) {
      buffer.write(', details: $details');
    }

    buffer.write(')');

    return buffer.toString();
  }
}

enum ErrorType {
  unknown,
  network,
  timeout,
  cancelled,
  unauthorized,
  forbidden,
  notFound,
  validation,
  client,
  server,
  parsing,
}
/// Base exception for app errors
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException([String message = 'No internet connection'])
      : super(message, code: 'NETWORK_ERROR');
}

/// API related exceptions
class ApiException extends AppException {
  final int? statusCode;
  final String? responseBody;

  ApiException(
    super.message, {
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() =>
      'ApiException: $message (Status: $statusCode)';
}

/// Not found exception
class NotFoundException extends AppException {
  NotFoundException([String message = 'Resource not found'])
      : super(message, code: 'NOT_FOUND');
}

/// Cache exception
class CacheException extends AppException {
  CacheException([String message = 'Cache error'])
      : super(message, code: 'CACHE_ERROR');
}

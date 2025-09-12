// core/network/api_error_handler.dart
import 'package:dio/dio.dart';
import 'api_result.dart';

class ApiErrorHandler {
  static ApiFailure handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiFailure("Connection timeout", statusCode: 408);
      case DioExceptionType.sendTimeout:
        return ApiFailure("Send timeout", statusCode: 408);
      case DioExceptionType.receiveTimeout:
        return ApiFailure("Receive timeout", statusCode: 408);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 500;
        final message = error.response?.data?['message'] ?? "Unexpected error";
        return ApiFailure(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return ApiFailure("Request cancelled");
      case DioExceptionType.unknown:
      default:
        return ApiFailure("Unexpected error: ${error.message}");
    }
  }
}

// core/extensions/context_api_result_extension.dart
import 'package:flutter/material.dart';
import '../network/api_result.dart';

extension ApiResultHandler on BuildContext {
  void handleApiResult<T>(
    ApiResult<T> result, {
    String successMessage = "Success",
    void Function(T data)? onSuccess,
  }) {
    if (result is ApiSuccess<T>) {
      // showSuccessSnackBar(successMessage);
      ScaffoldMessenger.of(this)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: const Color.fromARGB(255, 54, 149, 244),
            duration: const Duration(seconds: 2),
          ),
        );
      if (onSuccess != null) onSuccess(result.data);
    } else if (result is ApiFailure<T>) {
      ScaffoldMessenger.of(this)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }
}

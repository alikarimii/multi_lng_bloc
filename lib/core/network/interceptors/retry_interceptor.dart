import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RetryInterceptor extends Interceptor {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retryCount'] as int? ?? 0;
      if (retryCount < _maxRetries) {
        await Future.delayed(_retryDelay * (retryCount + 1));
        err.requestOptions.extra['retryCount'] = retryCount + 1;
        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

@lazySingleton
class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  @factoryMethod
  factory ApiClient.create(
    AuthInterceptor authInterceptor,
    RetryInterceptor retryInterceptor,
  ) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      authInterceptor,
      retryInterceptor,
      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return ApiClient(dio);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters, options: options);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) {
    return dio.put<T>(path, data: data, options: options);
  }

  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) {
    return dio.delete<T>(path, options: options);
  }

  Future<Response<T>> upload<T>(
    String path, {
    required FormData data,
    void Function(int, int)? onSendProgress,
  }) {
    return dio.post<T>(
      path,
      data: data,
      onSendProgress: onSendProgress,
      options: Options(
        sendTimeout: ApiConstants.uploadTimeout,
        receiveTimeout: ApiConstants.uploadTimeout,
      ),
    );
  }
}

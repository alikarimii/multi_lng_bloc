import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  });
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });
  Future<AuthResponseModel> refreshToken(String refreshToken);
  Future<UserModel> getProfile(String token);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  const AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException('Registration failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException('Login failed: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );
      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException('Token refresh failed: $e');
    }
  }

  @override
  Future<UserModel> getProfile(String token) async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException('Get profile failed: $e');
    }
  }
}

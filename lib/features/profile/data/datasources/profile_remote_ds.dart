import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getCurrentProfile();
  Future<UserModel> getUserById(String userId);
  Future<List<UserModel>> getUsers();
}

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  const ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> getCurrentProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException('Get profile failed: $e');
    }
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    try {
      final response = await _apiClient.get(ApiConstants.userById(userId));
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException('Get user failed: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _apiClient.get(ApiConstants.users);
      final data = response.data;
      if (data is! List) {
        throw const ServerException('Unexpected users payload');
      }
      return data
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on Exception catch (e) {
      throw ServerException('Get users failed: $e');
    }
  }
}

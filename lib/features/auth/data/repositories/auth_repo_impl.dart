import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/interceptors/auth_interceptor.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repo.dart';
import '../datasources/auth_local_ds.dart';
import '../datasources/auth_remote_ds.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final AuthInterceptor _authInterceptor;
  final NetworkInfo _networkInfo;

  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._authInterceptor,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await _remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );
      await _authInterceptor.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _localDataSource.cacheUser(result.user);
      return Right(result.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final result = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _authInterceptor.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _localDataSource.cacheUser(result.user);
      return Right(result.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, User>> refreshToken() async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final token = await _authInterceptor.refreshToken;
      if (token == null) return const Left(AuthFailure());

      final result = await _remoteDataSource.refreshToken(token);
      await _authInterceptor.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _localDataSource.cacheUser(result.user);
      return Right(result.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _authInterceptor.clearTokens();
    await _localDataSource.clearCache();
    return const Right(null);
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final user = await _localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}

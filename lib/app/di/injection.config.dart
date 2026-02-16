// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:multi_lng_bloc/app/di/injection.dart' as _i410;
import 'package:multi_lng_bloc/core/network/api_client.dart' as _i250;
import 'package:multi_lng_bloc/core/network/interceptors/auth_interceptor.dart'
    as _i449;
import 'package:multi_lng_bloc/core/network/interceptors/retry_interceptor.dart'
    as _i628;
import 'package:multi_lng_bloc/core/network/network_info.dart' as _i94;
import 'package:multi_lng_bloc/features/auth/data/datasources/auth_local_ds.dart'
    as _i126;
import 'package:multi_lng_bloc/features/auth/data/datasources/auth_remote_ds.dart'
    as _i3;
import 'package:multi_lng_bloc/features/auth/data/repositories/auth_repo_impl.dart'
    as _i196;
import 'package:multi_lng_bloc/features/auth/domain/repositories/auth_repo.dart'
    as _i968;
import 'package:multi_lng_bloc/features/auth/domain/usecases/login.dart'
    as _i950;
import 'package:multi_lng_bloc/features/auth/domain/usecases/logout.dart'
    as _i565;
import 'package:multi_lng_bloc/features/auth/domain/usecases/register.dart'
    as _i182;
import 'package:multi_lng_bloc/features/auth/presentation/bloc/auth_bloc.dart'
    as _i850;
import 'package:multi_lng_bloc/features/profile/data/datasources/profile_remote_ds.dart'
    as _i1042;
import 'package:multi_lng_bloc/features/profile/data/repositories/profile_repo_impl.dart'
    as _i381;
import 'package:multi_lng_bloc/features/profile/domain/repositories/profile_repo.dart'
    as _i284;
import 'package:multi_lng_bloc/features/profile/domain/usecases/get_profile.dart'
    as _i562;
import 'package:multi_lng_bloc/features/profile/domain/usecases/get_users.dart'
    as _i281;
import 'package:multi_lng_bloc/features/profile/presentation/bloc/profile_bloc.dart'
    as _i534;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i628.RetryInterceptor>(() => _i628.RetryInterceptor());
    gh.lazySingleton<_i94.NetworkInfo>(
      () => _i94.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i449.AuthInterceptor>(
      () => _i449.AuthInterceptor(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i250.ApiClient>(
      () => _i250.ApiClient.create(
        gh<_i449.AuthInterceptor>(),
        gh<_i628.RetryInterceptor>(),
      ),
    );
    gh.lazySingleton<_i3.AuthRemoteDataSource>(
      () => _i3.AuthRemoteDataSourceImpl(gh<_i250.ApiClient>()),
    );
    gh.lazySingleton<_i1042.ProfileRemoteDataSource>(
      () => _i1042.ProfileRemoteDataSourceImpl(gh<_i250.ApiClient>()),
    );
    gh.lazySingleton<_i126.AuthLocalDataSource>(
      () => _i126.AuthLocalDataSourceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i284.ProfileRepository>(
      () => _i381.ProfileRepositoryImpl(
        gh<_i1042.ProfileRemoteDataSource>(),
        gh<_i94.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i968.AuthRepository>(
      () => _i196.AuthRepositoryImpl(
        gh<_i3.AuthRemoteDataSource>(),
        gh<_i126.AuthLocalDataSource>(),
        gh<_i449.AuthInterceptor>(),
        gh<_i94.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i950.LoginUseCase>(
      () => _i950.LoginUseCase(gh<_i968.AuthRepository>()),
    );
    gh.lazySingleton<_i565.LogoutUseCase>(
      () => _i565.LogoutUseCase(gh<_i968.AuthRepository>()),
    );
    gh.lazySingleton<_i182.RegisterUseCase>(
      () => _i182.RegisterUseCase(gh<_i968.AuthRepository>()),
    );
    gh.factory<_i850.AuthBloc>(
      () => _i850.AuthBloc(
        gh<_i950.LoginUseCase>(),
        gh<_i182.RegisterUseCase>(),
        gh<_i565.LogoutUseCase>(),
        gh<_i968.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i562.GetProfileUseCase>(
      () => _i562.GetProfileUseCase(gh<_i284.ProfileRepository>()),
    );
    gh.lazySingleton<_i281.GetUsersUseCase>(
      () => _i281.GetUsersUseCase(gh<_i284.ProfileRepository>()),
    );
    gh.factory<_i534.ProfileBloc>(
      () => _i534.ProfileBloc(
        gh<_i562.GetProfileUseCase>(),
        gh<_i281.GetUsersUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i410.RegisterModule {}

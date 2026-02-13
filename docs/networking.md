# Networking and IO (interface-based)

This repo centralizes HTTP configuration in `ApiClient` (Dio wrapper) and keeps features talking to the network through data sources + repositories.

## Key building blocks

- `lib/core/network/api_client.dart`
  - Wraps `Dio` and provides `get/post/put/delete/upload`.
  - Attaches interceptors (auth, retry, logging).
- `lib/core/network/network_info.dart`
  - `NetworkInfo` interface + `NetworkInfoImpl` using `connectivity_plus`.
- `lib/core/network/interceptors/*`
  - `AuthInterceptor` injects access token into requests.

## How to add a new API call (recommended flow)

1. Add endpoint constant (if you’re using constants)

- `lib/core/constants/api_constants.dart`

2. Add method to a Remote DataSource interface

Example:

```dart
abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
}
```

3. Implement it using `ApiClient`

```dart
@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._api);
  final ApiClient _api;

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final res = await _api.get('/profile');
      return ProfileModel.fromJson(res.data as Map<String, dynamic>);
    } on Exception catch (e) {
      throw ServerException('Get profile failed: $e');
    }
  }
}
```

4. Call the data source from a Repository implementation

- Check `NetworkInfo.isConnected` if the call requires internet.
- Convert exceptions to `Failure` (domain-friendly).

This pattern is already used in `AuthRepositoryImpl`.

## Why interface-based helps

- Remote/local data sources are **interfaces**, so you can swap implementations.
- `NetworkInfo` is an interface, so you can use a fake in tests.
- Repositories depend on interfaces, not concrete IO.

## Swapping implementations (simple approach)

Because injectable binds interfaces to implementations (e.g. `@LazySingleton(as: NetworkInfo)`), you can:

- Replace bindings in tests using `getIt.registerSingleton(...)` / `registerFactory(...)`
- Or use injectable environments if you choose to add them later

## Testing tips

- Mock data sources/repositories at the boundary you’re testing.
- Use repository tests to verify exception -> failure mapping.
- Use bloc tests to verify event -> state transitions.

# Data layer (what it is, and why we need it)

In this project, the **data layer** is the part of a feature responsible for talking to the outside world (network, local storage, device APIs), and converting those details into the clean domain contracts your app uses.

It usually lives under:

```
lib/features/<feature>/data/
  datasources/
  models/
  repositories/
```

## Why we need a data layer

### 1) Keep the app testable

- UI/BLoC tests should not depend on real HTTP or storage.
- With a data layer, you can swap implementations (fake/real) by depending on interfaces.

### 2) Protect the domain from frameworks

- **Domain** should not import Flutter, Dio, SharedPreferences, SecureStorage, etc.
- Data layer isolates those dependencies so the domain stays pure and stable.

### 3) Make it easy to change IO

You can change:

- the HTTP client (`dio` → something else)
- storage mechanism (secure storage → shared prefs/db)
- endpoint shapes

…without rewriting BLoCs and pages, because they depend on repository interfaces.

### 4) Centralize error handling

Network/timeouts/JSON parsing errors are messy.
The data layer provides one consistent output:

- `Either<Failure, T>` to the domain/presentation

So UI logic doesn’t have to deal with exceptions.

## What the data layer contains

### 1) Models (DTOs)

Models represent how data looks **in JSON / persistence**, not necessarily how you want to use it in the app.

- Path: `lib/features/<feature>/data/models/`
- Typical contents:
  - `fromJson` / `toJson`
  - mapping helpers to/from entities (optional)

Example in this repo:

- Auth uses `UserModel` and parses `response.data` from Dio.

### 2) Data sources (remote/local)

Data sources are small classes that do the raw IO.

- Remote data source: calls APIs using `ApiClient`
- Local data source: reads/writes cache (secure storage/db)

They are usually defined as:

- An **abstract interface**
- A concrete implementation bound via injectable

Example pattern used here (Auth):

- `AuthRemoteDataSource` / `AuthRemoteDataSourceImpl`
- `AuthLocalDataSource` / `AuthLocalDataSourceImpl`

#### Data source rules

- Keep data sources focused on IO only.
- Throw exceptions from `lib/core/errors/exceptions.dart` (or wrap as `ServerException`).
- Don’t return `Either` from data sources (that is repository responsibility).

### 3) Repository implementation

The repository implementation is the “traffic controller”:

- It decides remote vs cache.
- It checks connectivity (`NetworkInfo`).
- It converts exceptions into domain-friendly `Failure`.
- It maps models → entities.

Example in this repo:

- `AuthRepositoryImpl` in `lib/features/auth/data/repositories/auth_repo_impl.dart`

Repository implementation is bound using injectable, e.g.:

```dart
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  // ...
}
```

## How it connects to domain + presentation

Typical flow:

1. UI dispatches an event to BLoC
2. BLoC calls a UseCase
3. UseCase calls a **domain repository interface**
4. Injectable provides the **data repository implementation**
5. Repository calls remote/local data sources
6. Repository returns `Either<Failure, Entity>`

This keeps BLoC clean: it only handles state transitions.

## Error handling approach (used in this repo)

- Data source throws exceptions (`ServerException`, `CacheException`)
- Repository catches and returns failures (`ServerFailure`, `CacheFailure`, `NetworkFailure`)

Example pattern:

```dart
if (!await _networkInfo.isConnected) {
  return const Left(NetworkFailure());
}

try {
  final model = await _remoteDataSource.someCall();
  final entity = model.toEntity(); // or mapping in repo
  return Right(entity);
} on ServerException catch (e) {
  return Left(ServerFailure(e.message, statusCode: e.statusCode));
} on CacheException catch (e) {
  return Left(CacheFailure(e.message));
}
```

## Using interfaces so we can swap implementations

This repo already follows interface-based design:

- `NetworkInfo` is an abstract class.
- Feature repositories are abstract classes in `domain/repositories/`.
- Data sources are abstract classes.

That makes swapping easy:

- Replace remote data source with a mock/fake.
- Replace repository implementation for dev/staging.

With GetIt, you can also override bindings in tests.

## Practical checklist when adding a new data feature

- [ ] Add/update endpoint constants (if used)
- [ ] Create `RemoteDataSource` interface + impl using `ApiClient`
- [ ] Create `LocalDataSource` interface + impl if caching is needed
- [ ] Create model(s) to parse/serialize
- [ ] Implement repository:
  - [ ] check `NetworkInfo` where required
  - [ ] catch exceptions → failures
  - [ ] map model → entity
- [ ] Annotate injectable bindings and run generator:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Testing notes

- **Repository tests**: verify exception → failure mapping and caching rules.
- **Data source tests**: verify correct request/response parsing (often with mocks).
- **BLoC tests**: verify event → state changes, while mocking use cases.

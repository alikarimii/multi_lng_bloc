# Adding a new feature

This repo uses a feature-first structure under `lib/features/`.

## 1) Create the feature folders

Example: `profile`

```
lib/features/profile/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc/
    pages/
    widgets/
```

## 2) Domain layer (contracts)

### Entities

Put your core types in `domain/entities/`.

### Repository interface

Define an interface in `domain/repositories/` returning `Either<Failure, T>`.

Example shape (similar to Auth):

```dart
abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile();
}
```

### Use cases

Create small classes in `domain/usecases/` that call the repository.

```dart
@lazySingleton
class GetProfileUseCase {
  const GetProfileUseCase(this._repo);
  final ProfileRepository _repo;

  Future<Either<Failure, Profile>> call() => _repo.getProfile();
}
```

## 3) Data layer (implementations)

### Data sources

Create interfaces + implementations:

- `ProfileRemoteDataSource` uses `ApiClient`
- `ProfileLocalDataSource` uses storage (if needed)

Throw `ServerException` / `CacheException` from data sources.

### Repository implementation

Implement the domain repository in `data/repositories/`:

- Check `NetworkInfo.isConnected` when needed
- Catch exceptions and return `Failure`
- Cache and map models -> entities

Bind it with injectable:

```dart
@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  // ...
}
```

## 4) Presentation layer (page + BLoC/Cubit)

- Put the page in `presentation/pages/`.
- Put the BLoC/Cubit in `presentation/bloc/` or `presentation/cubit/`.
- Provide it in the page with `BlocProvider(create: (_) => getIt<...>())`.

## 5) Register route (if needed)

Add `@RoutePage()` on the page and register it in `lib/app/router/app_router.dart`.
Then regenerate routes.

## 6) Regenerate code

Whenever you add new injectable classes or new routes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If you added/changed localized strings:

```bash
flutter gen-l10n
```

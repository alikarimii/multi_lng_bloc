# Use cases, repositories, and layers

This repo follows a common pattern:

- **Presentation** (Flutter UI) talks to **BLoC/Cubit**
- BLoC/Cubit calls **UseCases**
- UseCases call **Repository interfaces** (Domain)
- Repository implementations (Data) talk to **Remote/Local DataSources**

## Domain layer (what it should contain)

- `entities/`: business objects (no JSON, no Dio)
- `repositories/`: abstract contracts (interfaces)
- `usecases/`: small, focused operations

Domain returns results as:

- `Either<Failure, T>` (from `dartz`)

## Data layer (what it should contain)

- `models/`: JSON serializable types (DTOs)
- `datasources/`: IO details (network, storage)
- `repositories/`: implementations of domain repositories

Data layer responsibilities:

- Catch exceptions from IO (`ServerException`, `CacheException`)
- Convert them to domain failures (`ServerFailure`, `CacheFailure`, `NetworkFailure`)
- Map models <-> entities

## Failure & exception approach used here

- DataSource throws `*Exception` types from `lib/core/errors/exceptions.dart`
- Repository catches and returns `Failure` types from `lib/core/errors/failures.dart`

Example pattern (already used in Auth repository):

```dart
if (!await _networkInfo.isConnected) {
  return const Left(NetworkFailure());
}
try {
  final result = await _remoteDataSource.someCall();
  return Right(result);
} on ServerException catch (e) {
  return Left(ServerFailure(e.message, statusCode: e.statusCode));
}
```

## Use case guidelines

- Keep use cases thin.
- Avoid putting parsing/mapping logic in use cases.
- A use case should read almost like a sentence:
  - `LoginUseCase`, `RegisterUseCase`, `GetProfileUseCase`, etc.

## Repository guidelines

- Repositories define the feature’s data API.
- Prefer returning domain entities.
- Keep BLoC free from data-source details.

## Practical checklist (new feature)

- [ ] Domain: entity + repository interface + use case(s)
- [ ] Data: model + remote/local data sources + repository impl + mapping
- [ ] Presentation: bloc/cubit + page + widgets
- [ ] DI: annotate with injectable and run build_runner

# multi_lng_bloc

Multi-language Flutter app using BLoC + feature-first structure + code generation.

## Quick start

Install dependencies:

- `flutter pub get`

Run the app:

- `flutter run`

## Project structure (high level)

- `lib/app/` app wiring (DI, routing, root widget)
- `lib/core/` shared core (network, errors, constants, utils, theme)
- `lib/features/` feature modules (data/domain/presentation)
- `lib/shared/` reusable widgets/extensions
- `lib/l10n/` localization ARB + generated localization Dart files

More details: [docs/folder-structure.md](docs/folder-structure.md)

## Add a new feature

Create a new folder under `lib/features/<feature>/` and follow the layers:

- `domain/` (entities, repository interfaces, use cases)
- `data/` (models, data sources, repository implementations)
- `presentation/` (pages/widgets + BLoC/Cubit)

Step-by-step guide: [docs/adding-feature.md](docs/adding-feature.md)

## BLoC usage in new pages

- When to use Cubit vs Bloc
- Where to put state
- `BlocProvider` + `BlocBuilder` + `BlocListener/BlocConsumer`

Guide: [docs/bloc.md](docs/bloc.md)

## Code generation

This project uses code generation for:

- Routing (`auto_route`) → generates `app_router.gr.dart`
- DI (`injectable`) → generates `injection.config.dart`

Regenerate generated Dart files:

- `dart run build_runner build --delete-conflicting-outputs`

Watch mode (optional):

- `dart run build_runner watch --delete-conflicting-outputs`

Routing guide: [docs/routing.md](docs/routing.md)

## Localization (l10n / i10n)

The template ARB file is `lib/l10n/app_en.arb` and other locales must contain the same keys.

Regenerate localization Dart files:

- `flutter gen-l10n`

Guide: [docs/localization.md](docs/localization.md)

## Networking + data layer

- Networking/IO patterns: [docs/networking.md](docs/networking.md)
- Why we have a data layer: [docs/data-layer.md](docs/data-layer.md)
- Use cases + repositories: [docs/usecases-repositories.md](docs/usecases-repositories.md)

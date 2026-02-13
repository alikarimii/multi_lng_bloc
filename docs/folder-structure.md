# Folder structure

This repo follows a feature-first + clean-ish architecture layout.

## `lib/` overview

- `lib/main.dart`
  - App entry point.
- `lib/app/`
  - App-level wiring: router, DI setup, root `MyApp`, app-wide configuration.
- `lib/core/`
  - Cross-cutting, feature-agnostic code (network, errors, constants, utils, theme).
- `lib/features/`
  - Product features. Each feature owns its UI + state + domain + data.
- `lib/shared/`
  - Reusable UI and helpers used by multiple features (widgets, extensions).
- `lib/l10n/`
  - Localization ARB files + generated localization Dart files.

## Feature layout

Most features are expected to follow this structure:

```
lib/features/<feature>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    pages/
    widgets/
    bloc/ or cubit/
```

- **Domain**: pure Dart. No Flutter imports.
- **Data**: talks to IO (network/storage). Converts exceptions -> failures.
- **Presentation**: Flutter widgets + BLoC/Cubit.

## Rules of thumb

- `presentation` depends on `domain` (and DI), but shouldn’t depend directly on `data`.
- `domain` depends on nothing in `flutter`, `dio`, or persistence packages.
- Use `shared/` only for things that genuinely repeat across features.

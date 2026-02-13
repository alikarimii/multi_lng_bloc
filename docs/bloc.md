# BLoC in new pages

This project uses `flutter_bloc` for presentation-state and `get_it` + `injectable` for dependency injection.

You’ll typically do:

- Create a BLoC (or Cubit) under `lib/features/<feature>/presentation/bloc|cubit/`
- Provide it in the page using `BlocProvider(create: (_) => getIt<YourBloc>())`
- Build UI with `BlocBuilder` and handle side-effects with `BlocListener` / `BlocConsumer`

## When to use Cubit vs Bloc

- **Cubit**: simple state changes, few actions, minimal events.
- **Bloc**: multiple events, async flows (API calls), complex state transitions.

Your repo already uses both patterns:

- `LocaleCubit` in settings for locale state
- `AuthBloc` for login/register/check/logout

## Create a new BLoC (recommended folder structure)

Example: `profile` feature

```
lib/features/profile/
  presentation/
    bloc/
      profile_bloc.dart
      profile_event.dart
      profile_state.dart
  domain/
    usecases/
    repositories/
```

### 1) Define event + state

Use `equatable` so UI rebuilds correctly.

`profile_event.dart` (example)

- `ProfileLoadRequested`
- `ProfileUpdateRequested`

`profile_state.dart` (example)

- `ProfileInitial`
- `ProfileLoading`
- `ProfileLoaded`
- `ProfileError`

Follow the same style used in `AuthBloc`:

- `part 'profile_event.dart';`
- `part 'profile_state.dart';`

### 2) Implement the BLoC

`profile_bloc.dart` example skeleton:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(/* inject usecases/repos here */) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // final data = await _repo.load();
      // emit(ProfileLoaded(data));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
```

## Register dependencies (injectable)

This repo uses `@injectable` on BLoC classes (see `AuthBloc`).

After creating a new BLoC or adding new injected classes, regenerate injectable output:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Use BLoC inside a new page

### 1) Provide the BLoC

Provide the BLoC close to the widget subtree that uses it.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileLoadRequested()),
      child: const _ProfileView(),
    );
  }
}
```

### 2) Build UI from state

```dart
class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is ProfileLoaded) {
          return Text(state.profile.name);
        }
        if (state is ProfileError) {
          return Text(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

### 3) Handle one-off UI effects (snackbars/navigation)

Use `BlocListener` or `BlocConsumer` for effects:

```dart
BlocConsumer<ProfileBloc, ProfileState>(
  listener: (context, state) {
    if (state is ProfileError) {
      // showSnackbar/dialog
    }
  },
  builder: (context, state) {
    // build UI
    return const SizedBox.shrink();
  },
)
```

This matches the existing pattern in `RegisterPage`:

- `listener` navigates / shows errors
- `builder` renders loading state / form

## Dispatch events from UI

Use `context.read<YourBloc>().add(...)`:

```dart
context.read<ProfileBloc>().add(ProfileUpdateRequested(name: name));
```

## Common pitfalls

- Don’t do navigation/snackbars inside `BlocBuilder` (use `BlocListener`).
- Make sure the BLoC is provided **above** where you call `context.read()`.
- After adding new injectable classes, rerun build runner.

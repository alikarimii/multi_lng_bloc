# Widgets, components, and state in a BLoC structure

This repo uses BLoC/Cubit for app state and keeps UI widgets mostly declarative.

## Where to put widgets (components)

- Feature-specific widgets:
  - `lib/features/<feature>/presentation/widgets/`
- Shared reusable widgets:
  - `lib/shared/widgets/`

Rule:

- If a widget is only used by one feature, keep it inside that feature.
- Promote to `shared/` only when it is reused in multiple features.

## Stateless vs Stateful (what’s better with BLoC)

### Prefer `StatelessWidget` when

- The widget renders based only on:
  - BLoC/Cubit state (`BlocBuilder`)
  - inputs (`final` constructor params)
  - inherited values (`Theme`, `MediaQuery`, `AppLocalizations`)

Most UI widgets can be `StatelessWidget`.

### Use `StatefulWidget` when

You need ephemeral UI state that should **not** live in BLoC:

- `TextEditingController`, `FocusNode`
- form validation (`GlobalKey<FormState>`)
- animations (`AnimationController`)
- local UI toggles like “show/hide password”

Example in this repo: `RegisterPage` uses controllers + `_obscurePassword`, so it’s `StatefulWidget`.

### Where should state live?

- **Business / app state**: BLoC/Cubit (network calls, caching, auth status, user profile)
- **Ephemeral UI state**: local `StatefulWidget` fields

Avoid putting controllers and focus nodes into BLoC state.

## Recommended pattern for pages

- `BlocProvider` at the page boundary
- `BlocListener` or `BlocConsumer.listener` for side effects:
  - navigation
  - snackbars/dialogs
- `BlocBuilder` for rendering

## Keep rebuilds small

- Extract heavy subtrees into small widgets.
- Consider `BlocSelector` when you only need a small slice of state.
- Don’t call `context.read()` inside build for values you want to rebuild on.

## Naming conventions (suggested)

- Page widgets: `SomethingPage`
- Reusable pieces: `SomethingSection`, `SomethingCard`, `SomethingTile`
- BLoC: `SomethingBloc`, `SomethingEvent`, `SomethingState`
- Cubit: `SomethingCubit`, `SomethingState`

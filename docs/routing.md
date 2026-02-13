# Routing (auto_route)

This project uses `auto_route` + code generation to create strongly-typed routes (e.g. `HomeRoute`) from your router config.

## Where routes are defined

- Router config: `lib/app/router/app_router.dart`
- Generated routes: `lib/app/router/app_router.gr.dart` (generated file — do **not** edit)

`app_router.dart` contains:

- `@AutoRouterConfig()` on `AppRouter`
- A `routes` list that maps pages to routes
- `part 'app_router.gr.dart';` which links to the generated output

## Add a new route (new page)

### 1) Create a new page widget

Create a page file anywhere (recommended under a feature), for example:

- `lib/features/profile/presentation/pages/profile_page.dart`

Add `@RoutePage()` on the page widget:

```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Profile')),
    );
  }
}
```

### 2) Register it in the router

Open `lib/app/router/app_router.dart`:

1. Import the page:

```dart
import '../../features/profile/presentation/pages/profile_page.dart';
```

2. Add an `AutoRoute` entry in `routes`:

```dart
@override
List<AutoRoute> get routes => [
  // ...existing routes
  AutoRoute(page: ProfileRoute.page),
];
```

After generation, you’ll get:

- A generated route class named `ProfileRoute`
- A route `page` reference `ProfileRoute.page`

### 3) Navigate to the route

```dart
context.router.push(const ProfileRoute());
```

(You’ll need `import 'package:auto_route/auto_route.dart';` in the file that calls navigation.)

## Generate / regenerate routes

Whenever you add/remove/rename routes or pages, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Notes:

- You can also use `flutter pub run build_runner build --delete-conflicting-outputs` (older style).
- For continuous generation while developing:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Troubleshooting

- **"part 'app_router.gr.dart'" not found**: run the generator command above.
- **Route class not found** (e.g. `ProfileRoute`): make sure the page has `@RoutePage()` and is referenced in `routes`.
- **Stale generated files / conflicts**: keep `--delete-conflicting-outputs`.
- **Imports fail for `package:multi_lng_bloc/...`**: run `flutter pub get` to refresh `.dart_tool/package_config.json`.

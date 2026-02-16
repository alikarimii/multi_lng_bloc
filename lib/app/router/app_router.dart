import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:multi_lng_bloc/l10n/app_localizations.dart';

import '../di/injection.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/domain/repositories/auth_repo.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: SettingsRoute.page),
  ];
}

// Home page lives here; other pages are in `features/`.

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<bool> _isLoggedIn() async {
    final repo = getIt<AuthRepository>();
    final result = await repo.getCachedUser();
    return result.fold((_) => false, (user) => user != null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.pushRoute(const SettingsRoute()),
          ),
          FutureBuilder<bool>(
            future: _isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.data != true) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.person),
                onPressed: () => context.pushRoute(ProfileRoute()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 80),
            const SizedBox(height: 24),
            Text(
              l10n.brandName,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appSubtitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pushRoute(const LoginRoute()),
              child: Text(l10n.loginSlashRegister),
            ),
          ],
        ),
      ),
    );
  }
}

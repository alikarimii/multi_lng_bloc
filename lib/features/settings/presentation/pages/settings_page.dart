import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_lng_bloc/l10n/app_localizations.dart';

import '../cubit/locale_cubit.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          final current = state.locale;
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(
                  l10n.language,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _LocaleTile(
                title: l10n.systemDefault,
                selected: current == null,
                onTap: () => context.read<LocaleCubit>().changeLocale(null),
              ),
              _LocaleTile(
                title: l10n.english,
                selected: current == const Locale('en'),
                onTap: () => context.read<LocaleCubit>().changeLocale(
                  const Locale('en'),
                ),
              ),
              _LocaleTile(
                title: l10n.persian,
                selected: current == const Locale('fa'),
                onTap: () => context.read<LocaleCubit>().changeLocale(
                  const Locale('fa'),
                ),
              ),
              _LocaleTile(
                title: l10n.turkish,
                selected: current == const Locale('tr'),
                onTap: () => context.read<LocaleCubit>().changeLocale(
                  const Locale('tr'),
                ),
              ),
              _LocaleTile(
                title: l10n.arabic,
                selected: current == const Locale('ar'),
                onTap: () => context.read<LocaleCubit>().changeLocale(
                  const Locale('ar'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LocaleTile extends StatelessWidget {
  const _LocaleTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}

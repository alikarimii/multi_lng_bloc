import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_lng_bloc/l10n/app_localizations.dart';

import '../../../../app/di/injection.dart';
import '../../../../app/router/app_router.dart';
import '../../../auth/domain/entities/user.dart';
import '../bloc/profile_bloc.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  final String? userId;

  const ProfilePage({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()
        ..add(ProfileLoadRequested(userId: userId)),
      child: _ProfileView(userId: userId),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final String? userId;

  const _ProfileView({this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return Scaffold(
            appBar: AppBar(title: Text(_titleText(l10n))),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileError) {
          return Scaffold(
            appBar: AppBar(title: Text(_titleText(l10n))),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(
                              ProfileLoadRequested(userId: userId),
                            );
                      },
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final loaded = state as ProfileLoaded;
        return Scaffold(
          appBar: AppBar(title: Text(_titleText(l10n))),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(user: loaded.profileUser),
                  const SizedBox(height: 24),
                  Text(
                    l10n.usersTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _UsersList(
                      users: loaded.users,
                      currentUserId: loaded.profileUser.id,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _titleText(AppLocalizations l10n) {
    return userId == null ? l10n.profileTitleMy : l10n.profileTitle;
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final createdAt = MaterialLocalizations.of(context)
        .formatShortDate(user.createdAt.toLocal());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name?.isNotEmpty == true ? user.name! : l10n.unnamedUser,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(user.email),
            const SizedBox(height: 8),
            Text(l10n.joinedOn(createdAt)),
          ],
        ),
      ),
    );
  }
}

class _UsersList extends StatelessWidget {
  final List<User> users;
  final String currentUserId;

  const _UsersList({required this.users, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (users.isEmpty) {
      return Center(child: Text(l10n.noUsersFound));
    }

    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrent = user.id == currentUserId;
        return ListTile(
          leading: CircleAvatar(
            child: Text((user.name ?? user.email).characters.first),
          ),
          title: Text(user.name?.isNotEmpty == true ? user.name! : user.email),
          subtitle: Text(user.email),
          trailing: isCurrent
              ? const Icon(Icons.person, color: Colors.green)
              : const Icon(Icons.chevron_right),
          onTap: () {
            context.pushRoute(ProfileRoute(userId: user.id));
          },
        );
      },
    );
  }
}

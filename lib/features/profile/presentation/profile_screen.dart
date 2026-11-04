import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../auth/auth_providers.dart';
import '../../auth/domain/app_user.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppUser? user = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: 46,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                (user?.username.isNotEmpty ?? false)
                    ? user!.username.substring(0, 1).toUpperCase()
                    : '?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.username ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            user == null ? '' : l10n.signedInAs(user.username),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: Text(l10n.settings),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.password_rounded),
                  title: Text(l10n.changePasswordTitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/change-password'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                l10n.logout,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () async {
                await ref.read(authControllerProvider.notifier).signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}

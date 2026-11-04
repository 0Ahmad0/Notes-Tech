import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/app_settings.dart';
import '../settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppSettings settings =
        ref.watch(settingsControllerProvider).value ??
        const AppSettings();
    final SettingsController controller = ref.read(
      settingsControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: <Widget>[
          _SectionTitle(label: l10n.appearance),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                label: Text(l10n.themeLight),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                label: Text(l10n.themeDark),
              ),
            ],
            selected: <ThemeMode>{settings.themeMode},
            onSelectionChanged: (Set<ThemeMode> selection) {
              controller.setThemeMode(selection.first);
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(label: l10n.language),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'system',
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment<String>(value: 'en', label: Text(l10n.english)),
              ButtonSegment<String>(value: 'ar', label: Text(l10n.arabic)),
            ],
            selected: <String>{settings.locale?.languageCode ?? 'system'},
            onSelectionChanged: (Set<String> selection) {
              final String value = selection.first;
              controller.setLocale(value == 'system' ? null : Locale(value));
            },
          ),
          const SizedBox(height: 28),
          Text(
            l10n.splashTagline,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.titleMedium);
  }
}

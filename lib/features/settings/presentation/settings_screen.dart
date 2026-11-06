import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../reminders/reminders_providers.dart';
import '../domain/app_settings.dart';
import '../settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppSettings settings =
        ref.watch(settingsControllerProvider).value ?? const AppSettings();
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
          _SectionTitle(label: l10n.notesDisplay),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'grid',
                icon: const Icon(Icons.grid_view_rounded),
                label: Text(l10n.viewGrid),
              ),
              ButtonSegment<String>(
                value: 'list',
                icon: const Icon(Icons.view_agenda_outlined),
                label: Text(l10n.viewList),
              ),
            ],
            selected: <String>{settings.viewMode},
            onSelectionChanged: (Set<String> selection) {
              controller.setViewMode(selection.first);
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: settings.sortOrder,
            decoration: InputDecoration(
              labelText: l10n.sortBy,
              border: const OutlineInputBorder(),
            ),
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: 'updatedDesc',
                child: Text(l10n.sortUpdatedDesc),
              ),
              DropdownMenuItem<String>(
                value: 'updatedAsc',
                child: Text(l10n.sortUpdatedAsc),
              ),
              DropdownMenuItem<String>(
                value: 'createdDesc',
                child: Text(l10n.sortCreatedDesc),
              ),
              DropdownMenuItem<String>(
                value: 'titleAsc',
                child: Text(l10n.sortTitleAsc),
              ),
            ],
            onChanged: (String? value) {
              if (value != null) {
                controller.setSortOrder(value);
              }
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(label: l10n.font),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: <ButtonSegment<String>>[
              ButtonSegment<String>(
                value: 'system',
                label: Text(l10n.fontSystem),
              ),
              ButtonSegment<String>(
                value: 'plexArabic',
                label: Text(l10n.fontPlexArabic),
              ),
            ],
            selected: <String>{settings.fontPreset},
            onSelectionChanged: (Set<String> selection) {
              controller.setFontPreset(selection.first);
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(label: l10n.notifications),
          const SizedBox(height: 10),
          _NotificationStatus(
            enabled: ref.watch(notificationsEnabledProvider),
            onEnable: () async {
              final bool granted = await ref
                  .read(notificationServiceProvider)
                  .requestPermissions();
              ref.invalidate(notificationsEnabledProvider);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    granted ? l10n.notificationsOn : l10n.notificationsDisabled,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          _SectionTitle(label: l10n.privacy),
          const SizedBox(height: 10),
          Text(
            l10n.localOnlyNotice,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
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

class _NotificationStatus extends StatelessWidget {
  const _NotificationStatus({required this.enabled, required this.onEnable});

  final AsyncValue<bool> enabled;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isOn = enabled.value == true;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: enabled.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          : Icon(
              isOn
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
            ),
      title: Text(isOn ? l10n.notificationsOn : l10n.notificationsOff),
      trailing: isOn
          ? null
          : TextButton(
              onPressed: onEnable,
              child: Text(l10n.enableNotifications),
            ),
    );
  }
}

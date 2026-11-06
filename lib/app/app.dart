import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_providers.dart';
import '../features/auth/domain/app_user.dart';
import '../features/reminders/services/notification_service.dart';
import '../features/settings/domain/app_settings.dart';
import '../features/settings/settings_providers.dart';
import '../l10n/generated/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class NotesTechApp extends ConsumerStatefulWidget {
  const NotesTechApp({super.key});

  @override
  ConsumerState<NotesTechApp> createState() => _NotesTechAppState();
}

class _NotesTechAppState extends ConsumerState<NotesTechApp> {
  String? _pendingNoteId;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.onOpenNote = _handleNoteOpen;
    final String? launchNoteId = NotificationService.instance
        .takePendingNoteId();
    if (launchNoteId != null) {
      _handleNoteOpen(launchNoteId);
    }
  }

  @override
  void dispose() {
    NotificationService.instance.onOpenNote = null;
    super.dispose();
  }

  void _handleNoteOpen(String noteId) {
    _pendingNoteId = noteId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPendingNote());
  }

  void _openPendingNote() {
    final String? noteId = _pendingNoteId;
    if (!mounted || noteId == null) {
      return;
    }
    final AppUser? user = ref.read(authControllerProvider).value;
    if (user == null) {
      return;
    }
    _pendingNoteId = null;
    ref.read(routerProvider).go('/notes/$noteId');
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = ref.watch(routerProvider);
    final AppSettings settings =
        ref.watch(settingsControllerProvider).value ?? const AppSettings();

    ref.listen<AsyncValue<AppUser?>>(authControllerProvider, (_, next) {
      if (next.value != null && _pendingNoteId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _openPendingNote());
      }
    });

    return MaterialApp.router(
      title: 'Notes-Tech',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.light(fontFamily: settings.fontFamily),
      darkTheme: AppTheme.dark(fontFamily: settings.fontFamily),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_providers.dart';
import '../auth/domain/app_user.dart';
import 'data/settings_repository.dart';
import 'domain/app_settings.dart';

final Provider<SettingsRepository> settingsRepositoryProvider =
    Provider<SettingsRepository>(
      (Ref ref) => SettingsRepository(ref.watch(sharedPreferencesProvider)),
    );

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final AppUser? user = await ref.watch(authControllerProvider.future);
    return ref.watch(settingsRepositoryProvider).load(user?.id);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final AppSettings current = state.value ?? const AppSettings();
    state = AsyncData<AppSettings>(current.copyWith(themeMode: mode));
    await ref.read(settingsRepositoryProvider).saveThemeMode(_userId, mode);
  }

  Future<void> setLocale(Locale? locale) async {
    final AppSettings current = state.value ?? const AppSettings();
    state = AsyncData<AppSettings>(
      current.copyWith(locale: locale, replaceLocale: true),
    );
    await ref.read(settingsRepositoryProvider).saveLocale(_userId, locale);
  }

  String? get _userId => ref.read(authControllerProvider).value?.id;
}

final AsyncNotifierProvider<SettingsController, AppSettings>
settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );

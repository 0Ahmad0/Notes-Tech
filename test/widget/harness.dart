import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:task_ai1/app/theme/app_theme.dart';
import 'package:task_ai1/features/settings/domain/app_settings.dart';
import 'package:task_ai1/features/settings/settings_providers.dart';
import 'package:task_ai1/l10n/generated/app_localizations.dart';

Widget wrapApp(
  Widget child, {
  List<Override> overrides = const <Override>[],
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

final class FakeSettingsController extends SettingsController {
  FakeSettingsController(this.initial);

  final AppSettings initial;

  String? lastFontPreset;
  ThemeMode? lastThemeMode;
  String? lastViewMode;
  String? lastSortOrder;
  Locale? lastLocale;

  @override
  Future<AppSettings> build() async => initial;

  @override
  Future<void> setFontPreset(String fontPreset) async {
    lastFontPreset = fontPreset;
    state = AsyncData<AppSettings>(
      (state.value ?? initial).copyWith(fontPreset: fontPreset),
    );
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    lastThemeMode = mode;
    state = AsyncData<AppSettings>(
      (state.value ?? initial).copyWith(themeMode: mode),
    );
  }

  @override
  Future<void> setViewMode(String viewMode) async {
    lastViewMode = viewMode;
    state = AsyncData<AppSettings>(
      (state.value ?? initial).copyWith(viewMode: viewMode),
    );
  }

  @override
  Future<void> setSortOrder(String sortOrder) async {
    lastSortOrder = sortOrder;
    state = AsyncData<AppSettings>(
      (state.value ?? initial).copyWith(sortOrder: sortOrder),
    );
  }

  @override
  Future<void> setLocale(Locale? locale) async {
    lastLocale = locale;
    state = AsyncData<AppSettings>(
      (state.value ?? initial).copyWith(locale: locale, replaceLocale: true),
    );
  }
}

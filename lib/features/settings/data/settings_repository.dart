import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_settings.dart';

final class SettingsRepository {
  SettingsRepository(this._preferences);

  final SharedPreferencesAsync _preferences;

  Future<AppSettings> load(String? userId) async {
    if (userId == null) {
      return const AppSettings();
    }
    final String? themeMode = await _preferences.getString(
      _key(userId, 'themeMode'),
    );
    final String? locale = await _preferences.getString(_key(userId, 'locale'));
    final String? viewMode = await _preferences.getString(
      _key(userId, 'viewMode'),
    );
    final String? sortOrder = await _preferences.getString(
      _key(userId, 'sortOrder'),
    );
    return AppSettings(
      themeMode: _parseThemeMode(themeMode),
      locale: _parseLocale(locale),
      viewMode: viewMode ?? 'grid',
      sortOrder: sortOrder ?? 'updatedDesc',
    );
  }

  Future<void> saveThemeMode(String? userId, ThemeMode mode) async {
    if (userId == null) {
      return;
    }
    await _preferences.setString(_key(userId, 'themeMode'), mode.name);
  }

  Future<void> saveLocale(String? userId, Locale? locale) async {
    if (userId == null) {
      return;
    }
    await _preferences.setString(
      _key(userId, 'locale'),
      locale?.languageCode ?? 'system',
    );
  }

  Future<void> saveViewMode(String? userId, String viewMode) async {
    if (userId == null) {
      return;
    }
    await _preferences.setString(_key(userId, 'viewMode'), viewMode);
  }

  Future<void> saveSortOrder(String? userId, String sortOrder) async {
    if (userId == null) {
      return;
    }
    await _preferences.setString(_key(userId, 'sortOrder'), sortOrder);
  }

  String _key(String userId, String field) => 'settings.$userId.$field';

  ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Locale? _parseLocale(String? value) {
    return switch (value) {
      'en' => const Locale('en'),
      'ar' => const Locale('ar'),
      _ => null,
    };
  }
}

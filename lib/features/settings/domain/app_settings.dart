import 'package:flutter/material.dart';

final class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.viewMode = 'grid',
    this.sortOrder = 'updatedDesc',
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final String viewMode;
  final String sortOrder;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool replaceLocale = false,
    String? viewMode,
    String? sortOrder,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: replaceLocale ? locale : this.locale,
      viewMode: viewMode ?? this.viewMode,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

import 'package:flutter/material.dart';

final class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.viewMode = 'grid',
    this.sortOrder = 'updatedDesc',
    this.fontPreset = 'system',
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final String viewMode;
  final String sortOrder;
  final String fontPreset;

  String? get fontFamily {
    return switch (fontPreset) {
      'plexArabic' => 'IBMPlexSansArabic',
      _ => null,
    };
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    bool replaceLocale = false,
    String? viewMode,
    String? sortOrder,
    String? fontPreset,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: replaceLocale ? locale : this.locale,
      viewMode: viewMode ?? this.viewMode,
      sortOrder: sortOrder ?? this.sortOrder,
      fontPreset: fontPreset ?? this.fontPreset,
    );
  }
}

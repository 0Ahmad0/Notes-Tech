import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_ai1/features/settings/domain/app_settings.dart';

void main() {
  group('AppSettings fontFamily', () {
    test('uses the bundled Plex family for the Arabic preset', () {
      const AppSettings settings = AppSettings(fontPreset: 'plexArabic');
      expect(settings.fontFamily, 'IBMPlexSansArabic');
    });

    test('falls back to the platform font for system and unknown presets', () {
      const AppSettings system = AppSettings();
      const AppSettings unknown = AppSettings(fontPreset: 'unknown');
      expect(system.fontFamily, isNull);
      expect(unknown.fontFamily, isNull);
    });
  });

  group('AppSettings copyWith', () {
    test('keeps the locale unless replaceLocale is set', () {
      const AppSettings settings = AppSettings(locale: Locale('ar'));
      expect(
        settings.copyWith(themeMode: ThemeMode.dark).locale,
        const Locale('ar'),
      );
      expect(
        settings.copyWith(locale: null, replaceLocale: true).locale,
        isNull,
      );
    });

    test('updates string preferences independently', () {
      const AppSettings settings = AppSettings();
      final AppSettings updated = settings.copyWith(
        fontPreset: 'plexArabic',
        viewMode: 'list',
        sortOrder: 'titleAsc',
      );
      expect(updated.fontPreset, 'plexArabic');
      expect(updated.viewMode, 'list');
      expect(updated.sortOrder, 'titleAsc');
      expect(updated.themeMode, ThemeMode.system);
    });
  });
}

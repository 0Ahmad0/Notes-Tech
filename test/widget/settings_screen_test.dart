import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:task_ai1/features/reminders/reminders_providers.dart';
import 'package:task_ai1/features/settings/domain/app_settings.dart';
import 'package:task_ai1/features/settings/presentation/settings_screen.dart';
import 'package:task_ai1/features/settings/settings_providers.dart';

import 'harness.dart';

void main() {
  Future<void> useTallSurface(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('renders sections and persists display choices', (
    WidgetTester tester,
  ) async {
    await useTallSurface(tester);
    final FakeSettingsController controller = FakeSettingsController(
      const AppSettings(),
    );

    await tester.pumpWidget(
      wrapApp(
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => controller),
          notificationsEnabledProvider.overrideWith((Ref ref) => true),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Font'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Notifications are enabled.'), findsOneWidget);

    await tester.tap(find.text('IBM Plex Arabic'));
    await tester.pumpAndSettle();
    expect(controller.lastFontPreset, 'plexArabic');

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(controller.lastThemeMode, ThemeMode.dark);

    await tester.tap(find.text('العربية'));
    await tester.pumpAndSettle();
    expect(controller.lastLocale, const Locale('ar'));
  });

  testWidgets('offers to enable notifications when disabled', (
    WidgetTester tester,
  ) async {
    await useTallSurface(tester);
    final FakeSettingsController controller = FakeSettingsController(
      const AppSettings(),
    );

    await tester.pumpWidget(
      wrapApp(
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => controller),
          notificationsEnabledProvider.overrideWith((Ref ref) => false),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notifications are off.'), findsOneWidget);
    expect(find.text('Enable'), findsOneWidget);
  });

  testWidgets('meets accessibility guidelines', (WidgetTester tester) async {
    await useTallSurface(tester);
    final FakeSettingsController controller = FakeSettingsController(
      const AppSettings(),
    );

    await tester.pumpWidget(
      wrapApp(
        const SettingsScreen(),
        overrides: <Override>[
          settingsControllerProvider.overrideWith(() => controller),
          notificationsEnabledProvider.overrideWith((Ref ref) => true),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  });
}

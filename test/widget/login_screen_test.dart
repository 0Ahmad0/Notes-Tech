import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_ai1/features/auth/presentation/login_screen.dart';

import 'harness.dart';

void main() {
  testWidgets('requires a username and password', (WidgetTester tester) async {
    await tester.pumpWidget(wrapApp(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Required'), findsNWidgets(2));
  });

  testWidgets('rejects an invalid username', (WidgetTester tester) async {
    await tester.pumpWidget(wrapApp(const LoginScreen()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'ab');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid username.'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(wrapApp(const LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
  });
}

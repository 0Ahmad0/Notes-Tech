import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:task_ai1/core/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo renders the brand image', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: AppLogo())));

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
  });
}

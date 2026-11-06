import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_ai1/features/notes/domain/note.dart';
import 'package:task_ai1/features/notes/presentation/widgets/note_card.dart';

import 'harness.dart';

Note buildNote({
  String title = 'Groceries',
  String body = 'Milk and bread',
  bool isPinned = false,
}) {
  return Note(
    id: 'note-1',
    ownerId: 'user-1',
    type: NoteType.text,
    title: title,
    body: body,
    colorKey: 'default',
    isPinned: isPinned,
    isArchived: false,
    createdAtUtc: DateTime.utc(2026, 1, 1),
    updatedAtUtc: DateTime.utc(2026, 1, 2),
  );
}

Widget buildCard(
  Note note, {
  required VoidCallback onTap,
  required ValueChanged<NoteCardAction> onAction,
  bool compact = false,
}) {
  return wrapApp(
    Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          height: 240,
          child: NoteCard(
            note: note,
            onTap: onTap,
            onAction: onAction,
            compact: compact,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('shows the note title and preview and handles taps', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      buildCard(buildNote(), onTap: () => tapped = true, onAction: (_) {}),
    );
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Milk and bread'), findsOneWidget);
    expect(find.byIcon(Icons.push_pin_rounded), findsNothing);

    await tester.tap(find.text('Groceries'));
    expect(tapped, isTrue);
  });

  testWidgets('shows a pin indicator for pinned notes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildCard(buildNote(isPinned: true), onTap: () {}, onAction: (_) {}),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.push_pin_rounded), findsOneWidget);
  });

  testWidgets('reports menu actions', (WidgetTester tester) async {
    final List<NoteCardAction> actions = <NoteCardAction>[];

    await tester.pumpWidget(
      buildCard(buildNote(), onTap: () {}, onAction: actions.add),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(actions, <NoteCardAction>[NoteCardAction.delete]);
  });

  testWidgets('meets tap target and labeling guidelines', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      buildCard(buildNote(), onTap: () {}, onAction: (_) {}),
    );
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  });

  testWidgets('renders the compact list layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      buildCard(
        buildNote(body: 'Short preview'),
        onTap: () {},
        onAction: (_) {},
        compact: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Short preview'), findsOneWidget);
  });
}

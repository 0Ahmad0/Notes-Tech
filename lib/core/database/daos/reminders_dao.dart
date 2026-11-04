import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'reminders_dao.g.dart';

@DriftAccessor(tables: [Reminders])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Stream<List<ReminderRow>> watchForNote(String noteId) {
    final query = select(reminders)
      ..where((t) => t.noteId.equals(noteId))
      ..orderBy([(t) => OrderingTerm(expression: t.remindAtUtc)]);
    return query.watch();
  }

  Future<ReminderRow?> findForNote(String noteId) {
    return (select(
      reminders,
    )..where((t) => t.noteId.equals(noteId))).getSingleOrNull();
  }

  Future<void> upsertReminder(RemindersCompanion reminder) {
    return into(reminders).insertOnConflictUpdate(reminder);
  }

  Future<void> deleteForNote(String noteId) {
    return (delete(reminders)..where((t) => t.noteId.equals(noteId))).go();
  }
}

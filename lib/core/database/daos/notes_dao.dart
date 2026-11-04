import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<NoteRow>> watchActiveNotes(String ownerId) {
    final query = select(notes)
      ..where((t) => t.ownerId.equals(ownerId) & t.deletedAtUtc.isNull())
      ..orderBy([
        (t) => OrderingTerm(expression: t.isPinned, mode: OrderingMode.desc),
        (t) =>
            OrderingTerm(expression: t.updatedAtUtc, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Stream<List<NoteRow>> watchTrash(String ownerId) {
    final query = select(notes)
      ..where((t) => t.ownerId.equals(ownerId) & t.deletedAtUtc.isNotNull())
      ..orderBy([
        (t) =>
            OrderingTerm(expression: t.deletedAtUtc, mode: OrderingMode.desc),
      ]);
    return query.watch();
  }

  Future<NoteRow?> findById(String id) {
    return (select(notes)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertNote(NotesCompanion note) {
    return into(notes).insert(note);
  }

  Future<void> updateNote(String id, NotesCompanion note) {
    return (update(notes)..where((t) => t.id.equals(id))).write(note);
  }

  Future<void> softDelete(String id) {
    return (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        deletedAtUtc: Value<DateTime>(DateTime.now().toUtc()),
        updatedAtUtc: Value<DateTime>(DateTime.now().toUtc()),
        syncState: const Value<String>('pending'),
      ),
    );
  }

  Future<void> restore(String id) {
    return (update(notes)..where((t) => t.id.equals(id))).write(
      NotesCompanion(
        deletedAtUtc: const Value<DateTime?>(null),
        updatedAtUtc: Value<DateTime>(DateTime.now().toUtc()),
        syncState: const Value<String>('pending'),
      ),
    );
  }

  Future<int> deleteForever(String id) {
    return (delete(notes)..where((t) => t.id.equals(id))).go();
  }
}

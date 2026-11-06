import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/note.dart';
import '../domain/note_query.dart';
import '../domain/notes_repository.dart';

final class LocalNotesRepository implements NotesRepository {
  LocalNotesRepository(this._database);

  final AppDatabase _database;
  final Uuid _uuid = const Uuid();

  @override
  Stream<List<Note>> watchNotes({
    required String ownerId,
    required NoteFilter filter,
    required String search,
    required NoteSort sort,
  }) {
    final String needle = search.trim().toLowerCase();
    return _database.notesDao.watchActiveNotes(ownerId).map((
      List<NoteRow> rows,
    ) {
      final List<Note> notes = rows
          .where((NoteRow row) => !row.isArchived)
          .map(_toNote)
          .where((Note note) => filter.matches(note.type))
          .where((Note note) {
            if (needle.isEmpty) {
              return true;
            }
            return note.title.toLowerCase().contains(needle) ||
                note.body.toLowerCase().contains(needle);
          })
          .toList();
      notes.sort((Note a, Note b) => _compare(a, b, sort));
      return notes;
    });
  }

  @override
  Stream<List<Note>> watchTrash(String ownerId) {
    return _database.notesDao
        .watchTrash(ownerId)
        .map((List<NoteRow> rows) => rows.map(_toNote).toList());
  }

  @override
  Future<Note?> findById({required String ownerId, required String id}) async {
    final NoteRow? row = await _database.notesDao.findById(ownerId, id);
    return row == null ? null : _toNote(row);
  }

  @override
  Future<Note> create({
    required String ownerId,
    required NoteType type,
    required String title,
    required String body,
    required String colorKey,
  }) async {
    final DateTime now = DateTime.now().toUtc();
    final Note note = Note(
      id: _uuid.v4(),
      ownerId: ownerId,
      type: type,
      title: title.trim(),
      body: body,
      colorKey: colorKey,
      isPinned: false,
      isArchived: false,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    await _database.notesDao.insertNote(
      NotesCompanion.insert(
        id: note.id,
        ownerId: ownerId,
        type: Value<String>(note.type.name),
        title: Value<String>(note.title),
        body: Value<String>(note.body),
        colorKey: Value<String>(note.colorKey),
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
    return note;
  }

  @override
  Future<Note> update(Note note) async {
    final DateTime now = DateTime.now().toUtc();
    final Note updated = Note(
      id: note.id,
      ownerId: note.ownerId,
      type: note.type,
      title: note.title.trim(),
      body: note.body,
      colorKey: note.colorKey,
      isPinned: note.isPinned,
      isArchived: note.isArchived,
      createdAtUtc: note.createdAtUtc,
      updatedAtUtc: now,
      deletedAtUtc: note.deletedAtUtc,
    );
    await _database.notesDao.updateNote(
      note.ownerId,
      note.id,
      NotesCompanion(
        type: Value<String>(updated.type.name),
        title: Value<String>(updated.title),
        body: Value<String>(updated.body),
        colorKey: Value<String>(updated.colorKey),
        isPinned: Value<bool>(updated.isPinned),
        isArchived: Value<bool>(updated.isArchived),
        updatedAtUtc: Value<DateTime>(now),
      ),
    );
    return updated;
  }

  @override
  Future<void> moveToTrash(Note note) =>
      _database.notesDao.softDelete(note.ownerId, note.id);

  @override
  Future<void> restore(Note note) =>
      _database.notesDao.restore(note.ownerId, note.id);

  @override
  Future<void> deleteForever(Note note) =>
      _database.notesDao.deleteForever(note.ownerId, note.id);

  int _compare(Note a, Note b, NoteSort sort) {
    if (a.isPinned != b.isPinned) {
      return a.isPinned ? -1 : 1;
    }
    return switch (sort) {
      NoteSort.updatedDesc => b.updatedAtUtc.compareTo(a.updatedAtUtc),
      NoteSort.updatedAsc => a.updatedAtUtc.compareTo(b.updatedAtUtc),
      NoteSort.createdDesc => b.createdAtUtc.compareTo(a.createdAtUtc),
      NoteSort.titleAsc => _title(a).compareTo(_title(b)),
    };
  }

  String _title(Note note) {
    final String title = note.title.trim();
    return (title.isEmpty ? note.body.trim() : title).toLowerCase();
  }

  Note _toNote(NoteRow row) {
    return Note(
      id: row.id,
      ownerId: row.ownerId,
      type: NoteType.fromValue(row.type),
      title: row.title,
      body: row.body,
      colorKey: row.colorKey,
      isPinned: row.isPinned,
      isArchived: row.isArchived,
      createdAtUtc: row.createdAtUtc,
      updatedAtUtc: row.updatedAtUtc,
      deletedAtUtc: row.deletedAtUtc,
    );
  }
}

import 'note.dart';
import 'note_query.dart';

abstract interface class NotesRepository {
  Stream<List<Note>> watchNotes({
    required String ownerId,
    required NoteFilter filter,
    required String search,
    required NoteSort sort,
  });

  Stream<List<Note>> watchTrash(String ownerId);

  Future<Note?> findById(String id);

  Future<Note> create({
    required String ownerId,
    required NoteType type,
    required String title,
    required String body,
    required String colorKey,
  });

  Future<Note> update(Note note);

  Future<void> moveToTrash(String id);

  Future<void> restore(String id);

  Future<void> deleteForever(String id);
}

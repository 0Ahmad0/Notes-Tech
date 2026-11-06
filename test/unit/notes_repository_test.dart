import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_ai1/core/database/app_database.dart';
import 'package:task_ai1/features/notes/data/local_notes_repository.dart';
import 'package:task_ai1/features/notes/domain/note.dart';
import 'package:task_ai1/features/notes/domain/note_query.dart';

void main() {
  late AppDatabase db;
  late LocalNotesRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalNotesRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> createUser(String username) async {
    final DateTime now = DateTime.now().toUtc();
    final String id = 'user-$username';
    await db.usersDao.insertUser(
      UsersCompanion.insert(
        id: id,
        usernameNormalized: username,
        usernameDisplay: username,
        passwordHash: 'hash',
        salt: 'salt',
        hashParams: 'params',
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );
    return id;
  }

  Future<List<Note>> watchNotes(
    String ownerId, {
    NoteFilter filter = NoteFilter.all,
    String search = '',
    NoteSort sort = NoteSort.updatedDesc,
  }) {
    return repository
        .watchNotes(
          ownerId: ownerId,
          filter: filter,
          search: search,
          sort: sort,
        )
        .first;
  }

  test('creates a note and lists it for its owner', () async {
    final String ownerId = await createUser('owner');

    final Note created = await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: '  Shopping  ',
      body: 'Milk and bread',
      colorKey: 'default',
    );

    final List<Note> notes = await watchNotes(ownerId);

    expect(notes, hasLength(1));
    expect(notes.single.id, created.id);
    expect(notes.single.title, 'Shopping');
    expect(notes.single.body, 'Milk and bread');
  });

  test('keeps notes isolated per owner', () async {
    final String first = await createUser('first');
    final String second = await createUser('second');

    await repository.create(
      ownerId: first,
      type: NoteType.text,
      title: 'Private',
      body: '',
      colorKey: 'default',
    );

    expect(await watchNotes(first), hasLength(1));
    expect(await watchNotes(second), isEmpty);
  });

  test('cannot read a note through another owner id', () async {
    final String first = await createUser('first');
    final String second = await createUser('second');

    final Note note = await repository.create(
      ownerId: first,
      type: NoteType.text,
      title: 'Private',
      body: '',
      colorKey: 'default',
    );

    expect(await repository.findById(ownerId: first, id: note.id), isNotNull);
    expect(await repository.findById(ownerId: second, id: note.id), isNull);
  });

  test('searches title and body case-insensitively', () async {
    final String ownerId = await createUser('searcher');

    await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Grocery list',
      body: '',
      colorKey: 'default',
    );
    await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Ideas',
      body: 'Buy a GROCERY bag',
      colorKey: 'default',
    );
    await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Unrelated',
      body: 'Nothing here',
      colorKey: 'default',
    );

    final List<Note> matches = await watchNotes(ownerId, search: 'grocery');

    expect(matches, hasLength(2));
    expect(
      matches.map((Note note) => note.title),
      containsAll(<String>['Grocery list', 'Ideas']),
    );
  });

  test('filters notes by type', () async {
    final String ownerId = await createUser('filter');

    for (final NoteType type in NoteType.values) {
      await repository.create(
        ownerId: ownerId,
        type: type,
        title: type.name,
        body: '',
        colorKey: 'default',
      );
    }

    final List<Note> audio = await watchNotes(
      ownerId,
      filter: NoteFilter.audio,
    );

    expect(audio, hasLength(1));
    expect(audio.single.type, NoteType.audio);
    expect(await watchNotes(ownerId), hasLength(NoteType.values.length));
  });

  test('sorts by title ascending', () async {
    final String ownerId = await createUser('sorter');

    for (final String title in <String>['Bravo', 'alpha', 'Charlie']) {
      await repository.create(
        ownerId: ownerId,
        type: NoteType.text,
        title: title,
        body: '',
        colorKey: 'default',
      );
    }

    final List<Note> sorted = await watchNotes(
      ownerId,
      sort: NoteSort.titleAsc,
    );

    expect(sorted.map((Note note) => note.title), <String>[
      'alpha',
      'Bravo',
      'Charlie',
    ]);
  });

  test('pinned notes come first regardless of sort order', () async {
    final String ownerId = await createUser('pinner');

    final Note older = await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Older',
      body: '',
      colorKey: 'default',
    );
    final Note newer = await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Newer',
      body: '',
      colorKey: 'default',
    );

    await repository.update(newer.copyWith(isPinned: true));

    final List<Note> sorted = await watchNotes(
      ownerId,
      sort: NoteSort.updatedAsc,
    );

    expect(sorted.map((Note note) => note.id), <String>[newer.id, older.id]);
  });

  test('hides archived notes from the active list', () async {
    final String ownerId = await createUser('archiver');

    final Note note = await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Archived',
      body: '',
      colorKey: 'default',
    );
    await repository.update(note.copyWith(isArchived: true));

    expect(await watchNotes(ownerId), isEmpty);
  });

  test('moves notes to trash and restores them', () async {
    final String ownerId = await createUser('trash');

    final Note note = await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Temporary',
      body: '',
      colorKey: 'default',
    );

    await repository.moveToTrash(note);

    expect(await watchNotes(ownerId), isEmpty);
    final List<Note> trash = await repository.watchTrash(ownerId).first;
    expect(trash, hasLength(1));
    expect(trash.single.id, note.id);
    expect(trash.single.isDeleted, isTrue);

    await repository.restore(note);

    final List<Note> restored = await watchNotes(ownerId);
    expect(restored, hasLength(1));
    expect(restored.single.isDeleted, isFalse);
    expect(await repository.watchTrash(ownerId).first, isEmpty);
  });

  test('permanently deletes a note and cascades attachments', () async {
    final String ownerId = await createUser('deleter');

    final Note note = await repository.create(
      ownerId: ownerId,
      type: NoteType.image,
      title: 'Photo',
      body: '',
      colorKey: 'default',
    );
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'attachment-1',
            noteId: note.id,
            kind: 'image',
            mimeType: 'image/png',
            originalName: 'photo.png',
            relativeLocalPath: 'media/photo.png',
            byteSize: const Value<int>(42),
          ),
        );

    await repository.deleteForever(note);

    expect(await repository.findById(ownerId: ownerId, id: note.id), isNull);
    final List<AttachmentRow> attachments = await db
        .select(db.attachments)
        .get();
    expect(attachments, isEmpty);
  });

  test('update trims the title and refreshes updatedAtUtc', () async {
    final String ownerId = await createUser('updater');

    final Note note = await repository.create(
      ownerId: ownerId,
      type: NoteType.text,
      title: 'Original',
      body: 'Body',
      colorKey: 'default',
    );

    final Note updated = await repository.update(
      note.copyWith(title: '  Revised  '),
    );

    expect(updated.title, 'Revised');

    final Note? stored = await repository.findById(
      ownerId: ownerId,
      id: note.id,
    );
    expect(stored, isNotNull);
    expect(stored!.title, 'Revised');
    final int createdSecond =
        note.createdAtUtc.millisecondsSinceEpoch ~/ 1000 * 1000;
    expect(
      stored.updatedAtUtc.millisecondsSinceEpoch,
      greaterThanOrEqualTo(createdSecond),
    );
  });
}

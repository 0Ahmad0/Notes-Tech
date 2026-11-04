import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../auth/auth_providers.dart';
import '../auth/domain/app_user.dart';
import '../settings/domain/app_settings.dart';
import '../settings/settings_providers.dart';
import 'data/local_media_repository.dart';
import 'data/local_notes_repository.dart';
import 'domain/media_repository.dart';
import 'domain/note.dart';
import 'domain/note_attachment.dart';
import 'domain/note_query.dart';
import 'domain/notes_repository.dart';

final Provider<NotesRepository> notesRepositoryProvider =
    Provider<NotesRepository>(
      (Ref ref) => LocalNotesRepository(ref.watch(appDatabaseProvider)),
    );

final Provider<MediaRepository> mediaRepositoryProvider =
    Provider<MediaRepository>(
      (Ref ref) => LocalMediaRepository(ref.watch(appDatabaseProvider)),
    );

final attachmentsProvider = StreamProvider.family<List<NoteAttachment>, String>(
  (Ref ref, String noteId) {
    return ref.watch(mediaRepositoryProvider).watchForNote(noteId);
  },
);

final attachmentFileProvider = FutureProvider.family<File, NoteAttachment>((
  Ref ref,
  NoteAttachment attachment,
) {
  return ref.watch(mediaRepositoryProvider).fileFor(attachment);
});

class NoteQueryController extends Notifier<NoteQuery> {
  @override
  NoteQuery build() => const NoteQuery();

  void setFilter(NoteFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSearch(String search) {
    state = state.copyWith(search: search);
  }
}

final NotifierProvider<NoteQueryController, NoteQuery> noteQueryProvider =
    NotifierProvider<NoteQueryController, NoteQuery>(NoteQueryController.new);

final StreamProvider<List<Note>> notesProvider = StreamProvider<List<Note>>((
  Ref ref,
) {
  final AppUser? user = ref.watch(authControllerProvider).value;
  if (user == null) {
    return Stream<List<Note>>.value(const <Note>[]);
  }
  final NoteQuery query = ref.watch(noteQueryProvider);
  final AppSettings settings =
      ref.watch(settingsControllerProvider).value ?? const AppSettings();
  return ref
      .watch(notesRepositoryProvider)
      .watchNotes(
        ownerId: user.id,
        filter: query.filter,
        search: query.search,
        sort: NoteSort.fromValue(settings.sortOrder),
      );
});

final StreamProvider<List<Note>> trashProvider = StreamProvider<List<Note>>((
  Ref ref,
) {
  final AppUser? user = ref.watch(authControllerProvider).value;
  if (user == null) {
    return Stream<List<Note>>.value(const <Note>[]);
  }
  return ref.watch(notesRepositoryProvider).watchTrash(user.id);
});

final noteByIdProvider = FutureProvider.family<Note?, String>((
  Ref ref,
  String id,
) {
  return ref.watch(notesRepositoryProvider).findById(id);
});

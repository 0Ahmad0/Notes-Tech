import 'dart:io';

import 'note_attachment.dart';

enum MediaFailureReason { tooLarge, sourceMissing, copyFailed }

final class MediaFailure implements Exception {
  const MediaFailure(this.reason);

  final MediaFailureReason reason;

  @override
  String toString() => 'MediaFailure(${reason.name})';
}

abstract interface class MediaRepository {
  Stream<List<NoteAttachment>> watchForNote(String noteId);

  Future<List<NoteAttachment>> listForNote(String noteId);

  Future<NoteAttachment> attach({
    required String noteId,
    required AttachmentKind kind,
    required String sourcePath,
    required String originalName,
    String? mimeType,
    int? durationMs,
  });

  Future<void> remove(NoteAttachment attachment);

  Future<void> deleteAllForNote(String noteId);

  Future<File> fileFor(NoteAttachment attachment);

  Future<bool> exists(NoteAttachment attachment);
}

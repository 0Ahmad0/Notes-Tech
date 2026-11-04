import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/media_repository.dart';
import '../domain/note_attachment.dart';

final class LocalMediaRepository implements MediaRepository {
  LocalMediaRepository(this._database);

  final AppDatabase _database;
  final Uuid _uuid = const Uuid();
  Future<Directory>? _documents;

  @override
  Stream<List<NoteAttachment>> watchForNote(String noteId) {
    final query = _database.select(_database.attachments)
      ..where((t) => t.noteId.equals(noteId) & t.deletedAtUtc.isNull())
      ..orderBy([(t) => OrderingTerm(expression: t.originalName)]);
    return query.watch().map(
      (List<AttachmentRow> rows) => rows.map(_toAttachment).toList(),
    );
  }

  @override
  Future<List<NoteAttachment>> listForNote(String noteId) async {
    final List<AttachmentRow> rows =
        await (_database.select(_database.attachments)
              ..where((t) => t.noteId.equals(noteId) & t.deletedAtUtc.isNull())
              ..orderBy([(t) => OrderingTerm(expression: t.originalName)]))
            .get();
    return rows.map(_toAttachment).toList();
  }

  @override
  Future<NoteAttachment> attach({
    required String noteId,
    required AttachmentKind kind,
    required String sourcePath,
    required String originalName,
    String? mimeType,
    int? durationMs,
  }) async {
    final File source = File(sourcePath);
    if (!source.existsSync()) {
      throw const MediaFailure(MediaFailureReason.sourceMissing);
    }
    final int byteSize = source.lengthSync();
    if (byteSize > maxAttachmentBytes(kind)) {
      throw const MediaFailure(MediaFailureReason.tooLarge);
    }

    final Directory documents = await _documentsDirectory();
    final String extension = _extensionFor(originalName, kind);
    final String relativePath = 'media/$noteId/${_uuid.v4()}$extension';
    final File destination = File('${documents.path}/$relativePath');
    final Directory parent = destination.parent;
    if (!parent.existsSync()) {
      await parent.create(recursive: true);
    }

    try {
      await source.copy(destination.path);
    } on FileSystemException {
      throw const MediaFailure(MediaFailureReason.copyFailed);
    }

    final NoteAttachment attachment = NoteAttachment(
      id: _uuid.v4(),
      noteId: noteId,
      kind: kind,
      mimeType: mimeType ?? _mimeFor(extension, kind),
      originalName: originalName,
      relativeLocalPath: relativePath,
      byteSize: byteSize,
      durationMs: durationMs,
    );

    try {
      await _database
          .into(_database.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: attachment.id,
              noteId: noteId,
              kind: kind.name,
              mimeType: attachment.mimeType,
              originalName: originalName,
              relativeLocalPath: relativePath,
              byteSize: Value<int>(byteSize),
              durationMs: Value<int?>(durationMs),
            ),
          );
    } catch (_) {
      if (destination.existsSync()) {
        await destination.delete();
      }
      rethrow;
    }
    return attachment;
  }

  @override
  Future<void> remove(NoteAttachment attachment) async {
    await (_database.update(
      _database.attachments,
    )..where((t) => t.id.equals(attachment.id))).write(
      AttachmentsCompanion(
        deletedAtUtc: Value<DateTime>(DateTime.now().toUtc()),
      ),
    );
    await _deleteFileQuietly(attachment);
  }

  @override
  Future<void> deleteAllForNote(String noteId) async {
    final List<AttachmentRow> rows = await (_database.select(
      _database.attachments,
    )..where((t) => t.noteId.equals(noteId))).get();
    for (final AttachmentRow row in rows) {
      await _deleteFileQuietly(_toAttachment(row));
    }
    await (_database.delete(
      _database.attachments,
    )..where((t) => t.noteId.equals(noteId))).go();
  }

  @override
  Future<File> fileFor(NoteAttachment attachment) async {
    final Directory documents = await _documentsDirectory();
    return File('${documents.path}/${attachment.relativeLocalPath}');
  }

  @override
  Future<bool> exists(NoteAttachment attachment) async {
    final File file = await fileFor(attachment);
    return file.existsSync();
  }

  Future<Directory> _documentsDirectory() {
    return _documents ??= getApplicationDocumentsDirectory();
  }

  Future<void> _deleteFileQuietly(NoteAttachment attachment) async {
    try {
      final File file = await fileFor(attachment);
      if (file.existsSync()) {
        await file.delete();
      }
    } on FileSystemException {
      // The metadata can still be removed when the file is already gone.
    }
  }

  String _extensionFor(String name, AttachmentKind kind) {
    final int index = name.lastIndexOf('.');
    if (index > 0 && index < name.length - 1 && name.length - index <= 9) {
      final String extension = name.substring(index).toLowerCase();
      if (RegExp(r'^\.[a-z0-9]+$').hasMatch(extension)) {
        return extension;
      }
    }
    return switch (kind) {
      AttachmentKind.audio => '.m4a',
      AttachmentKind.image => '.jpg',
      AttachmentKind.file => '.bin',
    };
  }

  String _mimeFor(String extension, AttachmentKind kind) {
    return switch (extension) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.png' => 'image/png',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      '.heic' || '.heif' => 'image/heic',
      '.m4a' => 'audio/mp4',
      '.mp3' => 'audio/mpeg',
      '.aac' => 'audio/aac',
      '.wav' => 'audio/wav',
      '.ogg' || '.opus' => 'audio/ogg',
      '.pdf' => 'application/pdf',
      '.txt' => 'text/plain',
      '.md' => 'text/markdown',
      '.json' => 'application/json',
      _ => switch (kind) {
        AttachmentKind.audio => 'audio/mp4',
        AttachmentKind.image => 'image/jpeg',
        AttachmentKind.file => 'application/octet-stream',
      },
    };
  }

  NoteAttachment _toAttachment(AttachmentRow row) {
    return NoteAttachment(
      id: row.id,
      noteId: row.noteId,
      kind: AttachmentKind.fromValue(row.kind),
      mimeType: row.mimeType,
      originalName: row.originalName,
      relativeLocalPath: row.relativeLocalPath,
      byteSize: row.byteSize,
      durationMs: row.durationMs,
      deletedAtUtc: row.deletedAtUtc,
    );
  }
}

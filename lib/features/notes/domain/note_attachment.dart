enum AttachmentKind {
  audio,
  image,
  file;

  static AttachmentKind fromValue(String? value) {
    return AttachmentKind.values.firstWhere(
      (AttachmentKind kind) => kind.name == value,
      orElse: () => AttachmentKind.file,
    );
  }
}

int maxAttachmentBytes(AttachmentKind kind) {
  return switch (kind) {
    AttachmentKind.image => 20 * 1024 * 1024,
    AttachmentKind.audio => 50 * 1024 * 1024,
    AttachmentKind.file => 25 * 1024 * 1024,
  };
}

final class NoteAttachment {
  const NoteAttachment({
    required this.id,
    required this.noteId,
    required this.kind,
    required this.mimeType,
    required this.originalName,
    required this.relativeLocalPath,
    required this.byteSize,
    this.durationMs,
    this.deletedAtUtc,
  });

  final String id;
  final String noteId;
  final AttachmentKind kind;
  final String mimeType;
  final String originalName;
  final String relativeLocalPath;
  final int byteSize;
  final int? durationMs;
  final DateTime? deletedAtUtc;

  Duration? get duration {
    final int? value = durationMs;
    return value == null ? null : Duration(milliseconds: value);
  }

  String get formattedSize {
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    double value = byteSize.toDouble();
    int unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final String number = unit == 0
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '$number ${units[unit]}';
  }
}

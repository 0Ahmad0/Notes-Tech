enum NoteType {
  text,
  audio,
  image,
  file;

  static NoteType fromValue(String? value) {
    return NoteType.values.firstWhere(
      (NoteType type) => type.name == value,
      orElse: () => NoteType.text,
    );
  }
}

final class Note {
  const Note({
    required this.id,
    required this.ownerId,
    required this.type,
    required this.title,
    required this.body,
    required this.colorKey,
    required this.isPinned,
    required this.isArchived,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    required this.revision,
    this.deletedAtUtc,
  });

  final String id;
  final String ownerId;
  final NoteType type;
  final String title;
  final String body;
  final String colorKey;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;
  final DateTime? deletedAtUtc;
  final int revision;

  bool get isDeleted => deletedAtUtc != null;

  bool get isEmpty => title.trim().isEmpty && body.trim().isEmpty;

  Note copyWith({
    NoteType? type,
    String? title,
    String? body,
    String? colorKey,
    bool? isPinned,
    bool? isArchived,
  }) {
    return Note(
      id: id,
      ownerId: ownerId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      colorKey: colorKey ?? this.colorKey,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc,
      deletedAtUtc: deletedAtUtc,
      revision: revision,
    );
  }
}

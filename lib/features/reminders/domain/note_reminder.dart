final class NoteReminder {
  const NoteReminder({
    required this.id,
    required this.noteId,
    required this.ownerId,
    required this.remindAtUtc,
    required this.timezoneId,
    required this.enabled,
    required this.notificationId,
    this.deliveredAtUtc,
  });

  final String id;
  final String noteId;
  final String ownerId;
  final DateTime remindAtUtc;
  final String timezoneId;
  final bool enabled;
  final int notificationId;
  final DateTime? deliveredAtUtc;
}

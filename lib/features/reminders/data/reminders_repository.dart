import 'dart:math';

import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/app_logger.dart';
import '../../notes/domain/note.dart';
import '../domain/note_reminder.dart';
import '../services/notification_service.dart';

enum ReminderFailureReason { permissionDenied, scheduleFailed }

final class ReminderFailure implements Exception {
  const ReminderFailure(this.reason);

  final ReminderFailureReason reason;

  @override
  String toString() => 'ReminderFailure(${reason.name})';
}

final class RemindersRepository {
  RemindersRepository(this._database, this._notifications);

  static const AppLogger _logger = AppLogger('Reminders');

  final AppDatabase _database;
  final NotificationService _notifications;
  final Uuid _uuid = const Uuid();
  final Random _random = Random.secure();

  Stream<NoteReminder?> watchForNote(String noteId) {
    return _database.remindersDao.watchForNote(noteId).map((
      List<ReminderRow> rows,
    ) {
      return rows.isEmpty ? null : _toReminder(rows.first);
    });
  }

  Future<NoteReminder?> findForNote(String noteId) async {
    final ReminderRow? row = await _database.remindersDao.findForNote(noteId);
    return row == null ? null : _toReminder(row);
  }

  Future<NoteReminder> schedule({
    required Note note,
    required DateTime remindAtUtc,
    required String title,
    required String body,
  }) async {
    final bool permitted = await _notifications.requestPermissions();
    if (!permitted) {
      throw const ReminderFailure(ReminderFailureReason.permissionDenied);
    }

    final NoteReminder? existing = await findForNote(note.id);
    final int notificationId =
        existing?.notificationId ?? _random.nextInt(0x7fffffff);
    if (existing != null) {
      await _notifications.cancel(existing.notificationId);
    }

    try {
      await _notifications.schedule(
        id: notificationId,
        title: title,
        body: body,
        whenUtc: remindAtUtc,
        payload: note.id,
      );
    } catch (error, stack) {
      _logger.error('Failed to schedule reminder', error, stack);
      throw const ReminderFailure(ReminderFailureReason.scheduleFailed);
    }

    final NoteReminder reminder = NoteReminder(
      id: existing?.id ?? _uuid.v4(),
      noteId: note.id,
      ownerId: note.ownerId,
      remindAtUtc: remindAtUtc,
      timezoneId: tz.local.name,
      enabled: true,
      notificationId: notificationId,
    );

    try {
      await _database.remindersDao.upsertReminder(
        RemindersCompanion.insert(
          id: reminder.id,
          noteId: reminder.noteId,
          ownerId: reminder.ownerId,
          remindAtUtc: remindAtUtc,
          timezoneId: reminder.timezoneId,
          notificationId: notificationId,
          lastScheduledAtUtc: Value<DateTime>(DateTime.now().toUtc()),
        ),
      );
    } catch (error, stack) {
      _logger.error('Failed to persist reminder', error, stack);
      await _notifications.cancel(notificationId);
      throw const ReminderFailure(ReminderFailureReason.scheduleFailed);
    }
    return reminder;
  }

  Future<void> cancelForNote(String noteId) async {
    final NoteReminder? reminder = await findForNote(noteId);
    if (reminder == null) {
      return;
    }
    await _notifications.cancel(reminder.notificationId);
    await _database.remindersDao.deleteForNote(noteId);
  }

  NoteReminder _toReminder(ReminderRow row) {
    return NoteReminder(
      id: row.id,
      noteId: row.noteId,
      ownerId: row.ownerId,
      remindAtUtc: row.remindAtUtc,
      timezoneId: row.timezoneId,
      enabled: row.enabled,
      notificationId: row.notificationId,
      deliveredAtUtc: row.deliveredAtUtc,
    );
  }
}

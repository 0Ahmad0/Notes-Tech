import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'data/reminders_repository.dart';
import 'domain/note_reminder.dart';
import 'services/notification_service.dart';

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((Ref ref) => NotificationService.instance);

final Provider<RemindersRepository> remindersRepositoryProvider =
    Provider<RemindersRepository>(
      (Ref ref) => RemindersRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(notificationServiceProvider),
      ),
    );

final FutureProvider<bool> notificationsEnabledProvider = FutureProvider<bool>(
  (Ref ref) => ref.watch(notificationServiceProvider).areNotificationsEnabled(),
);

final reminderProvider = StreamProvider.family<NoteReminder?, String>((
  Ref ref,
  String noteId,
) {
  return ref.watch(remindersRepositoryProvider).watchForNote(noteId);
});

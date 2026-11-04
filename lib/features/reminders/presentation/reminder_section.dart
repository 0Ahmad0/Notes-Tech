import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../notes/domain/note.dart';
import '../data/reminders_repository.dart';
import '../domain/note_reminder.dart';
import '../reminders_providers.dart';

class ReminderSection extends ConsumerStatefulWidget {
  const ReminderSection({required this.note, super.key});

  final Note note;

  @override
  ConsumerState<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends ConsumerState<ReminderSection> {
  bool _busy = false;

  String _format(BuildContext context, DateTime utc) {
    final DateTime local = utc.toLocal();
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    final String date = localizations.formatFullDate(local);
    final String time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    return '$date · $time';
  }

  Future<void> _add() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime now = DateTime.now();
    final DateTime initial = now.add(const Duration(hours: 1));
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) {
      return;
    }
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) {
      return;
    }

    final DateTime selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!selected.isAfter(now)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reminderInPast)));
      return;
    }

    setState(() => _busy = true);
    try {
      final String title = widget.note.title.trim().isEmpty
          ? l10n.untitledNote
          : widget.note.title.trim();
      final NoteReminder reminder = await ref
          .read(remindersRepositoryProvider)
          .schedule(
            note: widget.note,
            remindAtUtc: selected.toUtc(),
            title: title,
            body: l10n.reminderNotificationBody,
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.reminderSet(_format(context, reminder.remindAtUtc)),
          ),
        ),
      );
    } on ReminderFailure catch (failure) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure.reason == ReminderFailureReason.permissionDenied
                ? l10n.notificationsDisabled
                : l10n.reminderFailed,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reminderFailed)));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    try {
      await ref.read(remindersRepositoryProvider).cancelForNote(widget.note.id);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final AsyncValue<NoteReminder?> reminder = ref.watch(
      reminderProvider(widget.note.id),
    );

    return reminder.when(
      loading: () => const SizedBox(
        height: 44,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (Object error, StackTrace stack) => _addButton(l10n),
      data: (NoteReminder? value) {
        if (value == null) {
          return _addButton(l10n);
        }
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.alarm_rounded),
            title: Text(l10n.reminders),
            subtitle: Text(
              l10n.reminderSet(_format(context, value.remindAtUtc)),
            ),
            trailing: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    tooltip: l10n.removeReminder,
                    onPressed: _remove,
                    icon: Icon(
                      Icons.notifications_off_outlined,
                      color: theme.colorScheme.error,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _addButton(AppLocalizations l10n) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _add,
        icon: _busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.alarm_add_rounded, size: 18),
        label: Text(l10n.addReminder),
      ),
    );
  }
}

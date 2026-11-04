import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../reminders/reminders_providers.dart';
import '../domain/note.dart';
import '../notes_providers.dart';
import 'note_visuals.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Note>> trash = ref.watch(trashProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trash)),
      body: trash.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) {
          return Center(child: Text(l10n.unexpectedError));
        },
        data: (List<Note> notes) {
          if (notes.isEmpty) {
            return _EmptyTrash(l10n: l10n);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: notes.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: 10),
            itemBuilder: (BuildContext context, int index) {
              final Note note = notes[index];
              return _TrashTile(note: note);
            },
          );
        },
      ),
    );
  }
}

class _TrashTile extends ConsumerWidget {
  const _TrashTile({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String date = MaterialLocalizations.of(context)
        .formatShortDate((note.deletedAtUtc ?? note.updatedAtUtc).toLocal());

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
        child: Row(
          children: <Widget>[
            Icon(
              noteTypeIcon(note.type),
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    noteDisplayTitle(l10n, note),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.restore,
              onPressed: () async {
                await ref.read(notesRepositoryProvider).restore(note.id);
              },
              icon: const Icon(Icons.restore_rounded),
            ),
            IconButton(
              tooltip: l10n.deleteForever,
              color: theme.colorScheme.error,
              onPressed: () => _confirmDeleteForever(context, ref, note),
              icon: const Icon(Icons.delete_forever_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteForever(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteForever),
          content: Text(l10n.deleteForeverConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(remindersRepositoryProvider).cancelForNote(note.id);
    await ref.read(mediaRepositoryProvider).deleteAllForNote(note.id);
    await ref.read(notesRepositoryProvider).deleteForever(note.id);
  }
}

class _EmptyTrash extends StatelessWidget {
  const _EmptyTrash({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.delete_sweep_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(l10n.emptyTrash, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

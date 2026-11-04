import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/note.dart';
import '../note_visuals.dart';

enum NoteCardAction { togglePin, color, delete }

class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    required this.onTap,
    required this.onAction,
    this.compact = false,
    super.key,
  });

  final Note note;
  final VoidCallback onTap;
  final ValueChanged<NoteCardAction> onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color surface = noteSurfaceFor(context, note.colorKey);
    final Color ink = noteInkFor(context, note.colorKey);
    final String date = MaterialLocalizations.of(context)
        .formatShortDate(note.updatedAtUtc.toLocal());

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: compact
            ? _ListCardBody(
                note: note,
                l10n: l10n,
                ink: ink,
                date: date,
                onAction: onAction,
              )
            : _GridCardBody(
                note: note,
                l10n: l10n,
                ink: ink,
                date: date,
                onAction: onAction,
              ),
      ),
    );
  }
}

class _GridCardBody extends StatelessWidget {
  const _GridCardBody({
    required this.note,
    required this.l10n,
    required this.ink,
    required this.date,
    required this.onAction,
  });

  final Note note;
  final AppLocalizations l10n;
  final Color ink;
  final String date;
  final ValueChanged<NoteCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String preview = notePreview(note);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                noteTypeIcon(note.type),
                size: 18,
                color: ink.withValues(alpha: 0.7),
              ),
              const Spacer(),
              if (note.isPinned)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Icon(
                    Icons.push_pin_rounded,
                    size: 17,
                    color: ink.withValues(alpha: 0.8),
                  ),
                ),
              _NoteMenu(note: note, l10n: l10n, ink: ink, onAction: onAction),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            noteDisplayTitle(l10n, note),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              color: ink,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          if (preview.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                preview,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: ink.withValues(alpha: 0.82),
                  height: 1.35,
                ),
              ),
            ),
          ] else
            const Spacer(),
          const SizedBox(height: 8),
          Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(
              color: ink.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListCardBody extends StatelessWidget {
  const _ListCardBody({
    required this.note,
    required this.l10n,
    required this.ink,
    required this.date,
    required this.onAction,
  });

  final Note note;
  final AppLocalizations l10n;
  final Color ink;
  final String date;
  final ValueChanged<NoteCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final String preview = notePreview(note);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              noteTypeIcon(note.type),
              size: 20,
              color: ink.withValues(alpha: 0.7),
            ),
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
                  style: textTheme.titleMedium?.copyWith(
                    color: ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (preview.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: ink.withValues(alpha: 0.78),
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    if (note.isPinned) ...<Widget>[
                      Icon(
                        Icons.push_pin_rounded,
                        size: 14,
                        color: ink.withValues(alpha: 0.65),
                      ),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      date,
                      style: textTheme.labelSmall?.copyWith(
                        color: ink.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _NoteMenu(note: note, l10n: l10n, ink: ink, onAction: onAction),
        ],
      ),
    );
  }
}

class _NoteMenu extends StatelessWidget {
  const _NoteMenu({
    required this.note,
    required this.l10n,
    required this.ink,
    required this.onAction,
  });

  final Note note;
  final AppLocalizations l10n;
  final Color ink;
  final ValueChanged<NoteCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<NoteCardAction>(
      tooltip: l10n.moreOptions,
      icon: Icon(Icons.more_horiz_rounded, color: ink.withValues(alpha: 0.75)),
      onSelected: onAction,
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<NoteCardAction>>[
          PopupMenuItem<NoteCardAction>(
            value: NoteCardAction.togglePin,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                note.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
              ),
              title: Text(note.isPinned ? l10n.unpin : l10n.pin),
            ),
          ),
          PopupMenuItem<NoteCardAction>(
            value: NoteCardAction.color,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.colorLabel),
            ),
          ),
          PopupMenuItem<NoteCardAction>(
            value: NoteCardAction.delete,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l10n.delete),
            ),
          ),
        ];
      },
    );
  }
}

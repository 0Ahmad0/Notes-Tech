import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/app_logger.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../reminders/presentation/reminder_section.dart';
import '../../reminders/reminders_providers.dart';
import '../domain/media_repository.dart';
import '../domain/note.dart';
import '../domain/note_attachment.dart';
import '../notes_providers.dart';
import 'note_visuals.dart';
import 'widgets/attachment_tile.dart';
import 'widgets/audio_recorder_sheet.dart';

class NoteEditorScreen extends ConsumerWidget {
  const NoteEditorScreen({this.noteId, super.key});

  final String? noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (noteId == null) {
      return const _NoteForm();
    }
    final AsyncValue<Note?> note = ref.watch(noteByIdProvider(noteId!));
    return note.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stack) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppLocalizations.of(context).unexpectedError)),
      ),
      data: (Note? value) {
        if (value == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(AppLocalizations.of(context).unexpectedError),
            ),
          );
        }
        return _NoteForm(initial: value);
      },
    );
  }
}

class _NoteForm extends ConsumerStatefulWidget {
  const _NoteForm({this.initial});

  final Note? initial;

  @override
  ConsumerState<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<_NoteForm> {
  static const AppLogger _logger = AppLogger('NoteEditor');

  late final TextEditingController _title;
  late final TextEditingController _body;
  late NoteType _type;
  late String _colorKey;
  late bool _isPinned;
  final List<_PendingMedia> _pending = <_PendingMedia>[];
  bool _dirty = false;
  bool _saving = false;
  bool _mediaBusy = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final Note? note = widget.initial;
    _title = TextEditingController(text: note?.title ?? '');
    _body = TextEditingController(text: note?.body ?? '');
    _type = note?.type ?? NoteType.text;
    _colorKey = note?.colorKey ?? 'yellow';
    _isPinned = note?.isPinned ?? false;
    _title.addListener(_markDirty);
    _body.addListener(_markDirty);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    for (final _PendingMedia media in _pending) {
      if (media.temporary) {
        unawaited(_deleteTemp(media.path));
      }
    }
    super.dispose();
  }

  Future<void> _deleteTemp(String path) async {
    try {
      final File file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    } on FileSystemException {
      // Ignore cleanup failures.
    }
  }

  void _markDirty() {
    if (!_dirty) {
      setState(() => _dirty = true);
    }
  }

  Future<void> _save() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty && _body.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.emptyNoteError)));
      return;
    }
    final AppUser? user = ref.read(authControllerProvider).value;
    if (user == null) {
      return;
    }

    setState(() => _saving = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final notesRepository = ref.read(notesRepositoryProvider);
      final String noteId;
      if (_isEditing) {
        final Note updated = await notesRepository.update(
          widget.initial!.copyWith(
            type: _type,
            title: _title.text,
            body: _body.text,
            colorKey: _colorKey,
            isPinned: _isPinned,
          ),
        );
        noteId = updated.id;
      } else {
        final Note created = await notesRepository.create(
          ownerId: user.id,
          type: _type,
          title: _title.text,
          body: _body.text,
          colorKey: _colorKey,
        );
        noteId = created.id;
      }

      String? attachmentError;
      if (_pending.isNotEmpty) {
        final mediaRepository = ref.read(mediaRepositoryProvider);
        for (final _PendingMedia media in List<_PendingMedia>.of(_pending)) {
          try {
            await mediaRepository.attach(
              noteId: noteId,
              kind: media.kind,
              sourcePath: media.path,
              originalName: media.name,
              durationMs: media.durationMs,
            );
          } on MediaFailure {
            attachmentError = l10n.attachmentFailed;
          } catch (error, stack) {
            _logger.error('Failed to attach media', error, stack);
            attachmentError = l10n.attachmentFailed;
          } finally {
            if (media.temporary) {
              await _deleteTemp(media.path);
            }
          }
        }
        _pending.clear();
      }

      _dirty = false;
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(attachmentError ?? l10n.noteSaved)),
      );
    } catch (error, stack) {
      _logger.error('Failed to save note', error, stack);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.unexpectedError)));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _delete() async {
    final Note? note = widget.initial;
    if (note == null) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteNote),
          content: Text(l10n.deleteNoteConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final notesRepository = ref.read(notesRepositoryProvider);
    await ref.read(remindersRepositoryProvider).cancelForNote(note.id);
    await notesRepository.moveToTrash(note.id);
    _dirty = false;
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.movedToTrash),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => notesRepository.restore(note.id),
        ),
      ),
    );
  }

  Future<bool> _confirmDiscard() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.discardChanges),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.keepEditing),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.discard),
            ),
          ],
        );
      },
    );
    return discard ?? false;
  }

  Future<void> _addMedia({
    required AttachmentKind kind,
    required String path,
    required String name,
    String? mimeType,
    int? durationMs,
    bool temporary = false,
  }) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final File file = File(path);
      final int size = await file.length();
      if (size > maxAttachmentBytes(kind)) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.attachmentTooLarge)),
        );
        return;
      }
      final Note? note = widget.initial;
      if (note == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _pending.add(
            _PendingMedia(
              kind: kind,
              path: path,
              name: name,
              durationMs: durationMs,
              temporary: temporary,
            ),
          );
          _dirty = true;
        });
        return;
      }

      if (mounted) {
        setState(() => _mediaBusy = true);
      }
      await ref
          .read(mediaRepositoryProvider)
          .attach(
            noteId: note.id,
            kind: kind,
            sourcePath: path,
            originalName: name,
            mimeType: mimeType,
            durationMs: durationMs,
          );
    } on MediaFailure catch (failure) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            failure.reason == MediaFailureReason.tooLarge
                ? l10n.attachmentTooLarge
                : l10n.attachmentFailed,
          ),
        ),
      );
    } catch (error, stack) {
      _logger.error('Failed to add media', error, stack);
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(l10n.attachmentFailed)));
    } finally {
      if (mounted) {
        setState(() => _mediaBusy = false);
      }
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage(
      imageQuality: 90,
    );
    if (!mounted) {
      return;
    }
    for (final XFile image in images) {
      await _addMedia(
        kind: AttachmentKind.image,
        path: image.path,
        name: image.name,
        mimeType: image.mimeType,
      );
    }
  }

  Future<void> _pickFiles() async {
    final List<PlatformFile> files = await FilePicker.pickFiles();
    if (!mounted) {
      return;
    }
    for (final PlatformFile file in files) {
      final String? path = file.path;
      if (path == null) {
        continue;
      }
      await _addMedia(kind: AttachmentKind.file, path: path, name: file.name);
    }
  }

  Future<void> _recordAudio() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final RecordedAudio? recorded = await showAudioRecorderSheet(context);
    if (recorded == null || !mounted) {
      return;
    }
    await _addMedia(
      kind: AttachmentKind.audio,
      path: recorded.path,
      name: l10n.recordAudio,
      durationMs: recorded.durationMs,
      temporary: true,
    );
  }

  void _removePending(int index) {
    final _PendingMedia media = _pending[index];
    if (media.temporary) {
      unawaited(_deleteTemp(media.path));
    }
    setState(() {
      _pending.removeAt(index);
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return PopScope<Object?>(
      canPop: !_dirty,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool discard = await _confirmDiscard();
        if (discard && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? l10n.noteEditorEdit : l10n.noteEditorNew),
          actions: <Widget>[
            IconButton(
              tooltip: _isPinned ? l10n.unpin : l10n.pin,
              onPressed: () {
                setState(() {
                  _isPinned = !_isPinned;
                  _dirty = true;
                });
              },
              icon: Icon(
                _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
              ),
            ),
            if (_isEditing)
              IconButton(
                tooltip: l10n.deleteNote,
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: <Widget>[
            TextField(
              controller: _title,
              autofocus: !_isEditing,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: l10n.noteTitleHint,
                border: InputBorder.none,
              ),
            ),
            const Divider(height: 8),
            TextField(
              controller: _body,
              minLines: 8,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              decoration: InputDecoration(
                hintText: l10n.noteBodyHint,
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.noteType, style: theme.textTheme.titleSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: NoteType.values.map((NoteType type) {
                return ChoiceChip(
                  avatar: Icon(noteTypeIcon(type), size: 18),
                  label: Text(noteTypeLabel(l10n, type)),
                  selected: _type == type,
                  onSelected: (_) {
                    setState(() {
                      _type = type;
                      _dirty = true;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(l10n.colorLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: <Widget>[
                _ColorChoice(
                  selected: _colorKey == 'default',
                  surface: theme.colorScheme.surfaceContainerHighest,
                  ink: theme.colorScheme.onSurface,
                  onTap: () {
                    setState(() {
                      _colorKey = 'default';
                      _dirty = true;
                    });
                  },
                ),
                ...AppColors.noteKeys.map((String key) {
                  return _ColorChoice(
                    selected: _colorKey == key,
                    surface: AppColors.noteSurface(key, theme.brightness),
                    ink: AppColors.onNoteSurface(key, theme.brightness),
                    onTap: () {
                      setState(() {
                        _colorKey = key;
                        _dirty = true;
                      });
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 26),
            Row(
              children: <Widget>[
                Text(l10n.attachments, style: theme.textTheme.titleSmall),
                const Spacer(),
                if (_mediaBusy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isEditing)
              _ExistingAttachments(noteId: widget.initial!.id)
            else ...<Widget>[
              for (int index = 0; index < _pending.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: MediaTile(
                    kind: _pending[index].kind,
                    name: _pending[index].name,
                    filePath: _pending[index].path,
                    sizeLabel: null,
                    durationMs: _pending[index].durationMs,
                    onRemove: () => _removePending(index),
                  ),
                ),
              if (_pending.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.pendingAttachmentsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _mediaBusy ? null : _pickImages,
                  icon: const Icon(Icons.image_outlined, size: 18),
                  label: Text(l10n.addImage),
                ),
                OutlinedButton.icon(
                  onPressed: _mediaBusy ? null : _recordAudio,
                  icon: const Icon(Icons.mic_none_rounded, size: 18),
                  label: Text(l10n.addAudio),
                ),
                OutlinedButton.icon(
                  onPressed: _mediaBusy ? null : _pickFiles,
                  icon: const Icon(Icons.attach_file_rounded, size: 18),
                  label: Text(l10n.addFile),
                ),
              ],
            ),
            if (_isEditing) ...<Widget>[
              const SizedBox(height: 26),
              Text(l10n.reminders, style: theme.textTheme.titleSmall),
              const SizedBox(height: 10),
              ReminderSection(note: widget.initial!),
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            onPressed: _saving || _mediaBusy ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(l10n.saveNote),
          ),
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.selected,
    required this.surface,
    required this.ink,
    required this.onTap,
  });

  final bool selected;
  final Color surface;
  final Color ink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 30,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 20, color: ink)
            : null,
      ),
    );
  }
}

class _ExistingAttachments extends ConsumerWidget {
  const _ExistingAttachments({required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<NoteAttachment>> attachments = ref.watch(
      attachmentsProvider(noteId),
    );
    return attachments.when(
      loading: () => const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (Object error, StackTrace stack) => const SizedBox.shrink(),
      data: (List<NoteAttachment> items) {
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          children: <Widget>[
            for (final NoteAttachment attachment in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AttachmentTile(attachment: attachment),
              ),
          ],
        );
      },
    );
  }
}

class _PendingMedia {
  const _PendingMedia({
    required this.kind,
    required this.path,
    required this.name,
    required this.temporary,
    this.durationMs,
  });

  final AttachmentKind kind;
  final String path;
  final String name;
  final bool temporary;
  final int? durationMs;
}

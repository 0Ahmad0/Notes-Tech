import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/note_attachment.dart';
import '../../notes_providers.dart';

class AttachmentTile extends ConsumerWidget {
  const AttachmentTile({required this.attachment, super.key});

  final NoteAttachment attachment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<File> file = ref.watch(attachmentFileProvider(attachment));
    return file.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: LinearProgressIndicator()),
      ),
      error: (Object error, StackTrace stack) => MediaTile(
        kind: attachment.kind,
        name: attachment.originalName,
        missing: true,
        onRemove: () => ref.read(mediaRepositoryProvider).remove(attachment),
      ),
      data: (File value) => MediaTile(
        kind: attachment.kind,
        name: attachment.originalName,
        filePath: value.path,
        sizeLabel: attachment.formattedSize,
        durationMs: attachment.durationMs,
        missing: !value.existsSync(),
        onRemove: () => ref.read(mediaRepositoryProvider).remove(attachment),
      ),
    );
  }
}

class MediaTile extends StatelessWidget {
  const MediaTile({
    required this.kind,
    required this.name,
    this.filePath,
    this.sizeLabel,
    this.durationMs,
    this.missing = false,
    this.onRemove,
    super.key,
  });

  final AttachmentKind kind;
  final String name;
  final String? filePath;
  final String? sizeLabel;
  final int? durationMs;
  final bool missing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      AttachmentKind.image => _ImageTile(
        name: name,
        filePath: filePath,
        missing: missing,
        onRemove: onRemove,
      ),
      AttachmentKind.audio => _AudioTile(
        name: name,
        filePath: filePath,
        missing: missing,
        durationMs: durationMs,
        onRemove: onRemove,
      ),
      AttachmentKind.file => _FileTile(
        name: name,
        sizeLabel: sizeLabel,
        missing: missing,
        onRemove: onRemove,
      ),
    };
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.name,
    required this.filePath,
    required this.missing,
    required this.onRemove,
  });

  final String name;
  final String? filePath;
  final bool missing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool hasImage = filePath != null && !missing;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (hasImage)
              GestureDetector(
                onTap: () => _openImage(context, filePath!),
                child: Image.file(
                  File(filePath!),
                  fit: BoxFit.cover,
                  cacheWidth: 900,
                  errorBuilder:
                      (BuildContext context, Object error, StackTrace? stack) {
                        return _MissingBox(
                          label: l10n.fileMissing,
                          theme: theme,
                        );
                      },
                ),
              )
            else
              _MissingBox(label: l10n.fileMissing, theme: theme),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Colors.transparent, Colors.black54],
                  ),
                ),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filledTonal(
                  tooltip: l10n.removeAttachment,
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openImage(BuildContext context, String path) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Image.file(File(path), fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton.filledTonal(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MissingBox extends StatelessWidget {
  const _MissingBox({required this.label, required this.theme});

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 6),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _AudioTile extends StatelessWidget {
  const _AudioTile({
    required this.name,
    required this.filePath,
    required this.missing,
    required this.durationMs,
    required this.onRemove,
  });

  final String name;
  final String? filePath;
  final bool missing;
  final int? durationMs;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (filePath == null || missing) {
      return _FileTile(
        name: '$name (${AppLocalizations.of(context).fileMissing})',
        sizeLabel: null,
        missing: true,
        onRemove: onRemove,
      );
    }
    return AudioAttachmentPlayer(
      name: name,
      filePath: filePath!,
      durationMs: durationMs,
      onRemove: onRemove,
    );
  }
}

class AudioAttachmentPlayer extends StatefulWidget {
  const AudioAttachmentPlayer({
    required this.name,
    required this.filePath,
    this.durationMs,
    this.onRemove,
    super.key,
  });

  final String name;
  final String filePath;
  final int? durationMs;
  final VoidCallback? onRemove;

  @override
  State<AudioAttachmentPlayer> createState() => _AudioAttachmentPlayerState();
}

class _AudioAttachmentPlayerState extends State<AudioAttachmentPlayer> {
  static const AppLogger _logger = AppLogger('AudioPlayer');

  final AudioPlayer _player = AudioPlayer();
  bool _failed = false;
  bool _loading = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_loading) {
      return;
    }
    setState(() => _loading = true);
    try {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
        await _player.play();
      } else if (_player.playing) {
        await _player.pause();
      } else {
        if (_player.audioSource == null) {
          await _player.setFilePath(widget.filePath);
        }
        await _player.play();
      }
      if (mounted) {
        setState(() => _failed = false);
      }
    } catch (error, stack) {
      _logger.error('Failed to play audio', error, stack);
      if (mounted) {
        setState(() => _failed = true);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _format(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Duration total = widget.durationMs == null
        ? Duration.zero
        : Duration(milliseconds: widget.durationMs!);

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          StreamBuilder<PlayerState>(
            stream: _player.playerStateStream,
            builder:
                (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
                  final PlayerState? state = snapshot.data;
                  final bool playing = state?.playing ?? false;
                  final bool completed =
                      state?.processingState == ProcessingState.completed;
                  return IconButton.filledTonal(
                    tooltip: playing ? l10n.pauseAudio : l10n.playAudio,
                    onPressed: _loading ? null : _toggle,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            completed
                                ? Icons.replay_rounded
                                : playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                  );
                },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder:
                      (BuildContext context, AsyncSnapshot<Duration> snapshot) {
                        final Duration position =
                            snapshot.data ?? Duration.zero;
                        final double progress = total.inMilliseconds == 0
                            ? 0
                            : (position.inMilliseconds / total.inMilliseconds)
                                  .clamp(0, 1);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 4,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${_format(position)} / ${_format(total)}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        );
                      },
                ),
                if (_failed)
                  Text(
                    l10n.audioPlaybackFailed,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onRemove != null)
            IconButton(
              tooltip: l10n.removeAttachment,
              onPressed: widget.onRemove,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.name,
    required this.sizeLabel,
    required this.missing,
    required this.onRemove,
  });

  final String name;
  final String? sizeLabel;
  final bool missing;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final String extension = name.contains('.')
        ? name.split('.').last.toUpperCase()
        : 'FILE';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            missing
                ? Icons.error_outline_rounded
                : Icons.insert_drive_file_outlined,
            color: missing
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  missing
                      ? l10n.fileMissing
                      : <String?>[
                          extension,
                          sizeLabel,
                        ].whereType<String>().join(' · '),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: missing
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: l10n.removeAttachment,
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 20),
            ),
        ],
      ),
    );
  }
}

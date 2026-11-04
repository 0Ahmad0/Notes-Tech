import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../l10n/generated/app_localizations.dart';

final class RecordedAudio {
  const RecordedAudio({required this.path, required this.durationMs});

  final String path;
  final int durationMs;
}

Future<RecordedAudio?> showAudioRecorderSheet(BuildContext context) {
  return showModalBottomSheet<RecordedAudio>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (BuildContext context) => const _AudioRecorderSheet(),
  );
}

class _AudioRecorderSheet extends StatefulWidget {
  const _AudioRecorderSheet();

  @override
  State<_AudioRecorderSheet> createState() => _AudioRecorderSheetState();
}

class _AudioRecorderSheetState extends State<_AudioRecorderSheet> {
  static const AppLogger _logger = AppLogger('AudioRecorder');

  final AudioRecorder _recorder = AudioRecorder();
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  Duration _elapsed = Duration.zero;
  String? _filePath;
  String? _error;
  bool _recording = false;
  bool _busy = false;
  bool _used = false;

  @override
  void dispose() {
    _ticker?.cancel();
    if (_recording) {
      unawaited(_recorder.cancel());
    }
    unawaited(_recorder.dispose());
    if (!_used && _filePath != null) {
      unawaited(_deleteFile(_filePath!));
    }
    super.dispose();
  }

  Future<void> _deleteFile(String path) async {
    try {
      final File file = File(path);
      if (file.existsSync()) {
        await file.delete();
      }
    } on FileSystemException {
      // Ignore cleanup failures.
    }
  }

  Future<void> _start() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final bool permitted = await _recorder.hasPermission();
      if (!permitted) {
        if (!mounted) {
          return;
        }
        setState(() {
          _error = l10n.microphoneDenied;
          _busy = false;
        });
        return;
      }
      final Directory temp = await getTemporaryDirectory();
      final String path =
          '${temp.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      if (!mounted) {
        return;
      }
      _stopwatch
        ..reset()
        ..start();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted) {
          setState(() => _elapsed = _stopwatch.elapsed);
        }
      });
      setState(() {
        _recording = true;
        _busy = false;
      });
    } catch (error, stack) {
      _logger.error('Failed to start recording', error, stack);
      if (!mounted) {
        return;
      }
      setState(() {
        _error = l10n.recordingFailed;
        _busy = false;
      });
    }
  }

  Future<void> _stop() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final String? path = await _recorder.stop();
      _stopwatch.stop();
      _ticker?.cancel();
      if (!mounted) {
        return;
      }
      setState(() {
        _recording = false;
        _busy = false;
        _filePath = path;
        _elapsed = _stopwatch.elapsed;
        if (path == null) {
          _error = l10n.recordingFailed;
        }
      });
    } catch (error, stack) {
      _logger.error('Failed to stop recording', error, stack);
      _stopwatch.stop();
      _ticker?.cancel();
      if (!mounted) {
        return;
      }
      setState(() {
        _recording = false;
        _busy = false;
        _error = l10n.recordingFailed;
      });
    }
  }

  Future<void> _cancel() async {
    if (_recording) {
      await _recorder.cancel();
    }
    _ticker?.cancel();
    final String? path = _filePath;
    if (path != null) {
      _used = true;
      await _deleteFile(path);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _use() {
    final String? path = _filePath;
    if (path == null) {
      return;
    }
    _used = true;
    Navigator.of(context)
        .pop(RecordedAudio(path: path, durationMs: _elapsed.inMilliseconds));
  }

  String _format(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool canUse = _filePath != null && !_recording && !_busy;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(l10n.recordAudio, style: theme.textTheme.titleLarge),
            const SizedBox(height: 18),
            Text(
              _format(_elapsed),
              style: theme.textTheme.displaySmall?.copyWith(
                fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _busy ? null : (_recording ? _stop : _start),
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(24),
                backgroundColor: _recording
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              child: Icon(
                _recording ? Icons.stop_rounded : Icons.mic_rounded,
                size: 36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recording ? l10n.stopRecording : l10n.recordAudio,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : _cancel,
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canUse ? _use : null,
                    child: Text(l10n.useRecording),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/note.dart';

IconData noteTypeIcon(NoteType type) {
  return switch (type) {
    NoteType.text => Icons.notes_rounded,
    NoteType.audio => Icons.mic_rounded,
    NoteType.image => Icons.image_rounded,
    NoteType.file => Icons.description_rounded,
  };
}

String noteTypeLabel(AppLocalizations l10n, NoteType type) {
  return switch (type) {
    NoteType.text => l10n.filterText,
    NoteType.audio => l10n.filterAudio,
    NoteType.image => l10n.filterImage,
    NoteType.file => l10n.filterFiles,
  };
}

String noteDisplayTitle(AppLocalizations l10n, Note note) {
  final String title = note.title.trim();
  if (title.isNotEmpty) {
    return title;
  }
  final String body = note.body.trim();
  if (body.isNotEmpty) {
    return body.split('\n').first;
  }
  return l10n.untitledNote;
}

String noteColorLabel(AppLocalizations l10n, String key) {
  return switch (key) {
    'yellow' => l10n.colorYellow,
    'mint' => l10n.colorMint,
    'sky' => l10n.colorSky,
    'lavender' => l10n.colorLavender,
    'peach' => l10n.colorPeach,
    'rose' => l10n.colorRose,
    'slate' => l10n.colorSlate,
    _ => l10n.colorDefault,
  };
}

String notePreview(Note note) {
  return note.body.trim().replaceAll(RegExp(r'\s+'), ' ');
}

Color noteSurfaceFor(BuildContext context, String colorKey) {
  return AppColors.noteSurface(colorKey, Theme.of(context).brightness);
}

Color noteInkFor(BuildContext context, String colorKey) {
  return AppColors.onNoteSurface(colorKey, Theme.of(context).brightness);
}

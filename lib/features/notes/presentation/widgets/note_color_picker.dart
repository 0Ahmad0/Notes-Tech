import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../note_visuals.dart';

Future<String?> showNoteColorPicker(
  BuildContext context, {
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      final ThemeData theme = Theme.of(context);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.colorLabel, style: theme.textTheme.titleMedium),
              const SizedBox(height: 18),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: <Widget>[
                  _ColorDot(
                    keyValue: 'default',
                    label: l10n.colorDefault,
                    selected: selected == 'default',
                    surface: theme.colorScheme.surfaceContainerHighest,
                    ink: theme.colorScheme.onSurface,
                  ),
                  ...AppColors.noteKeys.map((String key) {
                    return _ColorDot(
                      keyValue: key,
                      label: noteColorLabel(l10n, key),
                      selected: selected == key,
                      surface: AppColors.noteSurface(key, theme.brightness),
                      ink: AppColors.onNoteSurface(key, theme.brightness),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.keyValue,
    required this.label,
    required this.selected,
    required this.surface,
    required this.ink,
  });

  final String keyValue;
  final String label;
  final bool selected;
  final Color surface;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: () => Navigator.of(context).pop(keyValue),
        radius: 30,
        child: Container(
          width: 48,
          height: 48,
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
              ? Icon(Icons.check_rounded, size: 22, color: ink)
              : null,
        ),
      ),
    );
  }
}

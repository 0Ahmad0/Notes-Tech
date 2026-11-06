import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../auth/auth_providers.dart';
import '../../auth/domain/app_user.dart';
import '../../reminders/reminders_providers.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/settings_providers.dart';
import '../domain/note.dart';
import '../domain/note_query.dart';
import '../notes_providers.dart';
import 'widgets/note_card.dart';
import 'widgets/note_color_picker.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppUser? user = ref.watch(authControllerProvider).value;
    final AppSettings settings =
        ref.watch(settingsControllerProvider).value ?? const AppSettings();
    final NoteQuery query = ref.watch(noteQueryProvider);
    final AsyncValue<List<Note>> notes = ref.watch(notesProvider);
    final bool isGrid = settings.viewMode != 'list';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: <Widget>[
          PopupMenuButton<NoteSort>(
            tooltip: l10n.sortBy,
            icon: const Icon(Icons.sort_rounded),
            initialValue: NoteSort.fromValue(settings.sortOrder),
            onSelected: (NoteSort sort) {
              ref
                  .read(settingsControllerProvider.notifier)
                  .setSortOrder(sort.name);
            },
            itemBuilder: (BuildContext context) {
              final NoteSort current = NoteSort.fromValue(settings.sortOrder);
              return NoteSort.values.map((NoteSort sort) {
                return PopupMenuItem<NoteSort>(
                  value: sort,
                  child: Row(
                    children: <Widget>[
                      Icon(
                        sort == current
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(_sortLabel(l10n, sort)),
                    ],
                  ),
                );
              }).toList();
            },
          ),
          IconButton(
            tooltip: isGrid ? l10n.viewList : l10n.viewGrid,
            onPressed: () {
              ref
                  .read(settingsControllerProvider.notifier)
                  .setViewMode(isGrid ? 'list' : 'grid');
            },
            icon: Icon(
              isGrid ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
            ),
          ),
          PopupMenuButton<String>(
            tooltip: l10n.moreOptions,
            onSelected: (String value) {
              if (value == 'trash') {
                context.push('/trash');
              } else if (value == 'settings') {
                context.push('/settings');
              }
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'trash',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_outline_rounded),
                    title: Text(l10n.trash),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.tune_rounded),
                    title: Text(l10n.settings),
                  ),
                ),
              ];
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: l10n.profile,
              onPressed: () => context.push('/profile'),
              icon: CircleAvatar(
                radius: 17,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (user?.username.isNotEmpty ?? false)
                      ? user!.username.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/notes/new'),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.newNote),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: _NoteSearchField(
                hintText: l10n.searchNotes,
                onChanged: (String value) {
                  ref.read(noteQueryProvider.notifier).setSearch(value);
                },
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: NoteFilter.values.map((NoteFilter filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filterLabel(l10n, filter)),
                      selected: query.filter == filter,
                      onSelected: (_) {
                        ref.read(noteQueryProvider.notifier).setFilter(filter);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: notes.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object error, StackTrace stack) {
                  return _NotesError(
                    message: l10n.unexpectedError,
                    retryLabel: l10n.retry,
                    onRetry: () => ref.invalidate(notesProvider),
                  );
                },
                data: (List<Note> items) {
                  if (items.isEmpty) {
                    return _EmptyNotes(
                      query: query,
                      onCreate: () => context.push('/notes/new'),
                    );
                  }
                  return isGrid
                      ? _NotesGrid(items: items)
                      : _NotesList(items: items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _sortLabel(AppLocalizations l10n, NoteSort sort) {
    return switch (sort) {
      NoteSort.updatedDesc => l10n.sortUpdatedDesc,
      NoteSort.updatedAsc => l10n.sortUpdatedAsc,
      NoteSort.createdDesc => l10n.sortCreatedDesc,
      NoteSort.titleAsc => l10n.sortTitleAsc,
    };
  }

  String _filterLabel(AppLocalizations l10n, NoteFilter filter) {
    return switch (filter) {
      NoteFilter.all => l10n.filterAll,
      NoteFilter.text => l10n.filterText,
      NoteFilter.audio => l10n.filterAudio,
      NoteFilter.image => l10n.filterImage,
      NoteFilter.file => l10n.filterFiles,
    };
  }
}

class _NotesGrid extends ConsumerWidget {
  const _NotesGrid({required this.items});

  final List<Note> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.sizeOf(context).width;
    final int columns = width < 620
        ? 2
        : width < 960
        ? 3
        : 4;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 112),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final Note note = items[index];
        return NoteCard(
          note: note,
          onTap: () => context.push('/notes/${note.id}'),
          onAction: (NoteCardAction action) {
            _handleAction(context, ref, note, action);
          },
        );
      },
    );
  }
}

class _NotesList extends ConsumerWidget {
  const _NotesList({required this.items});

  final List<Note> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 112),
      itemCount: items.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final Note note = items[index];
        return NoteCard(
          note: note,
          compact: true,
          onTap: () => context.push('/notes/${note.id}'),
          onAction: (NoteCardAction action) {
            _handleAction(context, ref, note, action);
          },
        );
      },
    );
  }
}

Future<void> _handleAction(
  BuildContext context,
  WidgetRef ref,
  Note note,
  NoteCardAction action,
) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final notesRepository = ref.read(notesRepositoryProvider);

  switch (action) {
    case NoteCardAction.togglePin:
      await notesRepository.update(note.copyWith(isPinned: !note.isPinned));
    case NoteCardAction.color:
      final String? colorKey = await showNoteColorPicker(
        context,
        selected: note.colorKey,
      );
      if (colorKey == null || !context.mounted) {
        return;
      }
      await notesRepository.update(note.copyWith(colorKey: colorKey));
    case NoteCardAction.delete:
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
      if (confirmed != true || !context.mounted) {
        return;
      }
      final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
      await ref.read(remindersRepositoryProvider).cancelForNote(note.id);
      await notesRepository.moveToTrash(note);
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.movedToTrash),
          action: SnackBarAction(
            label: l10n.undo,
            onPressed: () => notesRepository.restore(note),
          ),
        ),
      );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.query, required this.onCreate});

  final NoteQuery query;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!query.isDefault) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.search_off_rounded,
                size: 56,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noSearchResults,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.emptyNotesTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyNotesSubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.newNote),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesError extends StatelessWidget {
  const _NotesError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
        ],
      ),
    );
  }
}

class _NoteSearchField extends StatefulWidget {
  const _NoteSearchField({required this.hintText, required this.onChanged});

  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_NoteSearchField> createState() => _NoteSearchFieldState();
}

class _NoteSearchFieldState extends State<_NoteSearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () {
                  _controller.clear();
                  _handleChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

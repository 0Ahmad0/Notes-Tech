import 'note.dart';

enum NoteFilter {
  all,
  text,
  audio,
  image,
  file;

  bool matches(NoteType type) {
    return switch (this) {
      NoteFilter.all => true,
      NoteFilter.text => type == NoteType.text,
      NoteFilter.audio => type == NoteType.audio,
      NoteFilter.image => type == NoteType.image,
      NoteFilter.file => type == NoteType.file,
    };
  }
}

enum NoteSort {
  updatedDesc,
  updatedAsc,
  createdDesc,
  titleAsc;

  static NoteSort fromValue(String? value) {
    return NoteSort.values.firstWhere(
      (NoteSort sort) => sort.name == value,
      orElse: () => NoteSort.updatedDesc,
    );
  }
}

final class NoteQuery {
  const NoteQuery({this.filter = NoteFilter.all, this.search = ''});

  final NoteFilter filter;
  final String search;

  bool get isDefault => filter == NoteFilter.all && search.trim().isEmpty;

  NoteQuery copyWith({NoteFilter? filter, String? search}) {
    return NoteQuery(
      filter: filter ?? this.filter,
      search: search ?? this.search,
    );
  }
}

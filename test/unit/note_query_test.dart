import 'package:flutter_test/flutter_test.dart';
import 'package:task_ai1/features/notes/domain/note.dart';
import 'package:task_ai1/features/notes/domain/note_query.dart';

void main() {
  group('NoteFilter', () {
    test('all matches every note type', () {
      for (final NoteType type in NoteType.values) {
        expect(NoteFilter.all.matches(type), isTrue);
      }
    });

    test('typed filters only match their own note type', () {
      expect(NoteFilter.text.matches(NoteType.text), isTrue);
      expect(NoteFilter.text.matches(NoteType.audio), isFalse);
      expect(NoteFilter.audio.matches(NoteType.audio), isTrue);
      expect(NoteFilter.image.matches(NoteType.image), isTrue);
      expect(NoteFilter.file.matches(NoteType.file), isTrue);
      expect(NoteFilter.file.matches(NoteType.text), isFalse);
    });
  });

  group('NoteSort', () {
    test('parses known values and falls back to updatedDesc', () {
      expect(NoteSort.fromValue('titleAsc'), NoteSort.titleAsc);
      expect(NoteSort.fromValue('createdDesc'), NoteSort.createdDesc);
      expect(NoteSort.fromValue('unknown'), NoteSort.updatedDesc);
      expect(NoteSort.fromValue(null), NoteSort.updatedDesc);
    });
  });

  group('NoteQuery', () {
    test('is default only when filter is all and search is blank', () {
      expect(const NoteQuery().isDefault, isTrue);
      expect(const NoteQuery(search: '   ').isDefault, isTrue);
      expect(const NoteQuery(search: 'milk').isDefault, isFalse);
      expect(const NoteQuery(filter: NoteFilter.audio).isDefault, isFalse);
    });

    test('copyWith replaces only the provided fields', () {
      const NoteQuery query = NoteQuery(search: 'milk');
      final NoteQuery filtered = query.copyWith(filter: NoteFilter.image);
      expect(filtered.filter, NoteFilter.image);
      expect(filtered.search, 'milk');
    });
  });
}

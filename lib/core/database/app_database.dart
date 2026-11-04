import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/notes_dao.dart';
import 'daos/preferences_dao.dart';
import 'daos/reminders_dao.dart';
import 'daos/users_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[
    Users,
    Notes,
    Attachments,
    Reminders,
    UserPreferences,
    SyncOutbox,
  ],
  daos: <Type>[UsersDao, NotesDao, RemindersDao, PreferencesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'notes_tech'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (OpeningDetails details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'preferences_dao.g.dart';

@DriftAccessor(tables: [UserPreferences])
class PreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$PreferencesDaoMixin {
  PreferencesDao(super.db);

  Future<UserPreferenceRow?> findForOwner(String ownerId) {
    return (select(
      userPreferences,
    )..where((t) => t.ownerId.equals(ownerId))).getSingleOrNull();
  }

  Future<void> upsert(UserPreferencesCompanion preferences) {
    return into(userPreferences).insertOnConflictUpdate(preferences);
  }
}

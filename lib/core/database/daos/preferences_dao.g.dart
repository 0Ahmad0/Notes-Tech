// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_dao.dart';

// ignore_for_file: type=lint
mixin _$PreferencesDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $UserPreferencesTable get userPreferences => attachedDatabase.userPreferences;
  PreferencesDaoManager get managers => PreferencesDaoManager(this);
}

class PreferencesDaoManager {
  final _$PreferencesDaoMixin _db;
  PreferencesDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$UserPreferencesTableTableManager get userPreferences =>
      $$UserPreferencesTableTableManager(
        _db.attachedDatabase,
        _db.userPreferences,
      );
}

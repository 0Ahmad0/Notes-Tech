import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<UserRow?> findById(String id) {
    return (select(users)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<UserRow?> findByNormalizedUsername(String usernameNormalized) {
    return (select(users)
          ..where((t) => t.usernameNormalized.equals(usernameNormalized)))
        .getSingleOrNull();
  }

  Future<void> insertUser(UsersCompanion user) {
    return into(users).insert(user);
  }

  Future<void> updateAvatar(String id, String? path) {
    return (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(avatarLocalPath: Value<String?>(path)),
    );
  }

  Future<void> updatePassword(
    String id, {
    required String passwordHash,
    required String salt,
    required String hashParams,
  }) {
    return (update(users)..where((t) => t.id.equals(id))).write(
      UsersCompanion(
        passwordHash: Value<String>(passwordHash),
        salt: Value<String>(salt),
        hashParams: Value<String>(hashParams),
        updatedAtUtc: Value<DateTime>(DateTime.now().toUtc()),
      ),
    );
  }
}

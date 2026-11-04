import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'password_hasher.dart';

final class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._db, this._preferences, this._hasher);

  static const String _sessionKey = 'session.activeUserId';
  static final RegExp _usernamePattern = RegExp(r'^[a-z0-9_]{3,24}$');

  final AppDatabase _db;
  final SharedPreferencesAsync _preferences;
  final PasswordHasher _hasher;
  final Uuid _uuid = const Uuid();

  @override
  Future<AppUser?> restoreSession() async {
    final String? userId = await _preferences.getString(_sessionKey);
    if (userId == null) {
      return null;
    }
    final UserRow? row = await _db.usersDao.findById(userId);
    if (row == null) {
      await _preferences.remove(_sessionKey);
      return null;
    }
    return _toUser(row);
  }

  @override
  Future<AppUser> signIn({
    required String username,
    required String password,
  }) async {
    final String normalized = _normalize(username);
    if (!_usernamePattern.hasMatch(normalized)) {
      throw const AuthFailure(AuthFailureCode.invalidCredentials);
    }
    final UserRow? row = await _db.usersDao.findByNormalizedUsername(
      normalized,
    );
    if (row == null) {
      throw const AuthFailure(AuthFailureCode.invalidCredentials);
    }
    final bool valid = await _hasher.verify(
      password: password,
      hash: row.passwordHash,
      salt: row.salt,
      params: row.hashParams,
    );
    if (!valid) {
      throw const AuthFailure(AuthFailureCode.invalidCredentials);
    }
    await _preferences.setString(_sessionKey, row.id);
    return _toUser(row);
  }

  @override
  Future<AppUser> register({
    required String username,
    required String password,
  }) async {
    final String displayName = username.trim();
    final String normalized = _normalize(username);
    if (!_usernamePattern.hasMatch(normalized)) {
      throw const AuthFailure(AuthFailureCode.invalidUsername);
    }
    if (password.length < 8) {
      throw const AuthFailure(AuthFailureCode.weakPassword);
    }
    final UserRow? existing = await _db.usersDao.findByNormalizedUsername(
      normalized,
    );
    if (existing != null) {
      throw const AuthFailure(AuthFailureCode.usernameTaken);
    }

    final PasswordHash passwordHash = await _hasher.hash(password);
    final String id = _uuid.v4();
    final DateTime now = DateTime.now().toUtc();
    await _db.usersDao.insertUser(
      UsersCompanion.insert(
        id: id,
        usernameNormalized: normalized,
        usernameDisplay: displayName,
        passwordHash: passwordHash.hash,
        salt: passwordHash.salt,
        hashParams: passwordHash.params,
        createdAtUtc: now,
        updatedAtUtc: now,
      ),
    );

    await _preferences.setString(_sessionKey, id);
    return AppUser(id: id, username: displayName);
  }

  @override
  Future<void> signOut() async {
    await _preferences.remove(_sessionKey);
  }

  @override
  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final UserRow? row = await _db.usersDao.findById(userId);
    if (row == null) {
      throw const AuthFailure(AuthFailureCode.userNotFound);
    }
    final bool valid = await _hasher.verify(
      password: currentPassword,
      hash: row.passwordHash,
      salt: row.salt,
      params: row.hashParams,
    );
    if (!valid) {
      throw const AuthFailure(AuthFailureCode.invalidCredentials);
    }
    if (newPassword.length < 8) {
      throw const AuthFailure(AuthFailureCode.weakPassword);
    }
    final PasswordHash passwordHash = await _hasher.hash(newPassword);
    await _db.usersDao.updatePassword(
      userId,
      passwordHash: passwordHash.hash,
      salt: passwordHash.salt,
      hashParams: passwordHash.params,
    );
  }

  @override
  Future<void> updateAvatar({
    required String userId,
    required String? avatarLocalPath,
  }) async {
    await _db.usersDao.updateAvatar(userId, avatarLocalPath);
  }

  String _normalize(String username) => username.trim().toLowerCase();

  AppUser _toUser(UserRow row) {
    return AppUser(
      id: row.id,
      username: row.usernameDisplay,
      avatarLocalPath: row.avatarLocalPath,
    );
  }
}

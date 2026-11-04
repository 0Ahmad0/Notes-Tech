import 'app_user.dart';

abstract interface class AuthRepository {
  Future<AppUser?> restoreSession();

  Future<AppUser> signIn({required String username, required String password});

  Future<AppUser> register({
    required String username,
    required String password,
  });

  Future<void> signOut();

  Future<void> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  Future<void> updateAvatar({
    required String userId,
    required String? avatarLocalPath,
  });
}

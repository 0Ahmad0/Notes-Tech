import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'data/local_auth_repository.dart';
import 'data/password_hasher.dart';
import 'domain/app_user.dart';
import 'domain/auth_repository.dart';

final Provider<PasswordHasher> passwordHasherProvider =
    Provider<PasswordHasher>((Ref ref) => PasswordHasher());

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => LocalAuthRepository(
        ref.watch(appDatabaseProvider),
        ref.watch(sharedPreferencesProvider),
        ref.watch(passwordHasherProvider),
      ),
    );

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final AuthRepository repository = ref.watch(authRepositoryProvider);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return repository.restoreSession();
  }

  Future<AppUser> signIn({
    required String username,
    required String password,
  }) async {
    final AppUser user = await ref
        .read(authRepositoryProvider)
        .signIn(username: username, password: password);
    state = AsyncData<AppUser?>(user);
    return user;
  }

  Future<AppUser> register({
    required String username,
    required String password,
  }) async {
    final AppUser user = await ref
        .read(authRepositoryProvider)
        .register(username: username, password: password);
    state = AsyncData<AppUser?>(user);
    return user;
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData<AppUser?>(null);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final AppUser? user = state.value;
    if (user == null) {
      return;
    }
    await ref
        .read(authRepositoryProvider)
        .changePassword(
          userId: user.id,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
  }
}

final AsyncNotifierProvider<AuthController, AppUser?> authControllerProvider =
    AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

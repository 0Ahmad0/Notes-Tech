enum AuthFailureCode {
  invalidCredentials,
  usernameTaken,
  invalidUsername,
  weakPassword,
  userNotFound,
  unknown,
}

sealed class AppFailure implements Exception {
  const AppFailure();

  String get code;
}

final class AuthFailure extends AppFailure {
  const AuthFailure(this.reason);

  final AuthFailureCode reason;

  @override
  String get code => 'auth.${reason.name}';
}

final class StorageFailure extends AppFailure {
  const StorageFailure(this.reason);

  final String reason;

  @override
  String get code => 'storage.$reason';
}

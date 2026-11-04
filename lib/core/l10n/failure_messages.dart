import '../../l10n/generated/app_localizations.dart';
import '../errors/app_failure.dart';

extension AppFailureMessages on AppLocalizations {
  String messageFor(Object error) {
    if (error is AuthFailure) {
      return switch (error.reason) {
        AuthFailureCode.invalidCredentials => invalidCredentials,
        AuthFailureCode.usernameTaken => usernameTaken,
        AuthFailureCode.invalidUsername => invalidUsername,
        AuthFailureCode.weakPassword => weakPassword,
        AuthFailureCode.userNotFound => invalidCredentials,
        AuthFailureCode.unknown => unexpectedError,
      };
    }
    return unexpectedError;
  }
}

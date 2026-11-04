// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Notes-Tech';

  @override
  String get splashTagline => 'Capture ideas. Keep them close.';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to open your notes.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubtitle => 'Local and private. No internet needed.';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Log out';

  @override
  String get usernameHelper =>
      '3-24 characters: lowercase letters, numbers or underscore.';

  @override
  String get usernameTaken => 'That username is already taken.';

  @override
  String get invalidUsername => 'Enter a valid username.';

  @override
  String get weakPassword => 'Use at least 8 characters.';

  @override
  String get invalidCredentials => 'Incorrect username or password.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get unexpectedError => 'Something went wrong. Please try again.';

  @override
  String get homeTitle => 'Notes-Tech';

  @override
  String get emptyNotesTitle => 'No notes yet';

  @override
  String get emptyNotesSubtitle =>
      'Tap the button below to create your first note.';

  @override
  String get newNote => 'New note';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get profile => 'Profile';

  @override
  String signedInAs(String username) {
    return 'Signed in as $username';
  }

  @override
  String get retry => 'Retry';

  @override
  String get requiredField => 'Required';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get save => 'Save';

  @override
  String get passwordChanged => 'Password updated successfully.';
}

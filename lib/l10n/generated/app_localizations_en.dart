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

  @override
  String get untitledNote => 'Untitled';

  @override
  String get noteEditorNew => 'New note';

  @override
  String get noteEditorEdit => 'Edit note';

  @override
  String get noteTitleHint => 'Title';

  @override
  String get noteBodyHint => 'Start writing...';

  @override
  String get saveNote => 'Save note';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get deleteNoteConfirm => 'Move this note to trash?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noteSaved => 'Note saved';

  @override
  String get movedToTrash => 'Moved to trash';

  @override
  String get undo => 'Undo';

  @override
  String get trash => 'Trash';

  @override
  String get restore => 'Restore';

  @override
  String get deleteForever => 'Delete forever';

  @override
  String get deleteForeverConfirm =>
      'Permanently delete this note? This cannot be undone.';

  @override
  String get emptyTrash => 'Trash is empty';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortUpdatedDesc => 'Newest first';

  @override
  String get sortUpdatedAsc => 'Oldest first';

  @override
  String get sortCreatedDesc => 'Recently created';

  @override
  String get sortTitleAsc => 'Title A-Z';

  @override
  String get viewGrid => 'Grid view';

  @override
  String get viewList => 'List view';

  @override
  String get searchNotes => 'Search notes';

  @override
  String get noSearchResults => 'No matching notes';

  @override
  String get filterAll => 'All';

  @override
  String get filterText => 'Text';

  @override
  String get filterAudio => 'Audio';

  @override
  String get filterImage => 'Images';

  @override
  String get filterFiles => 'Files';

  @override
  String get colorLabel => 'Color';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get moreOptions => 'More';

  @override
  String get discardChanges => 'Discard changes?';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get discard => 'Discard';

  @override
  String get noteType => 'Type';

  @override
  String get emptyNoteError => 'Add a title or some text first.';

  @override
  String get notesDisplay => 'Notes display';

  @override
  String get attachments => 'Attachments';

  @override
  String get addImage => 'Image';

  @override
  String get addAudio => 'Record';

  @override
  String get addFile => 'File';

  @override
  String get pendingAttachmentsHint =>
      'Attachments will be saved with the note.';

  @override
  String get removeAttachment => 'Remove attachment';

  @override
  String get attachmentTooLarge => 'That file is too large.';

  @override
  String get attachmentFailed => 'Could not add the attachment.';

  @override
  String get fileMissing => 'File missing';

  @override
  String get microphoneDenied =>
      'Microphone permission is needed to record audio.';

  @override
  String get recordingFailed => 'Recording failed. Please try again.';

  @override
  String get recordAudio => 'Record audio';

  @override
  String get recording => 'Recording';

  @override
  String get stopRecording => 'Stop';

  @override
  String get useRecording => 'Use recording';

  @override
  String get audioPlaybackFailed => 'Could not play this audio.';

  @override
  String get playAudio => 'Play audio';

  @override
  String get pauseAudio => 'Pause audio';

  @override
  String get colorDefault => 'Default';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorMint => 'Mint';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorPeach => 'Peach';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorSlate => 'Slate';

  @override
  String get reminders => 'Reminder';

  @override
  String get addReminder => 'Add reminder';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get reminderInPast => 'Choose a time in the future.';

  @override
  String reminderSet(String date) {
    return 'Reminder set for $date';
  }

  @override
  String get reminderNotificationBody => 'You have a note reminder.';

  @override
  String get reminderFailed => 'Could not set the reminder.';

  @override
  String get notificationsDisabled =>
      'Notifications are disabled for Notes-Tech.';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsOn => 'Notifications are enabled.';

  @override
  String get notificationsOff => 'Notifications are off.';

  @override
  String get enableNotifications => 'Enable';

  @override
  String get font => 'Font';

  @override
  String get fontSystem => 'System';

  @override
  String get fontPlexArabic => 'IBM Plex Arabic';

  @override
  String get privacy => 'Privacy';

  @override
  String get localOnlyNotice =>
      'Your notes are stored only on this device. There is no account server or cloud backup yet, so uninstalling the app or losing the device removes your data.';

  @override
  String editedDate(String date) {
    return 'Edited $date';
  }
}

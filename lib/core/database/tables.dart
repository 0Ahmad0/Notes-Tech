import 'package:drift/drift.dart';

@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get usernameNormalized => text().unique()();
  TextColumn get usernameDisplay => text()();
  TextColumn get passwordHash => text()();
  TextColumn get salt => text()();
  TextColumn get hashParams => text()();
  TextColumn get avatarLocalPath => text().nullable()();
  TextColumn get firebaseUid => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(
  name: 'notes_owner_deleted_updated',
  columns: {#ownerId, #deletedAtUtc, #updatedAtUtc},
)
@TableIndex(name: 'notes_owner_type', columns: {#ownerId, #type})
@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text().withDefault(const Constant('text'))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  TextColumn get colorKey => text().withDefault(const Constant('default'))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAtUtc => dateTime()();
  DateTimeColumn get updatedAtUtc => dateTime()();
  DateTimeColumn get deletedAtUtc => dateTime().nullable()();
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get syncState => text().withDefault(const Constant('localOnly'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(name: 'attachments_note', columns: {#noteId})
@DataClassName('AttachmentRow')
class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()();
  TextColumn get mimeType => text()();
  TextColumn get originalName => text()();
  TextColumn get relativeLocalPath => text()();
  IntColumn get byteSize => integer().withDefault(const Constant(0))();
  TextColumn get checksum => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get remoteStoragePath => text().nullable()();
  TextColumn get syncState => text().withDefault(const Constant('localOnly'))();
  DateTimeColumn get deletedAtUtc => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(name: 'reminders_owner_time', columns: {#ownerId, #remindAtUtc})
@DataClassName('ReminderRow')
class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get ownerId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get remindAtUtc => dateTime()();
  TextColumn get timezoneId => text()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastScheduledAtUtc => dateTime().nullable()();
  IntColumn get notificationId => integer().unique()();
  DateTimeColumn get deliveredAtUtc => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('UserPreferenceRow')
class UserPreferences extends Table {
  TextColumn get ownerId =>
      text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get locale => text().withDefault(const Constant('system'))();
  TextColumn get fontPreset => text().withDefault(const Constant('system'))();
  TextColumn get viewMode => text().withDefault(const Constant('grid'))();
  TextColumn get sortOrder =>
      text().withDefault(const Constant('updatedDesc'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{ownerId};
}

@DataClassName('SyncOutboxRow')
class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  IntColumn get payloadRevision => integer().withDefault(const Constant(0))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAtUtc => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAtUtc => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

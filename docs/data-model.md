# Notes-Tech — Data model

All identifiers are client-generated UUID v4 strings. All timestamps are UTC.

## users

| Column | Type | Notes |
|---|---|---|
| id | TEXT PK | Stable local account ID |
| usernameNormalized | TEXT UNIQUE | Lowercase, validated |
| usernameDisplay | TEXT | Original casing shown in UI |
| passwordHash | TEXT | Base64 PBKDF2 hash |
| salt | TEXT | Base64 random salt |
| hashParams | TEXT | e.g. `pbkdf2-sha256:120000:256` |
| avatarLocalPath | TEXT NULL | Relative app-private path |
| firebaseUid | TEXT NULL | Reserved for Phase 2 |
| createdAtUtc / updatedAtUtc | DATETIME | Audit |

## notes

| Column | Type | Notes |
|---|---|---|
| id | TEXT PK | Stable note ID |
| ownerId | TEXT FK users.id | Cascades on user delete |
| type | TEXT | `text`, `audio`, `image`, `file` |
| title / body | TEXT | Text content |
| colorKey | TEXT | Semantic palette key |
| isPinned / isArchived | BOOL | Default false |
| createdAtUtc / updatedAtUtc | DATETIME | Audit |
| deletedAtUtc | DATETIME NULL | Soft-delete tombstone |
| revision | INT | Sync bookkeeping |
| syncState | TEXT | `localOnly`, `pending`, `synced`, `failed` |

## attachments

| Column | Notes |
|---|---|
| id, noteId | Stable ID, parent note |
| kind, mimeType, originalName | Media metadata |
| relativeLocalPath, byteSize, checksum | App-private file metadata |
| durationMs | Audio duration, nullable |
| remoteStoragePath | Phase 2 |
| syncState, deletedAtUtc | Lifecycle |

## reminders

| Column | Notes |
|---|---|
| id, noteId, ownerId | Ownership |
| remindAtUtc, timezoneId | Schedule |
| enabled, lastScheduledAtUtc | State |
| notificationId | Stable 32-bit platform ID |
| deliveredAtUtc | Best-effort tracking |

## user_preferences

Per-user `themeMode`, `locale`, `fontPreset`, `viewMode`, `sortOrder`.

## sync_outbox

Reserved for Phase 2: `id`, `ownerId`, `entityType`, `entityId`, `operation`,
`payloadRevision`, `attempts`, `nextRetryAtUtc`, `lastError`, `createdAtUtc`.

## Indexes

`notes(ownerId, deletedAtUtc, updatedAtUtc)`, `notes(ownerId, type)`,
`attachments(noteId)`, `reminders(ownerId, remindAtUtc)`.

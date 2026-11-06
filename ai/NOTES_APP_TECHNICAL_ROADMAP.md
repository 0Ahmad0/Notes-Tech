# Notes App — Technical Roadmap & Implementation Tasks

> **Project:** Flutter Notes App  
> **Approach:** Offline-first, feature-first modular architecture  
> **Phases:** 1. Complete Local App → 2. Firebase Authentication & Sync  
> **Updated:** 2026-11-06  
> **Status:** Phase 1 implementation  
> **Platforms:** Android / iOS initially (confirm desktop/web support separately)

## 0. Product vision and scope

Build an elegant, fast, accessible notes app with an Apple-inspired visual language (not a copy of proprietary interfaces), supporting:

- [ ] Registration/login using a **unique username + password**.
- [ ] Text, audio, image, and document/file notes.
- [ ] Create, read, update, delete; restore from trash (soft delete).
- [ ] Time-based **local notifications** per note.
- [ ] Grid/List switch, persisted per user.
- [ ] Per-note color, with readable light/dark contrast.
- [ ] Filter: All / Text / Audio / Image / Files; plus search and sort.
- [ ] User profile with username and replaceable avatar.
- [ ] Settings: Arabic/English, system/light/dark theme, Arabic/Latin font presets.
- [ ] Existing app logo from `assets/` as the brand asset.
- [ ] Offline operation first, then Firebase account + metadata/media synchronization.

### Scope boundaries

- **Phase 1:** All features work with no network; accounts and usernames are unique **on the device/database only**. Local login is a device-local account, not an internet identity.
- **Phase 2:** Global username uniqueness, real cross-device sign-in, backups and sync. Firebase integration must not break local-only notes.
- One note has a *primary type* (`text`, `audio`, `image`, `file`) and may have attachments. Avoid adding several competing note models.
- First release: one-time reminders. Repeating reminders, collaboration, note-sharing, OCR/transcription, and end-to-end encryption are out of scope unless separately approved.
- Primary device is mobile. No promises about web/desktop notification parity.

## 1. Key architectural decisions (ADRs)

### ADR-001 — Offline-first source of truth

- **SQLite/Drift is the UI's primary data source in both phases.**
- Read notes from Drift streams, write to local tables first, then enqueue sync operations when cloud is enabled.
- No UI widget talks directly to Firebase or raw Drift.
- Interfaces hide persistence: `NotesRepository`, `AuthRepository`, `MediaRepository`, `SettingsRepository`, `ReminderScheduler`, `SyncRepository`.
- Keep a small number of application services/use-cases for multi-step operations; don't create one class per trivial getter/setter.

### ADR-002 — Data and file ownership

- Each note belongs to `ownerId` (stable local UUID, with optional linked cloud UID later).
- Each note and attachment gets a **client-generated UUID** (same stable ID across sync).
- Save metadata in Drift, media in **app-private persistent storage**. Never store large binary media blobs in SQLite or store only ephemeral picker/cache URIs.
- Store **relative app-managed paths**, not immutable absolute device paths; `MediaRepository` resolves them.
- When imported, stream/copy the file to permanent storage; capture byte size, MIME type, and checksum if appropriate.
- Use `createdAtUtc`, `updatedAtUtc`, `deletedAtUtc`, `remindAtUtc`, and timezone ID for reminders; render local time in UI.
- Database migrations are versioned and tested.

### ADR-003 — Authentication and security

- Phase 1: device-local registration and login, normalized username with a UNIQUE SQLite index **scoped to this DB**.
- Define username rules (e.g., 3–24 characters; ASCII lowercase letters, digits, underscore), case-insensitive uniqueness through normalization. Show display name independently if needed.
- **Never store plaintext or reversible passwords.** Use a reviewed password hashing/KDF implementation (prefer Argon2id with per-user salt and documented cost parameters; use PBKDF2-HMAC only if vetted platform/library constraints require it). Verify available packages/platform support before selecting the implementation.
- Persist no password in shared_preferences; use platform secure storage for appropriate secrets/keys, never as a substitute for password hashing.
- Local-only login does **not** protect notes against a compromised/rooted device; evaluate optional encrypted-at-rest storage if threat model requires it. Explicitly test logout/account switching for data isolation.
- Phase 2: Firebase Auth has **email/password**, not direct native **username/password** sign-in. To preserve username-only UX, implement a secure server-side credential exchange using Cloud Functions/Cloud Run + Admin SDK, rate limiting, and Firebase custom tokens; enforce globally unique usernames in a server-owned registry with atomic reservation. Do **not** create predictable pseudo-emails or expose email lookups to clients.
- Define account linking / local-to-cloud migration, including user consent and handling username conflicts, **before** enabling sync.

### ADR-004 — Sync strategy

- No Firebase SDK dependency in Phase 1 feature/domain code. Keep cloud adapters in `data/remote`/`sync` added during Phase 2.
- Local `syncState` (`localOnly`, `pending`, `synced`, `failed`) and an **outbox** for changes are designed early, but networking starts only in Phase 2.
- Keep soft-delete **tombstones** until deletion is acknowledged across devices; do not immediately remove sync records.
- Conflict policy: default **last-write-wins** with server timestamps + revision checks and an explicit conflict-handling UX for simultaneous edits; don't silently overwrite potentially important text when two devices edit offline. Define server-authoritative revision ordering to avoid relying solely on device clocks.
- Cloud metadata: Firestore; attachments/avatars: Cloud Storage. Files upload before publishing metadata references; retries are idempotent.
- Reminders are **scheduled on each device locally** from its local DB. Do not send duplicate local and FCM reminders. Sync reminder metadata; schedule/cancel on each client.

### ADR-005 — UI and state

- `flutter_riverpod` for state/DI; `go_router` for redirects and navigation.
- Flutter Material/Cupertino primitives with a small custom design system: Apple-inspired spacing, typography, radius, animations, translucency, native interactions and haptics, without unnecessarily nesting CupertinoApp and MaterialApp.
- Theme via semantic `ColorScheme` + custom note palette; verify foreground contrast in both modes.
- Use minimal dependencies; profile startup time, app size, image cache, and scrolling before optimization.

## 2. Recommended packages (verify compatibility against project Flutter/Dart SDK before pinning)

| Purpose | Package | Decision |
|---|---|---|
| State and dependency injection | `flutter_riverpod` | Core |
| Database | `drift`, `drift_flutter`, `sqlite3` (as needed) | Core |
| Generation | `drift_dev`, `build_runner` | Dev only |
| Routing | `go_router` | Core |
| Settings | `shared_preferences` (`SharedPreferencesAsync`) | Lightweight preferences only |
| Notifications | `flutter_local_notifications`, `timezone`, timezone-data initialization | Core |
| Audio recording | `record` | On-demand microphone access |
| Audio playback | `just_audio` | Playback with proper resource disposal |
| Gallery/camera | `image_picker` | OS pickers where possible |
| Files | `file_picker` | OS document picker |
| Application folders | `path_provider`, `path` | Persistent file management |
| Icons | `iconsax_flutter` | Check license and glyph availability |
| UUIDs | `uuid` | Stable local identifiers |
| Small UI preferences | Flutter SDK + `shared_preferences` | No extra theme framework required |
| Fonts | Bundled fonts declared in `pubspec.yaml` | Avoid network runtime fonts |
| Localization | Flutter `gen_l10n` + `flutter_localizations`, `intl` | Arabic/English + RTL |
| Secure storage | `flutter_secure_storage` | Only for secrets requiring it |
| Firebase, phase 2 | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `cloud_functions` | Add when phase 2 starts |
| Crash monitoring, optional | `firebase_crashlytics` | Not required for local MVP |

**Avoid by default:** multiple state managers, Hive and Drift together, unnecessary ORM layers, huge media data in app state, background polling, separate Firebase notification system for the same reminders.

**Package installation policy:** don't hardcode old dependency versions. Verify current versions, Flutter/Dart minimum requirements, Android/iOS setup, licenses and maintenance; pin compatible resolved versions and commit `pubspec.lock` for the app.

## 3. Proposed project structure

```text
notes_app/
├── assets/
│   ├── images/                 # existing logo + artwork
│   ├── fonts/                  # bundled licensed Arabic/Latin font files
│   └── icons/                  # optional custom assets
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   ├── router/app_router.dart
│   │   ├── bootstrap/bootstrap.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       ├── app_colors.dart
│   │       └── app_typography.dart
│   ├── core/
│   │   ├── database/           # drift tables, DAOs, migration strategy
│   │   ├── errors/             # typed failures
│   │   ├── storage/            # app-private media paths and file I/O
│   │   ├── notifications/      # platform scheduler + permission facade
│   │   ├── localization/       # ARB localization resources
│   │   ├── widgets/            # genuinely reused UI only
│   │   └── utils/
│   └── features/
│       ├── auth/
│       │   ├── domain/         # account + repository contracts
│       │   ├── data/           # local auth implementation
│       │   └── presentation/   # login, register, providers
│       ├── notes/
│       │   ├── domain/         # note entity, filters, repository contract
│       │   ├── data/           # local repo, DAO adapter
│       │   └── presentation/   # home, note editor, details, components
│       ├── media/
│       │   ├── domain/
│       │   ├── data/
│       │   └── presentation/   # record/player/picker UI
│       ├── reminders/
│       │   ├── domain/
│       │   ├── data/
│       │   └── presentation/
│       ├── profile/
│       │   ├── data/
│       │   └── presentation/
│       ├── settings/
│       │   ├── data/
│       │   └── presentation/
│       └── sync/               # EMPTY/interface-first; remote implementation in phase 2
├── l10n/
│   ├── app_ar.arb
│   └── app_en.arb
├── test/
│   ├── unit/
│   ├── widget/
│   └── fixtures/
├── integration_test/
├── docs/
│   ├── adr/
│   ├── data-model.md
│   ├── design-system.md
│   └── testing.md
└── pubspec.yaml
```

**Rule:** Use `domain/data/presentation` subfolders only where useful; a tiny feature should not receive six empty layers. Features may depend on `core`, but not directly on the data implementation of another feature.

## 4. Database schema — initial design

### `users`

| Column | Purpose |
|---|---|
| `id` (TEXT PK UUID) | Local stable account ID |
| `usernameNormalized` (TEXT UNIQUE) | Case-insensitive normalized username |
| `usernameDisplay` (TEXT) | Username shown to user |
| `passwordHash` / `salt` / `hashParams` | Password verifier metadata only |
| `avatarLocalPath` (TEXT nullable) | Local avatar |
| `firebaseUid` (TEXT nullable) | Linked cloud identity, phase 2 |
| `createdAtUtc`, `updatedAtUtc` | Audit timestamps |

### `notes`

| Column | Purpose |
|---|---|
| `id` (TEXT PK UUID) | Stable client-generated ID |
| `ownerId` (TEXT FK, indexed) | User data isolation |
| `type` (TEXT enum) | `text/audio/image/file` |
| `title`, `body` | Textual fields |
| `colorKey` | Semantic color ID, not device-specific hex text |
| `isPinned`, `isArchived` | Usability flags |
| `createdAtUtc`, `updatedAtUtc` | UTC timestamps |
| `deletedAtUtc` nullable | Soft-delete tombstone |
| `revision`, `syncState` | Future sync bookkeeping |

### `attachments`

| Column | Purpose |
|---|---|
| `id` (TEXT PK UUID) | Stable ID |
| `noteId` (TEXT FK, indexed) | Parent note |
| `kind`, `mimeType`, `originalName` | Media type/metadata |
| `relativeLocalPath`, `byteSize`, `checksum` | App-managed file metadata |
| `durationMs` nullable | Audio duration |
| `remoteStoragePath` nullable | Phase 2 blob path |
| `syncState`, `deletedAtUtc` nullable | Cloud lifecycle |

### `reminders`

| Column | Purpose |
|---|---|
| `id` (TEXT PK UUID) | Stable reminder ID |
| `noteId`, `ownerId` | Ownership |
| `remindAtUtc`, `timezoneId` | Reminder instant + timezone context |
| `enabled`, `lastScheduledAtUtc` | Scheduling state |
| `notificationId` (INT) | Persistent unique platform notification identifier |
| `deliveredAtUtc` nullable | Optional best-effort delivery tracking (not proof of display) |

### `sync_outbox` (Phase 2 runtime; schema can be prepared earlier)

`id`, `ownerId`, `entityType`, `entityId`, `operation`, `payloadRevision`, `attempts`, `nextRetryAtUtc`, `lastError`, `createdAtUtc`.

**Indexes:** `notes(ownerId, deletedAtUtc, updatedAtUtc)`, `notes(ownerId,type)`, `attachments(noteId)`, `reminders(ownerId,remindAtUtc)`; all repository queries must filter by owner. Add full-text search only when profiling/requirements justify SQLite FTS.

**Small user preferences:** user-specific `themeMode`, `locale`, `fontPreset`, `viewMode`, `sortOrder` may be stored in a user-scoped preferences table (ideal for cloud portability) or carefully namespaced `shared_preferences` keys for phase 1. Preserve both current behavior and migration path.

## 5. UI/UX specification

### Design direction

- Inspired by Apple Notes: clear hierarchy, spacious composition, restrained blur, rounded cards, predictable gestures, elegant transitions and light haptics.
- Avoid overdecorated gradients and unreadable translucent text. Support reduced motion and Dynamic Type/text scaling.
- Main navigation: Home, Search (may be in Home), Profile/Settings; prominent create action.
- Home toolbar: brand/logo, title, search, Grid/List toggle, filter chips, sort menu, profile avatar.
- Quick-create sheet: Text / Voice / Image / File; recorder and picker open only on user action.
- Note card: semantic color, title, short preview/media icon, updated time, reminder indicator; context menu: Edit / Pin / Change color / Archive / Delete.
- Note editor: explicit Save/Done and autosave/debounce only after reliable persistence, unsaved-change handling, keyboard-aware layout.
- Note details: audio player, image display, file open/share where platform allows, reminder scheduling.
- Profile: avatar picker, username, account information, change password.
- Settings: System/Light/Dark, Arabic/English, default/system font and two curated font combinations, privacy, notification settings.

### Font and RTL strategy

- Arabic: e.g., **IBM Plex Sans Arabic** or **Cairo** (bundle correct licensed files).
- Latin: e.g., **Inter** or platform system font; use font fallback that preserves Arabic shaping.
- Respect RTL for directional layouts, icon mirroring when meaningful, alignment, dates and mixed Arabic/English strings.
- Store language/font choice; apply without app restart. The logo asset filename/path must be confirmed from existing project before wiring it.

### Suggested semantic note colors (adjust during accessibility tests)

`yellow`, `mint`, `sky`, `lavender`, `peach`, `rose`, `slate` — define separate light/dark surfaces and readable text/icon colors. Persist only the semantic key, not a full `Color` object.

## 6. Work plan — Phase 1: Fully local app

### EPIC 01 — Foundation / repository / conventions

- [ ] **T01.01** Inspect existing Flutter project, SDK versions and `assets/` logo; preserve package ID and existing files. **DoD:** project builds cleanly before changes.
- [ ] **T01.02** Record architecture decisions, feature scope, naming and lint rules. **DoD:** `docs/adr/` and README updated.
- [ ] **T01.03** Create feature-first folder skeleton; enable recommended `flutter_lints` / strict analyzer settings. **DoD:** `flutter analyze` passes.
- [ ] **T01.04** Add minimum dependencies, lockfile, codegen scripts and CI commands. **DoD:** reproducible dependency resolution and build.
- [ ] **T01.05** Configure app icon/splash based on the supplied logo; ensure contrast. **DoD:** correct asset rendering on Android/iOS.
- [ ] **T01.06** Define typed errors/failures, result handling and centralized logging with no secret/PII leakage. **DoD:** consistent UI error states.

**Dependencies:** none. **Priority:** P0.

### EPIC 02 — Design system, theme, localization, navigation

- [ ] **T02.01** Build semantic color palette + note color tokens for light/dark themes. **DoD:** all major widgets readable in both modes.
- [ ] **T02.02** Build typography presets, bundled Arabic/Latin fonts and fallback rules. **DoD:** Arabic shaping, English typography and text scaling tested.
- [ ] **T02.03** Setup `gen_l10n` with `app_ar.arb`, `app_en.arb` and RTL review. **DoD:** no user-facing hardcoded strings in UI.
- [ ] **T02.04** Build shared app UI primitives: buttons, inputs, sheet, note card, empty/loading/error state. **DoD:** reusable and minimal widget APIs.
- [ ] **T02.05** Configure routes and protected route guard. **DoD:** unauthenticated users cannot navigate to notes.
- [ ] **T02.06** Wire persisted per-user theme, language, font and grid/list preferences. **DoD:** settings survive restart/account switch.

**Dependencies:** EPIC 01. **Priority:** P0.

### EPIC 03 — Local persistence and file system

- [ ] **T03.01** Define Drift tables, constraints, foreign keys, indexes and migration strategy. **DoD:** schema documented + generated code committed as appropriate.
- [x] **T03.02** Build DB singleton/provider and owner-scoped DAO queries. **DoD:** accounts cannot query each other's data through repositories.
- [ ] **T03.03** Add migration, transaction and repository tests using in-memory DB. **DoD:** create/update/delete/read tests pass.
- [ ] **T03.04** Implement app-private media service (copy, read, rename, safe delete, path resolution). **DoD:** picked files persist after temp cache cleanup.
- [ ] **T03.05** Add safe rollback/cleanup for failed note+attachment writes and orphan cleanup. **DoD:** no broken references after interrupted operations.
- [ ] **T03.06** Implement export/backup strategy decision: at minimum document uninstall/device-loss risks; optional local ZIP export in later scope. **DoD:** clear retention policy.

**Dependencies:** EPIC 01. **Priority:** P0.

### EPIC 04 — Local authentication and profile

- [ ] **T04.01** Define username normalization/validation and password policy. **DoD:** duplicate usernames rejected atomically by DB constraint.
- [ ] **T04.02** Implement vetted salted password hashing/verification; do not store raw passwords. **DoD:** tests check hash differences/same-password verification.
- [ ] **T04.03** Build sign-up and login flows with explicit input validation and safe error messages. **DoD:** a user can register, log out and log in offline.
- [ ] **T04.04** Implement locally persisted active session with scoped account ID and documented threat model. **DoD:** app reopens to correct account, no cross-account note leaks.
- [ ] **T04.05** Add profile screen, avatar import/replace and username display. **DoD:** avatar persists after restart.
- [ ] **T04.06** Add change-password flow with current-password verification. **DoD:** old password stops working.
- [ ] **T04.07** Define future cloud-link consent flow without adding Firebase dependency. **DoD:** domain interface supports cloud UID linking later.

**Dependencies:** EPIC 02, 03. **Priority:** P0.

### EPIC 05 — Notes CRUD and home experience

- [ ] **T05.01** Implement immutable note entity + repository contract and local adapter. **DoD:** UI does not import Drift table implementations.
- [ ] **T05.02** Implement create/edit/save/delete (soft delete) and restore; archive/pin optional but recommended. **DoD:** data survives force-stop/relaunch.
- [ ] **T05.03** Build responsive grid/list home with persisted per-user mode. **DoD:** smooth switching, no state loss.
- [ ] **T05.04** Build type filter chips (All/Text/Voice/Image/File) plus sort by recent/old/title. **DoD:** filters compose correctly with owner and deletion checks.
- [ ] **T05.05** Add search across title/body (local only), debounced input. **DoD:** empty/results/error cases covered.
- [ ] **T05.06** Implement note color picker and correct contrast in both themes. **DoD:** colors persist and remain legible.
- [ ] **T05.07** Build text note editor, unsaved changes and keyboard interaction. **DoD:** tested for long Arabic/English text.
- [x] **T05.08** Add deletion confirmation/undo and Trash flow. **DoD:** accidental delete recoverable.

**Dependencies:** EPIC 02, 03, 04. **Priority:** P0.

### EPIC 06 — Audio, image and file notes

- [ ] **T06.01** Implement microphone permission/request flow **only** when recording starts. **DoD:** denial and permanently-denied path handled.
- [ ] **T06.02** Record AAC/M4A (verify platform support), pause/resume/stop/cancel, max-duration/size guidance. **DoD:** audio survives app restart.
- [ ] **T06.03** Implement playback, progress seek/pause, lifecycle interruption and resource disposal. **DoD:** only active audio plays, no leaked players.
- [ ] **T06.04** Import image(s) through platform picker, save app-owned copies and generate efficient thumbnails. **DoD:** image notes load offline from permanent storage.
- [ ] **T06.05** Import documents via system file picker; validate MIME, extension and max size. **DoD:** file notes persist and open safely via supported platform handling.
- [ ] **T06.06** Handle limited storage, missing files, unsupported formats and cancelled pickers. **DoD:** useful recovery messages, no broken UI.
- [ ] **T06.07** Integrate media with note CRUD and deletion lifecycle. **DoD:** cleanup respects Trash retention and eventual sync state.

**Dependencies:** EPIC 03, 05. **Priority:** P0.

### EPIC 07 — Local reminders and permissions

- [ ] **T07.01** Define reminder domain contract/state and integer notification-ID mapping; ensure IDs never collide across users. **DoD:** schedule/cancel/update is idempotent.
- [ ] **T07.02** Initialize `flutter_local_notifications` and timezone database before scheduling. **DoD:** scheduling honors device timezone and DST.
- [ ] **T07.03** Add Android 13+ notification runtime permission (`POST_NOTIFICATIONS`) with contextual explanation. **DoD:** allow/deny cases tested.
- [ ] **T07.04** Select `inexact` as safe fallback; when precise timing is essential, use `SCHEDULE_EXACT_ALARM` and system special-access request/check. **DoD:** no silent assumption that exact permission is granted; do not use restricted `USE_EXACT_ALARM` without eligibility review.
- [ ] **T07.05** Configure required notification receivers, reboot rescheduling (`RECEIVE_BOOT_COMPLETED`) and version-specific manifest/Gradle/desugaring settings **as documented by pinned plugin**. **DoD:** reminders reappear after reboot as supported.
- [ ] **T07.06** Schedule notification on creation; cancel/reschedule on note edit, reminder edit, deletion, logout/account switch, and profile removal. **DoD:** no stale or cross-account notifications.
- [ ] **T07.07** Handle permission revoked, time/timezone changes, daylight saving, app upgrade and Android battery restrictions. **DoD:** user sees clear degraded state where delivery can be delayed.
- [x] **T07.08** Handle notification taps via navigation to the owned note; test cold start and locked screen. **DoD:** correct note opens after account authorization.
- [ ] **T07.09** Test on real Android 12/13/14/15+ devices or emulators, plus iOS permissions and behavior. **DoD:** scenario matrix signed off.

**Dependencies:** EPIC 02, 03, 04, 05. **Priority:** P0.

**Permissions policy (Android):**

| Capability | Permission / access | Trigger |
|---|---|---|
| Record audio | `RECORD_AUDIO` | When user taps Record |
| Show notifications, Android 13+ | `POST_NOTIFICATIONS` | When enabling reminder notifications |
| Rebuild schedules after reboot | `RECEIVE_BOOT_COMPLETED` | Manifest, no user runtime prompt |
| Exact clock-time alarms, where justified | `SCHEDULE_EXACT_ALARM` | Special app-access settings (not ordinary runtime grant) |
| Pick images/files | System Photo Picker / Storage Access Framework | Usually no broad storage permission required |
| Camera (only if used) | `CAMERA` according to selected plugin/device flow | On camera feature use |

Avoid requesting `MANAGE_EXTERNAL_STORAGE`, broad media permissions, `USE_EXACT_ALARM`, or foreground microphone service permissions without a concrete reviewed need. For iOS, configure required `Info.plist` usage strings and notification authorization. Scheduled local notifications are **best effort** under OS power and scheduling policies.

### EPIC 08 — Settings and polish

- [x] **T08.01** Build settings screen for theme, language, font, notification status and view preference. **DoD:** every setting persists and immediately updates UI.
- [x] **T08.02** Add skeleton/empty/error UX for all note types and denied permissions. **DoD:** no blank or broken screens.
- [x] **T08.03** Add accessibility labels, focus order, min touch targets and screen-reader checks. **DoD:** Arabic/English supported.
- [ ] **T08.04** Optimize long lists, thumbnails, audio disposal and DB query indexes based on profiling. **DoD:** no obvious frame jank on midrange device with 1,000+ notes.
- [x] **T08.05** Add privacy/data retention explanation, local-only warning and optional app lock/backups roadmap. **DoD:** no false cloud-backup claims.

**Dependencies:** EPIC 05, 06, 07. **Priority:** P1.

### EPIC 09 — Test, stabilize, release local milestone

- [ ] **T09.01** Unit tests: username validator, password verify, note filters, colors, date conversion and reminder logic.
- [ ] **T09.02** Repository/DB tests: CRUD, owner isolation, migrations, soft deletes and attachment cleanup.
- [ ] **T09.03** Widget tests: login, home grid/list, note editors, theme, RTL, settings.
- [ ] **T09.04** Integration tests: local signup → create all note types → set reminder → relaunch → update/delete/restore.
- [ ] **T09.05** Lifecycle tests: notification permission revoked, reboot, app force-stop, file picker cancellation, low disk and offline usage.
- [x] **T09.06** CI pipeline: `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test` and Android build smoke test.
- [ ] **T09.07** Manual QA for Arabic/English, light/dark, large text, Android/iOS and app upgrade/migration.
- [ ] **T09.08** Tag release `v0.1.0-local` and archive build/test report. **DoD:** local milestone is usable entirely offline.

**Dependencies:** all Phase 1 EPICs. **Priority:** P0 gate.

### Phase 1 exit criteria (all must pass)

- [ ] Create an account and sign in without internet; other local accounts cannot see its notes.
- [ ] Store/edit/restore/delete text, recorded audio, image and document notes; media survives relaunch.
- [ ] Grid/List choice, theme, language and font survive relaunch and remain scoped correctly.
- [ ] Filter/search/color/RTL work in both themes.
- [ ] Reminder can be scheduled, edited, cancelled and reopened from notification, with accurate permission behavior.
- [ ] No plaintext password; required platform permissions are minimal and explained.
- [ ] Analyzer, core automated tests and supported-platform smoke tests pass.
- [ ] No Firebase network/account dependency in the release.

## 7. Work plan — Phase 2: Firebase and cross-device sync

### EPIC 10 — Firebase project and security design

- [ ] **T10.01** Create Firebase projects/environments (`dev`, `prod`) with separate identifiers and billing/budget alerts. **DoD:** environment isolation.
- [ ] **T10.02** Install FlutterFire CLI, configure `firebase_core` and platform files. **DoD:** builds connect to correct project.
- [ ] **T10.03** Design secure global username registration/login backend. **DoD:** uniqueness enforced server-side, rate limiting, anti-enumeration controls and abuse limits.
- [ ] **T10.04** Implement server credential verification / Firebase custom-token flow with vetted password verifier and secure transport; define credential migration and recovery. **DoD:** real username+password login across devices with no secret material in Firestore.
- [ ] **T10.05** Write/test Firestore and Storage rules by `request.auth.uid`, including document ownership, media size/content restrictions where feasible, and emulator tests. **DoD:** cross-user access denied.
- [ ] **T10.06** Define data retention, delete-account behavior, recovery and cost ceilings. **DoD:** documented operational controls.

**Dependencies:** Phase 1 completed. **Priority:** P0.

### EPIC 11 — Account linking and initial migration

- [ ] **T11.01** Implement opt-in upgrade from local account to cloud account. **DoD:** user sees consequences of enabling sync.
- [ ] **T11.02** Resolve conflicting global usernames and existing cloud identities before linking. **DoD:** no automatic account takeover.
- [ ] **T11.03** Preserve original UUIDs and map local `ownerId` to cloud UID without changing data unexpectedly. **DoD:** original notes/attachments remain intact.
- [ ] **T11.04** Create idempotent first sync/upload for existing local notes and avatars. **DoD:** retry does not duplicate content.
- [ ] **T11.05** Handle aborted linking, quota errors and sign-out safely. **DoD:** local content remains readable and recoverable.

**Dependencies:** EPIC 10. **Priority:** P0.

### EPIC 12 — Firestore data synchronization

- [ ] **T12.01** Implement cloud DTOs, converters, schema version and timestamp/revision fields; keep domain independent.
- [ ] **T12.02** Build transactional outbox writer integrated with all local mutations.
- [ ] **T12.03** Build lifecycle/network-aware sync runner with bounded retry, exponential backoff, jitter and no polling loop.
- [ ] **T12.04** Handle initial pull, paged fetches, incremental change strategy and user scope.
- [ ] **T12.05** Implement conflict detection and user-visible resolution for important divergent edits.
- [ ] **T12.06** Implement deletion tombstones, cleanup acknowledgment and multi-device restore policy.
- [ ] **T12.07** Implement remote sign-out/account switch without clearing another user's local data accidentally.
- [ ] **T12.08** Add user-visible sync status, last sync and retry action.

**Dependencies:** EPIC 10, 11. **Priority:** P0.

### EPIC 13 — Cloud Storage for media

- [ ] **T13.01** Define paths like `users/{uid}/notes/{noteId}/attachments/{attachmentId}`; enforce rules.
- [ ] **T13.02** Implement resumable/controlled uploads for large media; retry and deduplication.
- [ ] **T13.03** Keep local file as offline cache; download missing media on demand when opening a note.
- [ ] **T13.04** Publish Firestore attachment refs **only after** confirmed upload; implement retry/recovery for partial failures.
- [ ] **T13.05** Handle deletions, quota exceeded, network changes, content validation and orphan cleanup.
- [ ] **T13.06** Sync profile avatar while retaining fallback to local copy.

**Dependencies:** EPIC 12. **Priority:** P0.

### EPIC 14 — Multi-device reminders, security and final release

- [ ] **T14.01** Sync reminder metadata only; locally schedule notifications per device/account to avoid duplicates.
- [ ] **T14.02** Reconcile schedules after remote changes, login, timezone change and account switch.
- [ ] **T14.03** Test two devices editing offline/online, attachment downloads and conflicts.
- [ ] **T14.04** Test Firebase Emulator Suite rules, abuse prevention, account takeover resistance and login limits.
- [ ] **T14.05** Add operational telemetry without storing note contents, passwords, tokens or sensitive filenames in logs.
- [ ] **T14.06** Test cost limits, quotas, backup/export and account deletion.
- [ ] **T14.07** Release `v1.0.0-cloud` after staged rollout and documented rollback procedure.

**Dependencies:** EPIC 10–13. **Priority:** P0.

### Phase 2 exit criteria

- [ ] Username uniqueness is global and enforced by the server (not only Firestore client checks).
- [ ] Credential sign-in works on a second device with appropriate secure recovery mechanism.
- [ ] Existing local notes migrate without being duplicated or lost.
- [ ] Offline edits sync after reconnection and conflict cases are deterministic/user-visible.
- [ ] Large audio/images/docs are in Storage; Firestore contains metadata, not files.
- [ ] Security rules prevent cross-user reads/writes/downloads.
- [ ] Reminder scheduling remains local to each authorized device.
- [ ] Logout, unlink, deletion, quota errors and retry flows are verified.

## 8. Recommended build order and milestone checkpoints

```text
M0  Project audit + decisions + dependencies
     T01.*
       ↓
M1  Design system + Drift schema + user accounts
     T02.* + T03.* + T04.*
       ↓
M2  Notes CRUD + Grid/List + filter/search/colors
     T05.*
       ↓
M3  Media notes + permanent attachments
     T06.*
       ↓
M4  Local reminders + permissions + settings
     T07.* + T08.*
       ↓
M5  QA + Local-only release (GATE)
     T09.*
       ↓
M6  Firebase Auth architecture + secure username backend
     T10.*
       ↓
M7  Link existing accounts + sync notes and media
     T11.* + T12.* + T13.*
       ↓
M8  Multi-device testing + production release
     T14.*
```

**Delivery rule:** don't start an EPIC before its P0 dependencies and tests have passed. Every pull request should mention task IDs, tests and screenshots for UI changes.

## 9. Task execution template

Copy for each task to GitHub Issues, Linear, or a sprint board:

```md
### [Txx.yy] Task title
- **Phase:** Local / Firebase
- **Priority:** P0 / P1 / P2
- **Depends on:** Txx.yy
- **Goal:** One clear user/developer outcome
- **Implementation:** Minimal, testable steps
- **Acceptance criteria:** Observable behavior
- **Tests:** Unit / Widget / Integration / Manual device
- **Status:** TODO / IN PROGRESS / BLOCKED / REVIEW / DONE
```

### Definition of Done (applies to every task)

- [ ] Meets the task's acceptance criteria.
- [ ] Small, readable implementation; no unused abstraction or packages.
- [ ] Error/empty/loading states and permission denials considered.
- [ ] Formatting/analyzer and relevant tests pass.
- [ ] No credentials/secret data hardcoded or logged.
- [ ] Arabic/English and dark/light UI validated for user-facing changes.
- [ ] Docs updated for a schema, permission, public API or architecture change.

## 10. Risks and design checkpoints

| Risk | Prevention |
|---|---|
| Assuming local username is globally unique | Mark local-only identity; cloud registry is server-authoritative |
| Insecure local password storage | Vetted salted password hashing, no plaintext, secure secret handling |
| Firebase username login incorrectly designed | Backend-issued custom tokens; threat model and rate limiting |
| Losing media imported from picker cache | Copy media into app-private persistent storage immediately |
| Android notification timing unreliable | Permission checks, exact-alarm eligibility, inexact fallback with user transparency |
| Reminder duplicates after account switch | Owner-scoped schedules, stable IDs, resync/cancel-on-switch |
| Note deletion races with offline sync | Soft-delete tombstones, ordered outbox, idempotency |
| Cross-device simultaneous edits | Revision-aware conflict detection; recovery instead of silent overwrite |
| Expensive cloud media | Upload limits, compression policy, lazy downloads, storage budget |
| Unreadable note colors | Semantic palette and accessibility contrast tests |
| Too many abstractions/packages | Keep local app straightforward, implement remote interfaces only when needed |
| App uninstall before Cloud enabled | Disclose local data-loss risk; optional encrypted backup/export feature |

## 11. Key documentation and source references

- Drift: https://pub.dev/packages/drift
- Drift Flutter: https://pub.dev/packages/drift_flutter
- Riverpod: https://pub.dev/packages/flutter_riverpod
- GoRouter: https://pub.dev/packages/go_router
- Flutter local notifications: https://pub.dev/packages/flutter_local_notifications
- Recording: https://pub.dev/packages/record
- Images: https://pub.dev/packages/image_picker
- File picker: https://pub.dev/packages/file_picker
- Iconsax Flutter: https://pub.dev/packages/iconsax_flutter
- Flutter localization: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Android exact alarms: https://developer.android.com/develop/background-work/services/alarms
- Firebase Flutter password auth: https://firebase.google.com/docs/auth/flutter/password-auth
- Firebase custom auth: https://firebase.google.com/docs/auth/flutter/custom-auth
- Firestore security: https://firebase.google.com/docs/firestore/security/get-started
- Storage security: https://firebase.google.com/docs/storage/security

---

**Next action:** Start with **T01.01**, inspecting the real project and logo assets, then freeze the SDK baseline and implement the Local-First MVP in order. **Never turn on Firebase before the Phase 1 acceptance gate.**

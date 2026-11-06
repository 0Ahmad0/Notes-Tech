# Notes-Tech

> A beautiful, offline-first notes app built with Flutter — fast, private, and available in Arabic and English.

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](#)
[![State](https://img.shields.io/badge/State-Riverpod-6C47FF)](https://riverpod.dev)
[![Database](https://img.shields.io/badge/Database-Drift%20%2F%20SQLite-003B57)](https://drift.simonbinder.eu)
[![Status](https://img.shields.io/badge/Phase-1%20Local%20MVP-orange)](#roadmap)
[![CI](https://github.com/0Ahmad0/Notes-Tech/actions/workflows/ci.yml/badge.svg)](https://github.com/0Ahmad0/Notes-Tech/actions/workflows/ci.yml)

Notes-Tech is a Flutter notes application designed around an **offline-first** architecture. Your notes live on your device first — no account server, no internet dependency, no tracking. The long-term goal is optional cloud sync through Firebase without compromising the local-only experience.

---

## Highlights

- **Offline-first** — every feature works with zero network access
- **Local accounts** — register and sign in with a unique username and password
- **Secure by design** — passwords are hashed with PBKDF2-HMAC-SHA256 and a per-user salt; plaintext passwords are never stored
- **Bilingual UI** — full English and Arabic support with RTL layout
- **Light & dark themes** — system, light, and dark modes, persisted per user
- **Font presets** — system font or bundled IBM Plex Sans Arabic, persisted per user
- **Local-only privacy** — notes never leave the device; the app states this plainly in Settings
- **Apple-inspired design** — generous spacing, rounded cards, subtle depth, and smooth transitions
- **Extensible data model** — notes, attachments, reminders, and per-user preferences, with sync-ready client UUIDs
- **Bundled SQLite** — SQLite is compiled from source for mobile, so builds do not depend on runtime downloads

---

## App preview

The current build ships a polished splash screen, local authentication, the full notes experience (text, audio, image, and document notes), trash, reminders, and settings.

```text
Splash  ->  Login / Register  ->  Home (notes shell)  ->  Settings / Profile
```

---

## Tech stack

| Layer | Technology |
| --- | --- |
| Framework | Flutter 3.47+, Dart 3.13+ |
| State & DI | `flutter_riverpod` |
| Navigation | `go_router` |
| Database | `drift` + SQLite (compiled from source) |
| Secure hashing | `cryptography` (PBKDF2-HMAC-SHA256) |
| Preferences | `shared_preferences` (`SharedPreferencesAsync`) |
| Localization | Flutter `gen_l10n` (English + Arabic) |
| IDs | `uuid` |
| Icons & branding | Flutter Material 3 + app logo in `assets/` |

---

## Architecture

Notes-Tech follows a **feature-first, offline-first** structure. The UI never talks to SQLite directly; repositories and providers mediate every read and write.

```text
lib/
├── main.dart                     # entry point
├── app/                          # app shell, router, theme, bootstrap
│   ├── app.dart
│   ├── bootstrap/bootstrap.dart
│   ├── router/app_router.dart
│   └── theme/
├── core/                         # cross-cutting concerns
│   ├── database/                 # Drift tables, database, DAOs
│   ├── errors/                   # typed failures
│   ├── l10n/                     # failure-to-message mapping
│   ├── providers.dart            # shared providers
│   ├── utils/                    # logging
│   └── widgets/                  # reusable UI
├── features/
│   ├── auth/                     # domain / data / presentation
│   ├── notes/                    # notes CRUD, media, trash
│   ├── profile/
│   ├── settings/
│   ├── reminders/                # local notifications
│   └── ...                       # profile, settings
└── l10n/                         # ARB files + generated localizations
```

### Data model at a glance

| Table | Purpose |
| --- | --- |
| `users` | Local accounts, normalized usernames, password verifier metadata |
| `notes` | Text/audio/image/file notes, colors, pin/archive, soft delete |
| `attachments` | Metadata for app-private media files |
| `reminders` | Local notification schedules |
| `user_preferences` | Per-user theme, language, font, view mode, sort order |

All timestamps are stored in UTC. Every note query is scoped by `ownerId`, so local accounts cannot see each other's data.

---

## Getting started

### Prerequisites

- Flutter **3.47+**
- Dart **3.13+**
- Android SDK (min SDK 21) and/or Xcode for iOS

### Install & run

```bash
git clone https://github.com/0Ahmad0/Notes-Tech.git
cd Notes-Tech

flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

### Run the checks

```bash
dart format --output=none --set-exit-if-changed lib test
flutter gen-l10n
flutter analyze
flutter test
```

The suite covers password hashing, note repository behavior against an in-memory
Drift database (ownership isolation, search, filters, sorting, trash, cascades),
widget tests for login and settings, and accessibility guidelines for settings.
The same commands run in GitHub Actions on every push and pull request.

> **SQLite note:** `third_party/sqlite/sqlite3.c` is compiled by the `sqlite3` build hook for Android and iOS. Windows unit tests use the system `winsqlite3.dll`, so no network access is needed at build time.

---

## Security notes

- Passwords are verified with PBKDF2-HMAC-SHA256 using a random 16-byte salt and 120,000 iterations.
- Only a session user ID is stored in preferences — never a password or token.
- Notes are isolated per local account.
- Local-only accounts are not a substitute for device encryption; anyone with full access to an unlocked device or a rooted device may access the database.
- Firebase authentication and cross-device sync are planned for Phase 2, with server-side username uniqueness and custom tokens.

---

## Roadmap

### Phase 1 — Fully local app

- [x] Project foundation, dependencies, and strict linting
- [x] Design system, light/dark themes, English + Arabic localization
- [x] Routing with authentication guards
- [x] Drift database schema, DAOs, and migrations foundation
- [x] Local registration, login, session restore, logout
- [x] Change password and basic profile
- [x] App icon and branded splash screen
- [x] Notes CRUD, grid/list view, filters, search, colors
- [x] Audio, image, and document notes
- [x] Local reminders and notification permissions
- [x] Settings polish and accessibility
- [ ] Performance tuning on physical devices
- [ ] Manual QA and `v0.1.0-local` release

### Phase 2 — Firebase & cross-device sync

- [ ] Firebase project setup and secure username backend
- [ ] Account linking and local-to-cloud migration
- [ ] Firestore metadata sync with conflict handling
- [ ] Cloud Storage for media
- [ ] Multi-device reminders and final release

See [`ai/NOTES_APP_TECHNICAL_ROADMAP.md`](ai/NOTES_APP_TECHNICAL_ROADMAP.md) for the full task breakdown and [`docs/adr/`](docs/adr/) for architecture decisions.

---

## Contributing

Contributions, ideas, and bug reports are welcome.

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "Add my feature"`
4. Push the branch: `git push origin feature/my-feature`
5. Open a Pull Request

Please run `flutter analyze` and `flutter test` before opening a PR.

---

## Author

**Ahmad** — [@0Ahmad0](https://github.com/0Ahmad0)

---

## License

This project does not yet declare a license. Contact the author before redistributing or using it commercially.

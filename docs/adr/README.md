# Architecture Decision Records

This file records the decisions that shape Notes-Tech. The detailed roadmap lives in
`ai/NOTES_APP_TECHNICAL_ROADMAP.md`.

## ADR-001 — Offline-first source of truth

- Drift/SQLite is the primary data source for the UI in both phases.
- UI reads from repositories/providers, never from raw Drift tables.
- Local writes happen first; cloud synchronization is added later through an outbox.

## ADR-002 — Data and file ownership

- Every note and attachment has a client-generated UUID.
- Notes are scoped by `ownerId`; every query filters by owner.
- Media is copied to app-private storage immediately; only metadata lives in SQLite.
- Timestamps are stored in UTC.

## ADR-003 — Authentication and security

- Phase 1 uses device-local accounts with a unique normalized username.
- Passwords are never stored in plaintext. The local implementation uses PBKDF2-HMAC-SHA256
  with a per-user random salt and documented iteration count via `package:cryptography`.
- The active session stores only the user ID in `shared_preferences`.
- Phase 2 will use a server-owned username registry with Firebase custom tokens.

## ADR-004 — Sync strategy

- No Firebase dependency in Phase 1.
- `syncState` and `sync_outbox` exist in the schema so writes are ready for Phase 2.
- Soft-deleted notes remain as tombstones until deletion is acknowledged.

## ADR-005 — UI and state

- `flutter_riverpod` for state/DI and `go_router` for navigation.
- Material 3 primitives with a refined, Apple-inspired visual language.
- All user-facing strings come from `gen_l10n` (English + Arabic, RTL supported).
- Theme, locale and view preferences are stored per user.

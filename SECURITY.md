# ROUNDVEIL — Security policy

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Security contacts and vulnerability reports
Repository ownership/contact, private reporting channel, supported release versions and response SLA are **TBD**; do not invent addresses or promise a public reporting service.

## Security baseline
- Offline-first and least privilege; no unnecessary identity, location, contacts, camera or microphone collection.
- Treat custom family photos, voice clips and trivia as private by default; no automatic upload.
- Validate external content packs, imported media and user-generated text; avoid executable content formats.
- No secrets or access tokens in Git; use platform-secure configuration when a network extension is approved.
- Document local data deletion and backups before public release.

## Developer reporting protocol
For a suspected vulnerability, stop sharing sensitive details publicly, record reproduction steps without including real family data, and request the maintainer's preferred private reporting path. See `docs/quality/SECURITY_PRIVACY.md` for requirements.

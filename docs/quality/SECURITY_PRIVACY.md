# Privacy, family safety and content security

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Sensitive local information
Saved family/player names, optional photos, custom family trivia, audio clips and game history may identify household members. Store locally by default; do not request cloud consent by implication or transmit to telemetry without explicit new feature approval.

## Data minimization
No contacts, precise location, SMS, background microphone or unrestricted media access for base gameplay. Use system picker and minimum permissions for optional photo/sound features. For human-judged pronunciation, no microphone is required by default.

## Content and assets
Validate imports by actual MIME/type, size and decoding constraints; reject path traversal, nested archive bombs and executable payloads. Verify pack schema/content IDs and safe asset paths. No arbitrary remote HTML/JS execution from packs.

## Child/family considerations
Avoid abusive or age-inappropriate official prompts, unsupported sensitive family questions, and mechanisms encouraging unsafe real-world physical behavior or speed eating. Include host skip and pause. Offer privacy controls and local data deletion/export when specified.

## Release hygiene
No hard-coded tokens, credentials or signed keys in source. Signed package release, checksums and dependency advisories before distribution. Security review must cover backup, restore, migration and removal of media.

## Licensing
Do not ship Felix the Reaper or Overwatch copyrighted imagery/fonts/audio. Reference screenshots are **internal design documentation** only; use original or licensed replacements for a distributed app.

# Windows and Android release plan

> **Status:** ACTIVE<br>
> **Authority:** ROUNDVEIL project decisions<br>
> **Product:** ROUNDVEIL — Windows + Android via Flutter/Dart<br>
> **Rule:** This file must not be used to revive removed features or to treat rejected prototype UX as approved.

## Release prerequisites
Formal UI/UX signoff; product name/trademark verification; license review; accessibility and safety QA; complete offline acceptance; crash/recovery scenarios; content entitlement and permissions policy.

## Windows
Build release with Flutter Windows toolchain/Visual Studio C++ workload. Choose packaging (MSIX or installer) after distribution decisions. Code signing and SmartScreen reputation planning before wide release. Test install, update, uninstall and user.db preservation.

## Android
Build debug APK during development, signed test APK/AAB when publishing; configure Android Studio SDK, signing keystore kept out of Git, Play target requirements valid at submission time. Test offline/permissions/backgrounding on physical devices as well as emulator.

## Build channels
Dev, Beta, Release flavors with separate identifiers, settings and clear version display; production must not expose developer controls/placeholder content inadvertently.

## Release gate matrix
- Tests pass on Windows and Android.
- Real host-configured gameplay works offline.
- Shared countdown behavior and character reveal invariants verified.
- Every shipped Guess the Country flag has a retained source revision/license record and offline native-ratio render check; territory inclusion policy is visible and versioned.
- Mystery absent.
- Copyright/trademark check and privacy disclosures complete.
- Crash logs exclude family private content by default.
- Backward-compatible storage migration and rollback/backup tested.

## Not in initial release scope
Mandatory online servers, accounts, purchases, network multiplayer, app-store launch date or cost assumptions. Decide separately with evidence.

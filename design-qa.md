# Home Lobby Visual QA — 2026-10-14

## Reference and candidate

- Approved visual reference: `assets/brand/approved_home_v5_scene_source.webp`.
- Windows runtime: `docs/evidence/home_lobby_rebuild_2026-10-14/windows_home.png` (1267×713 captured app window).
- Android runtime: `docs/evidence/home_lobby_rebuild_2026-10-14/android_home.png` (2400×1080 physical, 915×412 logical landscape; system bars visible).
- Interaction evidence: `docs/evidence/home_lobby_rebuild_2026-10-14/android_quiz_entry.png`.
- Source of behavior: existing shell/game callbacks; no game engine, content or session-route changes in this patch.

## Implemented and verified

- Responsive three-zone Home composition with squad, prominent character presentation, profile stats and centered Quick/Create actions.
- Three large interactive Home destinations: Quiz, Word Play, Guessing Games. Removed Riddles and Memory are not present.
- Compact landscape keeps the third/add-player slot visible for a two-player squad; individual remove buttons still work.
- Actual Windows and Android Quiz selections reached the existing Quiz round-entry state.
- `flutter analyze`: clean. `flutter test`: 84 passed. Windows debug build: passed and launched. Android debug APK: built, installed and launched; sampled startup logs showed no fatal exception.

## Visual differences and remaining blockers

- The supplied Version 5 reference is a vivid, layered city arena; the runtime uses a much simpler dark indoor CustomPainter stage. Depth, color, light and scene composition are not yet faithful.
- The source shows a large hooded ROUNDVEIL mascot integrated into the scene. Runtime shows a static, unrelated 2D tactical character; no genuine 3D render or animation is present.
- The existing logo image has a baked dark rectangle that remains visible against the Home background.
- The reference lineup shows four character portraits. Runtime is data-driven and currently shows the saved two-player lineup plus an add slot; the available static portrait library remains limited.
- Android retains the OS status and gesture/navigation bars. Its usable landscape viewport differs in aspect ratio from the Windows window.

## Result

**NOT PASSED — review candidate only.** The responsive layout and entry interactions work on both platforms, but the major art/composition differences above prevent a visual-fidelity claim. The candidate is not approved; owner review is required before any approval status changes. No gameplay or content work from the deferred Batch 2 brief is claimed complete here.

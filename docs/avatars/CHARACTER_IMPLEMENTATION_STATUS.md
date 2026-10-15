# Character video implementation status

**Decision:** Option A, animated character videos, is the active v1.0.0 character-presentation direction. Experimental 3D rendering is no longer on the v1.0.0 critical path; 360-degree interaction remains deferred. A 2D still image or moving background is not character animation and must not be reported as such.

## Playback foundation

- Common Flutter API: [`video_player`](https://pub.dev/packages/video_player), using its Android ExoPlayer implementation.
- Windows implementation: [`video_player_win`](https://pub.dev/packages/video_player_win), pinned to 3.3.0 and using Windows Media Foundation. Version 3.3.0 includes a fix for black output with Flutter 3.47+ Impeller.
- Both are registered as dependencies. `OfflineLoopingVideo` plays a local asset silently, loops it, pauses while the app is inactive, disposes its native player, and requires caller-supplied still art as a fallback. A missing clip never becomes an invented video.
- Windows plugin metadata identifies its pub.dev uploader as unverified. Review the upstream source/release provenance before shipping; the plugin declares BSD-3-Clause and relies on Windows built-in media components rather than bundling an additional codec suite.
- **Runtime status: NOT VERIFIED.** The repository currently contains no video clips. Flutter tests of the wrapper or a successful build do not count as real playback.

## Measured status (2026-10-15)

| Measure | Confirmed value |
|---|---:|
| Registered still-art avatar IDs | 38 |
| Existing referenced image files | 68 |
| Distinct hashes among those image files | 68 |
| Character idle videos | 0 |
| Individual character background videos | 0 |
| Video-enabled functional profiles | 0 |
| Windows video runtime checks | 0 |
| Android video runtime checks | 0 |
| Full target characters meeting every criterion | 0 / 200 |

Still-art byte uniqueness does not establish unique character identity. Two entries currently share the label `UNIVERSITY STUDENT`; visual roster acceptance is open. Details are in [`CHARACTER_ROSTER_200.md`](CHARACTER_ROSTER_200.md) and [`CHARACTER_VIDEO_MANIFEST.md`](CHARACTER_VIDEO_MANIFEST.md).

## Next work gate

Obtain or author authentic, genuinely animated, appropriately cleared clips for a small review batch first. Before expanding beyond it: verify H.264 MP4 decoding, looping, resize/layout, pause/resume, app lifecycle, disposal, and offline playback on a Windows runtime permitted by the existing Application Control policy and on Android. Then review video packaging size/performance and publisher provenance. Do not add 200 empty avatar records or begin bulk asset production before this slice passes.

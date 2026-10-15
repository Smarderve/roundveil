# Option A playback foundation evidence — 2026-10-15

- `android_home.png` was captured from `emulator-5554` with `adb shell screencap -p` after installing the new debug APK. The device reported API 37, CPU ABI `x86_64`; the screenshot is 2400 × 1080 landscape, and `MainActivity` was resumed.
- Filtered startup log inspection found no fatal exception, Flutter error, missing asset, or missing video-plugin error.
- Debug APK SHA-256: `0B061117C9E84CF60EBD9933B8DA5059ACBC3B963A34DC097580692A38782D92`.
- Screenshot SHA-256: `83697CFA5032AAAE06B5A315FD077CB542DE75B68D6C1A679317F2A697366F31`.
- This capture proves app startup/rendering only. It is **not** evidence of video playback, an animated character, video-loop behavior, or offline media playback. No video clip currently exists in the project.
- Windows debug compilation passed; Windows runtime was not verified in this batch. The previously documented enterprise Code Integrity block remains unchanged; no security policy was altered.

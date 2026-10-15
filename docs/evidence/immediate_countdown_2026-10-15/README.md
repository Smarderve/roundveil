# Immediate Win Countdown runtime evidence — 2026-10-15

These are direct Android emulator captures from the exact APK built by the local candidate script. They are not mockups or golden images.

- `android_home.png`: ROUNDVEIL running at 2400×1080 landscape.
- `android_quiz_entry.png`: Quick Quiz opened to Round 1, Short Answer.
- `android_quiz_challenge.png`: live Quiz question, “What is the name of the first surah in the Qur’an?”
- `android_countdown.png`: captured about 350 ms after submitting `Al-Fatiha`. The displayed `10`, `CORRECT`, and `+1 POINTS` confirm immediate state transition on the tested device.

The installed app package remained the foreground `MainActivity` with a live process after launch. It later advanced to Round 2. A sampled logcat search found no fatal exception, Flutter error, missing asset, or missing-plugin error. This is a single Quiz flow on an API 37 x86_64 emulator, not full-session acceptance or ARM64 testing.

APK SHA-256: `31587d74408b8f441ec2eb43363c2723dfde4f17b544f48b89ffac3405ee6ae0`.

The Windows portable Release ZIP was built and extracted, but its executable could not start under the current managed policy. Code Integrity events 3077/3033 recorded policy `{0283ac0f-fff1-49ae-ada1-8a933130cad6}` blocking the exact extracted `roundveil.exe`. No policy changes were made. Windows gameplay therefore remains unverified.

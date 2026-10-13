# Round-format correction evidence — 2026-10-13

Captured from the freshly built debug APK on `Medium_Phone_API_37.0` (`emulator-5554`, x86_64; app in landscape). These are actual `adb exec-out screencap` captures, not test renderings.

- `android_home.png`: app launch/home.
- `android_create_game.png`: live Create Game setup.
- `android_quiz_formats.png`: Quiz round-format selectors.
- `android_quiz_round_intro.png`: Round 1, Quiz — True or False; 2 players, 4 rounds.
- `android_quiz_turn_start.png`: live True/False question and answer controls.
- `android_quiz_player2.png`: Player 2 receives a different True/False prompt; the HUD shows Player 2's own hint balance.
- `android_quiz_round2_intro.png`: after both players completed Round 1, Round 2 remains Quiz and uses Fill in the Blank.
- `android_quiz_fill_blank.png`, `android_quiz_fill_blank_active.png`: additional captures during the in-progress session; due a rapid timed transition they do not establish keyboard input completion.
- `android_mixed_config.png` / `android_mixed_selected.png`: actual setup with Mixed selected; Quiz and Word Play both selected. This verifies that choosing the first game no longer collapses the mode back to Single.
- `android_mixed_round_intro.png`: installed app started a two-round Mixed session in Word Play — Word Scramble.
- `android_mixed_word_challenge.png`: actual offline scrambled-word challenge, with typed-answer composer.
- `android_mixed_word_typed.png`: capture during the post-word progression; it shows the second scheduled round had changed to Quiz — Multiple Choice. It does not establish which keyboard events or exact response were accepted.
- `android_mixed_word_result.png`: live second-round Quiz question in the same Mixed session (turn 3 of 4). Full completion/results were not reached.

The live interactions are partial: one Quiz session verified two players sharing the True/False format and a later round changing to Fill in the Blank; a separate Mixed session started in Word Play and reached a Quiz round. They do not claim completion of a three-player/four-format run, physical keyboard answer acceptance, Guessing Games' full four-format cycle, Mixed Games final results, or app-restart persistence. Licensed Character Picture Mode remains unavailable (zero local licensed images).

The build command was `flutter build apk --debug` with the previously authorized process-only `JAVA_TOOL_OPTIONS=-Djdk.net.unixdomain.tmpdir=C:\Windows\Temp`; the variable was removed immediately after the build process. APK installation succeeded, `com.example.roundveil/.MainActivity` became top-resumed, and the launch log filter contained no fatal/Flutter/overflow matches.

# Android playability evidence — 2026-10-12

These are direct `adb screencap` captures from `Medium_Phone_API_37.0` (x86_64 emulator), 2400×1080 landscape. They are runtime captures, not screenshots embedded as app UI.

## Final debug APK observations

- `android_fresh_home.png`: ROUNDVEIL branded Home after launch.
- `android_fresh_quiz_results.png`: ten-turn Quick Quiz results; Player 1 and Player 2 each have five wins. `android_fresh_quiz_next.png` shows Player 2 receiving a distinct H₂O question after Player 1's correct-answer countdown.
- `android_country_flag_final.png`: flag-only Brazil challenge with spoken answer instruction and Reveal Answer action; no answer choices or text field.
- `android_country_revealed_final.png`: country reveal and host Correct/Wrong controls.
- `android_country_countdown_final.png` and `android_country_next_player_final.png`: correct judgement countdown and next round/flag progression.
- `android_country_offline_reveal.png`: bundled flag/reveal while emulator Wi-Fi was disabled. Wi-Fi was re-enabled after capture.
- `android_mixed_final_quiz.png`, `android_mixed_final_word.png`, `android_mixed_character_turnaway.png`, `android_mixed_country_finalapk.png`, and `android_mixed_country_flag_finalapk.png`: one-round Party Mix progressing through the four selected modules. The Word challenge was submitted without text as an incorrect answer in this device run; typed-answer correctness is verified in widget tests. The character capture shows Name Mode turn-away; Country captures show the flag-only and judgement flow. The final tap returned to the Quick Game editor, captured as `android_mixed_returned_to_editor.png`, confirming the match reached its completion/return action; a screenshot of the result screen itself was not retained.

## Other captures

- `android_play_*` and `android_mixed_*` include earlier captures made during debugging. `android_play_quiz_results.png` and `android_mixed_word.png` contain pre-fix Flutter overflow banners; they document defects that were corrected, not accepted final UI. Latest APK captures listed above show the corrected Country and Word challenge layouts.
- `android_mixed_final_country_revealed.png` is the reveal state before a wrong judgement ended the match. The final score-summary layout is covered at 800×360 by `match results fit compact landscape and expose return action` in the widget suite; a final-build mixed score-summary screenshot was not retained.

No screenshot proves Picture Mode: the local licensed character-picture count remains zero. No screenshot or build alone establishes production content-target completion or Windows gameplay readiness.

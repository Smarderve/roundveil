import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/domain/session/round_game_format.dart';
import 'package:roundveil/domain/session/session_configuration.dart';

void main() {
  test('Object Name and Object Picture are Guessing Games formats', () {
    for (final id in <String>['object_name', 'object_picture']) {
      final format = roundGameFormatById(id);
      expect(format, isNotNull);
      expect(format!.family, RoundGameFamily.guessingGames);
      expect(format.moduleId, 'guess_objects');
    }

    expect(familyForModule('guess_objects'), RoundGameFamily.guessingGames);
  });

  test('object format can be selected as a single Guessing Game session', () {
    for (final formatId in <String>['object_name', 'object_picture']) {
      final config = SessionConfiguration(
        players: const <PlayerConfiguration>[
          PlayerConfiguration(id: 'p1', displayName: 'Player 1'),
        ],
        selectedModuleIds: const <String>['guess_objects'],
        roundFormatIds: <String>[formatId],
        roundFormatsExplicit: true,
        roundCount: 1,
      );

      expect(config.canStart, isTrue, reason: formatId);
    }
  });
}

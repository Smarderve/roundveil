import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'newly approved portraits play while rejected portraits stay excluded',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'rv-pictures-game-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
      );
      final pictures = await repository.loadPlayable();
      expect(
        pictures.map((picture) => picture.id),
        containsAll(<String>[
          'commons-chinese-jackie-chan',
          'commons-chinese-jet-li',
          'commons-chinese-donnie-yen',
          'commons-chinese-chow-yun-fat',
        ]),
      );
      expect(pictures, hasLength(4));
      expect(await repository.loadExcludedBundled(), hasLength(50));
      final configuration = SessionConfiguration(
        players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
        selectedModuleIds: const <String>['guess_character'],
        roundFormatIds: const <String>['character_picture'],
        roundCount: 1,
      );
      expect(
        ActiveMatchController.validateConfiguration(
          configuration,
          pictureChallenges: pictures
              .map(
                (picture) => OfflineChallenge(
                  id: picture.id,
                  prompt: 'Identify the person shown.',
                  answer: picture.name,
                  hint: picture.hint,
                  imageFilePath: picture.path,
                  imageSource: picture.sourceTitle,
                ),
              )
              .toList(growable: false),
        ),
        isNull,
      );
    },
  );
}

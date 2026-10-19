import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'reviewed portraits play while rejected portraits stay excluded',
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
          'commons-chinese-bruce-lee',
          'commons-indian-shah-rukh-khan',
          'commons-indian-priyanka-chopra',
          'commons-indian-madhuri-dixit',
          'commons-hollywood-brad-pitt',
          'commons-hollywood-leonardo-dicaprio',
          'commons-hollywood-morgan-freeman',
          'commons-hollywood-tom-cruise',
          'commons-hollywood-julia-roberts',
          'commons-hollywood-scarlett-johansson',
          'commons-hollywood-samuel-l-jackson',
          'commons-hollywood-will-smith',
          'commons-hollywood-keanu-reeves',
          'commons-hollywood-arnold-schwarzenegger',
        ]),
      );
      expect(pictures, hasLength(44));
      expect(
        pictures.where((picture) => picture.category == 'Chinese Actors'),
        hasLength(5),
      );
      expect(
        pictures.where(
          (picture) => picture.category == 'Indian Actors and Actresses',
        ),
        hasLength(19),
      );
      expect(
        pictures.where((picture) => picture.category == 'Hollywood Actors'),
        hasLength(20),
      );
      expect(await repository.loadExcludedBundled(), hasLength(26));
      expect(
        pictures.where((picture) => picture.category.contains('Fictional')),
        isEmpty,
        reason: 'Actor portraits must not inflate fictional-character counts.',
      );
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

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'bundled offline portraits run as distinct Picture Mode turns',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'rv-pictures-game-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final pictures = await CharacterPictureRepository(
        directoryProvider: () async => temporary,
      ).loadAll();
      final configuration = SessionConfiguration(
        players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
        selectedModuleIds: const <String>['guess_character'],
        roundFormatIds: const <String>['character_picture'],
        roundCount: pictures.length,
      );
      final challenges = pictures
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
          .toList(growable: false);
      final match = ActiveMatchController(
        configuration: configuration,
        enableTimers: false,
        pictureChallenges: challenges,
      );
      addTearDown(match.dispose);

      expect(
        ActiveMatchController.validateConfiguration(
          configuration,
          pictureChallenges: challenges,
        ),
        isNull,
      );
      match.start();
      final seenIds = <String>{};
      for (var turn = 0; turn < pictures.length; turn++) {
        if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
        match.beginChallenge();
        expect(match.state.phase, MatchPhase.turnAway);
        final challenge = match.state.challenge;
        expect(seenIds.add(challenge.id), isTrue);
        expect(File(challenge.imageFilePath!).existsSync(), isTrue);
        match.revealCharacterAfterPlayerTurnsAway();
        expect(match.state.phase, MatchPhase.awaitingJudgement);
        expect(match.state.challenge.imageFilePath, isNotNull);
        match.judge(correct: true);
        expect(match.state.phase, MatchPhase.winCountdown);
        match.completeCountdown();
      }
      expect(seenIds, hasLength(pictures.length));
      expect(match.state.phase, MatchPhase.complete);
    },
  );
}

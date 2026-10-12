import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';

void main() {
  test(
    'mixed match advances through real module challenges and shared countdowns',
    () {
      final match = ActiveMatchController(
        configuration: SessionConfiguration(
          players: <PlayerConfiguration>[
            PlayerConfiguration.placeholder(1),
            PlayerConfiguration.placeholder(2),
          ],
          selectedModuleIds: const <String>[
            'quiz',
            'word_play',
            'guess_character',
            'guess_country_flags',
          ],
          roundCount: 1,
          isMixed: true,
        ),
        enableTimers: false,
      );

      match.beginChallenge();
      expect(match.state.challenge.moduleId, 'quiz');
      match.answer('Jupiter');
      expect(match.state.phase, MatchPhase.scoreAward);
      match.beginWinCountdown();
      match.completeCountdown();

      match.beginChallenge();
      expect(match.state.challenge.moduleId, 'word_play');
      match.answer(match.state.challenge.answer);
      match.beginWinCountdown();
      match.completeCountdown();

      match.beginChallenge();
      expect(match.state.challenge.moduleId, 'guess_character');
      expect(match.state.phase, MatchPhase.turnAway);
      match.revealCharacterAfterPlayerTurnsAway();
      expect(match.state.phase, MatchPhase.awaitingJudgement);
      expect(match.state.challenge.answer, 'Sherlock Holmes');
      match.judge(correct: true);
      match.beginWinCountdown();
      match.completeCountdown();

      match.beginChallenge();
      expect(match.state.challenge.moduleId, 'guess_country_flags');
      expect(match.state.phase, MatchPhase.awaitingJudgement);
      expect(match.state.challenge.choices, isEmpty);
      expect(match.state.challenge.flagAssetPath, isNotNull);
      match.revealAnswer();
      expect(match.state.answerVisible, isTrue);
      match.judge(correct: false);
      expect(match.state.phase, MatchPhase.complete);
      expect(
        match.state.scores.values.fold<int>(0, (sum, score) => sum + score),
        3,
      );
      match.dispose();
    },
  );

  test('wrong quiz answer advances without entering the win countdown', () {
    final match = ActiveMatchController(
      configuration: SessionConfiguration(
        players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
        selectedModuleIds: const <String>['quiz'],
        roundCount: 1,
      ),
      enableTimers: false,
    );

    match.beginChallenge();
    match.answer('not the answer');

    expect(match.state.phase, MatchPhase.complete);
    expect(
      match.state.scores.values.fold<int>(0, (sum, score) => sum + score),
      0,
    );
    match.dispose();
  });

  test('correct answers apply the host-configured match point value', () {
    final match = ActiveMatchController(
      configuration: SessionConfiguration(
        players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
        selectedModuleIds: const <String>['quiz'],
        roundCount: 1,
        pointsPerCorrectAnswer: 7,
      ),
      enableTimers: false,
    );

    match.beginChallenge();
    match.answer('Jupiter');

    expect(match.state.scores['player-1'], 7);
    expect(match.state.phase, MatchPhase.scoreAward);
    match.beginWinCountdown();
    expect(match.state.phase, MatchPhase.winCountdown);
    match.dispose();
  });

  test('single-game turns give each player a different offline challenge', () {
    final match = ActiveMatchController(
      configuration: SessionConfiguration(
        players: <PlayerConfiguration>[
          PlayerConfiguration.placeholder(1),
          PlayerConfiguration.placeholder(2),
        ],
        selectedModuleIds: const <String>['quiz'],
        roundCount: 1,
      ),
      enableTimers: false,
    );
    match.beginChallenge();
    final firstChallengeId = match.state.challenge.id;

    match.answer(match.state.challenge.answer);
    match.beginWinCountdown();
    match.completeCountdown();

    expect(match.state.activePlayer.displayName, 'Player 2');
    match.beginChallenge();
    expect(match.state.challenge.id, isNot(firstChallengeId));
    expect(match.state.challenge.answer, 'H₂O');
    match.dispose();
  });

  test(
    'start is blocked rather than repeating content past the verified pool',
    () {
      final configuration = SessionConfiguration(
        players: <PlayerConfiguration>[
          PlayerConfiguration.placeholder(1),
          PlayerConfiguration.placeholder(2),
        ],
        selectedModuleIds: const <String>['quiz'],
        roundCount: 6,
      );

      expect(
        ActiveMatchController.validateConfiguration(configuration),
        'quiz has 10 unique offline challenges; 12 are required for this session. Reduce rounds or players.',
      );
    },
  );

  test(
    'offline starter pack has counted, unique records for all four modes',
    () {
      expect(quizChallenges, hasLength(10));
      expect(wordChallenges, hasLength(10));
      expect(characterChallenges, hasLength(10));
      expect(countryChallenges, hasLength(7));
      for (final items in <List<OfflineChallenge>>[
        quizChallenges,
        wordChallenges,
        characterChallenges,
        countryChallenges,
      ]) {
        expect(items.map((item) => item.id).toSet(), hasLength(items.length));
        expect(items.every((item) => item.answer.trim().isNotEmpty), isTrue);
      }
    },
  );

  test('country scope and difficulty are applied before start validation', () {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
      ],
      selectedModuleIds: const <String>['guess_country_flags'],
      roundCount: 2,
      countryRegion: 'africa',
      countryDifficulty: 'mixed',
    );

    expect(
      ActiveMatchController.validateConfiguration(configuration),
      contains('2 unique offline challenges; 4 are required'),
    );
  });

  test(
    'pause and resume preserve the current challenge and answer progress',
    () {
      final match = ActiveMatchController(
        configuration: SessionConfiguration(
          players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
          selectedModuleIds: const <String>['word_play'],
          roundCount: 1,
        ),
        enableTimers: false,
      );
      match.beginChallenge();
      final challengeId = match.state.challenge.id;
      match.pause();
      expect(match.state.phase, MatchPhase.paused);

      match.resume();

      expect(match.state.phase, MatchPhase.challenge);
      expect(match.state.challenge.id, challengeId);
      expect(match.state.activePlayer.displayName, 'Player 1');
      match.dispose();
    },
  );
}

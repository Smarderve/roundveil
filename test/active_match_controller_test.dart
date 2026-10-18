import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';

void main() {
  test(
    'three players receive one common module across each game-wide round',
    () async {
      final configuration = _configuration(players: 3, rounds: 4);
      final profiles = InMemoryPlayerProfileRepository();
      await profiles.ensureProfiles(configuration.players);
      final match = ActiveMatchController(
        configuration: configuration,
        enableTimers: false,
        random: Random(41),
        profileRepository: profiles,
        matchId: 'three-player-four-rounds',
      );

      expect(match.state.totalTurns, 12);
      expect(match.moduleSchedule, hasLength(4));
      expect(match.moduleSchedule.toSet(), hasLength(4));
      match.start();
      final allChallengeIds = <String>{};
      final moduleByRound = <int, String>{};
      final formatByRound = <int, String>{};
      final challengeIdsByRound = <int, Set<String>>{};
      final playerIdsByRound = <int, List<String>>{};

      for (var turn = 0; turn < 12; turn++) {
        if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
        match.beginChallenge();
        final state = match.state;
        moduleByRound.putIfAbsent(state.round, () => state.challenge.moduleId);
        expect(state.challenge.moduleId, moduleByRound[state.round]);
        formatByRound.putIfAbsent(state.round, () => state.challenge.formatId);
        expect(state.challenge.formatId, formatByRound[state.round]);
        expect(allChallengeIds.add(state.challenge.id), isTrue);
        final roundChallenges = challengeIdsByRound.putIfAbsent(
          state.round,
          () => <String>{},
        );
        roundChallenges.add(state.challenge.id);
        final roundPlayers = playerIdsByRound.putIfAbsent(
          state.round,
          () => <String>[],
        );
        roundPlayers.add(state.activePlayer.id);
        if (turn == 0) {
          expect(await match.revealHint(), isTrue);
          expect(match.state.hintVisible, isTrue);
        }
        if (turn == 4) {
          match.answer('not-the-answer');
          expect(match.state.phase, MatchPhase.playerIntro);
          expect(match.state.secondsRemaining, 0);
          continue;
        }
        _answerCorrectly(match);
        expect(match.state.phase, MatchPhase.winCountdown);
        expect(match.state.secondsRemaining, configuration.winCountdownSeconds);
        match.completeCountdown();
      }

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(match.state.phase, MatchPhase.complete);
      expect(moduleByRound.values.toSet(), hasLength(4));
      for (var round = 1; round <= 4; round++) {
        expect(challengeIdsByRound[round], hasLength(3));
        expect(playerIdsByRound[round], <String>[
          'player-1',
          'player-2',
          'player-3',
        ]);
      }
      expect(match.state.rankings.map((row) => row.rank), <int>[1, 2, 3]);
      expect(match.state.rankings.map((row) => row.playerId), <String>[
        'player-1',
        'player-3',
        'player-2',
      ]);
      expect(match.state.rankings.map((row) => row.matchPoints), <int>[
        4,
        4,
        3,
      ]);
      expect(match.state.rankings.map((row) => row.correctAnswers), <int>[
        4,
        4,
        3,
      ]);
      expect(match.state.rankings.map((row) => row.wrongAnswers), <int>[
        0,
        0,
        1,
      ]);
      expect(match.state.rankings.map((row) => row.hintCreditsAwarded), <int>[
        5,
        3,
        1,
      ]);
      final persisted = await profiles.loadAll();
      expect(persisted.map((profile) => profile.hintCredits), <int>[
        14,
        11,
        13,
      ]);
      match.dispose();
    },
  );

  test(
    'eight mixed rounds contain two complete mode cycles without repeats',
    () {
      final match = ActiveMatchController(
        configuration: _configuration(players: 3, rounds: 8),
        enableTimers: false,
        random: Random(17),
      );
      expect(match.state.totalTurns, 24);
      expect(match.moduleSchedule.take(4).toSet(), hasLength(4));
      expect(match.moduleSchedule.skip(4).take(4).toSet(), hasLength(4));
      expect(
        match.moduleSchedule.take(4).toSet(),
        match.moduleSchedule.skip(4).toSet(),
      );

      final challengeIds = <String>{};
      match.start();
      for (var turn = 0; turn < 24; turn++) {
        if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
        match.beginChallenge();
        expect(challengeIds.add(match.state.challenge.id), isTrue);
        _answerCorrectly(match);
        expect(match.state.phase, MatchPhase.winCountdown);
        match.completeCountdown();
      }
      expect(challengeIds, hasLength(24));
      match.dispose();
    },
  );

  test('Quiz keeps one game while all players share a format per round', () {
    final configuration = SessionConfiguration(
      players: List<PlayerConfiguration>.generate(
        3,
        (index) => PlayerConfiguration.placeholder(index + 1),
      ),
      selectedModuleIds: const <String>['quiz'],
      roundFormatIds: const <String>[
        'quiz_multiple_choice',
        'quiz_true_false',
        'quiz_fill_blank',
        'quiz_short_answer',
      ],
      roundCount: 4,
    );
    expect(configuration.canStart, isTrue);
    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      random: Random(91),
    );
    expect(match.state.totalTurns, 12);
    expect(match.formatSchedule.toSet(), configuration.roundFormatIds.toSet());
    final formatByRound = <int, String>{};
    final challengeIds = <String>{};
    match.start();
    for (var turn = 0; turn < 12; turn++) {
      if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
      match.beginChallenge();
      final state = match.state;
      expect(state.challenge.moduleId, 'quiz');
      formatByRound.putIfAbsent(state.round, () => state.challenge.formatId);
      expect(state.challenge.formatId, formatByRound[state.round]);
      expect(challengeIds.add(state.challenge.id), isTrue);
      if (state.challenge.formatId == 'quiz_true_false') {
        expect(state.challenge.choices, <String>['True', 'False']);
      }
      _answerCorrectly(match);
      expect(match.state.phase, MatchPhase.winCountdown);
      match.completeCountdown();
    }
    expect(formatByRound.length, 4);
    expect(match.state.phase, MatchPhase.complete);
    match.dispose();
  });

  test('Guessing Games combines categories without becoming Mixed Games', () {
    final configuration = SessionConfiguration(
      players: List<PlayerConfiguration>.generate(
        3,
        (index) => PlayerConfiguration.placeholder(index + 1),
      ),
      selectedModuleIds: const <String>[
        'guess_character',
        'guess_country_flags',
      ],
      roundFormatIds: const <String>[
        'character_name',
        'country_name',
        'country_flag',
      ],
      roundCount: 3,
      isMixed: false,
    );
    expect(configuration.canStart, isTrue);
    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      random: Random(39),
    );
    final challengeIds = <String>{};
    match.start();
    for (var turn = 0; turn < 9; turn++) {
      if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
      match.beginChallenge();
      expect(match.state.challenge.moduleId, isNot('quiz'));
      expect(challengeIds.add(match.state.challenge.id), isTrue);
      _answerCorrectly(match);
      expect(match.state.phase, MatchPhase.winCountdown);
      match.completeCountdown();
    }
    expect(match.formatSchedule.toSet(), configuration.roundFormatIds.toSet());
    expect(match.state.phase, MatchPhase.complete);
    match.dispose();
  });

  test('Object Name turns the guesser away and clue-givers see context', () {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
      ],
      selectedModuleIds: const <String>['guess_objects'],
      roundFormatIds: const <String>['object_name'],
      roundCount: 1,
    );
    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      objectChallenges: const <OfflineChallenge>[
        OfflineChallenge(
          id: 'object-electric-drill',
          prompt: 'Used for making holes and driving screws.',
          answer: 'Electric drill',
          hint: 'A powered tool with a rotating bit.',
          category: 'Tools',
          formatAnswers: <String, String>{'object_name': 'Electric drill'},
        ),
        OfflineChallenge(
          id: 'object-kettle',
          prompt: 'Used to heat water for drinks and cooking.',
          answer: 'Kettle',
          hint: 'Often used to prepare tea.',
          category: 'Kitchen',
        ),
      ],
      random: Random(21),
    );

    match.start();
    match.beginRound();
    match.beginChallenge();
    expect(match.state.phase, MatchPhase.turnAway);
    expect(match.state.challenge.formatId, 'object_name');
    expect(match.state.challenge.content.category, anyOf('Tools', 'Kitchen'));
    expect(
      match.state.challenge.prompt,
      anyOf(
        'Used for making holes and driving screws.',
        'Used to heat water for drinks and cooking.',
      ),
    );
    expect(match.state.challenge.hint, isNot(match.state.challenge.prompt));

    match.revealCharacterAfterPlayerTurnsAway();
    expect(match.state.phase, MatchPhase.awaitingJudgement);
    match.judge(correct: true);
    expect(match.state.phase, MatchPhase.winCountdown);
    expect(match.state.secondsRemaining, configuration.winCountdownSeconds);
    match.dispose();
  });

  test('Object Picture accepts only installed images and remains distinct', () {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
      ],
      selectedModuleIds: const <String>['guess_objects'],
      roundFormatIds: const <String>['object_picture'],
      roundCount: 4,
    );
    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      objectChallenges: objectChallengeCatalog,
      random: Random(22),
    );

    match.start();
    final drawnIds = <String>{};
    for (var turn = 0; turn < 8; turn++) {
      if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
      match.beginChallenge();
      expect(match.state.phase, MatchPhase.turnAway);
      expect(drawnIds.add(match.state.challenge.id), isTrue);
      expect(
        match.state.challenge.imageAssetPath ??
            match.state.challenge.imageFilePath,
        isNotNull,
      );
      match.revealCharacterAfterPlayerTurnsAway();
      expect(match.state.phase, MatchPhase.awaitingJudgement);
      if (turn == 0) {
        match.judge(correct: false);
        expect(match.state.phase, MatchPhase.playerIntro);
      } else {
        match.judge(correct: true);
        expect(match.state.phase, MatchPhase.winCountdown);
        match.completeCountdown();
      }
    }
    expect(drawnIds, hasLength(8));
    expect(match.state.phase, MatchPhase.complete);
    match.dispose();

    expect(
      ActiveMatchController.validateConfiguration(
        configuration,
        objectChallenges: const <OfflineChallenge>[
          OfflineChallenge(
            id: 'only-one-picture',
            prompt: 'A clear image of one object.',
            answer: 'Bicycle',
            imageAssetPath: 'assets/app/objects/bicycle.jpg',
          ),
        ],
      ),
      contains('distinct'),
    );
  });

  test('Character Picture Mode requires imported local images', () {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['guess_character'],
      roundFormatIds: const <String>['character_picture'],
      roundCount: 1,
    );
    expect(configuration.canStart, isTrue);
    expect(
      ActiveMatchController.validateConfiguration(configuration),
      contains('distinct local images'),
    );
  });

  test('Picture Mode draws image challenges and never changes to names', () {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['guess_character'],
      roundFormatIds: const <String>['character_picture'],
      roundCount: 1,
    );
    final picture = OfflineChallenge(
      id: 'family-picture-1',
      prompt: 'Identify the person or character shown.',
      answer: 'Captain Example',
      imageFilePath: r'C:\family\captain-example.jpg',
    );
    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      pictureChallenges: <OfflineChallenge>[picture],
      random: Random(5),
    );
    match.start();
    expect(match.state.challenge.formatId, 'character_picture');
    expect(match.state.challenge.imageFilePath, picture.imageFilePath);
    expect(match.state.challenge.answer, 'Captain Example');
    match.beginRound();
    match.beginChallenge();
    expect(match.state.phase, MatchPhase.turnAway);
    match.revealCharacterAfterPlayerTurnsAway();
    expect(match.state.phase, MatchPhase.awaitingJudgement);
    expect(match.state.challenge.imageFilePath, picture.imageFilePath);
    match.judge(correct: true);
    expect(match.state.phase, MatchPhase.winCountdown);
    expect(match.state.secondsRemaining, configuration.winCountdownSeconds);
    match.dispose();
  });

  test('Picture Mode category selection filters eligible challenges', () {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['guess_character'],
      roundFormatIds: const <String>['character_picture'],
      roundCount: 1,
      characterPictureCategory: 'Marvel Characters',
    );
    final pictures = <OfflineChallenge>[
      OfflineChallenge(
        id: 'spider-man',
        prompt: 'Identify the character.',
        answer: 'Spider-Man',
        category: 'Marvel Characters',
      ),
      OfflineChallenge(
        id: 'naruto',
        prompt: 'Identify the character.',
        answer: 'Naruto',
        category: 'Anime Characters',
      ),
    ];

    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      pictureChallenges: pictures,
      random: Random(4),
    );
    expect(match.state.challenge.answer, 'Spider-Man');
    match.dispose();

    expect(
      ActiveMatchController.validateConfiguration(
        configuration,
        pictureChallenges: <OfflineChallenge>[pictures.last],
      ),
      contains('only 0 are installed'),
    );
  });

  test('consecutive matches prefer unseen eligible challenges', () {
    final used = <String>[];
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['quiz'],
      roundCount: 1,
    );
    final first = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      random: Random(2),
      onChallengeDrawn: used.add,
    );
    first.start();
    final firstId = first.state.challenge.id;
    first.dispose();

    final second = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      random: Random(2),
      recentChallengeIds: used,
      onChallengeDrawn: used.add,
    );
    second.start();
    expect(second.state.challenge.id, isNot(firstId));
    second.dispose();
  });

  test('wrong answers skip Win Countdown', () {
    final match = ActiveMatchController(
      configuration: SessionConfiguration(
        players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
        selectedModuleIds: const <String>['quiz'],
        roundCount: 1,
      ),
      enableTimers: false,
      random: Random(5),
    );
    match.beginChallenge();
    match.answer('not the answer');
    expect(match.state.phase, MatchPhase.complete);
    expect(match.state.scores.values.single, 0);
    match.dispose();
  });

  test('hint credits are charged to the active saved player only', () async {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
      ],
      selectedModuleIds: const <String>['quiz'],
      roundCount: 1,
    );
    final repository = InMemoryPlayerProfileRepository();
    await repository.ensureProfiles(configuration.players);
    final saved = await repository.loadAll();
    await repository.updateProfile(saved[0].copyWith(hintCredits: 2));
    await repository.updateProfile(saved[1].copyWith(hintCredits: 5));
    final funded = await repository.loadAll();
    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      profileRepository: repository,
      profiles: {for (final profile in funded) profile.id: profile},
      matchId: 'independent-hints',
      random: Random(28),
    );
    match.beginChallenge();
    expect(await match.revealHint(), isTrue);
    match.timeoutChallenge();
    match.beginChallenge();
    expect(await match.revealHint(), isTrue);
    final latest = await repository.loadAll();
    expect(latest.map((profile) => profile.hintCredits), <int>[1, 4]);
    match.dispose();
  });

  test('content capacity uses configured scope and full country pool', () {
    final easyFlags = SessionConfiguration(
      players: List<PlayerConfiguration>.generate(
        3,
        (index) => PlayerConfiguration.placeholder(index + 1),
      ),
      selectedModuleIds: const <String>['guess_country_flags'],
      roundCount: 3,
      countryDifficulty: 'easy',
    );
    expect(
      ActiveMatchController.validateConfiguration(easyFlags),
      contains('5 unique offline challenges; 9 are required'),
    );

    final mixedCountryTail = _configuration(players: 3, rounds: 5);
    expect(
      ActiveMatchController.validateConfiguration(mixedCountryTail),
      isNull,
    );
    final unsupported = SessionConfiguration(
      players: List<PlayerConfiguration>.generate(
        3,
        (index) => PlayerConfiguration.placeholder(index + 1),
      ),
      selectedModuleIds: const <String>['guess_country_flags'],
      roundCount: 84,
    );
    expect(
      ActiveMatchController.validateConfiguration(unsupported),
      contains('249 unique offline challenges; 252 are required'),
    );
  });

  test(
    'offline starter content has unique nonempty records for four modes',
    () {
      expect(quizChallenges, hasLength(12));
      expect(wordChallenges, hasLength(16));
      expect(characterChallenges, hasLength(10));
      expect(countryChallenges, hasLength(249));
      for (final items in <List<OfflineChallenge>>[
        quizChallenges,
        wordChallenges,
        characterChallenges,
        countryChallenges,
      ]) {
        expect(items.map((item) => item.id).toSet(), hasLength(items.length));
        expect(items.every((item) => item.answer.trim().isNotEmpty), isTrue);
      }
      for (final word in wordChallenges) {
        final prompt =
            word
                .promptForFormat('word_scramble')
                .replaceFirst('Unscramble:', '')
                .replaceAll(RegExp(r'[^A-Za-z]'), '')
                .toLowerCase()
                .split('')
              ..sort();
        final answer = word.answer.toLowerCase().split('')..sort();
        expect(prompt.join(), answer.join(), reason: word.id);
        expect(word.promptForFormat('word_missing_letters'), contains('_'));
        expect(word.promptForFormat('word_completion'), contains('_'));
        expect(
          word.hintForFormat('word_guess'),
          isNot(word.promptForFormat('word_guess')),
          reason: word.id,
        );
      }
    },
  );

  test('pause and resume preserve the scheduled challenge', () {
    final match = ActiveMatchController(
      configuration: SessionConfiguration(
        players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
        selectedModuleIds: const <String>['word_play'],
        roundCount: 1,
      ),
      enableTimers: false,
      random: Random(8),
    );
    match.beginChallenge();
    final challengeId = match.state.challenge.id;
    match.pause();
    match.resume();
    expect(match.state.phase, MatchPhase.challenge);
    expect(match.state.challenge.id, challengeId);
    expect(match.state.activePlayer.displayName, 'Player 1');
    match.dispose();
  });

  test('Word Play starts a three-player, four-round match in all formats', () {
    final configuration = SessionConfiguration(
      players: List<PlayerConfiguration>.generate(
        3,
        (index) => PlayerConfiguration.placeholder(index + 1),
      ),
      selectedModuleIds: const <String>['word_play'],
      roundFormatIds: const <String>[
        'word_scramble',
        'word_missing_letters',
        'word_completion',
        'word_guess',
      ],
      roundCount: 4,
      isMixed: false,
    );
    expect(ActiveMatchController.validateConfiguration(configuration), isNull);

    final match = ActiveMatchController(
      configuration: configuration,
      enableTimers: false,
      random: Random(52),
    );
    expect(match.state.totalTurns, 12);
    expect(match.formatSchedule.toSet(), configuration.roundFormatIds.toSet());

    final challengeIds = <String>{};
    final playerIdsByRound = <int, List<String>>{};
    final formatByRound = <int, String>{};
    match.start();
    for (var turn = 0; turn < 12; turn++) {
      if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
      match.beginChallenge();
      final state = match.state;
      expect(state.challenge.moduleId, 'word_play');
      formatByRound.putIfAbsent(state.round, () => state.challenge.formatId);
      expect(state.challenge.formatId, formatByRound[state.round]);
      expect(challengeIds.add(state.challenge.id), isTrue);
      playerIdsByRound
          .putIfAbsent(state.round, () => <String>[])
          .add(state.activePlayer.id);
      expect(state.challenge.prompt.trim(), isNotEmpty);
      if (state.challenge.formatId == 'word_guess') {
        expect(state.challenge.hint, isNot(state.challenge.content.hint));
      }
      match.answer(state.challenge.answer);
      expect(match.state.phase, MatchPhase.winCountdown);
      expect(match.state.pointsAwarded, 1);
      match.completeCountdown();
    }
    expect(match.state.phase, MatchPhase.complete);
    expect(challengeIds, hasLength(12));
    expect(formatByRound.length, 4);
    for (var round = 1; round <= 4; round++) {
      expect(playerIdsByRound[round], <String>[
        'player-1',
        'player-2',
        'player-3',
      ]);
    }
    match.dispose();
  });
}

SessionConfiguration _configuration({
  required int players,
  required int rounds,
}) => SessionConfiguration(
  players: List<PlayerConfiguration>.generate(
    players,
    (index) => PlayerConfiguration.placeholder(index + 1),
  ),
  selectedModuleIds: const <String>[
    'quiz',
    'word_play',
    'guess_character',
    'guess_country_flags',
  ],
  roundCount: rounds,
  isMixed: true,
);

void _answerCorrectly(ActiveMatchController match) {
  switch (match.state.challenge.formatId) {
    case 'character_name' || 'character_picture' || 'country_name':
      expect(match.state.phase, MatchPhase.turnAway);
      match.revealCharacterAfterPlayerTurnsAway();
      match.judge(correct: true);
    case 'country_flag':
      expect(match.state.phase, MatchPhase.awaitingJudgement);
      expect(match.state.challenge.choices, isEmpty);
      match.revealAnswer();
      match.judge(correct: true);
    default:
      match.answer(match.state.challenge.answer);
  }
}

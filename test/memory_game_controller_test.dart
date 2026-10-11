import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/memory/application/memory_game_controller.dart';

void main() {
  late MemoryGameController controller;

  setUp(() {
    controller = MemoryGameController(
      players: <PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
      ],
      rounds: 1,
      challengeSeconds: 10,
      winCountdownSeconds: 2,
      hintsEnabled: true,
      scoringEnabled: true,
      seed: 21,
    );
  });

  tearDown(() => controller.dispose());

  test('correct pairs score and pass through Win Countdown', () {
    controller.start();
    final pair = _firstPair(controller.state.cardSymbols);

    expect(controller.flipCard(pair.$1), isTrue);
    expect(controller.flipCard(pair.$2), isTrue);
    expect(controller.state.phase, MemoryGamePhase.winCountdown);
    expect(controller.state.scores['player-1'], 1);
    expect(
      controller.state.matchedCardIndices,
      containsAll(<int>[pair.$1, pair.$2]),
    );

    controller.tick();
    expect(controller.state.countdownRemaining, 1);
    controller.tick();
    expect(controller.state.phase, MemoryGamePhase.playing);
    expect(controller.state.activePlayer.id, 'player-1');
  });

  test('wrong pair does not score or start countdown and advances player', () {
    controller.start();
    final pair = _differentPair(controller.state.cardSymbols);

    controller.flipCard(pair.$1);
    controller.flipCard(pair.$2);
    expect(controller.state.phase, MemoryGamePhase.wrongPair);
    expect(controller.state.scores['player-1'], 0);
    expect(controller.state.countdownRemaining, 0);

    controller.continueAfterWrongPair();
    expect(controller.state.phase, MemoryGamePhase.playing);
    expect(controller.state.activePlayer.id, 'player-2');
  });

  test('timer expiry advances without awarding a win countdown', () {
    controller.start();
    for (var i = 0; i < 10; i++) {
      controller.tick();
    }

    expect(controller.state.phase, MemoryGamePhase.wrongPair);
    expect(controller.state.notice, 'TIME EXPIRED');
    expect(controller.state.countdownRemaining, 0);
    controller.continueAfterWrongPair();
    expect(controller.state.activePlayer.id, 'player-2');
  });

  test('last matching pair completes the configured session', () {
    controller.start();
    final symbols = controller.state.cardSymbols.toSet();
    for (final symbol in symbols) {
      final indexes = <int>[
        for (var i = 0; i < controller.state.cardSymbols.length; i++)
          if (controller.state.cardSymbols[i] == symbol) i,
      ];
      controller.flipCard(indexes[0]);
      controller.flipCard(indexes[1]);
      controller.tick();
      controller.tick();
    }

    expect(controller.state.phase, MemoryGamePhase.complete);
    expect(controller.state.round, 1);
  });

  test('hint reveals a pair only when the host enabled hints', () {
    controller.start();
    expect(controller.useHint(), isTrue);
    expect(controller.state.hintedCardIndices, hasLength(2));

    final noHints = MemoryGameController(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      rounds: 1,
      challengeSeconds: null,
      winCountdownSeconds: 1,
      hintsEnabled: false,
      scoringEnabled: false,
      seed: 21,
    )..start();
    expect(noHints.useHint(), isFalse);
    noHints.dispose();
  });
}

(int, int) _firstPair(List<int> symbols) {
  for (var first = 0; first < symbols.length; first++) {
    for (var second = first + 1; second < symbols.length; second++) {
      if (symbols[first] == symbols[second]) return (first, second);
    }
  }
  throw StateError('No pair found.');
}

(int, int) _differentPair(List<int> symbols) {
  for (var first = 0; first < symbols.length; first++) {
    for (var second = first + 1; second < symbols.length; second++) {
      if (symbols[first] != symbols[second]) return (first, second);
    }
  }
  throw StateError('No mismatched pair found.');
}

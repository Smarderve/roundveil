import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roundveil/domain/session/session_configuration.dart';

enum MemoryGamePhase { ready, playing, wrongPair, winCountdown, complete }

class MemoryGameState {
  const MemoryGameState({
    required this.phase,
    required this.players,
    required this.round,
    required this.playerIndex,
    required this.cardSymbols,
    required this.flippedCardIndices,
    required this.matchedCardIndices,
    required this.hintedCardIndices,
    required this.hintUsed,
    required this.secondsRemaining,
    required this.countdownRemaining,
    required this.scores,
    this.notice,
  });

  final MemoryGamePhase phase;
  final List<PlayerConfiguration> players;
  final int round;
  final int playerIndex;
  final List<int> cardSymbols;
  final Set<int> flippedCardIndices;
  final Set<int> matchedCardIndices;
  final Set<int> hintedCardIndices;
  final bool hintUsed;
  final int? secondsRemaining;
  final int countdownRemaining;
  final Map<String, int> scores;
  final String? notice;

  PlayerConfiguration get activePlayer => players[playerIndex];
}

/// Offline card-match rules for a configured local player session.
///
/// Each round is one shared 8-pair board. A correct pair earns an immediate
/// Win Countdown and leaves the active player in control. A wrong pair or
/// expired turn advances to the next player without a countdown.
class MemoryGameController extends ChangeNotifier {
  MemoryGameController({
    required List<PlayerConfiguration> players,
    required this.rounds,
    required this.challengeSeconds,
    required this.winCountdownSeconds,
    required this.hintsEnabled,
    required this.scoringEnabled,
    this.seed = 1,
  }) : _players = List<PlayerConfiguration>.unmodifiable(players) {
    if (_players.isEmpty) {
      throw ArgumentError('At least one player is required.');
    }
    if (rounds < 1) throw ArgumentError.value(rounds, 'rounds');
    if (challengeSeconds != null && challengeSeconds! < 1) {
      throw ArgumentError.value(challengeSeconds, 'challengeSeconds');
    }
    if (winCountdownSeconds < 1) {
      throw ArgumentError.value(winCountdownSeconds, 'winCountdownSeconds');
    }
    _state = MemoryGameState(
      phase: MemoryGamePhase.ready,
      players: _players,
      round: 1,
      playerIndex: 0,
      cardSymbols: const <int>[],
      flippedCardIndices: const <int>{},
      matchedCardIndices: const <int>{},
      hintedCardIndices: const <int>{},
      hintUsed: false,
      secondsRemaining: challengeSeconds,
      countdownRemaining: 0,
      scores: scoringEnabled
          ? <String, int>{for (final player in _players) player.id: 0}
          : const <String, int>{},
    );
  }

  final List<PlayerConfiguration> _players;
  final int seed;
  final int rounds;
  final int? challengeSeconds;
  final int winCountdownSeconds;
  final bool hintsEnabled;
  final bool scoringEnabled;
  late MemoryGameState _state;

  MemoryGameState get state => _state;

  void start() {
    if (_state.phase != MemoryGamePhase.ready) return;
    _state = _newBoard(round: 1, playerIndex: 0);
    notifyListeners();
  }

  bool flipCard(int index) {
    if (_state.phase != MemoryGamePhase.playing ||
        index < 0 ||
        index >= _state.cardSymbols.length ||
        _state.matchedCardIndices.contains(index) ||
        _state.flippedCardIndices.contains(index) ||
        _state.flippedCardIndices.length >= 2) {
      return false;
    }

    final flipped = <int>{..._state.flippedCardIndices, index};
    if (flipped.length == 1) {
      _state = _stateWith(
        flippedCardIndices: flipped,
        hintedCardIndices: const <int>{},
      );
      notifyListeners();
      return true;
    }

    final first = flipped.first;
    if (_state.cardSymbols[first] == _state.cardSymbols[index]) {
      final matched = <int>{..._state.matchedCardIndices, ...flipped};
      final scores = Map<String, int>.of(_state.scores);
      if (scoringEnabled) {
        final id = _state.activePlayer.id;
        scores[id] = (scores[id] ?? 0) + 1;
      }
      _state = _stateWith(
        phase: MemoryGamePhase.winCountdown,
        flippedCardIndices: flipped,
        matchedCardIndices: matched,
        hintedCardIndices: const <int>{},
        countdownRemaining: winCountdownSeconds,
        scores: scores,
        notice: 'MATCH FOUND',
      );
    } else {
      _state = _stateWith(
        phase: MemoryGamePhase.wrongPair,
        flippedCardIndices: flipped,
        hintedCardIndices: const <int>{},
        notice: 'NO MATCH',
      );
    }
    notifyListeners();
    return true;
  }

  bool useHint() {
    if (!hintsEnabled ||
        _state.phase != MemoryGamePhase.playing ||
        _state.hintUsed) {
      return false;
    }
    for (var first = 0; first < _state.cardSymbols.length; first++) {
      if (_state.matchedCardIndices.contains(first)) continue;
      for (
        var second = first + 1;
        second < _state.cardSymbols.length;
        second++
      ) {
        if (!_state.matchedCardIndices.contains(second) &&
            _state.cardSymbols[first] == _state.cardSymbols[second]) {
          _state = _stateWith(
            hintedCardIndices: <int>{first, second},
            hintUsed: true,
          );
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }

  void tick() {
    if (_state.phase == MemoryGamePhase.winCountdown) {
      final remaining = _state.countdownRemaining - 1;
      if (remaining > 0) {
        _state = _stateWith(countdownRemaining: remaining);
      } else if (_state.matchedCardIndices.length ==
          _state.cardSymbols.length) {
        if (_state.round >= rounds) {
          _state = _stateWith(
            phase: MemoryGamePhase.complete,
            countdownRemaining: 0,
            notice: 'SESSION COMPLETE',
          );
        } else {
          _state = _newBoard(
            round: _state.round + 1,
            playerIndex: (_state.playerIndex + 1) % _players.length,
          );
        }
      } else {
        _state = _stateWith(
          phase: MemoryGamePhase.playing,
          flippedCardIndices: const <int>{},
          hintedCardIndices: const <int>{},
          hintUsed: false,
          secondsRemaining: challengeSeconds,
          countdownRemaining: 0,
          notice: null,
        );
      }
      notifyListeners();
      return;
    }

    if (_state.phase != MemoryGamePhase.playing || challengeSeconds == null) {
      return;
    }
    final remaining = _state.secondsRemaining! - 1;
    _state = _stateWith(
      phase: remaining <= 0 ? MemoryGamePhase.wrongPair : _state.phase,
      secondsRemaining: max(0, remaining),
      flippedCardIndices: remaining <= 0
          ? const <int>{}
          : _state.flippedCardIndices,
      notice: remaining <= 0 ? 'TIME EXPIRED' : _state.notice,
    );
    notifyListeners();
  }

  void continueAfterWrongPair() {
    if (_state.phase != MemoryGamePhase.wrongPair) return;
    _state = _stateWith(
      phase: MemoryGamePhase.playing,
      playerIndex: (_state.playerIndex + 1) % _players.length,
      flippedCardIndices: const <int>{},
      hintedCardIndices: const <int>{},
      hintUsed: false,
      secondsRemaining: challengeSeconds,
      notice: null,
    );
    notifyListeners();
  }

  MemoryGameState _newBoard({required int round, required int playerIndex}) {
    final symbols = List<int>.generate(16, (index) => index ~/ 2)
      ..shuffle(Random(seed + round));
    return MemoryGameState(
      phase: MemoryGamePhase.playing,
      players: _players,
      round: round,
      playerIndex: playerIndex,
      cardSymbols: List<int>.unmodifiable(symbols),
      flippedCardIndices: const <int>{},
      matchedCardIndices: const <int>{},
      hintedCardIndices: const <int>{},
      hintUsed: false,
      secondsRemaining: challengeSeconds,
      countdownRemaining: 0,
      scores: Map<String, int>.unmodifiable(_state.scores),
    );
  }

  MemoryGameState _stateWith({
    MemoryGamePhase? phase,
    int? playerIndex,
    Set<int>? flippedCardIndices,
    Set<int>? matchedCardIndices,
    Set<int>? hintedCardIndices,
    bool? hintUsed,
    int? secondsRemaining,
    int? countdownRemaining,
    Map<String, int>? scores,
    String? notice,
  }) => MemoryGameState(
    phase: phase ?? _state.phase,
    players: _state.players,
    round: _state.round,
    playerIndex: playerIndex ?? _state.playerIndex,
    cardSymbols: _state.cardSymbols,
    flippedCardIndices: flippedCardIndices ?? _state.flippedCardIndices,
    matchedCardIndices: matchedCardIndices ?? _state.matchedCardIndices,
    hintedCardIndices: hintedCardIndices ?? _state.hintedCardIndices,
    hintUsed: hintUsed ?? _state.hintUsed,
    secondsRemaining: secondsRemaining ?? _state.secondsRemaining,
    countdownRemaining: countdownRemaining ?? _state.countdownRemaining,
    scores: scores ?? _state.scores,
    notice: notice,
  );
}

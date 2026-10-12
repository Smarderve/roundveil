import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';

enum MatchPhase {
  challenge,
  turnAway,
  awaitingJudgement,
  winCountdown,
  paused,
  complete,
}

class MatchChallenge {
  const MatchChallenge({required this.moduleId, required this.content});

  final String moduleId;
  final OfflineChallenge content;

  String get id => content.id;
  String get prompt => content.prompt;
  String get answer => content.answer;
  List<String> get choices => content.choices;
  String get hint => content.hint;
  String? get flagAssetPath => content.flagAssetPath;
  double? get flagAspectRatio => content.flagAspectRatio;
}

class ActiveMatchState {
  const ActiveMatchState({
    required this.phase,
    required this.challenge,
    required this.activePlayer,
    required this.turnIndex,
    required this.totalTurns,
    required this.round,
    required this.secondsRemaining,
    required this.scores,
    this.answerVisible = false,
    this.hintVisible = false,
    this.feedback,
  });

  final MatchPhase phase;
  final MatchChallenge challenge;
  final PlayerConfiguration activePlayer;
  final int turnIndex;
  final int totalTurns;
  final int round;
  final int secondsRemaining;
  final Map<String, int> scores;
  final bool answerVisible;
  final bool hintVisible;
  final String? feedback;
}

class ActiveMatchController extends ChangeNotifier {
  ActiveMatchController({
    required SessionConfiguration configuration,
    this.enableTimers = true,
    int? challengeSeconds,
    int? winCountdownSeconds,
    bool? scoringEnabled,
  }) : _configuration = configuration,
       challengeSeconds = challengeSeconds ?? configuration.challengeSeconds,
       winCountdownSeconds =
           winCountdownSeconds ?? configuration.winCountdownSeconds,
       scoringEnabled = scoringEnabled ?? configuration.scoringEnabled {
    final issue = validateConfiguration(configuration);
    if (issue != null) {
      throw ArgumentError.value(configuration, 'configuration', issue);
    }
    _state = _stateForTurn(0, <String, int>{
      for (final player in configuration.players) player.id: 0,
    });
    if (_state.phase == MatchPhase.challenge ||
        _state.phase == MatchPhase.awaitingJudgement) {
      _runChallengeTimer();
    }
  }

  final SessionConfiguration _configuration;
  final bool enableTimers;
  final int challengeSeconds;
  final int winCountdownSeconds;
  final bool scoringEnabled;
  Timer? _timer;
  MatchPhase? _phaseBeforePause;
  late ActiveMatchState _state;
  ActiveMatchState get state => _state;

  static String? validateConfiguration(SessionConfiguration configuration) {
    if (!configuration.canStart) {
      return 'Complete the player, game, and round selections first.';
    }
    if (configuration.challengeSeconds < 1 ||
        configuration.winCountdownSeconds < 1) {
      return 'Challenge and Win Countdown timers must both be at least one second.';
    }
    final required = configuration.isMixed
        ? configuration.roundCount
        : configuration.roundCount * configuration.players.length;
    for (final moduleId in configuration.selectedModuleIds) {
      final count = challengesForModule(
        moduleId,
        configuration: configuration,
      ).length;
      if (count < required) {
        return '$moduleId has $count unique offline challenges; $required are required for this session. Reduce rounds or players.';
      }
    }
    return null;
  }

  void answer(String value) {
    if (_state.phase != MatchPhase.challenge) return;
    final isCorrect = _normalize(value) == _normalize(_state.challenge.answer);
    _resolve(isCorrect);
  }

  void revealCharacterAfterPlayerTurnsAway() {
    if (_state.phase != MatchPhase.turnAway) return;
    _set(_copy(phase: MatchPhase.awaitingJudgement, answerVisible: true));
    _runChallengeTimer();
  }

  void revealAnswer() {
    if (_state.phase != MatchPhase.awaitingJudgement ||
        _state.challenge.moduleId != 'guess_country_flags') {
      return;
    }
    _set(_copy(answerVisible: true));
  }

  void revealHint() {
    if (!_configuration.hintsEnabled ||
        _state.phase == MatchPhase.complete ||
        _state.phase == MatchPhase.paused) {
      return;
    }
    _set(_copy(hintVisible: true));
  }

  void judge({required bool correct}) {
    if (_state.phase != MatchPhase.awaitingJudgement || !_state.answerVisible) {
      return;
    }
    _resolve(correct);
  }

  void pause() {
    if (_state.phase == MatchPhase.complete ||
        _state.phase == MatchPhase.paused) {
      return;
    }
    _phaseBeforePause = _state.phase;
    _timer?.cancel();
    _set(_copy(phase: MatchPhase.paused));
  }

  void resume() {
    if (_state.phase != MatchPhase.paused) return;
    final previous = _phaseBeforePause ?? MatchPhase.challenge;
    _phaseBeforePause = null;
    _set(_copy(phase: previous));
    if (previous == MatchPhase.winCountdown) {
      _runCountdownTimer();
    } else if (previous == MatchPhase.challenge ||
        previous == MatchPhase.awaitingJudgement) {
      _runChallengeTimer();
    }
  }

  void completeCountdown() {
    if (_state.phase != MatchPhase.winCountdown) return;
    _timer?.cancel();
    _advance(_state.scores);
  }

  void _resolve(bool correct) {
    _timer?.cancel();
    if (!correct) {
      _advance(_state.scores);
      return;
    }
    final scores = Map<String, int>.from(_state.scores);
    if (scoringEnabled) {
      scores.update(
        _state.activePlayer.id,
        (score) => score + 1,
        ifAbsent: () => 1,
      );
    }
    _set(
      _copy(
        phase: MatchPhase.winCountdown,
        secondsRemaining: winCountdownSeconds,
        answerVisible: true,
        feedback: 'CORRECT · WIN COUNTDOWN',
        scores: scores,
      ),
    );
    _runCountdownTimer();
  }

  void _advance(Map<String, int> scores) {
    _timer?.cancel();
    final next = _state.turnIndex + 1;
    if (next >= _state.totalTurns) {
      _set(_copy(phase: MatchPhase.complete, feedback: 'MATCH COMPLETE'));
      return;
    }
    _state = _stateForTurn(next, scores);
    notifyListeners();
    if (_state.phase == MatchPhase.challenge ||
        _state.phase == MatchPhase.awaitingJudgement) {
      _runChallengeTimer();
    }
  }

  ActiveMatchState _stateForTurn(int turn, Map<String, int> scores) {
    final modules = _configuration.selectedModuleIds;
    final playerCount = _configuration.players.length;
    final mixed = _configuration.isMixed;
    final total = mixed
        ? _configuration.roundCount * modules.length
        : _configuration.roundCount * playerCount;
    final round = mixed ? turn ~/ modules.length + 1 : turn ~/ playerCount + 1;
    final moduleIndex = mixed ? turn % modules.length : 0;
    final moduleId = modules[moduleIndex];
    final contentIndex = mixed ? turn ~/ modules.length : turn;
    final playerIndex = mixed
        ? (turn + round - 1) % playerCount
        : turn % playerCount;
    final challenge = MatchChallenge(
      moduleId: moduleId,
      content: challengesForModule(
        moduleId,
        configuration: _configuration,
      )[contentIndex],
    );
    final phase = moduleId == 'guess_character'
        ? MatchPhase.turnAway
        : moduleId == 'guess_country_flags'
        ? MatchPhase.awaitingJudgement
        : MatchPhase.challenge;
    return ActiveMatchState(
      phase: phase,
      challenge: challenge,
      activePlayer: _configuration.players[playerIndex],
      turnIndex: turn,
      totalTurns: total,
      round: round,
      secondsRemaining: phase == MatchPhase.awaitingJudgement
          ? challengeSeconds
          : phase == MatchPhase.challenge
          ? challengeSeconds
          : 0,
      scores: Map<String, int>.unmodifiable(scores),
    );
  }

  void _runChallengeTimer() {
    _timer?.cancel();
    if (!enableTimers || _state.secondsRemaining <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.secondsRemaining <= 1) {
        timer.cancel();
        _advance(_state.scores);
      } else {
        _set(_copy(secondsRemaining: _state.secondsRemaining - 1));
      }
    });
  }

  void _runCountdownTimer() {
    if (!enableTimers || winCountdownSeconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.secondsRemaining <= 1) {
        timer.cancel();
        completeCountdown();
      } else {
        _set(_copy(secondsRemaining: _state.secondsRemaining - 1));
      }
    });
  }

  ActiveMatchState _copy({
    MatchPhase? phase,
    int? secondsRemaining,
    bool? answerVisible,
    bool? hintVisible,
    String? feedback,
    Map<String, int>? scores,
  }) => ActiveMatchState(
    phase: phase ?? _state.phase,
    challenge: _state.challenge,
    activePlayer: _state.activePlayer,
    turnIndex: _state.turnIndex,
    totalTurns: _state.totalTurns,
    round: _state.round,
    secondsRemaining: secondsRemaining ?? _state.secondsRemaining,
    scores: Map<String, int>.unmodifiable(scores ?? _state.scores),
    answerVisible: answerVisible ?? _state.answerVisible,
    hintVisible: hintVisible ?? _state.hintVisible,
    feedback: feedback ?? _state.feedback,
  );

  void _set(ActiveMatchState value) {
    _state = value;
    notifyListeners();
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

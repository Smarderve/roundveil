import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';

enum MatchPhase {
  playerIntro,
  challenge,
  turnAway,
  awaitingJudgement,
  scoreAward,
  winCountdown,
  paused,
  completing,
  complete,
}

enum GameAudioCue {
  playerIntroduction,
  questionStart,
  questionFinalSeconds,
  correctAnswer,
  wrongAnswer,
  pointsAwarded,
  hintPurchased,
  winCountdownStart,
  winCountdownTick,
  finalBuzzer,
  matchResults,
  hintRewards,
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
    required this.profiles,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeouts,
    this.rankings = const <PlayerRankingRow>[],
    this.answerVisible = false,
    this.hintVisible = false,
    this.pointsAwarded = 0,
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
  final Map<String, PlayerProfile> profiles;
  final Map<String, int> correctAnswers;
  final Map<String, int> wrongAnswers;
  final Map<String, int> timeouts;
  final List<PlayerRankingRow> rankings;
  final bool answerVisible;
  final bool hintVisible;
  final int pointsAwarded;
  final String? feedback;
}

class ActiveMatchController extends ChangeNotifier {
  ActiveMatchController({
    required SessionConfiguration configuration,
    this.enableTimers = true,
    int? challengeSeconds,
    int? winCountdownSeconds,
    bool? scoringEnabled,
    this.profileRepository,
    Map<String, PlayerProfile>? profiles,
    String? matchId,
    this.introductionDuration = const Duration(milliseconds: 1800),
    this.scoreAwardDuration = const Duration(milliseconds: 500),
  }) : _configuration = configuration,
       _profiles = Map<String, PlayerProfile>.from(
         profiles ??
             <String, PlayerProfile>{
               for (final profile in _defaultProfiles(configuration.players))
                 profile.id: profile,
             },
       ),
       matchId = matchId ?? DateTime.now().microsecondsSinceEpoch.toString(),
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
  }

  final SessionConfiguration _configuration;
  final bool enableTimers;
  final PlayerProfileRepository? profileRepository;
  final String matchId;
  final Duration introductionDuration;
  final Duration scoreAwardDuration;
  final int challengeSeconds;
  final int winCountdownSeconds;
  final bool scoringEnabled;
  final StreamController<GameAudioCue> _effects =
      StreamController<GameAudioCue>.broadcast();
  final Set<String> _redeemedChallenges = <String>{};
  Timer? _timer;
  Timer? _introTimer;
  MatchPhase? _phaseBeforePause;
  late ActiveMatchState _state;
  Map<String, PlayerProfile> _profiles;
  Map<String, int> _correct = <String, int>{};
  Map<String, int> _wrong = <String, int>{};
  Map<String, int> _timeouts = <String, int>{};
  bool _started = false;

  ActiveMatchState get state => _state;
  Stream<GameAudioCue> get effects => _effects.stream;

  void start() {
    if (_started) return;
    _started = true;
    _emit(GameAudioCue.playerIntroduction);
    _scheduleIntroduction();
  }

  static String? validateConfiguration(SessionConfiguration configuration) {
    if (!configuration.canStart) {
      return 'Complete the player, game, and round selections first.';
    }
    if (configuration.challengeSeconds < 1 ||
        configuration.winCountdownSeconds < 1) {
      return 'Challenge and Win Countdown timers must both be at least one second.';
    }
    if (configuration.scoringEnabled &&
        configuration.pointsPerCorrectAnswer < 1) {
      return 'Points per correct answer must be at least one when scoring is enabled.';
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

  void beginChallenge() {
    if (_state.phase != MatchPhase.playerIntro) return;
    _introTimer?.cancel();
    final moduleId = _state.challenge.moduleId;
    final phase = switch (moduleId) {
      'guess_character' => MatchPhase.turnAway,
      'guess_country_flags' => MatchPhase.awaitingJudgement,
      _ => MatchPhase.challenge,
    };
    _set(
      _copy(
        phase: phase,
        secondsRemaining: phase == MatchPhase.turnAway ? 0 : challengeSeconds,
      ),
    );
    if (phase == MatchPhase.challenge ||
        phase == MatchPhase.awaitingJudgement) {
      _emit(GameAudioCue.questionStart);
      _runChallengeTimer();
    }
  }

  void answer(String value) {
    if (_state.phase != MatchPhase.challenge) return;
    final isCorrect = _normalize(value) == _normalize(_state.challenge.answer);
    _resolve(isCorrect);
  }

  void revealCharacterAfterPlayerTurnsAway() {
    if (_state.phase != MatchPhase.turnAway) return;
    _set(
      _copy(
        phase: MatchPhase.awaitingJudgement,
        answerVisible: true,
        secondsRemaining: challengeSeconds,
      ),
    );
    _emit(GameAudioCue.questionStart);
    _runChallengeTimer();
  }

  void revealAnswer() {
    if (_state.phase != MatchPhase.awaitingJudgement ||
        _state.challenge.moduleId != 'guess_country_flags') {
      return;
    }
    _set(_copy(answerVisible: true));
  }

  Future<bool> revealHint() async {
    final phaseAllowsHint =
        _state.phase == MatchPhase.challenge ||
        _state.phase == MatchPhase.awaitingJudgement;
    if (!_configuration.hintsEnabled ||
        !phaseAllowsHint ||
        _state.hintVisible ||
        _state.challenge.hint.trim().isEmpty ||
        _redeemedChallenges.contains(_state.challenge.id)) {
      return false;
    }
    final playerId = _state.activePlayer.id;
    final profile = _profiles[playerId];
    if (profile == null || profile.hintCredits < 1) return false;
    final repository = profileRepository;
    if (repository != null) {
      final spent = await repository.spendHintCredit(
        matchId: matchId,
        playerId: playerId,
        challengeId: _state.challenge.id,
      );
      if (!spent) {
        final latest = await repository.loadAll();
        _profiles = <String, PlayerProfile>{
          for (final value in latest) value.id: value,
        };
        _set(_copy());
        return false;
      }
    }
    _redeemedChallenges.add(_state.challenge.id);
    _profiles = <String, PlayerProfile>{
      ..._profiles,
      playerId: profile.copyWith(hintCredits: profile.hintCredits - 1),
    };
    _set(_copy(hintVisible: true));
    _emit(GameAudioCue.hintPurchased);
    return true;
  }

  void judge({required bool correct}) {
    if (_state.phase != MatchPhase.awaitingJudgement || !_state.answerVisible) {
      return;
    }
    _resolve(correct);
  }

  void timeoutChallenge() {
    if (_state.phase != MatchPhase.challenge &&
        _state.phase != MatchPhase.awaitingJudgement) {
      return;
    }
    _resolve(false, timedOut: true);
  }

  void beginWinCountdown() {
    if (_state.phase != MatchPhase.scoreAward) return;
    _set(
      _copy(
        phase: MatchPhase.winCountdown,
        secondsRemaining: winCountdownSeconds,
      ),
    );
    _emit(GameAudioCue.winCountdownStart);
    _runCountdownTimer();
  }

  void pause() {
    if (_state.phase == MatchPhase.complete ||
        _state.phase == MatchPhase.completing ||
        _state.phase == MatchPhase.paused) {
      return;
    }
    _phaseBeforePause = _state.phase;
    _timer?.cancel();
    _introTimer?.cancel();
    _set(_copy(phase: MatchPhase.paused));
  }

  void resume() {
    if (_state.phase != MatchPhase.paused) return;
    final previous = _phaseBeforePause ?? MatchPhase.playerIntro;
    _phaseBeforePause = null;
    _set(_copy(phase: previous));
    switch (previous) {
      case MatchPhase.playerIntro:
        _emit(GameAudioCue.playerIntroduction);
        _scheduleIntroduction();
      case MatchPhase.challenge:
      case MatchPhase.awaitingJudgement:
        _runChallengeTimer();
      case MatchPhase.scoreAward:
        _scheduleWinCountdown();
      case MatchPhase.winCountdown:
        _runCountdownTimer();
      case MatchPhase.turnAway:
      case MatchPhase.completing:
      case MatchPhase.complete:
      case MatchPhase.paused:
        break;
    }
  }

  void completeCountdown() {
    if (_state.phase != MatchPhase.winCountdown) return;
    _timer?.cancel();
    _emit(GameAudioCue.finalBuzzer);
    _advance();
  }

  void finishTurnAsWrong() => _resolve(false);

  void _resolve(bool correct, {bool timedOut = false}) {
    _timer?.cancel();
    final playerId = _state.activePlayer.id;
    if (!correct) {
      if (timedOut) {
        _timeouts = <String, int>{
          ..._timeouts,
          playerId: (_timeouts[playerId] ?? 0) + 1,
        };
      } else {
        _wrong = <String, int>{
          ..._wrong,
          playerId: (_wrong[playerId] ?? 0) + 1,
        };
      }
      _emit(
        timedOut ? GameAudioCue.questionFinalSeconds : GameAudioCue.wrongAnswer,
      );
      _advance();
      return;
    }
    _correct = <String, int>{
      ..._correct,
      playerId: (_correct[playerId] ?? 0) + 1,
    };
    final scores = Map<String, int>.from(_state.scores);
    final awarded = scoringEnabled ? _configuration.pointsPerCorrectAnswer : 0;
    if (awarded > 0) {
      scores.update(
        playerId,
        (score) => score + awarded,
        ifAbsent: () => awarded,
      );
    }
    _set(
      _copy(
        phase: MatchPhase.scoreAward,
        answerVisible: true,
        feedback: 'CORRECT',
        scores: scores,
        pointsAwarded: awarded,
      ),
    );
    _emit(GameAudioCue.correctAnswer);
    if (awarded > 0) _emit(GameAudioCue.pointsAwarded);
    _scheduleWinCountdown();
  }

  void _scheduleWinCountdown() {
    _timer?.cancel();
    if (!enableTimers) return;
    _timer = Timer(scoreAwardDuration, beginWinCountdown);
  }

  void _advance() {
    _timer?.cancel();
    _introTimer?.cancel();
    final next = _state.turnIndex + 1;
    if (next >= _state.totalTurns) {
      unawaited(_completeMatch());
      return;
    }
    _state = _stateForTurn(next, _state.scores);
    notifyListeners();
    _emit(GameAudioCue.playerIntroduction);
    _scheduleIntroduction();
  }

  Future<void> _completeMatch() async {
    _set(_copy(phase: MatchPhase.completing));
    final results = <PlayerMatchResult>[
      for (final player in _configuration.players)
        PlayerMatchResult(
          playerId: player.id,
          matchPoints: _state.scores[player.id] ?? 0,
          correctAnswers: _correct[player.id] ?? 0,
          wrongAnswers: _wrong[player.id] ?? 0,
          timeouts: _timeouts[player.id] ?? 0,
        ),
    ];
    late List<PlayerRankingRow> rankings;
    final repository = profileRepository;
    if (repository != null) {
      final receipt = await repository.completeMatch(
        matchId: matchId,
        results: results,
      );
      rankings = receipt.rankings;
      final savedProfiles = await repository.loadAll();
      _profiles = <String, PlayerProfile>{
        for (final profile in savedProfiles) profile.id: profile,
      };
      if (rankings.any((row) => row.hintCreditsAwarded > 0)) {
        _emit(GameAudioCue.hintRewards);
      }
    } else {
      rankings = _rank(results);
      _profiles = <String, PlayerProfile>{
        for (final row in rankings)
          if (_profiles[row.playerId] case final profile?)
            row.playerId: profile.copyWith(
              hintCredits: profile.hintCredits + row.hintCreditsAwarded,
              gamesPlayed: profile.gamesPlayed + 1,
              correctAnswers: profile.correctAnswers + row.correctAnswers,
              wrongAnswers: profile.wrongAnswers + row.wrongAnswers,
              timeouts: profile.timeouts + row.timeouts,
              totalMatchPoints: profile.totalMatchPoints + row.matchPoints,
            ),
      };
      if (rankings.any((row) => row.hintCreditsAwarded > 0)) {
        _emit(GameAudioCue.hintRewards);
      }
    }
    _set(_copy(phase: MatchPhase.complete, rankings: rankings));
    _emit(GameAudioCue.matchResults);
  }

  void _scheduleIntroduction() {
    _introTimer?.cancel();
    if (!enableTimers) return;
    _introTimer = Timer(introductionDuration, beginChallenge);
  }

  void _runChallengeTimer() {
    _timer?.cancel();
    if (!enableTimers || _state.secondsRemaining <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.secondsRemaining <= 1) {
        timer.cancel();
        timeoutChallenge();
      } else {
        final remaining = _state.secondsRemaining - 1;
        _set(_copy(secondsRemaining: remaining));
        if (remaining <= 3) _emit(GameAudioCue.questionFinalSeconds);
      }
    });
  }

  void _runCountdownTimer() {
    _timer?.cancel();
    if (!enableTimers || _state.phase != MatchPhase.winCountdown) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.secondsRemaining <= 1) {
        timer.cancel();
        _set(_copy(secondsRemaining: 0));
        _emit(GameAudioCue.winCountdownTick);
        _timer = Timer(const Duration(milliseconds: 350), completeCountdown);
      } else {
        _set(_copy(secondsRemaining: _state.secondsRemaining - 1));
        _emit(GameAudioCue.winCountdownTick);
      }
    });
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
    return ActiveMatchState(
      phase: MatchPhase.playerIntro,
      challenge: challenge,
      activePlayer: _configuration.players[playerIndex],
      turnIndex: turn,
      totalTurns: total,
      round: round,
      secondsRemaining: 0,
      scores: Map<String, int>.unmodifiable(scores),
      profiles: Map<String, PlayerProfile>.unmodifiable(_profiles),
      correctAnswers: Map<String, int>.unmodifiable(_correct),
      wrongAnswers: Map<String, int>.unmodifiable(_wrong),
      timeouts: Map<String, int>.unmodifiable(_timeouts),
    );
  }

  ActiveMatchState _copy({
    MatchPhase? phase,
    int? secondsRemaining,
    bool? answerVisible,
    bool? hintVisible,
    String? feedback,
    Map<String, int>? scores,
    List<PlayerRankingRow>? rankings,
    int? pointsAwarded,
  }) => ActiveMatchState(
    phase: phase ?? _state.phase,
    challenge: _state.challenge,
    activePlayer: _state.activePlayer,
    turnIndex: _state.turnIndex,
    totalTurns: _state.totalTurns,
    round: _state.round,
    secondsRemaining: secondsRemaining ?? _state.secondsRemaining,
    scores: Map<String, int>.unmodifiable(scores ?? _state.scores),
    profiles: Map<String, PlayerProfile>.unmodifiable(_profiles),
    correctAnswers: Map<String, int>.unmodifiable(_correct),
    wrongAnswers: Map<String, int>.unmodifiable(_wrong),
    timeouts: Map<String, int>.unmodifiable(_timeouts),
    rankings: rankings ?? _state.rankings,
    answerVisible: answerVisible ?? _state.answerVisible,
    hintVisible: hintVisible ?? _state.hintVisible,
    pointsAwarded: pointsAwarded ?? _state.pointsAwarded,
    feedback: feedback ?? _state.feedback,
  );

  void _set(ActiveMatchState value) {
    _state = value;
    notifyListeners();
  }

  void _emit(GameAudioCue cue) {
    if (!_effects.isClosed) _effects.add(cue);
  }

  static List<PlayerProfile> _defaultProfiles(
    List<PlayerConfiguration> players,
  ) => <PlayerProfile>[
    for (var index = 0; index < players.length; index++)
      PlayerProfile(
        id: players[index].id,
        displayName: players[index].displayName,
        avatar: PlayerAvatarAppearance.forPlayer(index + 1),
      ),
  ];

  static List<PlayerRankingRow> _rank(List<PlayerMatchResult> results) {
    final sorted = [...results]
      ..sort((a, b) {
        final points = b.matchPoints.compareTo(a.matchPoints);
        if (points != 0) return points;
        final correct = b.correctAnswers.compareTo(a.correctAnswers);
        if (correct != 0) return correct;
        final wrong = a.wrongAnswers.compareTo(b.wrongAnswers);
        if (wrong != 0) return wrong;
        final timeouts = a.timeouts.compareTo(b.timeouts);
        if (timeouts != 0) return timeouts;
        return a.playerId.compareTo(b.playerId);
      });
    return <PlayerRankingRow>[
      for (var index = 0; index < sorted.length; index++)
        PlayerRankingRow(
          playerId: sorted[index].playerId,
          rank: index + 1,
          matchPoints: sorted[index].matchPoints,
          correctAnswers: sorted[index].correctAnswers,
          wrongAnswers: sorted[index].wrongAnswers,
          timeouts: sorted[index].timeouts,
          hintCreditsAwarded: switch (index) {
            0 => 5,
            1 => 3,
            2 => 1,
            _ => 0,
          },
        ),
    ];
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  @override
  void dispose() {
    _timer?.cancel();
    _introTimer?.cancel();
    unawaited(_effects.close());
    super.dispose();
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/round_game_format.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/active_match/application/answer_letter_hint.dart';

enum MatchPhase {
  playerIntro,
  roundIntro,
  challenge,
  turnAway,
  awaitingJudgement,
  winCountdown,
  paused,
  completing,
  complete,
}

enum GameAudioCue {
  playerIntroduction,
  roundIntroduction,
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
  const MatchChallenge({
    required this.moduleId,
    required this.formatId,
    required this.content,
  });

  final String moduleId;
  final String formatId;
  final OfflineChallenge content;

  String get id => content.id;
  String get prompt => content.promptForFormat(formatId);
  String get answer => content.answerForFormat(formatId);
  List<String> get choices => content.choicesForFormat(formatId);
  String get hint => content.hint;
  String? get flagAssetPath => content.flagAssetPath;
  double? get flagAspectRatio => content.flagAspectRatio;
  String? get imageFilePath => content.imageFilePath;
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
    this.hintText = '',
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
  final String hintText;
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
    Random? random,
    Iterable<String> recentChallengeIds = const <String>[],
    List<OfflineChallenge> pictureChallenges = const <OfflineChallenge>[],
    this.onChallengeDrawn,
    this.introductionDuration = const Duration(milliseconds: 1800),
  }) : _configuration = configuration,
       _profiles = Map<String, PlayerProfile>.from(
         profiles ??
             <String, PlayerProfile>{
               for (final profile in _defaultProfiles(configuration.players))
                 profile.id: profile,
             },
       ),
       matchId = matchId ?? DateTime.now().microsecondsSinceEpoch.toString(),
       _random = random ?? Random.secure(),
       _recentChallengeIds = Set<String>.from(recentChallengeIds),
       _pictureChallenges = List<OfflineChallenge>.unmodifiable(
         pictureChallenges,
       ),
       challengeSeconds = challengeSeconds ?? configuration.challengeSeconds,
       winCountdownSeconds =
           winCountdownSeconds ?? configuration.winCountdownSeconds,
       scoringEnabled = scoringEnabled ?? configuration.scoringEnabled {
    final initialIssue = _validateBaseConfiguration(configuration);
    if (initialIssue != null) {
      throw ArgumentError.value(configuration, 'configuration', initialIssue);
    }
    _roundSchedule = _buildRoundSchedule(configuration, _random);
    _moduleSchedule = _roundSchedule
        .map((format) => format.moduleId)
        .toList(growable: false);
    final requiredByPool = <String, int>{
      for (final format in _roundSchedule)
        _poolKey(format):
            (_roundSchedule
                .where((entry) => _poolKey(entry) == _poolKey(format))
                .length) *
            configuration.players.length,
    };
    final issue = _validateFormatContent(
      configuration,
      requiredByPool,
      _pictureChallenges,
    );
    if (issue != null) {
      throw ArgumentError.value(configuration, 'configuration', issue);
    }
    _challengeDecks = <String, List<OfflineChallenge>>{
      for (final poolKey in _roundSchedule.map(_poolKey).toSet())
        poolKey: _buildChallengeDeck(
          challengesForFormat(
            _roundSchedule
                .firstWhere((format) => _poolKey(format) == poolKey)
                .id,
            configuration: configuration,
            pictureChallenges: _pictureChallenges,
          ),
          _recentChallengeIds,
          _random,
        ),
    };
    _state = _stateForTurn(0, <String, int>{
      for (final player in configuration.players) player.id: 0,
    });
  }

  final SessionConfiguration _configuration;
  final Random _random;
  final Set<String> _recentChallengeIds;
  final List<OfflineChallenge> _pictureChallenges;
  final void Function(String challengeId)? onChallengeDrawn;
  late final List<String> _moduleSchedule;
  late final List<RoundGameFormat> _roundSchedule;
  late final Map<String, List<OfflineChallenge>> _challengeDecks;
  final Set<String> _reportedChallengeIds = <String>{};
  final bool enableTimers;
  final PlayerProfileRepository? profileRepository;
  final String matchId;
  final Duration introductionDuration;
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
  bool _hintPurchaseInProgress = false;

  ActiveMatchState get state => _state;
  Stream<GameAudioCue> get effects => _effects.stream;
  List<String> get moduleSchedule => List<String>.unmodifiable(_moduleSchedule);
  List<String> get formatSchedule =>
      List<String>.unmodifiable(_roundSchedule.map((format) => format.id));
  bool get canRevealHint =>
      _configuration.hintsEnabled &&
      !_state.hintVisible &&
      (_state.phase == MatchPhase.challenge ||
          _state.phase == MatchPhase.awaitingJudgement) &&
      (_redeemedChallenges.contains(_state.challenge.id) ||
          ((_profiles[_state.activePlayer.id]?.hintCredits ?? 0) > 0));

  void start() {
    if (_started) return;
    _started = true;
    _state = _stateForTurn(0, _state.scores, phase: MatchPhase.roundIntro);
    notifyListeners();
    _rememberCurrentChallenge();
    _emit(GameAudioCue.roundIntroduction);
  }

  void beginRound() {
    if (_state.phase != MatchPhase.roundIntro) return;
    _set(_stateForTurn(_state.turnIndex, _state.scores));
    _emit(GameAudioCue.playerIntroduction);
    _scheduleIntroduction();
  }

  static String? validateConfiguration(
    SessionConfiguration configuration, {
    List<OfflineChallenge> pictureChallenges = const <OfflineChallenge>[],
  }) {
    final baseIssue = _validateBaseConfiguration(configuration);
    if (baseIssue != null) return baseIssue;
    final players = configuration.players.length;
    final formats = configuration.effectiveRoundFormatIds
        .map(roundGameFormatById)
        .whereType<RoundGameFormat>()
        .toList();
    return validateConfigurationWithCounts(configuration, <String, int>{
      for (final moduleId in configuration.selectedModuleIds)
        moduleId:
            ((configuration.roundCount *
                        formats
                            .where((format) => format.moduleId == moduleId)
                            .length +
                    formats.length -
                    1) ~/
                formats.length) *
            players,
    }, pictureChallenges: pictureChallenges);
  }

  static String? validateConfigurationWithCounts(
    SessionConfiguration configuration,
    Map<String, int> requiredByModule, {
    List<OfflineChallenge> pictureChallenges = const <OfflineChallenge>[],
  }) {
    final baseIssue = _validateBaseConfiguration(configuration);
    if (baseIssue != null) return baseIssue;
    final formats = configuration.effectiveRoundFormatIds
        .map(roundGameFormatById)
        .whereType<RoundGameFormat>()
        .toList(growable: false);
    final requiredByPool = <String, int>{};
    for (final moduleId in configuration.selectedModuleIds) {
      final moduleFormats = formats
          .where((format) => format.moduleId == moduleId)
          .toList(growable: false);
      final poolIds = moduleFormats.map(_poolKey).toSet();
      final moduleNeed = requiredByModule[moduleId] ?? 0;
      for (final poolId in poolIds) {
        requiredByPool[poolId] =
            (moduleNeed + poolIds.length - 1) ~/ poolIds.length;
      }
    }
    return _validateFormatContent(
      configuration,
      requiredByPool,
      pictureChallenges,
    );
  }

  static String? _validateFormatContent(
    SessionConfiguration configuration,
    Map<String, int> requiredByPool,
    List<OfflineChallenge> pictureChallenges,
  ) {
    final formats = configuration.effectiveRoundFormatIds
        .map(roundGameFormatById)
        .whereType<RoundGameFormat>()
        .toList(growable: false);
    for (final entry in requiredByPool.entries) {
      final format = formats.firstWhere((item) => _poolKey(item) == entry.key);
      final expected = entry.value;
      final content = challengesForFormat(
        format.id,
        configuration: configuration,
        pictureChallenges: pictureChallenges,
      );
      final required = expected;
      if (content.length < required) {
        if (format.id == 'character_picture') {
          return 'Character Picture Mode needs $required distinct local images; only ${content.length} are installed. Import more pictures or reduce players and rounds.';
        }
        return '${format.title} has ${content.length} unique offline challenges; $required are required for this session. Reduce rounds or players.';
      }
    }
    return null;
  }

  static String? _validateBaseConfiguration(
    SessionConfiguration configuration,
  ) {
    if (!configuration.canStart) {
      if (configuration.effectiveRoundFormatIds.any(
        (id) => roundGameFormatById(id)?.available == false,
      )) {
        return 'Character Picture Mode is unavailable: no licensed local images are installed.';
      }
      return 'Choose one game family, its available round formats, players, and a round count.';
    }
    if (configuration.challengeSeconds < 1 ||
        configuration.winCountdownSeconds < 1) {
      return 'Challenge and Win Countdown timers must both be at least one second.';
    }
    if (configuration.scoringEnabled &&
        configuration.pointsPerCorrectAnswer < 1) {
      return 'Points per correct answer must be at least one when scoring is enabled.';
    }
    return null;
  }

  void beginChallenge() {
    if (_state.phase != MatchPhase.playerIntro) return;
    _introTimer?.cancel();
    final formatId = _state.challenge.formatId;
    final phase = switch (formatId) {
      'character_name' ||
      'character_picture' ||
      'country_name' => MatchPhase.turnAway,
      'country_flag' => MatchPhase.awaitingJudgement,
      _ => MatchPhase.challenge,
    };
    _set(
      _copy(
        phase: phase,
        secondsRemaining: phase == MatchPhase.turnAway ? 0 : challengeSeconds,
      ),
    );
    _rememberCurrentChallenge();
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
    if (_state.phase != MatchPhase.turnAway ||
        !const <String>{
          'character_name',
          'character_picture',
          'country_name',
        }.contains(_state.challenge.formatId)) {
      return;
    }
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
        _state.challenge.formatId != 'country_flag') {
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
        _state.hintVisible) {
      return false;
    }
    final existingHint = _hintTextByChallenge[_state.challenge.id];
    if (existingHint != null) {
      _set(_copy(hintVisible: true, hintText: existingHint));
      return true;
    }
    if (_hintPurchaseInProgress) return false;
    final generatedHint = _buildHintForCurrentAnswer();
    if (generatedHint == null) return false;
    final playerId = _state.activePlayer.id;
    final profile = _profiles[playerId];
    if (profile == null || profile.hintCredits < 1) return false;
    final repository = profileRepository;
    _hintPurchaseInProgress = true;
    try {
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
    } finally {
      _hintPurchaseInProgress = false;
    }
    _redeemedChallenges.add(_state.challenge.id);
    _hintTextByChallenge[_state.challenge.id] = generatedHint;
    _profiles = <String, PlayerProfile>{
      ..._profiles,
      playerId: profile.copyWith(hintCredits: profile.hintCredits - 1),
    };
    _set(_copy(hintVisible: true, hintText: generatedHint));
    _emit(GameAudioCue.hintPurchased);
    return true;
  }

  final Map<String, String> _hintTextByChallenge = <String, String>{};

  String? _buildHintForCurrentAnswer() {
    final letterHint = buildAnswerLetterHint(_state.challenge.answer);
    if (letterHint != null) return letterHint;
    final descriptive = _state.challenge.hint.trim();
    if (descriptive.isEmpty ||
        descriptive.toLowerCase() ==
            _state.challenge.answer.trim().toLowerCase()) {
      return null;
    }
    return descriptive;
  }

  void dismissHint() {
    if (_state.hintVisible) _set(_copy(hintVisible: false));
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
      case MatchPhase.roundIntro:
      case MatchPhase.challenge:
      case MatchPhase.awaitingJudgement:
        _runChallengeTimer();
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
        phase: MatchPhase.winCountdown,
        answerVisible: true,
        feedback: 'CORRECT',
        scores: scores,
        pointsAwarded: awarded,
        secondsRemaining: winCountdownSeconds,
      ),
    );
    _emit(GameAudioCue.correctAnswer);
    if (awarded > 0) _emit(GameAudioCue.pointsAwarded);
    _emit(GameAudioCue.winCountdownStart);
    _runCountdownTimer();
  }

  void _advance() {
    _timer?.cancel();
    _introTimer?.cancel();
    final next = _state.turnIndex + 1;
    if (next >= _state.totalTurns) {
      unawaited(_completeMatch());
      return;
    }
    final nextRound = next ~/ _configuration.players.length + 1;
    final phase = nextRound == _state.round
        ? MatchPhase.playerIntro
        : MatchPhase.roundIntro;
    _state = _stateForTurn(next, _state.scores, phase: phase);
    notifyListeners();
    _rememberCurrentChallenge();
    if (phase == MatchPhase.roundIntro) {
      _emit(GameAudioCue.roundIntroduction);
    } else {
      _emit(GameAudioCue.playerIntroduction);
      _scheduleIntroduction();
    }
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

  ActiveMatchState _stateForTurn(
    int turn,
    Map<String, int> scores, {
    MatchPhase phase = MatchPhase.playerIntro,
  }) {
    final playerCount = _configuration.players.length;
    final total = _configuration.roundCount * playerCount;
    final round = turn ~/ playerCount + 1;
    final format = _roundSchedule[round - 1];
    final moduleId = format.moduleId;
    final poolKey = _poolKey(format);
    final priorRoundsForFormat = _roundSchedule
        .take(round - 1)
        .where((entry) => _poolKey(entry) == poolKey)
        .length;
    final contentIndex =
        priorRoundsForFormat * playerCount + turn % playerCount;
    final playerIndex = turn % playerCount;
    final challenge = MatchChallenge(
      moduleId: moduleId,
      formatId: format.id,
      content: _challengeDecks[poolKey]![contentIndex],
    );
    return ActiveMatchState(
      phase: phase,
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

  void _rememberCurrentChallenge() {
    final id = _state.challenge.id;
    if (_reportedChallengeIds.add(id)) onChallengeDrawn?.call(id);
  }

  static List<RoundGameFormat> _buildRoundSchedule(
    SessionConfiguration configuration,
    Random random,
  ) {
    final enabledFormats = configuration.effectiveRoundFormatIds
        .map(roundGameFormatById)
        .whereType<RoundGameFormat>()
        .toList(growable: false);
    final result = <RoundGameFormat>[];
    while (result.length < configuration.roundCount) {
      final cycle = List<RoundGameFormat>.from(enabledFormats)..shuffle(random);
      if (result.isNotEmpty && cycle.length > 1) {
        final violatesBoundary = configuration.isMixed
            ? cycle.first.family == result.last.family
            : cycle.first.id == result.last.id;
        final differentIndex = configuration.isMixed
            ? cycle.indexWhere((format) => format.family != result.last.family)
            : cycle.indexWhere((format) => format.id != result.last.id);
        if (violatesBoundary && differentIndex > 0) {
          final first = cycle[0];
          cycle[0] = cycle[differentIndex];
          cycle[differentIndex] = first;
        }
      }
      result.addAll(cycle);
    }
    return result.take(configuration.roundCount).toList(growable: false);
  }

  static List<OfflineChallenge> _buildChallengeDeck(
    List<OfflineChallenge> eligible,
    Set<String> recentIds,
    Random random,
  ) {
    final shuffled = List<OfflineChallenge>.from(eligible)..shuffle(random);
    final unseen = shuffled.where((item) => !recentIds.contains(item.id));
    final recent = shuffled.where((item) => recentIds.contains(item.id));
    return <OfflineChallenge>[...unseen, ...recent];
  }

  static String _poolKey(RoundGameFormat format) =>
      format.id == 'character_picture' ? format.id : format.moduleId;

  ActiveMatchState _copy({
    MatchPhase? phase,
    int? secondsRemaining,
    bool? answerVisible,
    bool? hintVisible,
    String? hintText,
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
    hintText: hintText ?? _state.hintText,
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

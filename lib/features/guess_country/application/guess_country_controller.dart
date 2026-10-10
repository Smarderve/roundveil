import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/guess_country/domain/country_flag.dart';

enum ArenaScreen {
  opening,
  preparation,
  playerReady,
  challenge,
  winCountdown,
  complete,
}

enum CountryAnswerMode { multipleChoice, typed }

extension on CountryRegion {
  String get label => switch (this) {
    CountryRegion.africa => 'Africa',
    CountryRegion.americas => 'the Americas',
    CountryRegion.asia => 'Asia',
    CountryRegion.europe => 'Europe',
    CountryRegion.oceania => 'Oceania',
    CountryRegion.worldwide => 'worldwide',
  };
}

extension on CountryDifficulty {
  String get label => switch (this) {
    CountryDifficulty.easy => 'Easy',
    CountryDifficulty.medium => 'Medium',
    CountryDifficulty.hard => 'Hard',
    CountryDifficulty.expert => 'Expert',
    CountryDifficulty.mixed => 'Mixed',
  };
}

class GuessCountrySetup {
  const GuessCountrySetup({
    this.roundCount,
    this.difficulty,
    this.region,
    this.answerMode,
    this.challengeSeconds,
    this.hintsEnabled,
    this.winCountdownSeconds,
    this.scoringEnabled,
  });

  final int? roundCount;
  final CountryDifficulty? difficulty;
  final CountryRegion? region;
  final CountryAnswerMode? answerMode;
  final int? challengeSeconds;
  final bool? hintsEnabled;
  final int? winCountdownSeconds;
  final bool? scoringEnabled;

  bool get isComplete =>
      roundCount != null &&
      difficulty != null &&
      region != null &&
      answerMode != null &&
      challengeSeconds != null &&
      hintsEnabled != null &&
      winCountdownSeconds != null &&
      scoringEnabled != null;

  String? validate(List<CountryFlag> flags, int playerCount) {
    if (!isComplete) {
      return 'Choose every match setting to continue.';
    }
    if (playerCount < 1) {
      return 'Add at least one player before preparing a match.';
    }
    final eligible = flags.where(_matches).toList();
    final scope = region == CountryRegion.worldwide
        ? 'worldwide'
        : region!.label;
    if (eligible.isEmpty) {
      return 'The seven-flag review pack has no ${difficulty!.label} flags for $scope.';
    }
    if (answerMode == CountryAnswerMode.multipleChoice && eligible.length < 2) {
      return 'Only one flag is eligible for $scope. Multiple choice needs an in-scope alternative; choose typed answers or another scope.';
    }
    final required = playerCount * roundCount!;
    if (eligible.length < required) {
      return 'Only ${eligible.length} unique flags fit $scope / ${difficulty!.label}; $required are needed ($playerCount players × $roundCount rounds). Reduce players or rounds, or widen scope/change difficulty. Flags will not repeat.';
    }
    return null;
  }

  bool _matches(CountryFlag flag) =>
      (region == CountryRegion.worldwide || flag.region == region) &&
      (difficulty == CountryDifficulty.mixed || flag.difficulty == difficulty);

  GuessCountrySetup copyWith({
    int? roundCount,
    CountryDifficulty? difficulty,
    CountryRegion? region,
    CountryAnswerMode? answerMode,
    int? challengeSeconds,
    bool? hintsEnabled,
    int? winCountdownSeconds,
    bool? scoringEnabled,
    bool clearRegion = false,
  }) => GuessCountrySetup(
    roundCount: roundCount ?? this.roundCount,
    difficulty: difficulty ?? this.difficulty,
    region: clearRegion ? null : region ?? this.region,
    answerMode: answerMode ?? this.answerMode,
    challengeSeconds: challengeSeconds ?? this.challengeSeconds,
    hintsEnabled: hintsEnabled ?? this.hintsEnabled,
    winCountdownSeconds: winCountdownSeconds ?? this.winCountdownSeconds,
    scoringEnabled: scoringEnabled ?? this.scoringEnabled,
  );
}

class GuessCountryState {
  const GuessCountryState({
    this.screen = ArenaScreen.opening,
    this.players = const <PlayerConfiguration>[],
    this.setup = const GuessCountrySetup(),
    this.round = 1,
    this.playerIndex = 0,
    this.seenFlagIds = const <String>{},
    this.secondsRemaining = 0,
    this.hintVisible = false,
    this.scores = const <String, int>{},
    this.notice,
  });

  final ArenaScreen screen;
  final List<PlayerConfiguration> players;
  final GuessCountrySetup setup;
  final int round;
  final int playerIndex;
  final Set<String> seenFlagIds;
  final int secondsRemaining;
  final bool hintVisible;
  final Map<String, int> scores;
  final String? notice;

  PlayerConfiguration get activePlayer => players[playerIndex];
  bool get isReady => players.isNotEmpty && setup.isComplete;

  GuessCountryState copyWith({
    ArenaScreen? screen,
    List<PlayerConfiguration>? players,
    GuessCountrySetup? setup,
    int? round,
    int? playerIndex,
    Set<String>? seenFlagIds,
    int? secondsRemaining,
    bool? hintVisible,
    Map<String, int>? scores,
    String? notice,
    bool clearNotice = false,
  }) => GuessCountryState(
    screen: screen ?? this.screen,
    players: players ?? this.players,
    setup: setup ?? this.setup,
    round: round ?? this.round,
    playerIndex: playerIndex ?? this.playerIndex,
    seenFlagIds: seenFlagIds ?? this.seenFlagIds,
    secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    hintVisible: hintVisible ?? this.hintVisible,
    scores: scores ?? this.scores,
    notice: clearNotice ? null : notice ?? this.notice,
  );
}

class GuessCountryController extends ChangeNotifier {
  GuessCountryController({
    List<CountryFlag> flags = firstSliceFlags,
    this.onCountdownComplete,
    this.enableTimers = true,
  }) : _flags = List<CountryFlag>.unmodifiable(flags),
       super();

  final List<CountryFlag> _flags;
  final VoidCallback? onCountdownComplete;
  final bool enableTimers;
  Timer? _timer;
  GuessCountryState _state = const GuessCountryState();

  GuessCountryState get state => _state;

  CountryFlag get activeFlag {
    final unseen = _eligibleFlags
        .where((flag) => !_state.seenFlagIds.contains(flag.id))
        .toList();
    if (unseen.isEmpty) {
      throw StateError('No unseen eligible country flag remains.');
    }
    return unseen.first;
  }

  String? get configurationIssue =>
      _state.setup.validate(_flags, _state.players.length);
  List<CountryDifficulty> get availableDifficulties => CountryDifficulty.values
      .where(
        (difficulty) => _flags.any((flag) => flag.difficulty == difficulty),
      )
      .toList();

  List<CountryRegion> availableRegions([CountryDifficulty? difficulty]) =>
      CountryRegion.values
          .where(
            (region) => _flags.any(
              (flag) =>
                  flag.region == region &&
                  (difficulty == null || flag.difficulty == difficulty),
            ),
          )
          .toList();

  List<CountryFlag> get _eligibleFlags {
    final setup = _state.setup;
    return _flags.where(setup._matches).toList();
  }

  List<String> get answerOptions {
    final correct = activeFlag.name;
    final choices =
        _eligibleFlags
            .where((flag) => flag.id != activeFlag.id)
            .map((flag) => flag.name)
            .toList()
          ..sort();
    return <String>[correct, ...choices.take(3)]..sort();
  }

  void openPreparation() =>
      _set(_state.copyWith(screen: ArenaScreen.preparation, clearNotice: true));
  void addPlayer() {
    final position = _state.players.length + 1;
    _set(
      _state.copyWith(
        players: [..._state.players, PlayerConfiguration.placeholder(position)],
      ),
    );
  }

  void removePlayer() {
    if (_state.players.length <= 1) return;
    _set(
      _state.copyWith(
        players: _state.players.sublist(0, _state.players.length - 1),
      ),
    );
  }

  void configure(GuessCountrySetup setup) =>
      _set(_state.copyWith(setup: setup, clearNotice: true));

  void prepareSession() {
    if (!_state.isReady || configurationIssue != null) {
      _set(
        _state.copyWith(
          notice:
              configurationIssue ?? 'Choose every match setting to continue.',
        ),
      );
      return;
    }
    _set(_state.copyWith(screen: ArenaScreen.playerReady, clearNotice: true));
  }

  void startTurn() {
    if (configurationIssue != null ||
        !_eligibleFlags.any((flag) => !_state.seenFlagIds.contains(flag.id))) {
      _set(
        _state.copyWith(
          notice: configurationIssue ?? 'No unseen eligible flag remains.',
        ),
      );
      return;
    }
    _set(
      _state.copyWith(
        screen: ArenaScreen.challenge,
        hintVisible: false,
        secondsRemaining: _state.setup.challengeSeconds ?? 0,
        clearNotice: true,
      ),
    );
    final seconds = _state.setup.challengeSeconds ?? 0;
    if (seconds > 0) _startTimer(seconds, _onChallengeTick);
  }

  void revealHint() => _set(_state.copyWith(hintVisible: true));

  void submitAnswer(String answer) {
    if (_state.screen != ArenaScreen.challenge) return;
    final normalized = _normalize(answer);
    final correct = <String>{
      _normalize(activeFlag.name),
      ...activeFlag.aliases.map(_normalize),
    };
    _timer?.cancel();
    if (correct.contains(normalized)) {
      final seconds = _state.setup.winCountdownSeconds!;
      final scores = Map<String, int>.from(_state.scores);
      if (_state.setup.scoringEnabled!) {
        final player = _state.activePlayer.displayName;
        scores[player] = (scores[player] ?? 0) + 1;
      }
      _set(
        _state.copyWith(
          screen: ArenaScreen.winCountdown,
          secondsRemaining: seconds,
          scores: scores,
          seenFlagIds: {..._state.seenFlagIds, activeFlag.id},
          notice: 'Correct — Win Countdown active now.',
        ),
      );
      _startTimer(seconds, _onWinTick);
      return;
    }
    _advanceWithoutCountdown(
      'Incorrect — no Win Countdown. Next player ready.',
    );
  }

  void completeCountdown() {
    _timer?.cancel();
    _advanceWithoutCountdown('Countdown complete. Next player ready.');
  }

  void _onChallengeTick() {
    if (_state.secondsRemaining <= 1) {
      _timer?.cancel();
      _advanceWithoutCountdown(
        'Time expired — no Win Countdown. Next player ready.',
      );
    } else {
      _set(_state.copyWith(secondsRemaining: _state.secondsRemaining - 1));
    }
  }

  void _onWinTick() {
    if (_state.secondsRemaining <= 1) {
      onCountdownComplete?.call();
      completeCountdown();
    } else {
      _set(_state.copyWith(secondsRemaining: _state.secondsRemaining - 1));
    }
  }

  void _advanceWithoutCountdown(String notice) {
    final seenFlagIds = _state.screen == ArenaScreen.challenge
        ? {..._state.seenFlagIds, activeFlag.id}
        : _state.seenFlagIds;
    final lastPlayer = _state.playerIndex == _state.players.length - 1;
    final nextRound = lastPlayer ? _state.round + 1 : _state.round;
    if (nextRound > _state.setup.roundCount!) {
      _set(
        _state.copyWith(
          screen: ArenaScreen.complete,
          seenFlagIds: seenFlagIds,
          notice: 'Session complete.',
        ),
      );
      return;
    }
    _set(
      _state.copyWith(
        screen: ArenaScreen.playerReady,
        playerIndex: lastPlayer ? 0 : _state.playerIndex + 1,
        round: nextRound,
        seenFlagIds: seenFlagIds,
        notice: notice,
      ),
    );
  }

  void finishSession() {
    _timer?.cancel();
    _set(GuessCountryState(players: _state.players));
  }

  void _startTimer(int seconds, VoidCallback tick) {
    _timer?.cancel();
    if (!enableTimers) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  void _set(GuessCountryState next) {
    _state = next;
    notifyListeners();
  }

  String _normalize(String value) => value
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ');

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

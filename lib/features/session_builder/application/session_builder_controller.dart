import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/session_draft.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';

enum SessionFormat { single, mixed }

class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.titleKey,
    required this.iconCodePoint,
    this.playable = false,
  });

  final String id;
  final String titleKey;
  final int iconCodePoint;
  final bool playable;
}

const gameCatalog = <GameDefinition>[
  GameDefinition(
    id: 'quiz',
    titleKey: 'quiz',
    iconCodePoint: 0xe0bf,
    playable: true,
  ),
  GameDefinition(
    id: 'word_play',
    titleKey: 'wordPlay',
    iconCodePoint: 0xe262,
    playable: true,
  ),
  GameDefinition(
    id: 'guess_character',
    titleKey: 'guessCharacter',
    iconCodePoint: 0xe87c,
    playable: true,
  ),
  GameDefinition(
    id: 'guess_country_flags',
    titleKey: 'guessCountry',
    iconCodePoint: 0xe3a8,
    playable: true,
  ),
];

class QuickGameTemplate {
  const QuickGameTemplate({
    required this.id,
    required this.titleKey,
    required this.moduleIds,
    required this.players,
    required this.rounds,
  });

  final String id;
  final String titleKey;
  final List<String> moduleIds;
  final int players;
  final int rounds;

  SessionConfiguration get configuration => SessionConfiguration(
    players: List<PlayerConfiguration>.generate(
      players,
      (index) => PlayerConfiguration.placeholder(index + 1),
    ),
    selectedModuleIds: moduleIds,
    roundCount: rounds,
    isMixed: moduleIds.length > 1,
    challengeSeconds: 45,
    winCountdownSeconds: 3,
    hintsEnabled: true,
    scoringEnabled: true,
    countryRegion: 'worldwide',
    countryDifficulty: 'mixed',
  );
}

const quickGameTemplates = <QuickGameTemplate>[
  QuickGameTemplate(
    id: 'quick_quiz',
    titleKey: 'quickQuiz',
    moduleIds: <String>['quiz'],
    players: 2,
    rounds: 5,
  ),
  QuickGameTemplate(
    id: 'quick_word_play',
    titleKey: 'quickWordPlay',
    moduleIds: <String>['word_play'],
    players: 2,
    rounds: 4,
  ),
  QuickGameTemplate(
    id: 'quick_character',
    titleKey: 'quickCharacter',
    moduleIds: <String>['guess_character'],
    players: 3,
    rounds: 3,
  ),
  QuickGameTemplate(
    id: 'quick_flags',
    titleKey: 'quickFlags',
    moduleIds: <String>['guess_country_flags'],
    players: 2,
    rounds: 3,
  ),
  QuickGameTemplate(
    id: 'quick_party_mix',
    titleKey: 'quickPartyMix',
    moduleIds: <String>[
      'quiz',
      'word_play',
      'guess_character',
      'guess_country_flags',
    ],
    players: 3,
    rounds: 4,
  ),
];

class SessionBuilderController extends ChangeNotifier {
  SessionBuilderController({
    required this.drafts,
    SessionConfiguration? initial,
    this.templateId,
    this.draftId,
    String? name,
  }) : _configuration = _supportedConfiguration(
         initial ?? const SessionConfiguration(),
       ),
       _name = name ?? '';

  final DraftRepository drafts;
  SessionConfiguration _configuration;
  final String? templateId;
  final String? draftId;
  String _name;
  String? _message;
  bool _busy = false;

  SessionConfiguration get configuration => _configuration;
  String get name => _name;
  String? get message => _message;
  bool get busy => _busy;
  SessionFormat get format =>
      _configuration.isMixed ? SessionFormat.mixed : SessionFormat.single;

  String? get validationMessage {
    if (_configuration.players.isEmpty) return 'player';
    if (_configuration.selectedModuleIds.isEmpty) return 'game';
    if (_configuration.isMixed && _configuration.selectedModuleIds.length < 2) {
      return 'mixed';
    }
    if (!_configuration.isMixed &&
        _configuration.selectedModuleIds.length != 1) {
      return 'single';
    }
    if (_configuration.roundCount < 1) return 'rounds';
    return null;
  }

  static SessionConfiguration _supportedConfiguration(
    SessionConfiguration configuration,
  ) => configuration.copyWith(
    selectedModuleIds: configuration.selectedModuleIds
        .where(activeGameModuleIds.contains)
        .toSet()
        .toList(),
  );

  bool get canCreate => validationMessage == null && !_busy;

  bool get canStartMatch => startValidationMessage == null && !_busy;

  String? get startValidationMessage {
    final issue = validationMessage;
    if (issue != null) return issue;
    final moduleCount = _configuration.selectedModuleIds.length;
    final maxRoundsPerModule = _configuration.isMixed
        ? (_configuration.roundCount + moduleCount - 1) ~/ moduleCount
        : _configuration.roundCount;
    final requiredChallenges =
        maxRoundsPerModule * _configuration.players.length;
    for (final moduleId in _configuration.selectedModuleIds) {
      final available = challengesForModule(
        moduleId,
        configuration: _configuration,
      ).length;
      if (available < requiredChallenges) {
        return '$moduleId has $available unique offline challenges; $requiredChallenges are required. Reduce rounds or players.';
      }
    }
    return null;
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setFormat(SessionFormat value) {
    final selected = _configuration.selectedModuleIds;
    _configuration = _configuration.copyWith(
      isMixed: value == SessionFormat.mixed,
      selectedModuleIds: value == SessionFormat.single && selected.length > 1
          ? selected.take(1).toList()
          : selected,
    );
    notifyListeners();
  }

  void toggleGame(String id) {
    if (!gameCatalog.any((game) => game.id == id)) return;
    final selected = List<String>.from(_configuration.selectedModuleIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else if (_configuration.isMixed) {
      selected.add(id);
    } else {
      selected
        ..clear()
        ..add(id);
    }
    _configuration = _configuration.copyWith(selectedModuleIds: selected);
    notifyListeners();
  }

  void addPlayer() {
    final next = _configuration.players.length + 1;
    _configuration = _configuration.copyWith(
      players: <PlayerConfiguration>[
        ..._configuration.players,
        PlayerConfiguration.placeholder(next),
      ],
    );
    notifyListeners();
  }

  void removePlayer() {
    if (_configuration.players.isEmpty) return;
    final players = List<PlayerConfiguration>.generate(
      _configuration.players.length - 1,
      (index) => PlayerConfiguration.placeholder(index + 1),
    );
    _configuration = _configuration.copyWith(players: players);
    notifyListeners();
  }

  void setRoundCount(int value) {
    _configuration = _configuration.copyWith(roundCount: value);
    notifyListeners();
  }

  void setChallengeSeconds(int value) {
    _configuration = _configuration.copyWith(challengeSeconds: value);
    notifyListeners();
  }

  void setWinCountdownSeconds(int value) {
    _configuration = _configuration.copyWith(winCountdownSeconds: value);
    notifyListeners();
  }

  void setHintsEnabled(bool value) {
    _configuration = _configuration.copyWith(hintsEnabled: value);
    notifyListeners();
  }

  void setScoringEnabled(bool value) {
    _configuration = _configuration.copyWith(scoringEnabled: value);
    notifyListeners();
  }

  void setPointsPerCorrectAnswer(int value) {
    if (value < 1) return;
    _configuration = _configuration.copyWith(pointsPerCorrectAnswer: value);
    notifyListeners();
  }

  void setCountryRegion(String value) {
    _configuration = _configuration.copyWith(countryRegion: value);
    notifyListeners();
  }

  void setCountryDifficulty(String value) {
    _configuration = _configuration.copyWith(countryDifficulty: value);
    notifyListeners();
  }

  Future<SessionDraft?> saveDraft() async {
    if (validationMessage != null || _busy) return null;
    _busy = true;
    notifyListeners();
    final draft = SessionDraft(
      id:
          draftId ??
          '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 20)}',
      name: _name.trim().isEmpty ? 'ROUNDVEIL Session' : _name.trim(),
      configuration: _configuration,
      updatedAt: DateTime.now(),
      templateId: templateId,
    );
    try {
      await drafts.save(draft);
      _message = 'saved';
      return draft;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<SessionConfiguration?> startMatch() async {
    if (!canStartMatch) return null;
    _busy = true;
    notifyListeners();
    try {
      return _configuration;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}

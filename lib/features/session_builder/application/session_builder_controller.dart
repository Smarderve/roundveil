import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/session_draft.dart';
import 'package:roundveil/domain/session/round_game_format.dart';
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
    roundFormatIds: defaultRoundFormatIds(moduleIds),
    roundCount: rounds,
    isMixed: moduleIds.length > 1,
    challengeSeconds: 45,
    winCountdownSeconds: 10,
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
  List<RoundGameFormat> get selectedRoundFormats => _configuration
      .effectiveRoundFormatIds
      .map(roundGameFormatById)
      .whereType<RoundGameFormat>()
      .toList(growable: false);

  String? get validationMessage {
    if (_configuration.players.isEmpty) return 'player';
    if (_configuration.selectedModuleIds.isEmpty) return 'game';
    final familyCount = _configuration.selectedGameFamilies.length;
    if (_configuration.isMixed && familyCount < 2) {
      return 'mixed';
    }
    if (!_configuration.isMixed && familyCount != 1) {
      return 'single';
    }
    if (_configuration.roundCount < 1) return 'rounds';
    if (!_configuration.canStart) return 'format';
    return null;
  }

  static SessionConfiguration _supportedConfiguration(
    SessionConfiguration configuration,
  ) {
    final modules = configuration.selectedModuleIds
        .where(activeGameModuleIds.contains)
        .toSet()
        .toList();
    final formats = configuration.roundFormatIds
        .where((id) {
          final format = roundGameFormatById(id);
          return format == null || modules.contains(format.moduleId);
        })
        .toSet()
        .toList();
    final validFormats = configuration.roundFormatIds.isEmpty
        ? defaultRoundFormatIds(modules)
        : formats;
    return configuration.copyWith(
      selectedModuleIds: modules,
      roundFormatIds: validFormats,
      isMixed: configuration.isMixed,
    );
  }

  bool get canCreate => validationMessage == null && !_busy;

  bool get canStartMatch => startValidationMessage == null && !_busy;

  String? get startValidationMessage {
    final issue = validationMessage;
    if (issue != null) {
      return switch (issue) {
        'player' => 'Select at least one saved player for this match.',
        'game' => 'Select a game and its round formats.',
        'mixed' => 'Mixed Games needs formats from at least two game families.',
        'single' => 'A single-game session must use one game family.',
        'rounds' => 'Choose how many rounds to play.',
        'format' => 'Select an available round format for every selected game. Character Picture Mode needs licensed local images and is unavailable.',
        _ => issue,
      };
    }
    final formats = _configuration.effectiveRoundFormatIds
        .map(roundGameFormatById)
        .whereType<RoundGameFormat>()
        .toList();
    for (final moduleId in _configuration.selectedModuleIds) {
      final formatCount = formats
          .where((format) => format.moduleId == moduleId)
          .length;
      final possibleRounds =
          (_configuration.roundCount * formatCount + formats.length - 1) ~/
          formats.length;
      final requiredChallenges = possibleRounds * _configuration.players.length;
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
    var selected = List<String>.from(_configuration.selectedModuleIds);
    if (value == SessionFormat.single) {
      final families = <RoundGameFamily>{};
      selected = selected.where((module) {
        final family = familyForModule(module);
        if (family == null ||
            families.isNotEmpty && !families.contains(family)) {
          return false;
        }
        families.add(family);
        return true;
      }).toList();
    }
    _configuration = _configuration.copyWith(
      isMixed: value == SessionFormat.mixed,
      selectedModuleIds: selected,
      roundFormatIds: _configuration.effectiveRoundFormatIds.where((id) {
        final format = roundGameFormatById(id);
        return format != null && selected.contains(format.moduleId);
      }).toList(),
    );
    notifyListeners();
  }

  /// Replaces the selected game family set from the simplified match-entry UI.
  /// Formats are initialized to one playable format per selected module; hosts
  /// can change them under Advanced Settings.
  void setGameSelection({
    required List<String> moduleIds,
    required bool mixed,
  }) {
    final modules = moduleIds
        .where(activeGameModuleIds.contains)
        .toSet()
        .toList(growable: false);
    final formats = defaultRoundFormatIds(modules)
        .where((id) => roundGameFormatById(id)?.available ?? false)
        .toList(growable: false);
    _configuration = _configuration.copyWith(
      selectedModuleIds: modules,
      roundFormatIds: formats,
      roundFormatsExplicit: true,
      isMixed: mixed,
    );
    notifyListeners();
  }

  void setPlayers(List<PlayerConfiguration> players) {
    final unique = <String>{};
    _configuration = _configuration.copyWith(
      players: players
          .where((player) => unique.add(player.id))
          .toList(growable: false),
    );
    notifyListeners();
  }

  void toggleGame(String id) {
    if (!gameCatalog.any((game) => game.id == id)) return;
    final selected = List<String>.from(_configuration.selectedModuleIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else if (_configuration.isMixed ||
        familyForModule(id) == RoundGameFamily.guessingGames &&
            selected.any(
              (item) => familyForModule(item) == RoundGameFamily.guessingGames,
            )) {
      selected.add(id);
    } else {
      selected
        ..clear()
        ..add(id);
    }
    var formats = _configuration.effectiveRoundFormatIds.where((formatId) {
      final format = roundGameFormatById(formatId);
      return format != null && selected.contains(format.moduleId);
    }).toList();
    for (final module in selected) {
      if (!formats.any(
        (formatId) => roundGameFormatById(formatId)?.moduleId == module,
      )) {
        formats.add(defaultFormatIdForModule(module));
      }
    }
    _configuration = _configuration.copyWith(
      selectedModuleIds: selected,
      roundFormatIds: formats,
      // Keep the user's selected Mixed mode while the first family is being
      // assembled; otherwise an empty mixed playlist silently collapses to
      // Single as soon as its first game is chosen.
      isMixed:
          _configuration.isMixed ||
          selected.map(familyForModule).toSet().length > 1,
    );
    notifyListeners();
  }

  void toggleRoundFormat(String formatId) {
    final format = roundGameFormatById(formatId);
    if (format == null ||
        !_configuration.selectedModuleIds.contains(format.moduleId)) {
      return;
    }
    final selected = List<String>.from(_configuration.effectiveRoundFormatIds);
    if (selected.contains(formatId)) {
      selected.remove(formatId);
      if (!selected.any(
        (id) => roundGameFormatById(id)?.moduleId == format.moduleId,
      )) {
        return;
      }
    } else {
      if (!format.available) return;
      selected.add(formatId);
    }
    _configuration = _configuration.copyWith(
      roundFormatIds: selected,
      roundFormatsExplicit: true,
    );
    notifyListeners();
  }

  /// Allows hosts to repair a persisted draft that selected a format which
  /// is no longer available (or is unknown to this app version).
  void removeUnsupportedRoundFormat(String formatId) {
    final format = roundGameFormatById(formatId);
    if (format != null && format.available) return;
    final selected = List<String>.from(_configuration.effectiveRoundFormatIds)
      ..remove(formatId);
    _configuration = _configuration.copyWith(
      roundFormatIds: selected,
      roundFormatsExplicit: true,
    );
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

  void setCharacterPictureCategory(String value) {
    _configuration = _configuration.copyWith(characterPictureCategory: value);
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

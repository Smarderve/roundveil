import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/session_draft.dart';

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
  GameDefinition(id: 'quiz', titleKey: 'quiz', iconCodePoint: 0xe0bf),
  GameDefinition(id: 'word_play', titleKey: 'wordPlay', iconCodePoint: 0xe262),
  GameDefinition(
    id: 'guess_character',
    titleKey: 'guessCharacter',
    iconCodePoint: 0xe87c,
  ),
  GameDefinition(id: 'riddles', titleKey: 'riddles', iconCodePoint: 0xe3a5),
  GameDefinition(id: 'memory', titleKey: 'memory', iconCodePoint: 0xe1bd),
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
    id: 'quick_riddles',
    titleKey: 'quickRiddles',
    moduleIds: <String>['riddles'],
    players: 2,
    rounds: 4,
  ),
  QuickGameTemplate(
    id: 'quick_memory',
    titleKey: 'quickMemory',
    moduleIds: <String>['memory'],
    players: 2,
    rounds: 4,
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
    moduleIds: <String>['quiz', 'word_play', 'riddles'],
    players: 4,
    rounds: 6,
  ),
];

class SessionBuilderController extends ChangeNotifier {
  SessionBuilderController({
    required this.drafts,
    SessionConfiguration? initial,
    this.templateId,
    this.draftId,
    String? name,
  }) : _configuration = initial ?? const SessionConfiguration(),
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

  bool get canCreate => validationMessage == null && !_busy;

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

  Future<SessionDraft?> createSession() async => saveDraft();
}

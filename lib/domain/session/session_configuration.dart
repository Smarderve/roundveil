import 'round_game_format.dart';

const activeGameModuleIds = <String>{
  'quiz',
  'word_play',
  'guess_character',
  'guess_country_flags',
};

class PlayerConfiguration {
  const PlayerConfiguration({required this.id, required this.displayName});

  factory PlayerConfiguration.placeholder(int position) {
    if (position < 1) {
      throw ArgumentError.value(position, 'position', 'Must be positive.');
    }

    return PlayerConfiguration(
      id: 'player-$position',
      displayName: 'Player $position',
    );
  }

  final String id;
  final String displayName;
}

class SessionConfiguration {
  const SessionConfiguration({
    this.players = const <PlayerConfiguration>[],
    this.selectedModuleIds = const <String>[],
    this.roundFormatIds = const <String>[],
    this.roundFormatsExplicit = false,
    this.roundCount = 0,
    this.isMixed = false,
    this.challengeSeconds = 45,
    this.winCountdownSeconds = 10,
    this.hintsEnabled = true,
    this.scoringEnabled = true,
    this.pointsPerCorrectAnswer = 1,
    this.countryRegion = 'worldwide',
    this.countryDifficulty = 'mixed',
  });

  final List<PlayerConfiguration> players;
  final List<String> selectedModuleIds;

  /// Format pool shuffled at round boundaries. Empty is retained only for
  /// backwards-compatible legacy drafts/configurations.
  final List<String> roundFormatIds;

  /// Distinguishes an intentionally empty selection from a legacy config that
  /// predates round formats and needs its compatibility format mapping.
  final bool roundFormatsExplicit;
  final int roundCount;
  final bool isMixed;
  final int challengeSeconds;
  final int winCountdownSeconds;
  final bool hintsEnabled;
  final bool scoringEnabled;
  final int pointsPerCorrectAnswer;
  final String countryRegion;
  final String countryDifficulty;

  SessionConfiguration copyWith({
    List<PlayerConfiguration>? players,
    List<String>? selectedModuleIds,
    List<String>? roundFormatIds,
    bool? roundFormatsExplicit,
    int? roundCount,
    bool? isMixed,
    int? challengeSeconds,
    int? winCountdownSeconds,
    bool? hintsEnabled,
    bool? scoringEnabled,
    int? pointsPerCorrectAnswer,
    String? countryRegion,
    String? countryDifficulty,
  }) => SessionConfiguration(
    players: players ?? this.players,
    selectedModuleIds: selectedModuleIds ?? this.selectedModuleIds,
    roundFormatIds: roundFormatIds ?? this.roundFormatIds,
    roundFormatsExplicit:
        roundFormatsExplicit ??
        (roundFormatIds != null || this.roundFormatsExplicit),
    roundCount: roundCount ?? this.roundCount,
    isMixed: isMixed ?? this.isMixed,
    challengeSeconds: challengeSeconds ?? this.challengeSeconds,
    winCountdownSeconds: winCountdownSeconds ?? this.winCountdownSeconds,
    hintsEnabled: hintsEnabled ?? this.hintsEnabled,
    scoringEnabled: scoringEnabled ?? this.scoringEnabled,
    pointsPerCorrectAnswer:
        pointsPerCorrectAnswer ?? this.pointsPerCorrectAnswer,
    countryRegion: countryRegion ?? this.countryRegion,
    countryDifficulty: countryDifficulty ?? this.countryDifficulty,
  );

  List<String> get effectiveRoundFormatIds =>
      roundFormatIds.isEmpty && !roundFormatsExplicit
      ? defaultRoundFormatIds(selectedModuleIds)
      : roundFormatIds;

  Set<RoundGameFamily> get selectedGameFamilies => selectedModuleIds
      .map(familyForModule)
      .whereType<RoundGameFamily>()
      .toSet();

  bool get canStart {
    if (players.isEmpty || selectedModuleIds.isEmpty || roundCount < 1) {
      return false;
    }
    if (selectedModuleIds.toSet().length != selectedModuleIds.length ||
        !selectedModuleIds.every(activeGameModuleIds.contains)) {
      return false;
    }
    final families = selectedGameFamilies;
    if (families.isEmpty || isMixed != (families.length > 1)) return false;
    final formats = effectiveRoundFormatIds;
    if (formats.isEmpty || formats.toSet().length != formats.length) {
      return false;
    }
    final definitions = formats.map(roundGameFormatById).toList();
    if (definitions.any((format) => format == null || !format.available)) {
      return false;
    }
    final formatsByModule = <String>{
      for (final format in definitions) format!.moduleId,
    };
    return formatsByModule.length == selectedModuleIds.length &&
        selectedModuleIds.every(formatsByModule.contains) &&
        definitions.every((format) => families.contains(format!.family));
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'players': players
        .map(
          (player) => <String, String>{
            'id': player.id,
            'displayName': player.displayName,
          },
        )
        .toList(),
    'selectedModuleIds': selectedModuleIds,
    'roundFormatIds': roundFormatIds,
    'roundFormatsExplicit': roundFormatsExplicit,
    'roundCount': roundCount,
    'isMixed': isMixed,
    'challengeSeconds': challengeSeconds,
    'winCountdownSeconds': winCountdownSeconds,
    'hintsEnabled': hintsEnabled,
    'scoringEnabled': scoringEnabled,
    'pointsPerCorrectAnswer': pointsPerCorrectAnswer,
    'countryRegion': countryRegion,
    'countryDifficulty': countryDifficulty,
  };

  factory SessionConfiguration.fromJson(Map<String, Object?> json) =>
      SessionConfiguration(
        players: (json['players'] as List<Object?>? ?? const <Object?>[])
            .map(
              (value) => PlayerConfiguration(
                id: (value as Map<String, Object?>)['id']! as String,
                displayName: value['displayName']! as String,
              ),
            )
            .toList(),
        selectedModuleIds:
            (json['selectedModuleIds'] as List<Object?>? ?? const <Object?>[])
                .cast<String>(),
        roundFormatIds:
            (json['roundFormatIds'] as List<Object?>? ?? const <Object?>[])
                .cast<String>(),
        roundFormatsExplicit:
            json['roundFormatsExplicit'] as bool? ??
            ((json['roundFormatIds'] as List<Object?>?)?.isNotEmpty ?? false),
        roundCount: json['roundCount'] as int? ?? 3,
        isMixed: json['isMixed'] as bool? ?? false,
        challengeSeconds: json['challengeSeconds'] as int? ?? 45,
        winCountdownSeconds: json['winCountdownSeconds'] as int? ?? 10,
        hintsEnabled: json['hintsEnabled'] as bool? ?? true,
        scoringEnabled: json['scoringEnabled'] as bool? ?? true,
        pointsPerCorrectAnswer: json['pointsPerCorrectAnswer'] as int? ?? 1,
        countryRegion: json['countryRegion'] as String? ?? 'worldwide',
        countryDifficulty: json['countryDifficulty'] as String? ?? 'mixed',
      );
}

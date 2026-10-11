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
    this.roundCount = 0,
    this.isMixed = false,
  });

  final List<PlayerConfiguration> players;
  final List<String> selectedModuleIds;
  final int roundCount;
  final bool isMixed;

  SessionConfiguration copyWith({
    List<PlayerConfiguration>? players,
    List<String>? selectedModuleIds,
    int? roundCount,
    bool? isMixed,
  }) => SessionConfiguration(
    players: players ?? this.players,
    selectedModuleIds: selectedModuleIds ?? this.selectedModuleIds,
    roundCount: roundCount ?? this.roundCount,
    isMixed: isMixed ?? this.isMixed,
  );

  bool get canStart =>
      players.isNotEmpty &&
      selectedModuleIds.isNotEmpty &&
      !selectedModuleIds.contains('mystery') &&
      roundCount > 0 &&
      (isMixed ? selectedModuleIds.length > 1 : selectedModuleIds.length == 1);

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
    'roundCount': roundCount,
    'isMixed': isMixed,
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
        roundCount: json['roundCount'] as int? ?? 3,
        isMixed: json['isMixed'] as bool? ?? false,
      );
}

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
  });

  final List<PlayerConfiguration> players;
  final List<String> selectedModuleIds;

  bool get canStart =>
      players.isNotEmpty &&
      selectedModuleIds.isNotEmpty &&
      !selectedModuleIds.contains('mystery');
}

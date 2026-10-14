class PlayerAvatarDefinition {
  const PlayerAvatarDefinition({
    required this.id,
    required this.name,
    required this.assetPath,
    this.original = false,
  });

  final String id;
  final String name;
  final String assetPath;
  final bool original;
}

/// Stable offline avatar IDs. The requested 30-character production roster is
/// not complete; `original` identifies newly created artwork honestly.
abstract final class PlayerAvatarCatalog {
  static const List<PlayerAvatarDefinition> all = <PlayerAvatarDefinition>[
    PlayerAvatarDefinition(
      id: 'operator_scout',
      name: 'SCOUT',
      assetPath: 'assets/brand/avatars/operator_scout.png',
    ),
    PlayerAvatarDefinition(
      id: 'operator_striker',
      name: 'STRIKER',
      assetPath: 'assets/brand/avatars/operator_striker.png',
    ),
    PlayerAvatarDefinition(
      id: 'operator_vanguard',
      name: 'VANGUARD',
      assetPath: 'assets/brand/avatars/operator_vanguard.png',
    ),
    PlayerAvatarDefinition(
      id: 'operator_winterguard',
      name: 'WINTERGUARD',
      assetPath: 'assets/brand/avatars/operator_winterguard.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'operator_fieldmedic',
      name: 'FIELD MEDIC',
      assetPath: 'assets/brand/avatars/operator_fieldmedic.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'operator_engineer',
      name: 'ENGINEER',
      assetPath: 'assets/brand/avatars/operator_engineer.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'operator_pathfinder',
      name: 'PATHFINDER',
      assetPath: 'assets/brand/avatars/operator_pathfinder.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'operator_aeroguard',
      name: 'AEROGUARD',
      assetPath: 'assets/brand/avatars/operator_aeroguard.png',
      original: true,
    ),
  ];

  static PlayerAvatarDefinition byId(String? id) =>
      all.firstWhere((avatar) => avatar.id == id, orElse: () => all[2]);

  static String idForPlayer(int position) =>
      all[(position - 1) % all.length].id;

  static String legacyIdForAppearance({
    required int faceStyle,
    required int hairStyle,
    required int outfitStyle,
  }) {
    final variant = (hairStyle + outfitStyle + faceStyle * hairStyle) % 3;
    return all[variant].id;
  }
}

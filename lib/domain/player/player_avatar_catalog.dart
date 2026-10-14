class PlayerAvatarDefinition {
  const PlayerAvatarDefinition({
    required this.id,
    required this.name,
    required this.assetPath,
    this.portraitAssetPath,
    this.original = false,
  });

  final String id;
  final String name;
  final String assetPath;
  final String? portraitAssetPath;
  final bool original;

  String get effectivePortraitAssetPath => portraitAssetPath ?? assetPath;
}

/// Stable offline avatar IDs. New selectable art is stored as a full-body
/// transparent PNG plus a matching square portrait. All assets are local.
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
    PlayerAvatarDefinition(
      id: 'prince',
      name: 'PRINCE',
      assetPath: 'assets/brand/avatars/characters/prince.png',
      portraitAssetPath: 'assets/brand/avatars/characters/prince_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'princess',
      name: 'PRINCESS',
      assetPath: 'assets/brand/avatars/characters/princess.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/princess_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'king',
      name: 'KING',
      assetPath: 'assets/brand/avatars/characters/king.png',
      portraitAssetPath: 'assets/brand/avatars/characters/king_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'queen',
      name: 'QUEEN',
      assetPath: 'assets/brand/avatars/characters/queen.png',
      portraitAssetPath: 'assets/brand/avatars/characters/queen_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'doctor',
      name: 'DOCTOR',
      assetPath: 'assets/brand/avatars/characters/doctor.png',
      portraitAssetPath: 'assets/brand/avatars/characters/doctor_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'surgeon',
      name: 'SURGEON',
      assetPath: 'assets/brand/avatars/characters/surgeon.png',
      portraitAssetPath: 'assets/brand/avatars/characters/surgeon_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'nurse',
      name: 'NURSE',
      assetPath: 'assets/brand/avatars/characters/nurse.png',
      portraitAssetPath: 'assets/brand/avatars/characters/nurse_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'professor',
      name: 'PROFESSOR',
      assetPath: 'assets/brand/avatars/characters/professor.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/professor_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'executive',
      name: 'EXECUTIVE',
      assetPath: 'assets/brand/avatars/characters/executive.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/executive_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'businesswoman',
      name: 'BUSINESSWOMAN',
      assetPath: 'assets/brand/avatars/characters/businesswoman.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/businesswoman_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'male_student',
      name: 'UNIVERSITY STUDENT',
      assetPath: 'assets/brand/avatars/characters/male_student.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/male_student_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'female_student',
      name: 'UNIVERSITY STUDENT',
      assetPath: 'assets/brand/avatars/characters/female_student.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/female_student_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'young_man',
      name: 'YOUNG MAN',
      assetPath: 'assets/brand/avatars/characters/young_man.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/young_man_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'young_woman',
      name: 'YOUNG WOMAN',
      assetPath: 'assets/brand/avatars/characters/young_woman.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/young_woman_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'streetwear',
      name: 'STREETWEAR',
      assetPath: 'assets/brand/avatars/characters/streetwear.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/streetwear_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'older_man',
      name: 'OLDER MAN',
      assetPath: 'assets/brand/avatars/characters/older_man.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/older_man_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'muslim_man',
      name: 'MUSLIM MAN',
      assetPath: 'assets/brand/avatars/characters/muslim_man.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/muslim_man_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'muslim_woman',
      name: 'MUSLIM WOMAN',
      assetPath: 'assets/brand/avatars/characters/muslim_woman.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/muslim_woman_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'tanzanian_kitenge',
      name: 'KITENGE',
      assetPath: 'assets/brand/avatars/characters/tanzanian_kitenge.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/tanzanian_kitenge_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'nigerian_agbada',
      name: 'AGBADA',
      assetPath: 'assets/brand/avatars/characters/nigerian_agbada.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/nigerian_agbada_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'south_asian_saree',
      name: 'SAREE',
      assetPath: 'assets/brand/avatars/characters/south_asian_saree.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/south_asian_saree_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'east_asian_formal',
      name: 'EAST ASIAN FORMAL',
      assetPath: 'assets/brand/avatars/characters/east_asian_formal.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/east_asian_formal_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'chef',
      name: 'CHEF',
      assetPath: 'assets/brand/avatars/characters/chef.png',
      portraitAssetPath: 'assets/brand/avatars/characters/chef_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'firefighter',
      name: 'FIREFIGHTER',
      assetPath: 'assets/brand/avatars/characters/firefighter.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/firefighter_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'mechanic',
      name: 'MECHANIC',
      assetPath: 'assets/brand/avatars/characters/mechanic.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/mechanic_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'construction_worker',
      name: 'CONSTRUCTION WORKER',
      assetPath: 'assets/brand/avatars/characters/construction_worker.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/construction_worker_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'footballer',
      name: 'FOOTBALLER',
      assetPath: 'assets/brand/avatars/characters/footballer.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/footballer_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'basketball_player',
      name: 'BASKETBALL PLAYER',
      assetPath: 'assets/brand/avatars/characters/basketball_player.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/basketball_player_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'musician',
      name: 'MUSICIAN',
      assetPath: 'assets/brand/avatars/characters/musician.png',
      portraitAssetPath:
          'assets/brand/avatars/characters/musician_portrait.png',
      original: true,
    ),
    PlayerAvatarDefinition(
      id: 'dj',
      name: 'DJ',
      assetPath: 'assets/brand/avatars/characters/dj.png',
      portraitAssetPath: 'assets/brand/avatars/characters/dj_portrait.png',
      original: true,
    ),
  ];

  static bool contains(String? id) => all.any((avatar) => avatar.id == id);

  static PlayerAvatarDefinition byId(String? id) =>
      all.firstWhere((avatar) => avatar.id == id, orElse: () => all[2]);

  static String? firstUnusedId(Iterable<String> assignedIds) {
    final assigned = assignedIds.toSet();
    for (final avatar in all) {
      if (!assigned.contains(avatar.id)) return avatar.id;
    }
    return null;
  }

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

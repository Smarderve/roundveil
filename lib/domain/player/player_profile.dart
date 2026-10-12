import 'package:roundveil/domain/player/player_avatar_appearance.dart';

class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.displayName,
    required this.avatar,
    this.avatarImagePath,
    this.hintCredits = 0,
    this.gamesPlayed = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.timeouts = 0,
    this.totalMatchPoints = 0,
  });

  final String id;
  final String displayName;
  final PlayerAvatarAppearance avatar;
  final String? avatarImagePath;
  final int hintCredits;
  final int gamesPlayed;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeouts;
  final int totalMatchPoints;

  PlayerProfile copyWith({
    String? displayName,
    PlayerAvatarAppearance? avatar,
    String? avatarImagePath,
    int? hintCredits,
    int? gamesPlayed,
    int? correctAnswers,
    int? wrongAnswers,
    int? timeouts,
    int? totalMatchPoints,
  }) => PlayerProfile(
    id: id,
    displayName: displayName ?? this.displayName,
    avatar: avatar ?? this.avatar,
    avatarImagePath: avatarImagePath ?? this.avatarImagePath,
    hintCredits: hintCredits ?? this.hintCredits,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    wrongAnswers: wrongAnswers ?? this.wrongAnswers,
    timeouts: timeouts ?? this.timeouts,
    totalMatchPoints: totalMatchPoints ?? this.totalMatchPoints,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'displayName': displayName,
    'avatarImagePath': avatarImagePath,
    'avatar': <String, Object?>{
      'faceStyle': avatar.faceStyle.name,
      'skinTone': avatar.skinTone,
      'hairStyle': avatar.hairStyle.name,
      'hairColor': avatar.hairColor,
      'outfitStyle': avatar.outfitStyle.name,
      'outfitColor': avatar.outfitColor,
      'accentColor': avatar.accentColor,
      'accessory': avatar.accessory.name,
    },
    'hintCredits': hintCredits,
    'gamesPlayed': gamesPlayed,
    'correctAnswers': correctAnswers,
    'wrongAnswers': wrongAnswers,
    'timeouts': timeouts,
    'totalMatchPoints': totalMatchPoints,
  };

  factory PlayerProfile.fromJson(Map<String, Object?> json) {
    final avatarJson = json['avatar'] as Map<String, Object?>? ?? const {};
    return PlayerProfile(
      id: json['id']! as String,
      displayName: json['displayName']! as String,
      avatarImagePath: json['avatarImagePath'] as String?,
      avatar: PlayerAvatarAppearance(
        faceStyle: AvatarFaceStyle.values.byName(
          avatarJson['faceStyle'] as String? ?? 'focused',
        ),
        skinTone: avatarJson['skinTone'] as int? ?? 0xFFE7B99A,
        hairStyle: AvatarHairStyle.values.byName(
          avatarJson['hairStyle'] as String? ?? 'cropped',
        ),
        hairColor: avatarJson['hairColor'] as int? ?? 0xFF263449,
        outfitStyle: AvatarOutfitStyle.values.byName(
          avatarJson['outfitStyle'] as String? ?? 'striker',
        ),
        outfitColor: avatarJson['outfitColor'] as int? ?? 0xFF2879BA,
        accentColor: avatarJson['accentColor'] as int? ?? 0xFFF4A62C,
        accessory: AvatarAccessory.values.byName(
          avatarJson['accessory'] as String? ?? 'none',
        ),
      ),
      hintCredits: json['hintCredits'] as int? ?? 0,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      wrongAnswers: json['wrongAnswers'] as int? ?? 0,
      timeouts: json['timeouts'] as int? ?? 0,
      totalMatchPoints: json['totalMatchPoints'] as int? ?? 0,
    );
  }
}

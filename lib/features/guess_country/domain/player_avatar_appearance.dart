/// Ephemeral, host-controlled appearance for a local match participant.
///
/// This is deliberately separate from [PlayerConfiguration]: it is not an
/// account, identity, or persisted player profile.
enum AvatarFaceStyle { soft, focused, bold }

enum AvatarHairStyle { cropped, swept, curls, long }

enum AvatarOutfitStyle { striker, scout, vanguard }

enum AvatarAccessory { none, visor, headband, comms }

class PlayerAvatarAppearance {
  const PlayerAvatarAppearance({
    this.faceStyle = AvatarFaceStyle.focused,
    this.skinTone = 0xFFE7B99A,
    this.hairStyle = AvatarHairStyle.cropped,
    this.hairColor = 0xFF263449,
    this.outfitStyle = AvatarOutfitStyle.striker,
    this.outfitColor = 0xFF2879BA,
    this.accentColor = 0xFFF4A62C,
    this.accessory = AvatarAccessory.none,
  });

  final AvatarFaceStyle faceStyle;
  final int skinTone;
  final AvatarHairStyle hairStyle;
  final int hairColor;
  final AvatarOutfitStyle outfitStyle;
  final int outfitColor;
  final int accentColor;
  final AvatarAccessory accessory;

  PlayerAvatarAppearance copyWith({
    AvatarFaceStyle? faceStyle,
    int? skinTone,
    AvatarHairStyle? hairStyle,
    int? hairColor,
    AvatarOutfitStyle? outfitStyle,
    int? outfitColor,
    int? accentColor,
    AvatarAccessory? accessory,
  }) => PlayerAvatarAppearance(
    faceStyle: faceStyle ?? this.faceStyle,
    skinTone: skinTone ?? this.skinTone,
    hairStyle: hairStyle ?? this.hairStyle,
    hairColor: hairColor ?? this.hairColor,
    outfitStyle: outfitStyle ?? this.outfitStyle,
    outfitColor: outfitColor ?? this.outfitColor,
    accentColor: accentColor ?? this.accentColor,
    accessory: accessory ?? this.accessory,
  );

  static PlayerAvatarAppearance forPlayer(int position) {
    const palettes = <(int, int)>[
      (0xFF2879BA, 0xFFF4A62C),
      (0xFF7357A5, 0xFF55C4B2),
      (0xFFB84D48, 0xFFFFC65C),
      (0xFF26796F, 0xFFFF865D),
    ];
    final colors = palettes[(position - 1) % palettes.length];
    return PlayerAvatarAppearance(
      outfitColor: colors.$1,
      accentColor: colors.$2,
      faceStyle: AvatarFaceStyle.values[(position - 1) % 3],
      hairStyle: AvatarHairStyle.values[(position - 1) % 4],
      outfitStyle: AvatarOutfitStyle.values[(position - 1) % 3],
    );
  }
}

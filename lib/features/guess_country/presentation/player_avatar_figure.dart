import 'package:flutter/material.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';

/// Shared original 2D player-character artwork for lobby, squad, customization,
/// player introduction and results. This is static 2D art, not a 3D model.
class PlayerAvatarFigure extends StatelessWidget {
  const PlayerAvatarFigure({
    required this.appearance,
    this.width = 150,
    this.height = 220,
    this.portrait,
    super.key,
  });

  final PlayerAvatarAppearance appearance;
  final double width;
  final double height;
  final bool? portrait;

  String get _artPath {
    // A saved combination selects one of the distinct bundled character
    // silhouettes. This intentionally avoids reusing the ROUNDVEIL mascot as
    // every player's default identity.
    final variant =
        (appearance.hairStyle.index +
            appearance.outfitStyle.index +
            appearance.faceStyle.index * appearance.hairStyle.index) %
        3;
    return switch (variant) {
      0 => 'assets/brand/avatars/operator_scout.png',
      1 => 'assets/brand/avatars/operator_striker.png',
      _ => 'assets/brand/avatars/operator_vanguard.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = portrait ?? width / height > .84;
    final outfitAndHair = Color.lerp(
      Color(appearance.outfitColor),
      Color(appearance.hairColor),
      .18,
    )!;
    final paletteTint = Color.lerp(
      outfitAndHair,
      Color(appearance.skinTone),
      .16,
    )!;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              paletteTint.withValues(alpha: .13),
              BlendMode.softLight,
            ),
            child: Image.asset(
              _artPath,
              fit: isPortrait ? BoxFit.cover : BoxFit.contain,
              alignment: isPortrait
                  ? Alignment.topCenter
                  : Alignment.bottomCenter,
              filterQuality: FilterQuality.high,
              semanticLabel: isPortrait
                  ? 'Individual ROUNDVEIL player avatar portrait'
                  : 'Individual ROUNDVEIL full-body 2D character artwork; 3D integration pending',
            ),
          ),
          if (appearance.accessory != AvatarAccessory.none)
            Align(
              alignment: const Alignment(0, -.73),
              child: _AppearanceAccessory(appearance: appearance),
            ),
        ],
      ),
    );
  }
}

class _AppearanceAccessory extends StatelessWidget {
  const _AppearanceAccessory({required this.appearance});
  final PlayerAvatarAppearance appearance;

  @override
  Widget build(BuildContext context) {
    final color = Color(appearance.accentColor);
    return switch (appearance.accessory) {
      AvatarAccessory.none => const SizedBox.shrink(),
      AvatarAccessory.visor => Container(
        width: 46,
        height: 7,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .9),
          border: Border.all(color: const Color(0xFF07111D), width: 1.2),
          boxShadow: <BoxShadow>[
            BoxShadow(color: color.withValues(alpha: .35), blurRadius: 8),
          ],
        ),
      ),
      AvatarAccessory.headband => Container(
        width: 37,
        height: 3,
        decoration: BoxDecoration(
          color: color,
          boxShadow: <BoxShadow>[
            BoxShadow(color: color.withValues(alpha: .4), blurRadius: 5),
          ],
        ),
      ),
      AvatarAccessory.comms => Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Icon(Icons.sensors_rounded, size: 12, color: color),
        ),
      ),
    };
  }
}

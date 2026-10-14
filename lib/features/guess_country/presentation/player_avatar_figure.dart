import 'package:flutter/material.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_avatar_catalog.dart';

/// Shared original 2D player-character artwork for lobby, squad, customization,
/// player introduction and results. This is static 2D art, not a 3D model.
class PlayerAvatarFigure extends StatelessWidget {
  const PlayerAvatarFigure({
    required this.appearance,
    this.width = 150,
    this.height = 220,
    this.portrait,
    this.avatarId,
    super.key,
  });

  final PlayerAvatarAppearance appearance;
  final double width;
  final double height;
  final bool? portrait;
  final String? avatarId;

  String get _artPath {
    if (avatarId != null) return PlayerAvatarCatalog.byId(avatarId).assetPath;
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
    final assetPath = avatarId == null
        ? _artPath
        : isPortrait
        ? PlayerAvatarCatalog.byId(avatarId).effectivePortraitAssetPath
        : _artPath;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            assetPath,
            fit: isPortrait ? BoxFit.cover : BoxFit.contain,
            alignment: isPortrait
                ? Alignment.topCenter
                : Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
            semanticLabel: isPortrait ? 'ROUNDVEIL player avatar portrait' : 'ROUNDVEIL original full-body character illustration; 3D integration pending',
          ),
        ],
      ),
    );
  }
}

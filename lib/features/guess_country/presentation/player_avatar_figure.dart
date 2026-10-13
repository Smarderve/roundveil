import 'package:flutter/material.dart';
import 'package:roundveil/features/guess_country/domain/player_avatar_appearance.dart';

/// Approved ROUNDVEIL character artwork used while personalized 3D rendering
/// remains blocked. Appearance data is still saved, but this image is not
/// modified to suggest that those choices have rendered as a character.
class PlayerAvatarFigure extends StatelessWidget {
  const PlayerAvatarFigure({
    required this.appearance,
    this.width = 150,
    this.height = 220,
    super.key,
  });

  final PlayerAvatarAppearance appearance;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF050D1C),
        border: Border.all(
          color: Color(appearance.accentColor).withValues(alpha: .78),
          width: 1.5,
        ),
      ),
      child: Image.asset(
        'assets/brand/roundveil_mascot_portrait.webp',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: 'Official ROUNDVEIL hooded character artwork. Personalized 3D rendering is pending.',
      ),
    ),
  );
}

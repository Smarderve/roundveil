import 'package:flutter/material.dart';
import 'package:roundveil/features/guess_country/domain/player_avatar_appearance.dart';

/// Original, locally drawn character art for the pre-match squad lobby.
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
    child: CustomPaint(painter: _AvatarPainter(appearance)),
  );
}

class _AvatarPainter extends CustomPainter {
  const _AvatarPainter(this.avatar);
  final PlayerAvatarAppearance avatar;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 150;
    final sy = size.height / 220;
    canvas.save();
    canvas.scale(sx, sy);
    final accent = Color(avatar.accentColor);
    final outfit = Color(avatar.outfitColor);
    final skin = Color(avatar.skinTone);
    final hair = Color(avatar.hairColor);

    // Floating arena spotlight and floor ring make the figure read as a
    // character on a stage, rather than content inside a profile tile.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: .30), accent.withValues(alpha: 0)],
      ).createShader(const Rect.fromLTWH(10, 12, 130, 178));
    canvas.drawOval(const Rect.fromLTWH(10, 12, 130, 178), glow);
    canvas.drawOval(
      const Rect.fromLTWH(24, 197, 102, 13),
      Paint()
        ..color = accent.withValues(alpha: .30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Long coat/armor silhouette and the planted, slightly angled stance.
    final legs = Paint()..color = const Color(0xFF263449);
    final leftLeg = Path()
      ..moveTo(51, 148)
      ..lineTo(76, 151)
      ..lineTo(68, 197)
      ..lineTo(48, 197)
      ..close();
    final rightLeg = Path()
      ..moveTo(76, 151)
      ..lineTo(102, 146)
      ..lineTo(111, 196)
      ..lineTo(88, 198)
      ..close();
    canvas.drawPath(leftLeg, legs);
    canvas.drawPath(rightLeg, legs);
    canvas.drawPath(
      Path()
        ..moveTo(48, 190)
        ..lineTo(70, 190)
        ..lineTo(74, 201)
        ..lineTo(42, 201)
        ..close(),
      Paint()..color = outfit,
    );
    canvas.drawPath(
      Path()
        ..moveTo(88, 190)
        ..lineTo(112, 189)
        ..lineTo(121, 201)
        ..lineTo(86, 201)
        ..close(),
      Paint()..color = outfit,
    );

    // Rear arm and glove.
    canvas.drawPath(
      Path()
        ..moveTo(44, 89)
        ..lineTo(32, 97)
        ..lineTo(25, 140)
        ..lineTo(37, 145)
        ..lineTo(53, 111)
        ..close(),
      Paint()..color = outfit.withValues(alpha: .78),
    );
    canvas.drawCircle(const Offset(30, 143), 8, Paint()..color = skin);

    // Shoulder silhouette differs slightly by outfit archetype.
    final torso = Path()
      ..moveTo(52, 77)
      ..lineTo(97, 77)
      ..lineTo(115, 94)
      ..lineTo(104, 151)
      ..lineTo(48, 151)
      ..lineTo(38, 96)
      ..close();
    canvas.drawPath(
      torso,
      Paint()
        ..shader = LinearGradient(
          colors: [
            outfit.withValues(alpha: .80),
            outfit,
            outfit.withValues(alpha: .72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(38, 77, 77, 74)),
    );
    final shoulder = Path()
      ..moveTo(41, 91)
      ..lineTo(54, 81)
      ..lineTo(64, 91)
      ..lineTo(56, 110)
      ..lineTo(38, 105)
      ..close();
    canvas.drawPath(shoulder, Paint()..color = accent.withValues(alpha: .92));

    // Outfit type changes the chest panel silhouette.
    switch (avatar.outfitStyle) {
      case AvatarOutfitStyle.striker:
        canvas.drawPath(
          Path()
            ..moveTo(62, 88)
            ..lineTo(87, 88)
            ..lineTo(81, 130)
            ..lineTo(68, 130)
            ..close(),
          Paint()..color = const Color(0xFF263449).withValues(alpha: .78),
        );
      case AvatarOutfitStyle.scout:
        canvas.drawPath(
          Path()
            ..moveTo(59, 86)
            ..lineTo(90, 86)
            ..lineTo(99, 142)
            ..lineTo(53, 142)
            ..close(),
          Paint()..color = outfit.withValues(alpha: .38),
        );
        canvas.drawLine(
          const Offset(74, 89),
          const Offset(74, 139),
          Paint()
            ..color = accent
            ..strokeWidth = 3,
        );
      case AvatarOutfitStyle.vanguard:
        canvas.drawPath(
          Path()
            ..moveTo(53, 87)
            ..lineTo(95, 87)
            ..lineTo(103, 107)
            ..lineTo(93, 145)
            ..lineTo(54, 145)
            ..lineTo(45, 107)
            ..close(),
          Paint()
            ..color = outfit.withValues(alpha: .62)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
    }
    canvas.drawPath(
      Path()
        ..moveTo(63, 104)
        ..lineTo(83, 104)
        ..lineTo(88, 113)
        ..lineTo(73, 123)
        ..lineTo(58, 113)
        ..close(),
      Paint()..color = accent,
    );
    canvas.drawLine(
      const Offset(51, 147),
      const Offset(103, 147),
      Paint()
        ..color = accent
        ..strokeWidth = 4,
    );

    // Raised forward arm gives the lineup a confident, active stance.
    canvas.drawPath(
      Path()
        ..moveTo(99, 88)
        ..lineTo(113, 94)
        ..lineTo(123, 124)
        ..lineTo(111, 132)
        ..lineTo(93, 108)
        ..close(),
      Paint()..color = outfit,
    );
    canvas.drawCircle(const Offset(117, 132), 8, Paint()..color = skin);

    // Neck, face, ears, hair and graphic face shading.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(66, 63, 19, 23),
        const Radius.circular(5),
      ),
      Paint()..color = skin,
    );
    canvas.drawOval(const Rect.fromLTWH(50, 25, 49, 55), Paint()..color = skin);
    canvas.drawOval(
      const Rect.fromLTWH(80, 35, 18, 37),
      Paint()..color = skin.withValues(alpha: .5),
    );
    final facePath = Path()
      ..moveTo(55, 36)
      ..quadraticBezierTo(57, 18, 75, 18)
      ..quadraticBezierTo(95, 19, 99, 39)
      ..lineTo(92, 32)
      ..lineTo(86, 39)
      ..lineTo(71, 33)
      ..lineTo(59, 42)
      ..close();
    canvas.drawPath(facePath, Paint()..color = hair);
    switch (avatar.hairStyle) {
      case AvatarHairStyle.cropped:
        canvas.drawOval(
          const Rect.fromLTWH(51, 24, 47, 20),
          Paint()..color = hair,
        );
      case AvatarHairStyle.swept:
        canvas.drawPath(
          Path()
            ..moveTo(48, 42)
            ..quadraticBezierTo(52, 12, 84, 18)
            ..lineTo(105, 29)
            ..lineTo(79, 33)
            ..lineTo(58, 44)
            ..close(),
          Paint()..color = hair,
        );
      case AvatarHairStyle.curls:
        for (final point in const [
          Offset(57, 31),
          Offset(68, 24),
          Offset(80, 23),
          Offset(91, 30),
        ]) {
          canvas.drawCircle(point, 8, Paint()..color = hair);
        }
      case AvatarHairStyle.long:
        canvas.drawPath(
          Path()
            ..moveTo(51, 34)
            ..quadraticBezierTo(48, 56, 58, 76)
            ..lineTo(66, 67)
            ..lineTo(61, 42)
            ..close(),
          Paint()..color = hair,
        );
        canvas.drawPath(
          Path()
            ..moveTo(92, 34)
            ..quadraticBezierTo(105, 52, 94, 76)
            ..lineTo(86, 68)
            ..lineTo(89, 41)
            ..close(),
          Paint()..color = hair,
        );
    }
    final eye = Paint()..color = const Color(0xFF263449);
    canvas.drawOval(const Rect.fromLTWH(62, 47, 5, 3), eye);
    canvas.drawOval(const Rect.fromLTWH(81, 47, 5, 3), eye);
    canvas.drawLine(
      const Offset(68, 61),
      const Offset(79, 61),
      Paint()
        ..color = const Color(0xFF9A5A51)
        ..strokeWidth = avatar.faceStyle == AvatarFaceStyle.bold ? 2.2 : 1.4
        ..strokeCap = StrokeCap.round,
    );
    if (avatar.faceStyle == AvatarFaceStyle.focused) {
      canvas.drawLine(
        const Offset(60, 43),
        const Offset(68, 42),
        Paint()
          ..color = hair
          ..strokeWidth = 2,
      );
      canvas.drawLine(
        const Offset(80, 42),
        const Offset(88, 43),
        Paint()
          ..color = hair
          ..strokeWidth = 2,
      );
    } else if (avatar.faceStyle == AvatarFaceStyle.bold) {
      canvas.drawArc(
        const Rect.fromLTWH(57, 35, 37, 39),
        .2,
        2.5,
        false,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    switch (avatar.accessory) {
      case AvatarAccessory.none:
        break;
      case AvatarAccessory.visor:
        final visor = Paint()..color = accent.withValues(alpha: .86);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(54, 41, 42, 10),
            const Radius.circular(3),
          ),
          visor,
        );
        canvas.drawLine(
          const Offset(60, 45),
          const Offset(90, 45),
          Paint()
            ..color = Colors.white.withValues(alpha: .7)
            ..strokeWidth = 1.5,
        );
      case AvatarAccessory.headband:
        canvas.drawLine(
          const Offset(54, 39),
          const Offset(95, 39),
          Paint()
            ..color = accent
            ..strokeWidth = 4,
        );
      case AvatarAccessory.comms:
        canvas.drawCircle(const Offset(98, 54), 6, Paint()..color = accent);
        canvas.drawLine(
          const Offset(98, 54),
          const Offset(107, 62),
          Paint()
            ..color = accent
            ..strokeWidth = 2,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter oldDelegate) =>
      oldDelegate.avatar != avatar;
}

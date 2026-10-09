import 'dart:ui';

import 'package:flutter/material.dart';

enum RoundveilVisualStyle { paperStage, heroArena }

@immutable
class RoundveilPalette {
  const RoundveilPalette({
    required this.canvas,
    required this.surface,
    required this.panel,
    required this.panelRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.primaryAction,
    required this.secondaryAccent,
    required this.border,
  });

  final Color canvas;
  final Color surface;
  final Color panel;
  final Color panelRaised;
  final Color textPrimary;
  final Color textSecondary;
  final Color primaryAction;
  final Color secondaryAccent;
  final Color border;
}

@immutable
class RoundveilGeometry extends ThemeExtension<RoundveilGeometry> {
  const RoundveilGeometry({
    required this.cornerRadius,
    required this.borderWidth,
    required this.shadowOffset,
    required this.decorativeAngle,
  });

  final double cornerRadius;
  final double borderWidth;
  final Offset shadowOffset;
  final double decorativeAngle;

  @override
  RoundveilGeometry copyWith({
    double? cornerRadius,
    double? borderWidth,
    Offset? shadowOffset,
    double? decorativeAngle,
  }) {
    return RoundveilGeometry(
      cornerRadius: cornerRadius ?? this.cornerRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      decorativeAngle: decorativeAngle ?? this.decorativeAngle,
    );
  }

  @override
  RoundveilGeometry lerp(covariant RoundveilGeometry? other, double t) {
    if (other is! RoundveilGeometry) {
      return this;
    }

    return RoundveilGeometry(
      cornerRadius: lerpDouble(cornerRadius, other.cornerRadius, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
      shadowOffset: Offset.lerp(shadowOffset, other.shadowOffset, t)!,
      decorativeAngle: lerpDouble(decorativeAngle, other.decorativeAngle, t)!,
    );
  }
}

abstract final class RoundveilThemeFactory {
  static const paperStagePalette = RoundveilPalette(
    canvas: Color(0xFFE6DEC9),
    surface: Color(0xFFF9EFDB),
    panel: Color(0xFFF6EDD8),
    panelRaised: Color(0xFFE9DCC2),
    textPrimary: Color(0xFF27251F),
    textSecondary: Color(0xFF625B50),
    primaryAction: Color(0xFFB7332D),
    secondaryAccent: Color(0xFF252822),
    border: Color(0xFFA99B81),
  );

  static const heroArenaPalette = RoundveilPalette(
    canvas: Color(0xFFE8EDF4),
    surface: Color(0xFFF3F7FC),
    panel: Color(0xDEF8FBFF),
    panelRaised: Color(0xFFF8FBFF),
    textPrimary: Color(0xFF263449),
    textSecondary: Color(0xFF50647D),
    primaryAction: Color(0xFFF4A62C),
    secondaryAccent: Color(0xFF2879BA),
    border: Color(0xFFA3B5C6),
  );

  static ThemeData themeFor(RoundveilVisualStyle style) {
    final palette = switch (style) {
      RoundveilVisualStyle.paperStage => paperStagePalette,
      RoundveilVisualStyle.heroArena => heroArenaPalette,
    };
    final geometry = switch (style) {
      RoundveilVisualStyle.paperStage => const RoundveilGeometry(
        cornerRadius: 2,
        borderWidth: 2,
        shadowOffset: Offset(5, 5),
        decorativeAngle: 3,
      ),
      RoundveilVisualStyle.heroArena => const RoundveilGeometry(
        cornerRadius: 0,
        borderWidth: 2,
        shadowOffset: Offset.zero,
        decorativeAngle: -8,
      ),
    };

    final textTheme = TextTheme(
      bodyLarge: TextStyle(color: palette.textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: palette.textPrimary, fontSize: 16),
      bodySmall: TextStyle(color: palette.textSecondary),
      headlineLarge: TextStyle(
        color: palette.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: palette.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );

    final onPrimary = style == RoundveilVisualStyle.paperStage
        ? Colors.white
        : palette.textPrimary;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: palette.canvas,
      colorScheme: ColorScheme.light(
        primary: palette.primaryAction,
        secondary: palette.secondaryAccent,
        surface: palette.surface,
        onPrimary: onPrimary,
        onSecondary: Colors.white,
        onSurface: palette.textPrimary,
        outline: palette.border,
      ),
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[geometry],
    );
  }
}

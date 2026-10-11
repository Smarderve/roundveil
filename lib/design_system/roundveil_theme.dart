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
  static ThemeData versionFive({required bool dark}) {
    final background = dark ? const Color(0xFF07111F) : const Color(0xFFEAF0F7);
    final surface = dark ? const Color(0xFF101F31) : const Color(0xFFF7FAFD);
    final raised = dark ? const Color(0xFF172A40) : const Color(0xFFFFFFFF);
    final ink = dark ? const Color(0xFFF5F8FC) : const Color(0xFF13253A);
    final muted = dark ? const Color(0xFFA4B6C8) : const Color(0xFF52667D);
    const cyan = Color(0xFF47D8E9);
    const orange = Color(0xFFFF963E);
    final scheme = ColorScheme.fromSeed(
      seedColor: cyan,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: cyan,
      secondary: orange,
      surface: surface,
      onSurface: ink,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      cardColor: surface,
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7)),
        ),
      ),
      dividerColor: dark ? const Color(0xFF263A50) : const Color(0xFFD3DDE7),
      textTheme:
          ThemeData(brightness: dark ? Brightness.dark : Brightness.light)
              .textTheme
              .apply(bodyColor: ink, displayColor: ink)
              .copyWith(
                headlineLarge: TextStyle(
                  color: ink,
                  fontSize: 42,
                  height: 1.02,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.6,
                ),
                headlineMedium: TextStyle(
                  color: ink,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
                titleLarge: TextStyle(color: ink, fontWeight: FontWeight.w800),
                bodyMedium: TextStyle(color: muted, height: 1.45),
              ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: orange,
          foregroundColor: const Color(0xFF21160E),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: .4,
          ),
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        RoundveilBrandTokens(
          background: background,
          surface: surface,
          raised: raised,
          ink: ink,
          muted: muted,
          cyan: cyan,
          orange: orange,
        ),
      ],
    );
  }

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

@immutable
class RoundveilBrandTokens extends ThemeExtension<RoundveilBrandTokens> {
  const RoundveilBrandTokens({
    required this.background,
    required this.surface,
    required this.raised,
    required this.ink,
    required this.muted,
    required this.cyan,
    required this.orange,
  });

  final Color background;
  final Color surface;
  final Color raised;
  final Color ink;
  final Color muted;
  final Color cyan;
  final Color orange;

  @override
  RoundveilBrandTokens copyWith({Color? background}) => RoundveilBrandTokens(
    background: background ?? this.background,
    surface: surface,
    raised: raised,
    ink: ink,
    muted: muted,
    cyan: cyan,
    orange: orange,
  );

  @override
  RoundveilBrandTokens lerp(covariant RoundveilBrandTokens? other, double t) =>
      this;
}

import 'package:flutter/material.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/features/guess_country/presentation/hero_arena_page.dart';

class RoundveilApp extends StatelessWidget {
  const RoundveilApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'ROUNDVEIL',
    debugShowCheckedModeBanner: false,
    theme: RoundveilThemeFactory.themeFor(RoundveilVisualStyle.heroArena),
    home: const HeroArenaPage(),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/app/roundveil_app.dart';
import 'package:roundveil/design_system/responsive_layout.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';

void main() {
  test('placeholder players use the approved naming convention', () {
    final player = PlayerConfiguration.placeholder(2);

    expect(player.id, 'player-2');
    expect(player.displayName, 'Player 2');
  });

  test('a session needs players and a selected module before it can start', () {
    const empty = SessionConfiguration();
    final configured = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['future-module'],
    );

    expect(empty.canStart, isFalse);
    expect(configured.canStart, isTrue);
  });

  test('both approved visual styles expose distinct documented tokens', () {
    final paper = RoundveilThemeFactory.themeFor(
      RoundveilVisualStyle.paperStage,
    );
    final hero = RoundveilThemeFactory.themeFor(RoundveilVisualStyle.heroArena);

    expect(paper.scaffoldBackgroundColor, const Color(0xFFE6DEC9));
    expect(hero.scaffoldBackgroundColor, const Color(0xFFE8EDF4));
    expect(paper.extension<RoundveilGeometry>()!.cornerRadius, 2);
    expect(hero.extension<RoundveilGeometry>()!.cornerRadius, 0);
  });

  test('responsive primitive distinguishes compact and expanded widths', () {
    expect(
      RoundveilResponsiveLayout.forConstraints(
        const BoxConstraints(maxWidth: 599),
      ),
      RoundveilLayoutClass.compact,
    );
    expect(
      RoundveilResponsiveLayout.forConstraints(
        const BoxConstraints(maxWidth: 600),
      ),
      RoundveilLayoutClass.expanded,
    );
  });

  testWidgets('app boots without introducing a navigation flow', (
    tester,
  ) async {
    await tester.pumpWidget(const RoundveilApp());

    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byType(Navigator), findsNothing);
  });
}

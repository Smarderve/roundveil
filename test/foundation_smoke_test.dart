import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roundveil/app/roundveil_app.dart';
import 'package:roundveil/design_system/responsive_layout.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/guess_country/application/guess_country_controller.dart';
import 'package:roundveil/features/guess_country/domain/country_flag.dart';

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

  test('a removed Mystery module cannot make a session startable', () {
    final mystery = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['mystery'],
    );
    final country = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['guess_country_flags'],
    );

    expect(mystery.canStart, isFalse);
    expect(country.canStart, isTrue);
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

  test('correct country answer enters countdown and wrong answer does not', () {
    final controller = GuessCountryController();
    controller.addPlayer();
    controller.openPreparation();
    controller.configure(
      const GuessCountrySetup(
        roundCount: 3,
        difficulty: CountryDifficulty.easy,
        region: CountryRegion.worldwide,
        answerMode: CountryAnswerMode.multipleChoice,
        challengeSeconds: 0,
        hintsEnabled: false,
        winCountdownSeconds: 3,
        scoringEnabled: false,
      ),
    );
    controller.prepareSession();
    controller.startTurn();
    controller.submitAnswer(controller.activeFlag.name);
    expect(controller.state.screen, ArenaScreen.winCountdown);
    controller.completeCountdown();
    controller.startTurn();
    controller.submitAnswer('Not Japan');
    expect(controller.state.screen, ArenaScreen.playerReady);
    expect(controller.state.notice, contains('no Win Countdown'));
    controller.dispose();
  });

  test('multiple-choice distractors stay inside the selected region', () {
    final controller = GuessCountryController()..addPlayer();
    controller.configure(
      const GuessCountrySetup(
        roundCount: 3,
        difficulty: CountryDifficulty.easy,
        region: CountryRegion.americas,
        answerMode: CountryAnswerMode.multipleChoice,
        challengeSeconds: 0,
        hintsEnabled: false,
        winCountdownSeconds: 3,
        scoringEnabled: false,
      ),
    );

    expect(controller.configurationIssue, isNull);
    controller.prepareSession();
    controller.startTurn();
    expect(controller.answerOptions, contains(controller.activeFlag.name));
    expect(
      controller.answerOptions,
      everyElement(anyOf('Brazil', 'Canada', 'United States')),
    );
    expect(controller.answerOptions, hasLength(3));
    controller.dispose();
  });

  test(
    'undersized eligible pool blocks the session instead of repeating flags',
    () {
      final controller = GuessCountryController()
        ..addPlayer()
        ..addPlayer();
      controller.configure(
        const GuessCountrySetup(
          roundCount: 3,
          difficulty: CountryDifficulty.easy,
          region: CountryRegion.americas,
          answerMode: CountryAnswerMode.multipleChoice,
          challengeSeconds: 0,
          hintsEnabled: false,
          winCountdownSeconds: 3,
          scoringEnabled: false,
        ),
      );

      expect(controller.configurationIssue, contains('6 are needed'));
      controller.openPreparation();
      controller.prepareSession();
      expect(controller.state.screen, ArenaScreen.preparation);
      expect(controller.state.notice, contains('Flags will not repeat'));
      controller.removePlayer();
      expect(controller.configurationIssue, isNull);
      controller.prepareSession();
      final seen = <String>{};
      for (var turn = 0; turn < 3; turn++) {
        controller.startTurn();
        seen.add(controller.activeFlag.id);
        controller.submitAnswer('wrong');
      }
      expect(seen, hasLength(3));
      expect(controller.state.screen, ArenaScreen.complete);
      controller.dispose();
    },
  );

  test('single-country pool requires typed mode and one turn', () {
    final controller = GuessCountryController()..addPlayer();
    controller.configure(
      const GuessCountrySetup(
        roundCount: 1,
        difficulty: CountryDifficulty.easy,
        region: CountryRegion.asia,
        answerMode: CountryAnswerMode.multipleChoice,
        challengeSeconds: 0,
        hintsEnabled: false,
        winCountdownSeconds: 3,
        scoringEnabled: false,
      ),
    );
    expect(controller.configurationIssue, contains('in-scope alternative'));
    controller.configure(
      controller.state.setup.copyWith(answerMode: CountryAnswerMode.typed),
    );
    expect(controller.configurationIssue, isNull);
    controller.dispose();
  });

  test('host must explicitly add players before a match can start', () {
    final controller = GuessCountryController()..openPreparation();
    controller.configure(
      const GuessCountrySetup(
        roundCount: 1,
        difficulty: CountryDifficulty.mixed,
        region: CountryRegion.worldwide,
        answerMode: CountryAnswerMode.typed,
        challengeSeconds: 0,
        hintsEnabled: false,
        winCountdownSeconds: 3,
        scoringEnabled: false,
      ),
    );
    expect(controller.state.players, isEmpty);
    expect(controller.configurationIssue, contains('Add at least one player'));
    controller.addPlayer();
    expect(controller.configurationIssue, isNull);
    controller.dispose();
  });

  testWidgets('app boots into the Hero Arena opening candidate', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RoundveilApp()));
    expect(find.text('ROUNDVEIL'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}

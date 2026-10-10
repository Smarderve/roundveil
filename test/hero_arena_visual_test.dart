import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/app/roundveil_app.dart';
import 'package:roundveil/features/guess_country/application/guess_country_controller.dart';
import 'package:roundveil/features/guess_country/domain/country_flag.dart';
import 'package:roundveil/features/guess_country/presentation/hero_arena_page.dart';

void main() {
  const desktop = Size(1200, 900);
  const mobile = Size(390, 844);

  Future<void> pumpCandidate(
    WidgetTester tester,
    GuessCountryController controller,
    Size size,
  ) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final container = ProviderContainer(
      overrides: [
        guessCountryControllerProvider.overrideWith((ref) => controller),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RoundveilApp(),
      ),
    );
    await tester.pump();
  }

  GuessCountryController configuredController() {
    final controller = GuessCountryController(enableTimers: false)
      ..addPlayer()
      ..addPlayer();
    controller.openPreparation();
    controller.configure(
      const GuessCountrySetup(
        roundCount: 3,
        difficulty: CountryDifficulty.mixed,
        region: CountryRegion.worldwide,
        answerMode: CountryAnswerMode.multipleChoice,
        challengeSeconds: 30,
        hintsEnabled: true,
        winCountdownSeconds: 3,
        scoringEnabled: true,
      ),
    );
    return controller;
  }

  testWidgets('desktop opening visual', (tester) async {
    await pumpCandidate(tester, GuessCountryController(), desktop);
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_opening_desktop.png'),
    );
  });

  testWidgets('desktop preparation visual', (tester) async {
    await pumpCandidate(tester, configuredController(), desktop);
    expect(find.text('GUESS THE COUNTRY'), findsOneWidget);
    expect(find.text('YOUR LINEUP'), findsOneWidget);
    expect(find.text('MATCH BRIEF'), findsOneWidget);
    expect(find.text('MATCH RULES'), findsOneWidget);
    expect(find.text('START MATCH'), findsOneWidget);
    expect(find.text('01 Players & rounds'), findsNothing);
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_preparation_desktop.png'),
    );
  });

  testWidgets('match rules overlay preserves every explicit choice', (
    tester,
  ) async {
    final controller = GuessCountryController(enableTimers: false)
      ..addPlayer()
      ..openPreparation();
    await pumpCandidate(tester, controller, mobile);
    await tester.tap(find.text('MATCH RULES'));
    await tester.pumpAndSettle();
    expect(find.text('HOST LOADOUT'), findsOneWidget);
    expect(find.text('ROUNDS PER PLAYER'), findsOneWidget);
    expect(find.text('DIFFICULTY'), findsOneWidget);
    expect(find.text('GEOGRAPHIC SCOPE'), findsOneWidget);
    expect(find.text('ANSWER TYPE'), findsOneWidget);
    expect(find.text('CHALLENGE TIMER'), findsOneWidget);
    expect(find.text('HINTS'), findsOneWidget);
    expect(find.text('WIN COUNTDOWN'), findsOneWidget);
    expect(find.text('POINTS & WINNER SUMMARY'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('Worldwide'), findsOneWidget);
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();
    expect(find.text('HOST LOADOUT'), findsNothing);
  });

  testWidgets('host can add and remove the final lobby player', (tester) async {
    final controller = GuessCountryController(enableTimers: false)
      ..openPreparation();
    await pumpCandidate(tester, controller, mobile);
    await tester.tap(find.text('ADD PLAYER'));
    await tester.pumpAndSettle();
    expect(controller.state.players.single.displayName, 'Player 1');
    await tester.tap(find.byTooltip('Remove Player 1'));
    await tester.pumpAndSettle();
    expect(controller.state.players, isEmpty);
    expect(find.text('ADD PLAYER'), findsOneWidget);
  });

  testWidgets(
    'lobby and rules overlay adapt to narrow phone and tablet widths',
    (tester) async {
      final phoneController = GuessCountryController(enableTimers: false)
        ..addPlayer()
        ..openPreparation();
      await pumpCandidate(tester, phoneController, const Size(320, 800));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('MATCH RULES'));
      await tester.tap(find.text('MATCH RULES'));
      await tester.pumpAndSettle();
      expect(find.text('HOST LOADOUT'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('DONE'));
      await tester.pumpAndSettle();

      final tabletController = GuessCountryController(enableTimers: false)
        ..addPlayer()
        ..openPreparation();
      await pumpCandidate(tester, tabletController, const Size(768, 1024));
      expect(find.text('GUESS THE COUNTRY'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('MATCH RULES'));
      await tester.tap(find.text('MATCH RULES'));
      await tester.pumpAndSettle();
      expect(find.text('HOST LOADOUT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('desktop player-ready visual', (tester) async {
    final controller = configuredController()..prepareSession();
    await pumpCandidate(tester, controller, desktop);
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_player_ready_desktop.png'),
    );
  });

  testWidgets('desktop challenge visual', (tester) async {
    final controller = configuredController()
      ..prepareSession()
      ..startTurn();
    await pumpCandidate(tester, controller, desktop);
    expect(find.text('IDENTIFY THE FLAG'), findsOneWidget);
    expect(find.text('PLAYER 1'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'\d+ seconds remaining')),
      findsOneWidget,
    );
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_challenge_desktop.png'),
    );
  });

  testWidgets('desktop win-countdown visual', (tester) async {
    final controller = configuredController()
      ..prepareSession()
      ..startTurn();
    controller.submitAnswer(controller.activeFlag.name);
    await pumpCandidate(tester, controller, desktop);
    expect(find.text('WIN COUNTDOWN'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_countdown_desktop.png'),
    );
  });

  testWidgets('desktop session-completion visual', (tester) async {
    final controller = GuessCountryController(enableTimers: false)
      ..addPlayer()
      ..openPreparation()
      ..configure(
        const GuessCountrySetup(
          roundCount: 1,
          difficulty: CountryDifficulty.mixed,
          region: CountryRegion.worldwide,
          answerMode: CountryAnswerMode.multipleChoice,
          challengeSeconds: 30,
          hintsEnabled: true,
          winCountdownSeconds: 3,
          scoringEnabled: true,
        ),
      )
      ..prepareSession()
      ..startTurn();
    controller.submitAnswer(controller.activeFlag.name);
    controller.completeCountdown();
    await pumpCandidate(tester, controller, desktop);
    expect(find.text('PLAYER 1 WINS'), findsOneWidget);
    expect(find.text('1 player • 1 round'), findsOneWidget);
    expect(find.text('PLAYER 1'), findsOneWidget);
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_complete_desktop.png'),
    );
  });

  testWidgets('mobile challenge visual', (tester) async {
    final controller = configuredController()
      ..prepareSession()
      ..startTurn();
    await pumpCandidate(tester, controller, mobile);
    expect(find.text('IDENTIFY THE FLAG'), findsOneWidget);
    expect(find.byType(Scrollable), findsWidgets);
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_challenge_mobile.png'),
    );
  });
}

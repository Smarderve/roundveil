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
    await expectLater(
      find.byType(HeroArenaPage),
      matchesGoldenFile('goldens/hero_arena_preparation_desktop.png'),
    );
  });

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

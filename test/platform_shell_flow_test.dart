import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/app/roundveil_app.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_draft.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/features/platform_shell/presentation/cinematic_session_builder_page.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_quick_games_page.dart';
import 'package:roundveil/features/active_match/presentation/active_match_page.dart';
import 'package:roundveil/features/guess_country/application/guess_country_controller.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

Future<void> _startVisibleTurn(WidgetTester tester) async {
  final startTurn = find.text('START TURN');
  if (startTurn.evaluate().isNotEmpty) {
    await tester.ensureVisible(startTurn);
    await tester.tap(startTurn);
    await tester.pumpAndSettle();
  }
}

void main() {
  test(
    'builder enforces single and mixed selection and persists a draft',
    () async {
      final repository = _MemoryDraftRepository();
      final controller = SessionBuilderController(drafts: repository);

      expect(controller.canCreate, isFalse);
      controller.addPlayer();
      controller.toggleGame('quiz');
      expect(controller.configuration.selectedModuleIds, <String>['quiz']);

      controller.setFormat(SessionFormat.mixed);
      controller.toggleGame('word_play');
      expect(controller.canCreate, isFalse);
      controller.setRoundCount(4);
      expect(controller.canCreate, isTrue);

      final draft = await controller.saveDraft();
      expect(draft, isNotNull);
      expect(draft!.configuration.isMixed, isTrue);
      expect(
        draft.configuration.selectedModuleIds,
        containsAll(<String>['quiz', 'word_play']),
      );
      expect((await repository.loadAll()).single.id, draft.id);
      controller.dispose();
    },
  );

  test(
    'starting a match returns its configuration without saving a draft',
    () async {
      final repository = _MemoryDraftRepository();
      final controller = SessionBuilderController(drafts: repository);
      controller.addPlayer();
      controller.addPlayer();
      controller.toggleGame('quiz');
      controller.setRoundCount(2);

      final configuration = await controller.startMatch();

      expect(configuration, isNotNull);
      expect(configuration!.selectedModuleIds, <String>['quiz']);
      expect(configuration.players.length, 2);
      expect(await repository.loadAll(), isEmpty);
      controller.dispose();
    },
  );

  test('created country session carries its explicit roster and rounds', () {
    final players = <PlayerConfiguration>[
      PlayerConfiguration.placeholder(1),
      PlayerConfiguration.placeholder(2),
    ];
    final controller = GuessCountryController(
      initialPlayers: players,
      initialSetup: const GuessCountrySetup(roundCount: 4),
    );

    expect(controller.state.screen, ArenaScreen.preparation);
    expect(controller.state.players, players);
    expect(controller.state.setup.roundCount, 4);
    expect(controller.state.setup.isComplete, isFalse);
    expect(
      controller.configurationIssue,
      contains('Choose every match setting'),
    );
    controller.dispose();
  });

  testWidgets('Create Game navigation reaches a working session builder', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(844, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RoundveilApp(profileRepository: InMemoryPlayerProfileRepository()),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('CREATE GAME'), findsOneWidget);
    await tester.tap(find.text('CREATE GAME'));
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE THE CHALLENGE'), findsOneWidget);
    expect(find.byTooltip('Add player'), findsOneWidget);
  });

  testWidgets('removed games are absent from Create Game and Quick Game', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RoundveilApp(profileRepository: InMemoryPlayerProfileRepository()),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('RIDDLES'), findsNothing);
    expect(find.text('MEMORY'), findsNothing);
    await tester.tap(find.text('CREATE GAME'));
    await tester.pumpAndSettle();
    expect(find.text('RIDDLES'), findsNothing);
    expect(find.text('MEMORY'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('QUICK GAME'));
    await tester.pumpAndSettle();
    expect(find.text('QUICK RIDDLES'), findsNothing);
    expect(find.text('QUICK MEMORY'), findsNothing);
    await tester.tap(find.byTooltip('Back'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('GAMES'));
    await tester.pumpAndSettle();
    expect(find.text('RIDDLES'), findsNothing);
    expect(find.text('MEMORY'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell keeps the home and navigation usable in landscape', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(960, 390));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RoundveilApp(profileRepository: InMemoryPlayerProfileRepository()),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('CREATE GAME'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('CREATE GAME'));
    await tester.pumpAndSettle();
    expect(find.text('SQUAD & ROUNDS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('avatar workshop edits and persists the selected squad look', (
    tester,
  ) async {
    final profiles = InMemoryPlayerProfileRepository();
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(RoundveilApp(profileRepository: profiles));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 280));
    await tester.tap(find.text('AVATARS').first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('SQUAD ARMORY'), findsOneWidget);
    await tester.tap(find.text('CURLS'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      (await profiles.loadAll()).first.avatar.hairStyle,
      AvatarHairStyle.curls,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'host can create a multi-game session through the actual builder UI',
    (tester) async {
      final repository = _MemoryDraftRepository();
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _TestApp(
          child: CinematicSessionBuilderPage(drafts: repository, onBack: () {}),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('MIXED'));
      await tester.tap(find.text('QUIZ'));
      await tester.tap(find.text('WORD PLAY').first);
      await tester.tap(find.byTooltip('Add player'));
      await tester.tap(find.byKey(const ValueKey<String>('round-count')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('PREPARE MATCH'));
      await tester.pumpAndSettle();
      await _startVisibleTurn(tester);

      expect(
        find.text('Which planet is the largest in our solar system?'),
        findsOneWidget,
      );
      expect(repository.items, isEmpty);
      await tester.tap(find.text('Jupiter'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('3'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
      await _startVisibleTurn(tester);
      expect(find.text('Unscramble: T E N A L P'), findsOneWidget);
      expect(repository.items, isEmpty);
    },
  );

  testWidgets('quick template editor provides Material for its text field', (
    tester,
  ) async {
    final repository = _MemoryDraftRepository();
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: V5QuickGamesPage(drafts: repository, onBack: () {}),
      ),
    );
    await tester.tap(find.text('QUICK QUIZ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit quick game settings'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Friday Match');
    await tester.pump();
    expect(find.text('Friday Match'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick template Start Match opens the selected game directly', (
    tester,
  ) async {
    final repository = _MemoryDraftRepository();
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: V5QuickGamesPage(drafts: repository, onBack: () {}),
      ),
    );
    await tester.tap(find.text('QUICK QUIZ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('START MATCH'));
    await tester.pumpAndSettle();
    await _startVisibleTurn(tester);

    expect(
      find.text('Which planet is the largest in our solar system?'),
      findsOneWidget,
    );
    expect(repository.items, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mixed quick preview fits compact landscape', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: V5QuickGamesPage(
          drafts: _MemoryDraftRepository(),
          onBack: () {},
        ),
      ),
    );
    await tester.tap(find.text('MIXED'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PARTY MIX'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'country match is flag-only and requires reveal before judgement',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 360));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _TestApp(
          child: ActiveMatchPage(
            configuration: SessionConfiguration(
              players: <PlayerConfiguration>[
                PlayerConfiguration.placeholder(1),
              ],
              selectedModuleIds: const <String>['guess_country_flags'],
              roundCount: 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _startVisibleTurn(tester);

      expect(find.text('SAY THE COUNTRY ALOUD'), findsOneWidget);
      expect(find.text('REVEAL ANSWER'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Brazil'), findsNothing);
      await tester.ensureVisible(find.text('REVEAL ANSWER'));
      await tester.tap(find.text('REVEAL ANSWER'));
      await tester.pump();
      expect(find.text('BRAZIL'), findsOneWidget);
      expect(find.text('CORRECT'), findsOneWidget);
      await tester.ensureVisible(find.text('CORRECT'));
      await tester.tap(find.text('CORRECT'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('3'), findsOneWidget);
    },
  );

  testWidgets('character player turns away before the name is revealed', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(960, 540));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: ActiveMatchPage(
          configuration: SessionConfiguration(
            players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
            selectedModuleIds: const <String>['guess_character'],
            roundCount: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startVisibleTurn(tester);
    expect(find.text('PLAYER — TURN AWAY'), findsOneWidget);
    expect(find.text('Sherlock Holmes'), findsNothing);
    await tester.tap(find.text('PLAYER IS TURNED AWAY · REVEAL'));
    await tester.pump();
    expect(find.text('Sherlock Holmes'), findsOneWidget);
    expect(find.text('CORRECT'), findsOneWidget);
    await tester.tap(find.text('CORRECT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('word play accepts a typed offline answer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(960, 540));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: ActiveMatchPage(
          configuration: SessionConfiguration(
            players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
            selectedModuleIds: const <String>['word_play'],
            roundCount: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _startVisibleTurn(tester);
    await tester.enterText(find.byType(TextField), 'planet');
    await tester.tap(find.text('SUBMIT WORD'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('word challenge fits a compact landscape viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: ActiveMatchPage(
          enableTimers: false,
          configuration: SessionConfiguration(
            players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
            selectedModuleIds: const <String>['word_play'],
            roundCount: 1,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('match results fit compact landscape and expose return action', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: ActiveMatchPage(
          configuration: SessionConfiguration(
            players: <PlayerConfiguration>[
              PlayerConfiguration.placeholder(1),
              PlayerConfiguration.placeholder(2),
              PlayerConfiguration.placeholder(3),
              PlayerConfiguration.placeholder(4),
            ],
            selectedModuleIds: const <String>['quiz'],
            roundCount: 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final answer in <String>['Jupiter', 'H₂O', 'Africa', '56']) {
      await _startVisibleTurn(tester);
      await tester.tap(find.text(answer));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
    }
    expect(find.text('MATCH COMPLETE'), findsOneWidget);
    expect(find.text('BACK TO LOBBY'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('builder fits narrow landscape without unbounded flex errors', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(640, 360));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: CinematicSessionBuilderPage(
          drafts: _MemoryDraftRepository(),
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('quick game templates are complete, editable configurations', () {
    final template = quickGameTemplates.firstWhere(
      (item) => item.id == 'quick_party_mix',
    );
    final config = template.configuration;
    expect(config.canStart, isTrue);
    expect(config.isMixed, isTrue);
    expect(config.players.map((player) => player.displayName), <String>[
      'Player 1',
      'Player 2',
      'Player 3',
      'Player 4',
    ]);
    expect(config.roundCount, 6);
    expect(gameCatalog.map((game) => game.id), <String>[
      'quiz',
      'word_play',
      'guess_character',
      'guess_country_flags',
    ]);
    expect(config.selectedModuleIds, <String>[
      'quiz',
      'word_play',
      'guess_character',
      'guess_country_flags',
    ]);
    expect(
      quickGameTemplates
          .expand((template) => template.moduleIds)
          .toSet()
          .difference(gameCatalog.map((game) => game.id).toSet()),
      isEmpty,
    );
  });

  test('legacy draft with discontinued games remains flagged for editing', () {
    final draft = SessionDraft(
      id: 'legacy-memory-mix',
      name: 'Family night',
      configuration: SessionConfiguration(
        players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
        selectedModuleIds: const <String>['quiz', 'memory'],
        roundCount: 4,
        isMixed: true,
      ),
      updatedAt: DateTime.utc(2026, 10, 11),
      templateId: 'quick_party_mix',
    );
    expect(draft.needsEditing, isTrue);
    expect(draft.configuration.selectedModuleIds, <String>['quiz', 'memory']);
    expect(draft.name, 'Family night');
  });

  test(
    'editing a legacy mixed draft drops retired IDs but retains active IDs',
    () {
      final legacy = SessionDraft(
        id: 'legacy-mix',
        name: 'Family night',
        configuration: SessionConfiguration(
          players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
          selectedModuleIds: const <String>['quiz', 'memory', 'riddles'],
          roundCount: 4,
          isMixed: true,
        ),
        updatedAt: DateTime.utc(2026, 10, 11),
        templateId: 'quick_party_mix',
      );
      final controller = SessionBuilderController(
        drafts: _MemoryDraftRepository(),
        initial: legacy.configuration,
        draftId: legacy.id,
        templateId: legacy.templateId,
        name: legacy.name,
      );
      expect(controller.configuration.selectedModuleIds, <String>['quiz']);
      expect(controller.configuration.players.single.displayName, 'Player 1');
      expect(controller.configuration.roundCount, 4);
      expect(controller.configuration.isMixed, isTrue);
      expect(legacy.needsEditing, isTrue);
      controller.dispose();
    },
  );

  test(
    'local draft repository survives reload and supports deletion',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'roundveil-drafts-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final repository = LocalDraftRepository(
        directoryProvider: () async => directory,
      );
      final draft = SessionDraft(
        id: 'draft-1',
        name: 'Friday games',
        configuration: quickGameTemplates.last.configuration.copyWith(
          challengeSeconds: 30,
          winCountdownSeconds: 5,
          hintsEnabled: false,
          scoringEnabled: false,
          countryRegion: 'africa',
          countryDifficulty: 'hard',
        ),
        updatedAt: DateTime.utc(2026, 10, 11),
        templateId: quickGameTemplates.last.id,
      );

      await repository.save(draft);
      final restored = (await LocalDraftRepository(
        directoryProvider: () async => directory,
      ).loadAll()).single;
      expect(restored.name, draft.name);
      expect(restored.configuration.toJson(), draft.configuration.toJson());
      expect(restored.templateId, draft.templateId);

      await repository.delete(draft.id);
      expect(await repository.loadAll(), isEmpty);
    },
  );

  test('application exposes exactly the 12 requested UI locales', () {
    expect(RoundveilApp.supportedLocales, hasLength(12));
    expect(RoundveilApp.supportedLocales, contains(Locale('sw')));
    expect(RoundveilApp.supportedLocales, contains(Locale('ar')));
    expect(RoundveilApp.supportedLocales, contains(Locale('ur')));
    expect(
      RoundveilApp.supportedLocales,
      contains(Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')),
    );
  });
}

class _MemoryDraftRepository implements DraftRepository {
  final List<SessionDraft> items = <SessionDraft>[];
  @override
  Future<List<SessionDraft>> loadAll() async => List<SessionDraft>.of(items);
  @override
  Future<void> save(SessionDraft draft) async {
    items.removeWhere((item) => item.id == draft.id);
    items.add(draft);
  }

  @override
  Future<void> delete(String id) async =>
      items.removeWhere((item) => item.id == id);
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: RoundveilThemeFactory.versionFive(dark: true),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
}

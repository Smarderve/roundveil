import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/app/roundveil_app.dart';
import 'package:roundveil/data/repositories/draft_repository.dart';
import 'package:roundveil/data/repositories/challenge_history_repository.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_draft.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/player/player_avatar_catalog.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/features/platform_shell/presentation/cinematic_session_builder_page.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_quick_games_page.dart';
import 'package:roundveil/features/active_match/presentation/active_match_page.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/guess_country/application/guess_country_controller.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';
import 'package:roundveil/features/session_builder/application/session_builder_controller.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

Future<void> _startVisibleTurn(WidgetTester tester) async {
  final beginRound = find.text('BEGIN ROUND');
  if (beginRound.evaluate().isNotEmpty) {
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'BEGIN ROUND'),
    );
    button.onPressed!.call();
    await tester.pump();
  }
  final startTurn = find.text('START TURN');
  if (startTurn.evaluate().isNotEmpty) {
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'START TURN'),
    );
    button.onPressed!.call();
    await tester.pump();
  }
}

OfflineChallenge _visibleChallenge(
  WidgetTester tester,
  Iterable<OfflineChallenge> pool,
) => pool.firstWhere(
  (challenge) => find.text(challenge.prompt).evaluate().isNotEmpty,
);

void _activateButton(WidgetTester tester, String label) {
  final button = tester.widget<FilledButton>(
    find.widgetWithText(FilledButton, label),
  );
  button.onPressed!.call();
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

  test('builder configures round formats without crossing game families', () {
    final controller = SessionBuilderController(
      drafts: _MemoryDraftRepository(),
    );
    controller.addPlayer();
    controller.toggleGame('quiz');
    controller.setRoundCount(4);
    controller.toggleRoundFormat('quiz_true_false');
    controller.toggleRoundFormat('quiz_fill_blank');
    controller.toggleRoundFormat('quiz_short_answer');
    expect(controller.configuration.isMixed, isFalse);
    expect(controller.configuration.selectedModuleIds, <String>['quiz']);
    expect(controller.configuration.roundFormatIds, <String>[
      'quiz_multiple_choice',
      'quiz_true_false',
      'quiz_fill_blank',
      'quiz_short_answer',
    ]);
    expect(controller.canStartMatch, isTrue);

    controller.setFormat(SessionFormat.mixed);
    controller.toggleGame('word_play');
    expect(controller.configuration.isMixed, isTrue);
    expect(controller.configuration.selectedModuleIds, <String>[
      'quiz',
      'word_play',
    ]);
    controller.dispose();
  });

  test(
    'empty Mixed Games selection remains mixed while first family is added',
    () {
      final controller = SessionBuilderController(
        drafts: _MemoryDraftRepository(),
      );
      controller.addPlayer();
      controller.setRoundCount(2);
      controller.setFormat(SessionFormat.mixed);
      controller.toggleGame('quiz');
      expect(controller.format, SessionFormat.mixed);
      expect(controller.configuration.selectedModuleIds, <String>['quiz']);
      expect(controller.canStartMatch, isFalse);

      controller.toggleGame('word_play');
      expect(controller.format, SessionFormat.mixed);
      expect(controller.configuration.selectedModuleIds, <String>[
        'quiz',
        'word_play',
      ]);
      expect(controller.canStartMatch, isTrue);
      controller.dispose();
    },
  );

  test('Picture Mode configuration requires imported local images', () {
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['guess_character'],
      roundFormatIds: const <String>['character_picture'],
      roundCount: 1,
    );
    expect(
      ActiveMatchController.validateConfiguration(configuration),
      contains('needs 1 distinct local images'),
    );

    final controller = SessionBuilderController(
      drafts: _MemoryDraftRepository(),
      initial: configuration,
    );
    expect(controller.canStartMatch, isTrue);
    controller.toggleRoundFormat('character_name');
    controller.toggleRoundFormat('character_picture');
    expect(controller.configuration.roundFormatIds, <String>['character_name']);
    expect(controller.canStartMatch, isTrue);
    controller.dispose();
  });

  test(
    'Character and Country categories belong to one Guessing Games session',
    () {
      final controller = SessionBuilderController(
        drafts: _MemoryDraftRepository(),
      );
      controller.addPlayer();
      controller.toggleGame('guess_character');
      controller.toggleGame('guess_country_flags');
      controller.setRoundCount(2);
      expect(controller.configuration.isMixed, isFalse);
      expect(controller.configuration.selectedGameFamilies, hasLength(1));
      expect(controller.configuration.roundFormatIds, <String>[
        'character_name',
        'country_flag',
      ]);
      expect(controller.canStartMatch, isTrue);
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
    expect(find.text('CHOOSE YOUR GAME'), findsOneWidget);
    expect(find.text('PLAYERS'), findsOneWidget);
    expect(find.text('ROUNDS'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('start-match')), findsOneWidget);
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
    expect(find.text('CHOOSE YOUR GAME'), findsOneWidget);
    expect(find.text('ADVANCED SETTINGS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home squad selection is shared with the Avatars page', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RoundveilApp(profileRepository: InMemoryPlayerProfileRepository()),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 280));

    await tester.tap(
      find.byKey(const ValueKey<String>('squad-player-slot-player-2')),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('lobby-hero-player-2')),
      findsOneWidget,
    );

    await tester.tap(find.text('AVATARS').first);
    await tester.pumpAndSettle();
    final selector = tester.widget<DropdownButtonFormField<String>>(
      find.byKey(const ValueKey<String>('squad-player-selector')),
    );
    expect(selector.initialValue, 'player-2');
    expect(find.text('Player 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('avatar workshop selects and persists a ready-made character', (
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
    expect(find.text('SKIN TONE'), findsNothing);
    expect(find.text('CHOOSE YOUR OPERATOR'), findsOneWidget);
    await tester.tap(find.text('VANGUARD'));
    await tester.pumpAndSettle();
    expect((await profiles.loadAll()).first.avatarId, 'operator_vanguard');
    expect(PlayerAvatarCatalog.all, hasLength(38));
    await tester.tap(
      find.byKey(const ValueKey<String>('edit-player-callsign')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Captain Nova');
    await tester.tap(find.widgetWithText(FilledButton, 'SAVE'));
    await tester.pumpAndSettle();
    expect((await profiles.loadAll()).first.displayName, 'Captain Nova');
    expect(tester.takeException(), isNull);
  });

  testWidgets('avatar workshop fits compact landscape without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(915, 412));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RoundveilApp(profileRepository: InMemoryPlayerProfileRepository()),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 280));
    await tester.tap(find.text('AVATARS').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const ValueKey<String>('selected-player-callsign')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Armory creates, selects, and confirms deletion of saved players',
    (tester) async {
      final profiles = InMemoryPlayerProfileRepository();
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(RoundveilApp(profileRepository: profiles));
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pump(const Duration(milliseconds: 280));
      await tester.tap(find.text('AVATARS').first);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byTooltip('Create player'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Nova Prime');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      final assignedAvatarIds = (await profiles.loadAll())
          .map((profile) => profile.avatarId)
          .toSet();
      final availableAvatar = PlayerAvatarCatalog.all.firstWhere(
        (avatar) => !assignedAvatarIds.contains(avatar.id),
      );
      await tester.tap(
        find.byKey(ValueKey<String>('new-player-avatar-${availableAvatar.id}')),
      );
      await tester.tap(
        find.byType(DropdownButtonFormField<PlayerGender?>).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('NON-BINARY').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'CREATE PLAYER'));
      await tester.pumpAndSettle();

      var saved = await profiles.loadAll();
      final nova = saved.singleWhere(
        (profile) => profile.displayName == 'Nova Prime',
      );
      expect(nova.gender, PlayerGender.nonBinary);
      await tester.tap(
        find.byKey(const ValueKey<String>('use-player-in-squad')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('HOME').first);
      await tester.pumpAndSettle();
      expect(find.text('NOVA PRIME'), findsNWidgets(2));

      await tester.tap(find.text('AVATARS').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('NOVA PRIME').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete Nova Prime'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'DELETE'));
      await tester.pumpAndSettle();
      saved = await profiles.loadAll();
      expect(saved.any((profile) => profile.id == nova.id), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'host can create a multi-game session through the actual builder UI',
    (tester) async {
      final repository = _MemoryDraftRepository();
      await tester.binding.setSurfaceSize(const Size(1280, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _TestApp(
          child: CinematicSessionBuilderPage(
            drafts: repository,
            challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
            onBack: () {},
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('MIXED GAMES'));
      await tester.tap(
        find.byKey(const ValueKey<String>('choose-saved-players')),
      );
      await tester.tap(find.byKey(const ValueKey<String>('round-count')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4').last);
      await tester.pumpAndSettle();
      _activateButton(tester, 'START GAME');
      for (var frame = 0; frame < 20; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(repository.items, isEmpty);
      expect(find.text('BEGIN ROUND'), findsOneWidget);
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
        child: V5QuickGamesPage(
          drafts: repository,
          challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
          onBack: () {},
        ),
      ),
    );
    await tester.tap(find.text('QUICK QUIZ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit quick game settings'));
    await tester.pumpAndSettle();

    expect(find.text('ADVANCED SETTINGS'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.text('ADVANCED SETTINGS'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Friday Match');
    await tester.pump();
    expect(find.text('Friday Match'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rename dialog fits compact landscape with keyboard open', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(915, 412));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      RoundveilApp(profileRepository: InMemoryPlayerProfileRepository()),
    );
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pump(const Duration(milliseconds: 280));
    await tester.tap(find.text('AVATARS').first);
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 235);
    await tester.tap(
      find.byKey(const ValueKey<String>('edit-player-callsign')),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('EDIT PLAYER CALLSIGN'), findsOneWidget);
  });

  testWidgets('quick template Start Match opens the selected game directly', (
    tester,
  ) async {
    final repository = _MemoryDraftRepository();
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: V5QuickGamesPage(
          drafts: repository,
          challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
          onBack: () {},
        ),
      ),
    );
    await tester.tap(find.text('QUICK QUIZ'));
    await tester.pump(const Duration(milliseconds: 250));
    _activateButton(tester, 'START MATCH');
    for (var frame = 0; frame < 8; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _startVisibleTurn(tester);

    expect(_visibleChallenge(tester, quizChallenges).prompt, isNotEmpty);
    expect(repository.items, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Quick Game uses selected saved profiles without placeholders', (
    tester,
  ) async {
    final repository = _MemoryDraftRepository();
    final profiles = InMemoryPlayerProfileRepository();
    await profiles.ensureProfiles(const <PlayerConfiguration>[
      PlayerConfiguration(id: 'saved-avery', displayName: 'Avery'),
      PlayerConfiguration(id: 'saved-blake', displayName: 'Blake'),
      PlayerConfiguration(id: 'saved-casey', displayName: 'Casey'),
    ]);
    await tester.binding.setSurfaceSize(const Size(1280, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: V5QuickGamesPage(
          drafts: repository,
          profileRepository: profiles,
          challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('MIXED'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PARTY MIX'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('START MATCH'));
    await tester.pumpAndSettle();

    expect(find.text('CHOOSE YOUR PLAYERS'), findsOneWidget);
    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byType(CheckboxListTile).at(index));
      await tester.pump();
    }
    expect(
      find
          .byType(CheckboxListTile)
          .evaluate()
          .map((element) => (element.widget as CheckboxListTile).value),
      everyElement(isTrue),
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'START WITH SELECTED'),
          )
          .onPressed,
      isNotNull,
    );
    final startSelected = find.widgetWithText(
      FilledButton,
      'START WITH SELECTED',
    );
    await tester.ensureVisible(startSelected);
    await tester.tap(startSelected);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('CHOOSE YOUR PLAYERS'), findsNothing);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('ROUND 1'), findsOneWidget);
    await tester.tap(find.text('BEGIN ROUND'));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('AVERY'), findsOneWidget);
    expect(find.text('Player 1'), findsNothing);
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
            challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
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
      await tester.pump(const Duration(milliseconds: 200));
      await _startVisibleTurn(tester);

      expect(find.text('NAME THE PLACE OR TERRITORY'), findsOneWidget);
      expect(find.text('REVEAL ANSWER'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      expect(
        countryChallenges.any(
          (challenge) =>
              find.text(challenge.answer.toUpperCase()).evaluate().isNotEmpty,
        ),
        isFalse,
      );
      await tester.ensureVisible(find.text('REVEAL ANSWER'));
      await tester.tap(find.text('REVEAL ANSWER'));
      await tester.pump();
      final challenge = countryChallenges.firstWhere(
        (challenge) =>
            find.text(challenge.answer.toUpperCase()).evaluate().isNotEmpty,
      );
      expect(find.text(challenge.answer.toUpperCase()), findsOneWidget);
      expect(find.text('CORRECT'), findsOneWidget);
      await tester.ensureVisible(find.text('CORRECT'));
      await tester.tap(find.text('CORRECT'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 550));
      expect(find.text('10'), findsOneWidget);
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
          challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
          configuration: SessionConfiguration(
            players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
            selectedModuleIds: const <String>['guess_character'],
            roundCount: 1,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await _startVisibleTurn(tester);
    expect(find.text('PLAYER — TURN AWAY'), findsOneWidget);
    await tester.tap(find.text('PLAYER IS TURNED AWAY · REVEAL CHARACTER'));
    await tester.pump();
    final challenge = characterChallenges.firstWhere(
      (challenge) => find.text(challenge.answer).evaluate().isNotEmpty,
    );
    expect(find.text(challenge.answer), findsOneWidget);
    expect(find.text('CORRECT'), findsOneWidget);
    await tester.tap(find.text('CORRECT'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('word play accepts a typed offline answer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(960, 540));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _TestApp(
        child: ActiveMatchPage(
          challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
          configuration: SessionConfiguration(
            players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
            selectedModuleIds: const <String>['word_play'],
            roundCount: 1,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await _startVisibleTurn(tester);
    final challenge = _visibleChallenge(tester, wordChallenges);
    await tester.enterText(find.byType(TextField), challenge.answer);
    await tester.tap(find.text('SUBMIT WORD'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 550));
    expect(find.text('10'), findsOneWidget);
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
          challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
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
          challengeHistoryRepository: InMemoryChallengeHistoryRepository(),
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
    await tester.pump(const Duration(milliseconds: 200));
    final answered = <String>{};
    for (var turn = 0; turn < 4; turn++) {
      await _startVisibleTurn(tester);
      final challenge = _visibleChallenge(tester, quizChallenges);
      expect(answered.add(challenge.id), isTrue);
      await tester.ensureVisible(find.text(challenge.answer));
      await tester.tap(find.text(challenge.answer));
      await tester.pump();
      await tester.pump(const Duration(seconds: 11));
    }
    expect(find.text('MATCH COMPLETE'), findsOneWidget);
    expect(find.text('PLAY AGAIN'), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.textContaining('HINT ·'), findsNothing);
    expect(find.textContaining('TURN '), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Play Again reuses rules and players with a fresh challenge', (
    tester,
  ) async {
    final history = InMemoryChallengeHistoryRepository();
    final profiles = InMemoryPlayerProfileRepository();
    final configuration = SessionConfiguration(
      players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
      selectedModuleIds: const <String>['quiz'],
      roundCount: 1,
    );
    await tester.pumpWidget(
      _TestApp(
        child: ActiveMatchPage(
          challengeHistoryRepository: history,
          profileRepository: profiles,
          configuration: configuration,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await _startVisibleTurn(tester);
    final firstChallenge = _visibleChallenge(tester, quizChallenges);
    await tester.tap(find.text(firstChallenge.answer));
    await tester.pump();
    await tester.pump(const Duration(seconds: 11));
    expect(find.text('MATCH COMPLETE'), findsOneWidget);
    expect((await history.loadRecentIds()), contains(firstChallenge.id));
    expect((await profiles.loadAll()).single.hintCredits, 15);
    expect((await profiles.loadAll()).single.gamesPlayed, 1);

    await tester.tap(find.byKey(const ValueKey<String>('play-again')));
    await tester.pumpAndSettle();
    expect(find.text('ROUND 1'), findsOneWidget);
    await _startVisibleTurn(tester);
    final nextChallenge = _visibleChallenge(tester, quizChallenges);
    expect(nextChallenge.id, isNot(firstChallenge.id));
    expect(find.text('0 PTS'), findsOneWidget);
    expect((await profiles.loadAll()).single.hintCredits, 15);
    expect((await profiles.loadAll()).single.gamesPlayed, 1);
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
    ]);
    expect(config.roundCount, 4);
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

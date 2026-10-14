import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/guess_country/presentation/player_avatar_figure.dart';
import 'package:roundveil/features/platform_shell/presentation/v5_lobby_page.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

void main() {
  final players = <PlayerConfiguration>[
    for (var i = 1; i <= 3; i++) PlayerConfiguration.placeholder(i),
  ];
  final profiles = <PlayerProfile>[
    PlayerProfile(
      id: 'player-1',
      displayName: 'Player 1',
      avatarId: 'operator_scout',
      avatar: const PlayerAvatarAppearance(
        hairStyle: AvatarHairStyle.cropped,
        hairColor: 0xFF202B38,
        outfitStyle: AvatarOutfitStyle.striker,
        outfitColor: 0xFF2879BA,
        accentColor: 0xFFF4A62C,
        accessory: AvatarAccessory.visor,
      ),
      wins: 2,
      gamesPlayed: 5,
      hintCredits: 4,
    ),
    PlayerProfile(
      id: 'player-2',
      displayName: 'Player 2',
      avatarId: 'operator_striker',
      avatar: const PlayerAvatarAppearance(
        faceStyle: AvatarFaceStyle.bold,
        skinTone: 0xFF9F624A,
        hairStyle: AvatarHairStyle.curls,
        hairColor: 0xFF241B18,
        outfitStyle: AvatarOutfitStyle.scout,
        outfitColor: 0xFF7251A3,
        accentColor: 0xFF57D0B8,
        accessory: AvatarAccessory.comms,
      ),
      wins: 1,
      gamesPlayed: 3,
      hintCredits: 2,
    ),
    PlayerProfile(
      id: 'player-3',
      displayName: 'Player 3',
      avatarId: 'operator_vanguard',
      avatar: const PlayerAvatarAppearance(
        faceStyle: AvatarFaceStyle.soft,
        skinTone: 0xFFF0C7A0,
        hairStyle: AvatarHairStyle.long,
        hairColor: 0xFFB66B34,
        outfitStyle: AvatarOutfitStyle.vanguard,
        outfitColor: 0xFF26796F,
        accentColor: 0xFFFF865D,
        accessory: AvatarAccessory.headband,
      ),
      wins: 0,
      gamesPlayed: 1,
      hintCredits: 1,
    ),
  ];

  Future<void> pumpLobby(
    WidgetTester tester, {
    required Size size,
    required VoidCallback onQuick,
    required ValueChanged<List<PlayerConfiguration>> onCreate,
    ValueChanged<PlayerProfile>? onProfileChanged,
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: RoundveilThemeFactory.versionFive(dark: true),
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: V5LobbyPage(
            players: players,
            profiles: profiles,
            onPlayersChanged: (_) {},
            onCreate: onCreate,
            onQuick: onQuick,
            onDrafts: () {},
            onGames: () {},
            onLaunchGame: (_) {},
            onAvatars: () {},
            onProfileChanged: onProfileChanged ?? (_) {},
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'lobby presents Quick Game before Create Game and launches both',
    (tester) async {
      var quickLaunches = 0;
      List<PlayerConfiguration>? createdPlayers;
      await pumpLobby(
        tester,
        size: const Size(1440, 900),
        onQuick: () => quickLaunches++,
        onCreate: (value) => createdPlayers = value,
      );

      final quick = find.text('QUICK GAME');
      final create = find.text('CREATE GAME');
      expect(quick, findsOneWidget);
      expect(create, findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.contains('/game_modes/'),
        ),
        findsNWidgets(3),
      );
      expect(
        tester.getTopLeft(quick).dy,
        lessThan(tester.getTopLeft(create).dy),
      );

      await tester.tap(quick);
      expect(quickLaunches, 1);
      await tester.tap(create);
      expect(createdPlayers, hasLength(3));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('saved profile appearance drives matching lobby hero and squad', (
    tester,
  ) async {
    await pumpLobby(
      tester,
      size: const Size(1440, 900),
      onQuick: () {},
      onCreate: (_) {},
    );

    final expected = <String, PlayerAvatarAppearance>{
      for (final profile in profiles) profile.id: profile.avatar,
    };
    final avatarAssets = <String>{};
    for (final profile in profiles) {
      final portrait = tester.widget<PlayerAvatarFigure>(
        find.byKey(ValueKey<String>('squad-portrait-${profile.id}')),
      );
      expect(portrait.appearance, expected[profile.id]);
      final image = tester.widget<Image>(
        find.descendant(
          of: find.byKey(ValueKey<String>('squad-portrait-${profile.id}')),
          matching: find.byType(Image),
        ),
      );
      expect(image.image, isA<AssetImage>());
      final assetName = (image.image as AssetImage).assetName;
      expect(assetName, contains('assets/brand/avatars/operator_'));
      avatarAssets.add(assetName);
    }
    expect(avatarAssets, hasLength(3));

    expect(
      find.byKey(const ValueKey<String>('lobby-hero-player-1')),
      findsOneWidget,
    );
    expect(find.text('2 WINS  ·  5 MATCHES  ·  4 HINTS'), findsOneWidget);
    await tester.tap(find.byTooltip('Next player'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('lobby-hero-player-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home-player-portrait-player-2')),
      findsOneWidget,
    );
    expect(find.text('1 WINS  ·  3 MATCHES  ·  2 HINTS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('home character opens browse-and-select avatar overlay', (
    tester,
  ) async {
    PlayerProfile? savedProfile;
    await pumpLobby(
      tester,
      size: const Size(1280, 800),
      onQuick: () {},
      onCreate: (_) {},
      onProfileChanged: (profile) => savedProfile = profile,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('home-avatar-selector')),
    );
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE PLAYER 1’S AVATAR'), findsOneWidget);
    expect(find.byTooltip('Next avatar'), findsOneWidget);

    await tester.tap(find.byTooltip('Next avatar'));
    await tester.pumpAndSettle();
    expect(find.text('STRIKER  ·  2/8'), findsOneWidget);
    expect(savedProfile, isNull, reason: 'Browsing must not save prematurely');

    await tester.tap(
      find.byKey(const ValueKey<String>('save-home-avatar-selection')),
    );
    await tester.pumpAndSettle();
    expect(savedProfile?.id, 'player-1');
    expect(savedProfile?.avatarId, 'operator_striker');
    expect(find.byType(Dialog), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lobby fits landscape phone and desktop sizes without overflow', (
    tester,
  ) async {
    for (final size in <Size>[
      const Size(915, 412),
      const Size(1229, 736),
      const Size(1440, 900),
    ]) {
      await pumpLobby(tester, size: size, onQuick: () {}, onCreate: (_) {});
      expect(
        tester.getRect(find.text('QUICK GAME')).right,
        lessThanOrEqualTo(size.width),
      );
      expect(
        tester.getRect(find.text('CREATE GAME')).right,
        lessThanOrEqualTo(size.width),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('changing a saved appearance changes its rendered avatar asset', (
    tester,
  ) async {
    const initial = PlayerAvatarAppearance(
      faceStyle: AvatarFaceStyle.soft,
      hairStyle: AvatarHairStyle.cropped,
      outfitStyle: AvatarOutfitStyle.striker,
    );
    PlayerAvatarAppearance current = initial;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => Column(
              children: <Widget>[
                PlayerAvatarFigure(
                  appearance: current,
                  width: 150,
                  height: 220,
                ),
                TextButton(
                  onPressed: () => setState(
                    () => current = current.copyWith(
                      hairStyle: AvatarHairStyle.swept,
                    ),
                  ),
                  child: const Text('CHANGE LOOK'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    String assetName() =>
        (tester.widget<Image>(find.byType(Image)).image as AssetImage)
            .assetName;

    final before = assetName();
    await tester.tap(find.text('CHANGE LOOK'));
    await tester.pumpAndSettle();
    expect(assetName(), isNot(before));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/features/platform_shell/presentation/guessing_mode_selection_page.dart';

void main() {
  testWidgets('shows all six modes and returns the selected mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final navigatorKey = GlobalKey<NavigatorState>();
    GuessingModeSelection? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: RoundveilThemeFactory.versionFive(dark: true),
        navigatorKey: navigatorKey,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context)
                    .push<GuessingModeSelection>(
                      MaterialPageRoute<GuessingModeSelection>(
                        builder: (_) => GuessingModeSelectionPage(
                          options: _options,
                          categories: const <String>[
                            'All Categories',
                            'Kitchen',
                          ],
                          playersForPreview: 2,
                        ),
                      ),
                    );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    for (final mode in <String>[
      'CHARACTER NAME',
      'CHARACTER PICTURE',
      'COUNTRY NAME',
      'COUNTRY FLAG',
      'OBJECT NAME',
      'OBJECT PICTURE',
    ]) {
      expect(find.text(mode), findsOneWidget);
    }
    expect(
      find.text('Choose one format. Next, select the players for your match.'),
      findsOneWidget,
    );
    expect(find.textContaining('108 challenges · 4 rounds'), findsWidgets);
    expect(
      find.textContaining("Instance of 'GuessingModeOption'"),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('guessing-mode-object_name')),
    );
    await tester.pumpAndSettle();
    expect(result?.formatId, 'object_name');
    expect(result?.category, 'All Categories');
    expect(result?.contentCount, 108);
  });

  testWidgets(
    'picture categories explain unavailable content and filter counts',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: RoundveilThemeFactory.versionFive(dark: true),
          home: GuessingModeSelectionPage(
            options: _options,
            categories: const <String>['All Categories', 'Kitchen'],
            playersForPreview: 2,
          ),
        ),
      );

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('guessing-mode-object_picture')),
        450,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('8 images'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('guessing-picture-category')),
        -450,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('guessing-picture-category')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kitchen').last);
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('guessing-mode-object_picture')),
        450,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('1 images'), findsNothing);
      expect(
        find.text('Need at least 2 distinct images for 2 players.'),
        findsOneWidget,
      );
      expect(
        find.text('No eligible images in this category yet.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'picture availability offers rounds supported by decoded images',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: RoundveilThemeFactory.versionFive(dark: true),
          home: GuessingModeSelectionPage(
            options: <GuessingModeOption>[
              _options[1].copyWithForTest(
                contentCount: 4,
                categoryCounts: const <String, int>{'Anime Characters': 4},
              ),
            ],
            categories: const <String>['All Categories', 'Anime Characters'],
            playersForPreview: 2,
          ),
        ),
      );

      expect(
        find.textContaining('4 images · up to 2 rounds · 2 players'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<InkWell>(
              find.byKey(
                const ValueKey<String>('guessing-mode-character_picture'),
              ),
            )
            .onTap,
        isNotNull,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

extension on GuessingModeOption {
  GuessingModeOption copyWithForTest({
    required int contentCount,
    required Map<String, int> categoryCounts,
  }) => GuessingModeOption(
    id: id,
    title: title,
    description: description,
    contentCount: contentCount,
    roundCount: roundCount,
    icon: icon,
    isPictureMode: isPictureMode,
    categoryCounts: categoryCounts,
  );
}

const _options = <GuessingModeOption>[
  GuessingModeOption(
    id: 'character_name',
    title: 'CHARACTER NAME',
    description: 'Verbal clues.',
    contentCount: 50,
    roundCount: 4,
    icon: Icons.person,
    isPictureMode: false,
  ),
  GuessingModeOption(
    id: 'character_picture',
    title: 'CHARACTER PICTURE',
    description: 'Real images.',
    contentCount: 50,
    roundCount: 4,
    icon: Icons.image,
    isPictureMode: true,
    categoryCounts: <String, int>{'Kitchen': 0},
  ),
  GuessingModeOption(
    id: 'country_name',
    title: 'COUNTRY NAME',
    description: 'Geographic clues.',
    contentCount: 100,
    roundCount: 4,
    icon: Icons.public,
    isPictureMode: false,
  ),
  GuessingModeOption(
    id: 'country_flag',
    title: 'COUNTRY FLAG',
    description: 'Offline flags.',
    contentCount: 100,
    roundCount: 4,
    icon: Icons.flag,
    isPictureMode: false,
  ),
  GuessingModeOption(
    id: 'object_name',
    title: 'OBJECT NAME',
    description: 'Object clues.',
    contentCount: 108,
    roundCount: 4,
    icon: Icons.category,
    isPictureMode: false,
  ),
  GuessingModeOption(
    id: 'object_picture',
    title: 'OBJECT PICTURE',
    description: 'Object photos.',
    contentCount: 8,
    roundCount: 4,
    icon: Icons.photo,
    isPictureMode: true,
    categoryCounts: <String, int>{'Kitchen': 1},
  ),
];

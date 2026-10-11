import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/design_system/roundveil_theme.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/memory/presentation/memory_game_page.dart';
import 'package:roundveil/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('host must explicitly configure Memory before starting', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(960, 432));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_TestApp(child: _page()));

    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    await _configureMemory(tester);
    expect(
      tester.getRect(find.text('START MATCH')).bottom,
      lessThanOrEqualTo(432),
    );
    await tester.tap(find.text('START MATCH'));
    await tester.pump();

    expect(find.text('PLAYER 1'), findsOneWidget);
    expect(find.byType(IconButton), findsAtLeastNWidgets(16));
    expect(tester.takeException(), isNull);
  });

  testWidgets('memory board runs a correct pair through countdown', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(960, 432));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_TestApp(child: _page(seed: 21)));
    await _configureMemory(tester);
    await tester.tap(find.text('START MATCH'));
    await tester.pump();

    final symbols = List<int>.generate(16, (index) => index ~/ 2)
      ..shuffle(Random(21 + 1));
    final pair = _firstPair(symbols);
    await tester.tap(find.byKey(ValueKey<String>('memory-card-${pair.$1}')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey<String>('memory-card-${pair.$2}')));
    await tester.pump();

    expect(find.text('WIN COUNTDOWN'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong memory pair advances player without Win Countdown', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(960, 432));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_TestApp(child: _page(seed: 31)));
    await _configureMemory(tester);
    await tester.tap(find.text('START MATCH'));
    await tester.pump();

    final symbols = List<int>.generate(16, (index) => index ~/ 2)
      ..shuffle(Random(31 + 1));
    final pair = _differentPair(symbols);
    await tester.tap(find.byKey(ValueKey<String>('memory-card-${pair.$1}')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey<String>('memory-card-${pair.$2}')));
    await tester.pump();

    expect(find.text('NO MATCH'), findsOneWidget);
    expect(find.text('WIN COUNTDOWN'), findsNothing);
    await tester.tap(find.text('CONTINUE TURN'));
    await tester.pump();
    expect(find.text('PLAYER 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}


MemoryGamePage _page({int seed = 21}) => MemoryGamePage(
  players: <PlayerConfiguration>[
    PlayerConfiguration.placeholder(1),
    PlayerConfiguration.placeholder(2),
  ],
  rounds: 1,
  onExit: () {},
  seed: seed,
);

Future<void> _configureMemory(WidgetTester tester) async {
  await tester.tap(
    find.byKey(const ValueKey<String>('memory-timer-unlimited')),
  );
  await tester.tap(find.byKey(const ValueKey<String>('memory-countdown-3')));
  await tester.tap(find.byKey(const ValueKey<String>('memory-hints-off')));
  await tester.tap(find.byKey(const ValueKey<String>('memory-scoring-on')));
  await tester.pump();
}

(int, int) _firstPair(List<int> symbols) {
  for (var a = 0; a < symbols.length; a++) {
    for (var b = a + 1; b < symbols.length; b++) {
      if (symbols[a] == symbols[b]) return (a, b);
    }
  }
  throw StateError('No pair.');
}

(int, int) _differentPair(List<int> symbols) {
  for (var a = 0; a < symbols.length; a++) {
    for (var b = a + 1; b < symbols.length; b++) {
      if (symbols[a] != symbols[b]) return (a, b);
    }
  }
  throw StateError('No mismatched pair.');
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

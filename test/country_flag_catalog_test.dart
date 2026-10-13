import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_controller.dart';
import 'package:roundveil/features/guess_country/domain/country_flag.dart';

void main() {
  test('offline country catalog contains all 249 ISO alpha-2 entries', () {
    expect(countryFlags, hasLength(249));
    expect(countryFlags.map((flag) => flag.id).toSet(), hasLength(249));
    expect(countryFlags.map((flag) => flag.name).toSet(), hasLength(249));
    expect(countryFlags.map((flag) => flag.assetPath).toSet(), hasLength(249));
    expect(countryFlags.every((flag) => flag.id.length == 2), isTrue);
  });

  test(
    'every catalog flag resolves offline to a valid SVG with preserved viewBox',
    () {
      for (final flag in countryFlags) {
        final asset = File(flag.assetPath);
        expect(asset.existsSync(), isTrue, reason: flag.id);
        final svg = asset.readAsStringSync();
        expect(svg, startsWith('<svg'), reason: flag.id);
        final match = RegExp(r'viewBox="([^"]+)"').firstMatch(svg);
        expect(match, isNotNull, reason: flag.id);
        final dimensions = match!.group(1)!.split(RegExp(r'\s+'));
        final ratio = double.parse(dimensions[2]) / double.parse(dimensions[3]);
        expect(ratio, closeTo(flag.aspectRatio, 0.0001), reason: flag.id);
      }
      expect(
        File('assets/app/flags/LICENSE.flag-icons.txt').existsSync(),
        isTrue,
      );
    },
  );

  test('country regions distinguish North and South America and other', () {
    expect(
      countryFlags.any((flag) => flag.region == CountryRegion.northAmerica),
      isTrue,
    );
    expect(
      countryFlags.any((flag) => flag.region == CountryRegion.southAmerica),
      isTrue,
    );
    expect(
      countryFlags.any((flag) => flag.region == CountryRegion.other),
      isTrue,
    );
    expect(
      countryFlags.where(
        (flag) => flag.difficulty == CountryDifficulty.unrated,
      ),
      hasLength(242),
    );
  });

  test('worldwide flag openings randomize across matches without repeats', () {
    List<String> firstTen(int seed) {
      final match = ActiveMatchController(
        configuration: SessionConfiguration(
          players: <PlayerConfiguration>[PlayerConfiguration.placeholder(1)],
          selectedModuleIds: const <String>['guess_country_flags'],
          roundCount: 10,
        ),
        enableTimers: false,
        random: Random(seed),
      );
      match.start();
      final ids = <String>[];
      for (var turn = 0; turn < 10; turn++) {
        if (match.state.phase == MatchPhase.roundIntro) match.beginRound();
        ids.add(match.state.challenge.id);
        match.beginChallenge();
        match.revealAnswer();
        match.judge(correct: false);
      }
      match.dispose();
      return ids;
    }

    final first = firstTen(101);
    final second = firstTen(202);
    expect(first, hasLength(10));
    expect(first.toSet(), hasLength(10));
    expect(second.toSet(), hasLength(10));
    expect(second, isNot(first));
  });
}

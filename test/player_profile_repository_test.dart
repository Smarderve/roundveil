import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/session/session_configuration.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('roundveil-profiles-');
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test(
    'hint credit spend is one per challenge and survives repository reload',
    () async {
      final repository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      await repository.ensureProfiles(<PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
      ]);
      await repository.completeMatch(
        matchId: 'reward-match',
        results: const <PlayerMatchResult>[
          PlayerMatchResult(playerId: 'player-1', matchPoints: 3),
        ],
      );

      expect(
        await repository.spendHintCredit(
          matchId: 'match-a',
          playerId: 'player-1',
          challengeId: 'quiz-1',
        ),
        isTrue,
      );
      expect(
        await repository.spendHintCredit(
          matchId: 'match-a',
          playerId: 'player-1',
          challengeId: 'quiz-1',
        ),
        isFalse,
      );
      final reloaded = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );

      expect((await reloaded.loadAll()).single.hintCredits, 4);
      for (var index = 2; index <= 5; index++) {
        expect(
          await reloaded.spendHintCredit(
            matchId: 'match-a',
            playerId: 'player-1',
            challengeId: 'quiz-$index',
          ),
          isTrue,
        );
      }
      expect(
        await reloaded.spendHintCredit(
          matchId: 'match-a',
          playerId: 'player-1',
          challengeId: 'quiz-6',
        ),
        isFalse,
      );
    },
  );

  test(
    'leaderboard rewards use deterministic ordering and are granted once',
    () async {
      final repository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      await repository.ensureProfiles(<PlayerConfiguration>[
        for (var index = 1; index <= 4; index++)
          PlayerConfiguration.placeholder(index),
      ]);
      final results = <PlayerMatchResult>[
        const PlayerMatchResult(playerId: 'player-3', matchPoints: 4),
        const PlayerMatchResult(playerId: 'player-2', matchPoints: 9),
        const PlayerMatchResult(playerId: 'player-1', matchPoints: 9),
        const PlayerMatchResult(playerId: 'player-4', matchPoints: 1),
      ];

      final receipts = await Future.wait(<Future<MatchCompletionReceipt>>[
        repository.completeMatch(matchId: 'match-a', results: results),
        repository.completeMatch(matchId: 'match-a', results: results),
      ]);
      final receipt = receipts.firstWhere((row) => row.applied);
      final duplicate = receipts.firstWhere((row) => !row.applied);

      expect(receipt.applied, isTrue);
      expect(receipt.rankings.map((row) => row.playerId), [
        'player-1',
        'player-2',
        'player-3',
        'player-4',
      ]);
      expect(receipt.rankings.map((row) => row.hintCreditsAwarded), [
        5,
        3,
        1,
        0,
      ]);
      expect(receipt.applied, isTrue);
      expect(duplicate.applied, isFalse);
      final profiles = await repository.loadAll();
      expect(profiles.map((profile) => profile.hintCredits), [5, 3, 1, 0]);
      expect(profiles.every((profile) => profile.gamesPlayed == 1), isTrue);
    },
  );

  test('a hint with no valid content cannot consume a credit', () async {
    final repository = LocalPlayerProfileRepository(
      directoryProvider: () async => directory,
    );
    await repository.ensureProfiles(<PlayerConfiguration>[
      PlayerConfiguration.placeholder(1),
    ]);
    await repository.completeMatch(
      matchId: 'reward-match',
      results: const <PlayerMatchResult>[
        PlayerMatchResult(playerId: 'player-1', matchPoints: 3),
      ],
    );

    expect(
      await repository.spendHintCredit(
        matchId: 'match-a',
        playerId: 'player-1',
        challengeId: '',
      ),
      isFalse,
    );
    expect((await repository.loadAll()).single.hintCredits, 5);
  });

  test(
    'custom 2D appearance is preserved across profile repository reloads',
    () async {
      final directory = await Directory.systemTemp.createTemp('rv-appearance-');
      addTearDown(() => directory.delete(recursive: true));
      final repository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      final player = PlayerConfiguration.placeholder(1);
      final profile = (await repository.ensureProfiles([player])).single;
      final updated = profile.copyWith(
        avatar: profile.avatar.copyWith(
          hairStyle: AvatarHairStyle.curls,
          accessory: AvatarAccessory.visor,
          outfitColor: 0xFF7357A5,
        ),
      );
      await repository.updateProfile(updated);

      final reloaded = (await LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      ).loadAll()).single;
      expect(reloaded.avatar.hairStyle, AvatarHairStyle.curls);
      expect(reloaded.avatar.accessory, AvatarAccessory.visor);
      expect(reloaded.avatar.outfitColor, 0xFF7357A5);
    },
  );
}

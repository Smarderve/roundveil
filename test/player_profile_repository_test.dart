import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/player_profile_repository.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';
import 'package:roundveil/domain/player/player_profile.dart';
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

      expect((await reloaded.loadAll()).single.hintCredits, 14);
      for (var index = 2; index <= 15; index++) {
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
          challengeId: 'quiz-16',
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
      expect(profiles.map((profile) => profile.hintCredits), [15, 13, 11, 10]);
      expect(profiles.every((profile) => profile.gamesPlayed == 1), isTrue);
      expect(profiles.map((profile) => profile.wins), [1, 0, 0, 0]);
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
    expect((await repository.loadAll()).single.hintCredits, 15);
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
        avatarId: 'operator_pathfinder',
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
      expect(reloaded.avatarId, 'operator_pathfinder');
    },
  );

  test(
    'custom callsign survives reload and generated profile bootstrap',
    () async {
      final repository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      final profile = (await repository.ensureProfiles(<PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
      ])).single;
      await repository.updateProfile(
        profile.copyWith(displayName: 'Captain Nova'),
      );

      final reloadedRepository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      await reloadedRepository.ensureProfiles(<PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
      ]);
      expect(
        (await reloadedRepository.loadAll()).single.displayName,
        'Captain Nova',
      );
      await reloadedRepository.ensureProfiles(const <PlayerConfiguration>[
        PlayerConfiguration(id: 'player-1', displayName: 'Nova Prime'),
      ]);
      expect(
        (await reloadedRepository.loadAll()).single.displayName,
        'Nova Prime',
      );
    },
  );

  test(
    'profiles can be created and deleted without draft resurrection',
    () async {
      final repository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      final created = await repository.createProfile(
        displayName: '  Nova  ',
        gender: PlayerGender.nonBinary,
      );
      expect(created.id, 'player-1');
      expect(created.displayName, 'Nova');
      expect(created.gender, PlayerGender.nonBinary);

      final reloaded = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      expect((await reloaded.loadAll()).single.gender, PlayerGender.nonBinary);
      await reloaded.deleteProfile(created.id);
      await reloaded.ensureProfiles(<PlayerConfiguration>[
        PlayerConfiguration(id: created.id, displayName: created.displayName),
      ]);
      expect(await reloaded.loadAll(), isEmpty);

      final replacement = await reloaded.createProfile(displayName: 'Orion');
      expect(replacement.id, 'player-2');
    },
  );

  test(
    'legacy duplicate avatar assignments migrate without losing profiles',
    () async {
      final repository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      await repository.ensureProfiles(<PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
      ]);
      await repository.updateProfile(
        (await repository.loadAll())[0].copyWith(displayName: 'Nova'),
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}roundveil_players.json',
      );
      final data =
          jsonDecode(await file.readAsString()) as Map<String, Object?>;
      final saved = (data['profiles']! as List<Object?>)
          .cast<Map<String, Object?>>();
      saved[1]['avatarId'] = saved[0]['avatarId'];
      await file.writeAsString(jsonEncode(data));

      final migrated = await LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      ).loadAll();
      expect(migrated.map((profile) => profile.id), ['player-1', 'player-2']);
      expect(migrated.first.displayName, 'Nova');
      expect(migrated.map((profile) => profile.avatarId).toSet(), hasLength(2));
      final created = await LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      ).createProfile(displayName: 'Orion');
      expect(
        migrated.map((profile) => profile.avatarId),
        isNot(contains(created.avatarId)),
      );
    },
  );

  test(
    'existing hint balances reset once and spent credits survive reloads',
    () async {
      final repository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      await repository.ensureProfiles(<PlayerConfiguration>[
        PlayerConfiguration.placeholder(1),
        PlayerConfiguration.placeholder(2),
        PlayerConfiguration.placeholder(3),
      ]);
      final file = File(
        '${directory.path}${Platform.pathSeparator}roundveil_players.json',
      );
      final data =
          jsonDecode(await file.readAsString()) as Map<String, Object?>;
      data.remove('hintCreditResetVersion');
      final saved = (data['profiles']! as List<Object?>)
          .cast<Map<String, Object?>>();
      saved[0]['hintCredits'] = 1;
      saved[1]['hintCredits'] = 7;
      saved[2]['hintCredits'] = 0;
      await file.writeAsString(jsonEncode(data));

      final migratedRepository = LocalPlayerProfileRepository(
        directoryProvider: () async => directory,
      );
      expect((await migratedRepository.loadAll()).map((p) => p.hintCredits), [
        10,
        10,
        10,
      ]);
      expect((await migratedRepository.loadAll()).map((p) => p.hintCredits), [
        10,
        10,
        10,
      ]);
      expect(
        await migratedRepository.spendHintCredit(
          matchId: 'migration-test',
          playerId: 'player-1',
          challengeId: 'one',
        ),
        isTrue,
      );
      expect(
        (await LocalPlayerProfileRepository(
          directoryProvider: () async => directory,
        ).loadAll()).map((p) => p.hintCredits),
        [9, 10, 10],
      );
    },
  );
}

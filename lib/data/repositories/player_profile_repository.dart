import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:roundveil/domain/player/player_profile.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/player/player_avatar_appearance.dart';

bool _isGeneratedPlayerName(PlayerConfiguration player) {
  final match = RegExp(r'^player-(\d+)$').firstMatch(player.id);
  return match != null && player.displayName == 'Player ${match.group(1)}';
}

String _nextProfileId(Iterable<String> existingIds) {
  final existing = existingIds.toSet();
  var number = 1;
  while (existing.contains('player-$number')) {
    number++;
  }
  return 'player-$number';
}

class PlayerMatchResult {
  const PlayerMatchResult({
    required this.playerId,
    required this.matchPoints,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.timeouts = 0,
  });

  final String playerId;
  final int matchPoints;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeouts;
}

class PlayerRankingRow {
  const PlayerRankingRow({
    required this.playerId,
    required this.rank,
    required this.matchPoints,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeouts,
    required this.hintCreditsAwarded,
  });

  final String playerId;
  final int rank;
  final int matchPoints;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeouts;
  final int hintCreditsAwarded;
}

class MatchCompletionReceipt {
  const MatchCompletionReceipt({required this.applied, required this.rankings});

  final bool applied;
  final List<PlayerRankingRow> rankings;
}

abstract interface class PlayerProfileRepository {
  Future<List<PlayerProfile>> loadAll();
  Future<PlayerProfile> createProfile({
    required String displayName,
    PlayerGender? gender,
  });
  Future<void> deleteProfile(String playerId);
  Future<List<PlayerProfile>> ensureProfiles(
    Iterable<PlayerConfiguration> players,
  );
  Future<bool> spendHintCredit({
    required String matchId,
    required String playerId,
    required String challengeId,
  });
  Future<void> updateProfile(PlayerProfile profile);
  Future<MatchCompletionReceipt> completeMatch({
    required String matchId,
    required List<PlayerMatchResult> results,
  });
}

class LocalPlayerProfileRepository implements PlayerProfileRepository {
  LocalPlayerProfileRepository({
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? _applicationDataDirectory;

  final Future<Directory> Function() _directoryProvider;
  Future<void> _writes = Future<void>.value();

  Future<File> get _file async {
    final directory = await _directoryProvider();
    return File(
      '${directory.path}${Platform.pathSeparator}roundveil_players.json',
    );
  }

  static Future<Directory> _applicationDataDirectory() async {
    if (Platform.isWindows) {
      final root =
          Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'];
      if (root == null || root.isEmpty) {
        throw StateError('Windows application data directory is unavailable.');
      }
      return Directory('$root${Platform.pathSeparator}ROUNDVEIL');
    }
    if (Platform.isAndroid) {
      final packageRoot = Directory.systemTemp.parent;
      return Directory(
        '${packageRoot.path}${Platform.pathSeparator}files${Platform.pathSeparator}ROUNDVEIL',
      );
    }
    final root =
        Platform.environment['XDG_DATA_HOME'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    return Directory('$root${Platform.pathSeparator}ROUNDVEIL');
  }

  Future<Map<String, Object?>> _read() async {
    final file = await _file;
    final source = file.existsSync() ? file : File('${file.path}.bak');
    if (!await source.exists()) {
      return <String, Object?>{
        'schemaVersion': 1,
        'profiles': <Object?>[],
        'deletedProfileIds': <Object?>[],
        'spentHintKeys': <Object?>[],
        'completedMatchIds': <Object?>[],
      };
    }
    final decoded = jsonDecode(await source.readAsString());
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Player profile store has invalid shape.');
    }
    return decoded;
  }

  List<PlayerProfile> _profiles(Map<String, Object?> data) =>
      (data['profiles'] as List<Object?>? ?? const <Object?>[])
          .map(
            (value) => PlayerProfile.fromJson(value! as Map<String, Object?>),
          )
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));

  @override
  Future<List<PlayerProfile>> loadAll() async => _profiles(await _read());

  @override
  Future<PlayerProfile> createProfile({
    required String displayName,
    PlayerGender? gender,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError.value(displayName, 'displayName');
    late PlayerProfile created;
    await _serialize(() async {
      final data = await _read();
      final profiles = _profiles(data);
      final deletedIds =
          (data['deletedProfileIds'] as List<Object?>? ?? const <Object?>[])
              .cast<String>();
      final id = _nextProfileId(<String>[
        ...profiles.map((profile) => profile.id),
        ...deletedIds,
      ]);
      final position = int.parse(id.substring('player-'.length));
      created = PlayerProfile(
        id: id,
        displayName: name,
        gender: gender,
        avatar: PlayerAvatarAppearance.forPlayer(position),
      );
      profiles.add(created);
      data['profiles'] = profiles.map((profile) => profile.toJson()).toList();
      await _write(data);
    });
    return created;
  }

  @override
  Future<void> deleteProfile(String playerId) => _serialize(() async {
    final data = await _read();
    final profiles = _profiles(data);
    if (!profiles.any((profile) => profile.id == playerId)) {
      throw StateError('Unknown local player $playerId.');
    }
    final deletedIds =
        (data['deletedProfileIds'] as List<Object?>? ?? <Object?>[])
            .cast<String>();
    if (!deletedIds.contains(playerId)) deletedIds.add(playerId);
    data['profiles'] = profiles
        .where((profile) => profile.id != playerId)
        .map((profile) => profile.toJson())
        .toList();
    data['deletedProfileIds'] = deletedIds;
    await _write(data);
  });

  @override
  Future<List<PlayerProfile>> ensureProfiles(
    Iterable<PlayerConfiguration> players,
  ) async {
    await _serialize(() async {
      final data = await _read();
      final deletedIds =
          (data['deletedProfileIds'] as List<Object?>? ?? const <Object?>[])
              .cast<String>()
              .toSet();
      final existing = <String, PlayerProfile>{
        for (final profile in _profiles(data)) profile.id: profile,
      };
      for (final player in players) {
        if (deletedIds.contains(player.id)) continue;
        final profile = existing[player.id];
        if (profile != null) {
          final requestedName = _isGeneratedPlayerName(player)
              ? profile.displayName
              : player.displayName;
          if (profile.displayName != requestedName) {
            existing[player.id] = profile.copyWith(displayName: requestedName);
          }
          continue;
        }
        final position =
            int.tryParse(
              RegExp(r'(\d+)$').firstMatch(player.id)?.group(1) ?? '',
            ) ??
            existing.length + 1;
        existing[player.id] = PlayerProfile(
          id: player.id,
          displayName: player.displayName,
          avatar: PlayerAvatarAppearance.forPlayer(position),
        );
      }
      data['profiles'] = existing.values
          .map((profile) => profile.toJson())
          .toList();
      await _write(data);
    });
    return loadAll();
  }

  @override
  Future<bool> spendHintCredit({
    required String matchId,
    required String playerId,
    required String challengeId,
  }) async {
    if (matchId.isEmpty || playerId.isEmpty || challengeId.isEmpty) {
      return false;
    }
    var spent = false;
    await _serialize(() async {
      final data = await _read();
      final key = '$matchId|$playerId|$challengeId';
      final spentKeys = (data['spentHintKeys'] as List<Object?>? ?? <Object?>[])
          .cast<String>();
      if (spentKeys.contains(key)) return;
      final profiles = _profiles(data);
      final index = profiles.indexWhere((profile) => profile.id == playerId);
      if (index < 0 || profiles[index].hintCredits <= 0) return;
      final updated = profiles[index].copyWith(
        hintCredits: profiles[index].hintCredits - 1,
      );
      profiles[index] = updated;
      data['profiles'] = profiles.map((profile) => profile.toJson()).toList();
      data['spentHintKeys'] = <String>[...spentKeys, key];
      await _write(data);
      spent = true;
    });
    return spent;
  }

  @override
  Future<void> updateProfile(PlayerProfile profile) => _serialize(() async {
    final data = await _read();
    final profiles = _profiles(data);
    final index = profiles.indexWhere((item) => item.id == profile.id);
    if (index < 0) throw StateError('Unknown local player ${profile.id}.');
    profiles[index] = profile;
    data['profiles'] = profiles.map((item) => item.toJson()).toList();
    await _write(data);
  });

  @override
  Future<MatchCompletionReceipt> completeMatch({
    required String matchId,
    required List<PlayerMatchResult> results,
  }) async {
    if (matchId.isEmpty) throw ArgumentError.value(matchId, 'matchId');
    final sorted = [...results]..sort(_compareResults);
    var applied = false;
    late List<PlayerRankingRow> rankings;
    await _serialize(() async {
      final data = await _read();
      final completed =
          (data['completedMatchIds'] as List<Object?>? ?? <Object?>[])
              .cast<String>();
      if (completed.contains(matchId)) {
        rankings = _rankings(sorted);
        return;
      }
      final profiles = <String, PlayerProfile>{
        for (final profile in _profiles(data)) profile.id: profile,
      };
      rankings = _rankings(sorted);
      for (final row in rankings) {
        final profile = profiles[row.playerId];
        if (profile == null) continue;
        profiles[row.playerId] = profile.copyWith(
          hintCredits: profile.hintCredits + row.hintCreditsAwarded,
          wins: profile.wins + (row.rank == 1 ? 1 : 0),
          gamesPlayed: profile.gamesPlayed + 1,
          correctAnswers: profile.correctAnswers + row.correctAnswers,
          wrongAnswers: profile.wrongAnswers + row.wrongAnswers,
          timeouts: profile.timeouts + row.timeouts,
          totalMatchPoints: profile.totalMatchPoints + row.matchPoints,
        );
      }
      data['profiles'] = profiles.values
          .map((profile) => profile.toJson())
          .toList();
      data['completedMatchIds'] = <String>[...completed, matchId];
      await _write(data);
      applied = true;
    });
    return MatchCompletionReceipt(applied: applied, rankings: rankings);
  }

  static int _compareResults(PlayerMatchResult a, PlayerMatchResult b) {
    final points = b.matchPoints.compareTo(a.matchPoints);
    if (points != 0) return points;
    final correct = b.correctAnswers.compareTo(a.correctAnswers);
    if (correct != 0) return correct;
    final wrong = a.wrongAnswers.compareTo(b.wrongAnswers);
    if (wrong != 0) return wrong;
    final timeouts = a.timeouts.compareTo(b.timeouts);
    if (timeouts != 0) return timeouts;
    return a.playerId.compareTo(b.playerId);
  }

  static List<PlayerRankingRow> _rankings(List<PlayerMatchResult> results) =>
      <PlayerRankingRow>[
        for (var index = 0; index < results.length; index++)
          PlayerRankingRow(
            playerId: results[index].playerId,
            rank: index + 1,
            matchPoints: results[index].matchPoints,
            correctAnswers: results[index].correctAnswers,
            wrongAnswers: results[index].wrongAnswers,
            timeouts: results[index].timeouts,
            hintCreditsAwarded: switch (index) {
              0 => 5,
              1 => 3,
              2 => 1,
              _ => 0,
            },
          ),
      ];

  Future<void> _write(Map<String, Object?> data) async {
    final file = await _file;
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(jsonEncode(data), flush: true);
    final backup = File('${file.path}.bak');
    final hadPrevious = await file.exists();
    if (hadPrevious) await file.rename(backup.path);
    try {
      await temporary.rename(file.path);
      if (await backup.exists()) await backup.delete();
    } on Object {
      if (hadPrevious && await backup.exists() && !await file.exists()) {
        await backup.rename(file.path);
      }
      rethrow;
    }
  }

  Future<void> _serialize(Future<void> Function() operation) {
    _writes = _writes.then((_) => operation());
    return _writes;
  }
}

class InMemoryPlayerProfileRepository implements PlayerProfileRepository {
  final Map<String, PlayerProfile> _profiles = <String, PlayerProfile>{};
  final Set<String> _deletedProfileIds = <String>{};
  final Set<String> _spentHints = <String>{};
  final Set<String> _completedMatches = <String>{};

  @override
  Future<List<PlayerProfile>> loadAll() async => _sortedProfiles;

  @override
  Future<PlayerProfile> createProfile({
    required String displayName,
    PlayerGender? gender,
  }) async {
    final name = displayName.trim();
    if (name.isEmpty) throw ArgumentError.value(displayName, 'displayName');
    final id = _nextProfileId(<String>[
      ..._profiles.keys,
      ..._deletedProfileIds,
    ]);
    final created = PlayerProfile(
      id: id,
      displayName: name,
      gender: gender,
      avatar: PlayerAvatarAppearance.forPlayer(
        int.parse(id.substring('player-'.length)),
      ),
    );
    _profiles[id] = created;
    return created;
  }

  @override
  Future<void> deleteProfile(String playerId) async {
    if (_profiles.remove(playerId) == null) {
      throw StateError('Unknown local player $playerId.');
    }
    _deletedProfileIds.add(playerId);
  }

  @override
  Future<List<PlayerProfile>> ensureProfiles(
    Iterable<PlayerConfiguration> players,
  ) async {
    for (final player in players) {
      if (_deletedProfileIds.contains(player.id)) continue;
      _profiles.putIfAbsent(player.id, () {
        final position =
            int.tryParse(
              RegExp(r'(\d+)$').firstMatch(player.id)?.group(1) ?? '',
            ) ??
            _profiles.length + 1;
        return PlayerProfile(
          id: player.id,
          displayName: player.displayName,
          avatar: PlayerAvatarAppearance.forPlayer(position),
        );
      });
      final profile = _profiles[player.id]!;
      final requestedName = _isGeneratedPlayerName(player)
          ? profile.displayName
          : player.displayName;
      if (profile.displayName != requestedName) {
        _profiles[player.id] = _profiles[player.id]!.copyWith(
          displayName: requestedName,
        );
      }
    }
    return _sortedProfiles;
  }

  @override
  Future<bool> spendHintCredit({
    required String matchId,
    required String playerId,
    required String challengeId,
  }) async {
    final key = '$matchId|$playerId|$challengeId';
    final profile = _profiles[playerId];
    if (matchId.isEmpty ||
        challengeId.isEmpty ||
        profile == null ||
        profile.hintCredits <= 0 ||
        !_spentHints.add(key)) {
      return false;
    }
    _profiles[playerId] = profile.copyWith(
      hintCredits: profile.hintCredits - 1,
    );
    return true;
  }

  @override
  Future<void> updateProfile(PlayerProfile profile) async {
    if (!_profiles.containsKey(profile.id)) {
      throw StateError('Unknown local player ${profile.id}.');
    }
    _profiles[profile.id] = profile;
  }

  @override
  Future<MatchCompletionReceipt> completeMatch({
    required String matchId,
    required List<PlayerMatchResult> results,
  }) async {
    final sorted = [...results]
      ..sort(LocalPlayerProfileRepository._compareResults);
    final rankings = LocalPlayerProfileRepository._rankings(sorted);
    if (!_completedMatches.add(matchId)) {
      return MatchCompletionReceipt(applied: false, rankings: rankings);
    }
    for (final row in rankings) {
      final profile = _profiles[row.playerId];
      if (profile == null) continue;
      _profiles[row.playerId] = profile.copyWith(
        hintCredits: profile.hintCredits + row.hintCreditsAwarded,
        wins: profile.wins + (row.rank == 1 ? 1 : 0),
        gamesPlayed: profile.gamesPlayed + 1,
        correctAnswers: profile.correctAnswers + row.correctAnswers,
        wrongAnswers: profile.wrongAnswers + row.wrongAnswers,
        timeouts: profile.timeouts + row.timeouts,
        totalMatchPoints: profile.totalMatchPoints + row.matchPoints,
      );
    }
    return MatchCompletionReceipt(applied: true, rankings: rankings);
  }

  List<PlayerProfile> get _sortedProfiles =>
      _profiles.values.toList()..sort((a, b) => a.id.compareTo(b.id));
}

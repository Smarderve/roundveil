import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract interface class ChallengeHistoryRepository {
  Future<List<String>> loadRecentIds();
  Future<void> recordUsed(String challengeId);
}

/// Keeps a bounded cross-match history in the app-private data directory.
class LocalChallengeHistoryRepository implements ChallengeHistoryRepository {
  LocalChallengeHistoryRepository({Future<Directory> Function()? directory})
    : _directory = directory ?? _applicationDataDirectory;

  final Future<Directory> Function() _directory;
  Future<void> _writes = Future<void>.value();
  static const int _historyLimit = 500;

  Future<File> get _file async {
    final directory = await _directory();
    return File(
      '${directory.path}${Platform.pathSeparator}roundveil_challenge_history.json',
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

  @override
  Future<List<String>> loadRecentIds() async {
    final file = await _file;
    final source = file.existsSync() ? file : File('${file.path}.bak');
    if (!await source.exists()) return <String>[];
    final decoded = jsonDecode(await source.readAsString());
    if (decoded is! Map<String, Object?> || decoded['ids'] is! List<Object?>) {
      throw const FormatException('Challenge history has invalid shape.');
    }
    return (decoded['ids']! as List<Object?>).cast<String>();
  }

  @override
  Future<void> recordUsed(String challengeId) => _serialize(() async {
    if (challengeId.isEmpty) return;
    final ids = await loadRecentIds();
    ids.remove(challengeId);
    ids.add(challengeId);
    final retained = ids.length > _historyLimit
        ? ids.sublist(ids.length - _historyLimit)
        : ids;
    final file = await _file;
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode(<String, Object?>{'schemaVersion': 1, 'ids': retained}),
      flush: true,
    );
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
  });

  Future<void> _serialize(Future<void> Function() operation) {
    _writes = _writes.then((_) => operation());
    return _writes;
  }
}

class InMemoryChallengeHistoryRepository implements ChallengeHistoryRepository {
  final List<String> _ids = <String>[];

  @override
  Future<List<String>> loadRecentIds() async => List<String>.unmodifiable(_ids);

  @override
  Future<void> recordUsed(String challengeId) async {
    if (challengeId.isEmpty) return;
    _ids.remove(challengeId);
    _ids.add(challengeId);
  }
}

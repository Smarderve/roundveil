import 'dart:convert';
import 'dart:io';

import 'package:roundveil/domain/session/session_draft.dart';

abstract interface class DraftRepository {
  Future<List<SessionDraft>> loadAll();
  Future<void> save(SessionDraft draft);
  Future<void> delete(String id);
}

class LocalDraftRepository implements DraftRepository {
  LocalDraftRepository({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? _applicationDataDirectory;

  final Future<Directory> Function() _directoryProvider;
  Future<void> _writes = Future<void>.value();

  Future<File> get _file async {
    final directory = await _directoryProvider();
    return File(
      '${directory.path}${Platform.pathSeparator}roundveil_drafts.json',
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
      // Flutter's Android temp directory is app-scoped .../<package>/cache.
      // Store beside cache, under the app-private files directory, instead.
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
  Future<List<SessionDraft>> loadAll() async {
    final file = await _file;
    if (!await file.exists()) {
      final backup = File('${file.path}.bak');
      if (!await backup.exists()) return <SessionDraft>[];
      await backup.rename(file.path);
    }
    final decoded = jsonDecode(await file.readAsString()) as List<Object?>;
    return decoded
        .map((value) => SessionDraft.fromJson(value! as Map<String, Object?>))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  @override
  Future<void> save(SessionDraft draft) => _serialize(() async {
    final drafts = await loadAll();
    final next = <SessionDraft>[
      draft,
      ...drafts.where((item) => item.id != draft.id),
    ];
    await _write(next);
  });

  @override
  Future<void> delete(String id) => _serialize(() async {
    final drafts = await loadAll();
    await _write(drafts.where((draft) => draft.id != id).toList());
  });

  Future<void> _write(List<SessionDraft> drafts) async {
    final file = await _file;
    await file.parent.create(recursive: true);
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode(drafts.map((draft) => draft.toJson()).toList()),
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
  }

  Future<void> _serialize(Future<void> Function() operation) {
    _writes = _writes.then((_) => operation());
    return _writes;
  }
}

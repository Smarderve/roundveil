import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:roundveil/domain/player/player_avatar_catalog.dart';

void main() {
  testWidgets('all catalog art exists and is included as PNG bundle data', (
    tester,
  ) async {
    final paths = <String>{};
    for (final avatar in PlayerAvatarCatalog.all) {
      paths
        ..add(avatar.assetPath)
        ..add(avatar.effectivePortraitAssetPath);
    }
    expect(PlayerAvatarCatalog.all, hasLength(38));
    expect(
      PlayerAvatarCatalog.all.map((avatar) => avatar.id).toSet(),
      hasLength(PlayerAvatarCatalog.all.length),
    );
    expect(paths, hasLength(68));

    for (final path in paths) {
      expect(File(path).existsSync(), isTrue, reason: path);
      final bytes = await rootBundle.load(path);
      final data = bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      );
      expect(data.length, greaterThan(8), reason: path);
      expect(data.take(8), <int>[
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
      ], reason: path);
    }
  });

  test('the registered avatar roster does not invent 200 video records', () {
    final newCharacters = PlayerAvatarCatalog.all.skip(8).toList();
    expect(
      PlayerAvatarCatalog.all.map((avatar) => avatar.id).toSet(),
      hasLength(PlayerAvatarCatalog.all.length),
    );
    expect(newCharacters, hasLength(30));
    for (final avatar in newCharacters) {
      expect(avatar.assetPath, isNot(avatar.effectivePortraitAssetPath));
    }
  });
}

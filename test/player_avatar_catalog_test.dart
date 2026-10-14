import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/domain/player/player_avatar_catalog.dart';

void main() {
  test(
    'catalog has 30 distinct new offline characters with both image sizes',
    () {
      final newCharacters = PlayerAvatarCatalog.all.skip(8).toList();
      expect(
        PlayerAvatarCatalog.all.map((avatar) => avatar.id).toSet(),
        hasLength(PlayerAvatarCatalog.all.length),
      );
      expect(newCharacters, hasLength(30));
      for (final avatar in newCharacters) {
        expect(File(avatar.assetPath).existsSync(), isTrue, reason: avatar.id);
        expect(
          File(avatar.effectivePortraitAssetPath).existsSync(),
          isTrue,
          reason: avatar.id,
        );
        expect(avatar.assetPath, isNot(avatar.effectivePortraitAssetPath));
      }
    },
  );
}

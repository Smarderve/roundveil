import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/features/platform_shell/application/guessing_mode_capacity.dart';

void main() {
  test(
    'private anime pack supports one distinct round for two lobby players',
    () {
      expect(pictureModeRoundCapacity(imageCount: 3, playerCount: 2), 1);
    },
  );

  test('a category smaller than the lobby cannot start a no-repeat round', () {
    expect(pictureModeRoundCapacity(imageCount: 1, playerCount: 2), 0);
  });

  test('available images cap the normal match at four no-repeat rounds', () {
    expect(pictureModeRoundCapacity(imageCount: 11, playerCount: 2), 4);
  });
}

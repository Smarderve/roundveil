import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/features/character_media/presentation/offline_looping_video.dart';

void main() {
  testWidgets('missing video metadata keeps the supplied still-art fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OfflineLoopingVideo(
          assetPath: null,
          fallback: ColoredBox(
            key: ValueKey<String>('avatar-still-fallback'),
            color: Colors.indigo,
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('avatar-still-fallback')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

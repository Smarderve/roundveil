import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/challenge_history_repository.dart';

void main() {
  test(
    'local challenge history survives repository recreation and deduplicates',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'roundveil-history-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final first = LocalChallengeHistoryRepository(
        directory: () async => directory,
      );
      await first.recordUsed('quiz-01');
      await first.recordUsed('word-01');
      await first.recordUsed('quiz-01');

      final reopened = LocalChallengeHistoryRepository(
        directory: () async => directory,
      );
      expect(await reopened.loadRecentIds(), <String>['word-01', 'quiz-01']);
    },
  );
}

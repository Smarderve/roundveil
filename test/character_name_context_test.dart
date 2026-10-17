import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';

void main() {
  test('every built-in Character Name challenge identifies its universe', () {
    expect(characterChallenges, isNotEmpty);
    for (final challenge in characterChallenges) {
      expect(challenge.category, isNotEmpty, reason: challenge.id);
      expect(challenge.franchise, isNotEmpty, reason: challenge.id);
      expect(challenge.subjectType, isNotEmpty, reason: challenge.id);
      expect(challenge.prompt, isNotEmpty, reason: challenge.id);
    }
  });
}

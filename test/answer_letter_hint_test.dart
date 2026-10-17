import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/features/active_match/application/answer_letter_hint.dart';

void main() {
  test('reveals first and last letters for multiword answers', () {
    expect(buildAnswerLetterHint('Peter Parker'), 'Pet__ ___ker');
    // Uzumaki has seven letters; preserve its length while revealing the last
    // three letters (aki).
    expect(buildAnswerLetterHint('Naruto Uzumaki'), 'Nar___ ____aki');
  });

  test('keeps one or more answer letters concealed for a short answer', () {
    expect(buildAnswerLetterHint('Alice'), 'Ali__');
    expect(buildAnswerLetterHint('Cat'), 'Ca_');
    expect(buildAnswerLetterHint('Al'), 'A_');
  });

  test('preserves spaces, hyphens, punctuation and case', () {
    expect(buildAnswerLetterHint('Spider-Man'), 'Spi___-_an');
    expect(buildAnswerLetterHint('Jean-Luc'), 'Jea_-_uc');
    expect(buildAnswerLetterHint('Émile'), 'Émi__');
    expect(buildAnswerLetterHint('O’Connor'), '_’___nor');
    expect(buildAnswerLetterHint('A. B.'), isNull);
  });

  test('does not return a hint that reveals the complete answer', () {
    for (final answer in <String>['I', '42', 'A/B', '']) {
      final hint = buildAnswerLetterHint(answer);
      expect(hint == null || hint != answer, isTrue);
    }
  });
}

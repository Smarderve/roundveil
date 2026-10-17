/// Builds a compact partial-answer clue without ever returning the full answer.
///
/// The first word contributes up to its first three letters and the final word
/// contributes up to its last three. A one-word answer keeps at least one
/// letter concealed. Separators and punctuation are preserved.
String? buildAnswerLetterHint(String answer) {
  final runes = answer.runes.toList(growable: false);
  final words = <(int, int)>[];
  var start = -1;
  for (var index = 0; index < runes.length; index++) {
    if (_isWordRune(runes[index])) {
      if (start < 0) start = index;
    } else if (start >= 0) {
      words.add((start, index));
      start = -1;
    }
  }
  if (start >= 0) words.add((start, runes.length));
  if (words.isEmpty) return null;

  final revealed = <int>{};
  final first = words.first;
  final last = words.last;
  if (words.length == 1) {
    final revealCount = _min(3, first.$2 - first.$1 - 1);
    for (var index = first.$1; index < first.$1 + revealCount; index++) {
      revealed.add(index);
    }
  } else {
    final firstCount = _min(3, first.$2 - first.$1 - 1);
    for (var index = first.$1; index < first.$1 + firstCount; index++) {
      revealed.add(index);
    }
    final lastCount = _min(3, last.$2 - last.$1 - 1);
    for (var index = last.$2 - lastCount; index < last.$2; index++) {
      revealed.add(index);
    }
  }
  if (revealed.isEmpty) return null;

  final result = StringBuffer();
  for (var index = 0; index < runes.length; index++) {
    final rune = runes[index];
    result.write(
      _isWordRune(rune) && !revealed.contains(index)
          ? '_'
          : String.fromCharCode(rune),
    );
  }
  final hint = result.toString();
  return hint == answer ? null : hint;
}

bool _isWordRune(int rune) =>
    !_isPunctuationRune(rune) &&
    ((rune >= 0x30 && rune <= 0x39) ||
        (rune >= 0x41 && rune <= 0x5a) ||
        (rune >= 0x61 && rune <= 0x7a) ||
        (rune >= 0xc0 && rune <= 0x2fff) ||
        (rune >= 0x3040 && rune <= 0xd7ff) ||
        (rune >= 0xf900 && rune <= 0xfdcf) ||
        (rune >= 0xfdf0 && rune <= 0xffef));

bool _isPunctuationRune(int rune) =>
    rune == 0x00d7 ||
    rune == 0x00f7 ||
    (rune >= 0x2000 && rune <= 0x206f) ||
    (rune >= 0x2e00 && rune <= 0x2e7f) ||
    (rune >= 0x3000 && rune <= 0x303f) ||
    (rune >= 0xfe10 && rune <= 0xfe1f) ||
    (rune >= 0xfe30 && rune <= 0xfe4f);

int _min(int left, int right) => left < right ? left : right;

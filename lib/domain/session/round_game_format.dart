enum RoundGameFamily { quiz, guessingGames, wordPlay }

class RoundGameFormat {
  const RoundGameFormat({
    required this.id,
    required this.family,
    required this.moduleId,
    required this.title,
    this.available = true,
    this.unavailableReason,
  });

  final String id;
  final RoundGameFamily family;
  final String moduleId;
  final String title;
  final bool available;
  final String? unavailableReason;
}

const roundGameFormats = <RoundGameFormat>[
  RoundGameFormat(
    id: 'quiz_multiple_choice',
    family: RoundGameFamily.quiz,
    moduleId: 'quiz',
    title: 'Multiple Choice',
  ),
  RoundGameFormat(
    id: 'quiz_true_false',
    family: RoundGameFamily.quiz,
    moduleId: 'quiz',
    title: 'True or False',
  ),
  RoundGameFormat(
    id: 'quiz_fill_blank',
    family: RoundGameFamily.quiz,
    moduleId: 'quiz',
    title: 'Fill in the Blank',
  ),
  RoundGameFormat(
    id: 'quiz_short_answer',
    family: RoundGameFamily.quiz,
    moduleId: 'quiz',
    title: 'Short Answer',
  ),
  RoundGameFormat(
    id: 'word_scramble',
    family: RoundGameFamily.wordPlay,
    moduleId: 'word_play',
    title: 'Word Scramble',
  ),
  RoundGameFormat(
    id: 'word_missing_letters',
    family: RoundGameFamily.wordPlay,
    moduleId: 'word_play',
    title: 'Missing Letters',
  ),
  RoundGameFormat(
    id: 'word_completion',
    family: RoundGameFamily.wordPlay,
    moduleId: 'word_play',
    title: 'Word Completion',
  ),
  RoundGameFormat(
    id: 'word_guess',
    family: RoundGameFamily.wordPlay,
    moduleId: 'word_play',
    title: 'Guess the Word',
  ),
  RoundGameFormat(
    id: 'character_picture',
    family: RoundGameFamily.guessingGames,
    moduleId: 'guess_character',
    title: 'Character Picture Mode',
  ),
  RoundGameFormat(
    id: 'character_name',
    family: RoundGameFamily.guessingGames,
    moduleId: 'guess_character',
    title: 'Character Name Mode',
  ),
  RoundGameFormat(
    id: 'country_name',
    family: RoundGameFamily.guessingGames,
    moduleId: 'guess_country_flags',
    title: 'Country Name Mode',
  ),
  RoundGameFormat(
    id: 'country_flag',
    family: RoundGameFamily.guessingGames,
    moduleId: 'guess_country_flags',
    title: 'Country Flag Mode',
  ),
];

RoundGameFormat? roundGameFormatById(String id) {
  for (final format in roundGameFormats) {
    if (format.id == id) return format;
  }
  return null;
}

RoundGameFamily? familyForModule(String moduleId) => switch (moduleId) {
  'quiz' => RoundGameFamily.quiz,
  'word_play' => RoundGameFamily.wordPlay,
  'guess_character' || 'guess_country_flags' => RoundGameFamily.guessingGames,
  _ => null,
};

String defaultFormatIdForModule(String moduleId) => switch (moduleId) {
  'quiz' => 'quiz_multiple_choice',
  'word_play' => 'word_scramble',
  'guess_character' => 'character_name',
  'guess_country_flags' => 'country_flag',
  _ => '',
};

List<String> defaultRoundFormatIds(Iterable<String> moduleIds) => moduleIds
    .map(defaultFormatIdForModule)
    .where((id) => id.isNotEmpty)
    .toList();

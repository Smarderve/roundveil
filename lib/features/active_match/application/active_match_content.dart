// The outer quiz collection is const, so format-specific maps are const too.
// ignore_for_file: unnecessary_const

import 'package:roundveil/features/guess_country/domain/country_flag.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/domain/session/round_game_format.dart';

class OfflineChallenge {
  const OfflineChallenge({
    required this.id,
    required this.prompt,
    required this.answer,
    this.choices = const <String>[],
    this.hint = '',
    this.flagAssetPath,
    this.flagAspectRatio,
    this.imageFilePath,
    this.imageSource,
    this.formatPrompts = const <String, String>{},
    this.formatAnswers = const <String, String>{},
    this.category,
    this.franchise,
  });

  final String id;
  final String prompt;
  final String answer;
  final List<String> choices;
  final String hint;
  final String? flagAssetPath;
  final double? flagAspectRatio;
  final String? imageFilePath;
  final String? imageSource;
  final Map<String, String> formatPrompts;
  final Map<String, String> formatAnswers;

  final String? category;
  final String? franchise;
  String promptForFormat(String formatId) {
    final specified = formatPrompts[formatId];
    if (specified != null) return specified;
    final letters = answer.runes.map(String.fromCharCode).toList();
    return switch (formatId) {
      'word_missing_letters' =>
        letters
            .asMap()
            .entries
            .map((entry) => entry.key % 3 == 1 ? '_' : entry.value)
            .join(' '),
      'word_completion' =>
        letters
            .asMap()
            .entries
            .map((entry) => entry.key < 2 ? entry.value : '_')
            .join(' '),
      'word_guess' => hint,
      _ => prompt,
    };
  }

  String answerForFormat(String formatId) => formatAnswers[formatId] ?? answer;

  List<String> choicesForFormat(String formatId) =>
      formatId == 'quiz_true_false' ? const <String>['True', 'False'] : choices;
}

const quizChallenges = <OfflineChallenge>[
  OfflineChallenge(
    id: 'quiz-space-001',
    prompt: 'Which planet is the largest in our solar system?',
    answer: 'Jupiter',
    choices: ['Jupiter', 'Saturn', 'Neptune', 'Earth'],
    hint: 'It is a gas giant.',
    formatPrompts: const {
      'quiz_true_false': 'Jupiter is the largest planet in our solar system.',
      'quiz_fill_blank': 'The largest planet in our solar system is _____.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-science-002',
    prompt: 'What is the chemical formula for water?',
    answer: 'H₂O',
    choices: ['H₂O', 'CO₂', 'O₂', 'NaCl'],
    hint: 'Each molecule contains two hydrogen atoms.',
    formatPrompts: const {
      'quiz_true_false': 'A water molecule contains three hydrogen atoms.',
      'quiz_fill_blank': 'The chemical formula for water is _____.',
    },
    formatAnswers: const {'quiz_true_false': 'False'},
  ),
  OfflineChallenge(
    id: 'quiz-geography-003',
    prompt: 'On which continent is Kenya?',
    answer: 'Africa',
    choices: ['Africa', 'Asia', 'Europe', 'South America'],
    hint: 'It is the continent crossed by the Equator and the Prime Meridian.',
    formatPrompts: const {
      'quiz_true_false': 'Kenya is located in Africa.',
      'quiz_fill_blank': 'Kenya is located on the continent of _____.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-math-004',
    prompt: 'What is 7 × 8?',
    answer: '56',
    choices: ['56', '54', '64', '48'],
    hint: 'Seven groups of eight.',
    formatPrompts: const {
      'quiz_true_false': 'Seven multiplied by eight equals 54.',
      'quiz_fill_blank': 'Seven multiplied by eight equals _____.',
    },
    formatAnswers: const {'quiz_true_false': 'False'},
  ),
  OfflineChallenge(
    id: 'quiz-science-005',
    prompt: 'Which planet is known as the Red Planet?',
    answer: 'Mars',
    choices: ['Mars', 'Venus', 'Mercury', 'Jupiter'],
    hint: 'It is the fourth planet from the Sun.',
    formatPrompts: const {
      'quiz_true_false': 'Mars is known as the Red Planet.',
      'quiz_fill_blank': 'The planet known as the Red Planet is _____.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-literature-006',
    prompt: 'Who wrote the play Romeo and Juliet?',
    answer: 'William Shakespeare',
    choices: [
      'William Shakespeare',
      'Charles Dickens',
      'Jane Austen',
      'Mark Twain',
    ],
    hint: 'The playwright was born in Stratford-upon-Avon.',
    formatPrompts: const {
      'quiz_true_false': 'William Shakespeare wrote Romeo and Juliet.',
      'quiz_fill_blank': 'The play Romeo and Juliet was written by _____.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-general-007',
    prompt: 'How many sides does a hexagon have?',
    answer: 'Six',
    choices: ['Six', 'Five', 'Seven', 'Eight'],
    hint: 'The prefix “hexa-” means this number.',
    formatPrompts: const {
      'quiz_true_false': 'A hexagon has six sides.',
      'quiz_fill_blank': 'A hexagon has _____ sides.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-geography-008',
    prompt: 'What is the capital city of Japan?',
    answer: 'Tokyo',
    choices: ['Tokyo', 'Kyoto', 'Osaka', 'Hiroshima'],
    hint: 'It hosted the 2020 Summer Olympics.',
    formatPrompts: const {
      'quiz_true_false': 'Kyoto is the capital city of Japan.',
      'quiz_fill_blank': 'The capital city of Japan is _____.',
    },
    formatAnswers: const {'quiz_true_false': 'False'},
  ),
  OfflineChallenge(
    id: 'quiz-science-009',
    prompt: 'Which gas do plants absorb from the air during photosynthesis?',
    answer: 'Carbon dioxide',
    choices: ['Carbon dioxide', 'Oxygen', 'Nitrogen', 'Hydrogen'],
    hint: 'Its chemical formula is CO₂.',
    formatPrompts: const {
      'quiz_true_false': 'Plants absorb carbon dioxide during photosynthesis.',
      'quiz_fill_blank':
          'During photosynthesis, plants absorb _____ from the air.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-islamic-010',
    prompt: 'What is the name of the first surah in the Qur’an?',
    answer: 'Al-Fatiha',
    choices: ['Al-Fatiha', 'Al-Baqarah', 'Al-Ikhlas', 'An-Nas'],
    hint: 'Its name means “The Opening”.',
    formatPrompts: const {
      'quiz_true_false': 'Al-Fatiha is the first surah in the Qur’an.',
      'quiz_fill_blank': 'The first surah in the Qur’an is _____.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-ocean-011',
    prompt: 'Which ocean is the largest on Earth?',
    answer: 'Pacific Ocean',
    choices: [
      'Pacific Ocean',
      'Atlantic Ocean',
      'Indian Ocean',
      'Arctic Ocean',
    ],
    hint: 'It covers about one third of Earth’s surface.',
    formatPrompts: const {
      'quiz_true_false': 'The Pacific is the largest ocean basin on Earth.',
      'quiz_fill_blank': 'The largest ocean basin on Earth is the _____ Ocean.',
    },
    formatAnswers: const {'quiz_true_false': 'True'},
  ),
  OfflineChallenge(
    id: 'quiz-chemistry-012',
    prompt: 'What is the chemical symbol for gold?',
    answer: 'Au',
    choices: ['Au', 'Ag', 'Fe', 'Cu'],
    hint: 'Its symbol comes from the Latin word aurum.',
    formatPrompts: const {
      'quiz_true_false': 'The chemical symbol for gold is Ag.',
      'quiz_fill_blank': 'The chemical symbol for gold is _____.',
    },
    formatAnswers: const {'quiz_true_false': 'False'},
  ),
];

const wordChallenges = <OfflineChallenge>[
  OfflineChallenge(
    id: 'word-001',
    prompt: 'Unscramble: T E N A L P',
    answer: 'planet',
    hint: 'A large body that orbits a star.',
  ),
  OfflineChallenge(
    id: 'word-002',
    prompt: 'Unscramble: H P L E A N T E',
    answer: 'elephant',
    hint: 'The largest living land animal.',
  ),
  OfflineChallenge(
    id: 'word-003',
    prompt: 'Unscramble: R B A I R Y L',
    answer: 'library',
    hint: 'A place where books are borrowed.',
  ),
  OfflineChallenge(
    id: 'word-004',
    prompt: 'Unscramble: P A S S M O C',
    answer: 'compass',
    hint: 'A tool that points toward magnetic north.',
  ),
  OfflineChallenge(
    id: 'word-005',
    prompt: 'Unscramble: N I A T U N O M',
    answer: 'mountain',
    hint: 'A high natural elevation of the Earth’s surface.',
  ),
  OfflineChallenge(
    id: 'word-006',
    prompt: 'Unscramble: T E L E S C O P E',
    answer: 'telescope',
    hint: 'An instrument used to observe distant objects in space.',
  ),
  OfflineChallenge(
    id: 'word-007',
    prompt: 'Unscramble: P H I N L O D',
    answer: 'dolphin',
    hint: 'An intelligent marine mammal.',
  ),
  OfflineChallenge(
    id: 'word-008',
    prompt: 'Unscramble: D A L N E R',
    answer: 'lander',
    hint: 'A spacecraft designed to touch down on a surface.',
  ),
  OfflineChallenge(
    id: 'word-009',
    prompt: 'Unscramble: E R A T H',
    answer: 'heart',
    hint: 'The organ that pumps blood.',
  ),
  OfflineChallenge(
    id: 'word-010',
    prompt: 'Unscramble: B E R I D G',
    answer: 'bridge',
    hint: 'A structure built to cross an obstacle.',
  ),
];

/// Curated name-only entries. Image mode stays unavailable until licensed,
/// locally bundled image records have been reviewed and counted.
const characterChallenges = <OfflineChallenge>[
  OfflineChallenge(
    id: 'character-001',
    prompt: 'A consulting detective who lives at 221B Baker Street.',
    answer: 'Sherlock Holmes',
    hint: 'Created by Arthur Conan Doyle.',
  ),
  OfflineChallenge(
    id: 'character-002',
    prompt: 'A curious girl who follows a White Rabbit into a strange world.',
    answer: 'Alice',
    hint: 'Created by Lewis Carroll.',
  ),
  OfflineChallenge(
    id: 'character-003',
    prompt: 'A wooden puppet whose nose grows when he lies.',
    answer: 'Pinocchio',
    hint: 'Created by Carlo Collodi.',
  ),
  OfflineChallenge(
    id: 'character-004',
    prompt: 'A young Kansas girl carried by a cyclone to the Land of Oz.',
    answer: 'Dorothy Gale',
    hint: 'Created by L. Frank Baum.',
  ),
  OfflineChallenge(
    id: 'character-005',
    prompt: 'A clever archer associated with Sherwood Forest.',
    answer: 'Robin Hood',
    hint: 'A figure of English folklore.',
  ),
  OfflineChallenge(
    id: 'character-006',
    prompt: 'A boy who never grows up and lives in Neverland.',
    answer: 'Peter Pan',
    hint: 'Created by J. M. Barrie.',
  ),
  OfflineChallenge(
    id: 'character-007',
    prompt: 'A young sailor who travels with Jim Hawkins in Treasure Island.',
    answer: 'Jim Hawkins',
    hint: 'Created by Robert Louis Stevenson.',
  ),
  OfflineChallenge(
    id: 'character-008',
    prompt: 'A small girl who visits a family of bears in the forest.',
    answer: 'Goldilocks',
    hint: 'A character from a traditional fairy tale.',
  ),
  OfflineChallenge(
    id: 'character-009',
    prompt: 'A boy who escapes to the Mississippi River with Huckleberry Finn.',
    answer: 'Tom Sawyer',
    hint: 'Created by Mark Twain.',
  ),
  OfflineChallenge(
    id: 'character-010',
    prompt: 'A clever cat who tricks an ogre and helps his master.',
    answer: 'Puss in Boots',
    hint: 'A European fairy-tale character.',
  ),
];

final countryChallenges = countryFlags
    .map(
      (flag) => OfflineChallenge(
        id: 'country-${flag.id.toLowerCase()}',
        prompt: 'Identify this flag aloud. The host reveals its place or territory after your guess.',
        answer: flag.name,
        hint: flag.hint,
        flagAssetPath: flag.assetPath,
        flagAspectRatio: flag.aspectRatio,
      ),
    )
    .toList(growable: false);

List<OfflineChallenge> challengesForModule(
  String moduleId, {
  SessionConfiguration? configuration,
}) {
  final content = switch (moduleId) {
    'quiz' => quizChallenges,
    'word_play' => wordChallenges,
    'guess_character' => characterChallenges,
    'guess_country_flags' => countryChallenges,
    _ => const <OfflineChallenge>[],
  };
  if (moduleId != 'guess_country_flags' || configuration == null) {
    return content;
  }
  return content
      .where((challenge) {
        final flagId = challenge.id.split('-').last.toUpperCase();
        final flag = countryFlags.firstWhere((item) => item.id == flagId);
        final inRegion =
            configuration.countryRegion == 'worldwide' ||
            flag.region.name == configuration.countryRegion ||
            (configuration.countryRegion == 'americas' &&
                const <CountryRegion>{
                  CountryRegion.northAmerica,
                  CountryRegion.southAmerica,
                  CountryRegion.americas,
                }.contains(flag.region));
        final inDifficulty =
            configuration.countryDifficulty == 'mixed' ||
            flag.difficulty.name == configuration.countryDifficulty;
        return inRegion && inDifficulty;
      })
      .toList(growable: false);
}

List<OfflineChallenge> challengesForFormat(
  String formatId, {
  SessionConfiguration? configuration,
  List<OfflineChallenge> pictureChallenges = const <OfflineChallenge>[],
}) => switch (roundGameFormatById(formatId)?.moduleId) {
  'quiz' => quizChallenges,
  'word_play' => wordChallenges,
  'guess_character' when formatId == 'character_picture' =>
    configuration == null ||
            configuration.characterPictureCategory == 'All Categories'
        ? pictureChallenges
        : pictureChallenges
              .where(
                (challenge) =>
                    challenge.category ==
                    configuration.characterPictureCategory,
              )
  'guess_character' => characterChallenges,
  'guess_country_flags' => challengesForModule(
    'guess_country_flags',
    configuration: configuration,
  ),
  _ => const <OfflineChallenge>[],
};

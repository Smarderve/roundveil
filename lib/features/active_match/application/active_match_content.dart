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
    this.imageAssetPath,
    this.imageSource,
    this.acceptedAnswers = const <String>[],
    this.formatPrompts = const <String, String>{},
    this.formatAnswers = const <String, String>{},
    this.formatHints = const <String, String>{},
    this.category,
    this.franchise,
    this.subjectType,
    this.difficulty = 'medium',
  });

  final String id;
  final String prompt;
  final String answer;
  final List<String> choices;
  final String hint;
  final String? flagAssetPath;
  final double? flagAspectRatio;
  final String? imageFilePath;
  final String? imageAssetPath;
  final String? imageSource;
  final List<String> acceptedAnswers;
  final Map<String, String> formatPrompts;
  final Map<String, String> formatAnswers;
  final Map<String, String> formatHints;
  final String? category;
  final String? franchise;
  final String? subjectType;
  final String difficulty;

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

  String hintForFormat(String formatId) => formatHints[formatId] ?? hint;

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
    formatHints: {'word_guess': 'It does not make its own light.'},
  ),
  OfflineChallenge(
    id: 'word-002',
    prompt: 'Unscramble: H P L E A N T E',
    answer: 'elephant',
    hint: 'The largest living land animal.',
    formatHints: {'word_guess': 'It has a long trunk.'},
  ),
  OfflineChallenge(
    id: 'word-003',
    prompt: 'Unscramble: R B A I R Y L',
    answer: 'library',
    hint: 'A place where books are borrowed.',
    formatHints: {'word_guess': 'Readers can study quietly there.'},
  ),
  OfflineChallenge(
    id: 'word-004',
    prompt: 'Unscramble: P A S S M O C',
    answer: 'compass',
    hint: 'A tool that points toward magnetic north.',
    formatHints: {'word_guess': 'It helps travelers find direction.'},
  ),
  OfflineChallenge(
    id: 'word-005',
    prompt: 'Unscramble: N I A T U N O M',
    answer: 'mountain',
    hint: 'A high natural elevation of the Earth’s surface.',
    formatHints: {'word_guess': 'Mount Kilimanjaro is one.'},
  ),
  OfflineChallenge(
    id: 'word-006',
    prompt: 'Unscramble: T E L E S C O P E',
    answer: 'telescope',
    hint: 'An instrument used to observe distant objects in space.',
    formatHints: {
      'word_guess': 'It uses lenses or mirrors to magnify distant objects.',
    },
  ),
  OfflineChallenge(
    id: 'word-007',
    prompt: 'Unscramble: P H I N L O D',
    answer: 'dolphin',
    hint: 'An intelligent marine mammal.',
    formatHints: {'word_guess': 'It breathes air through a blowhole.'},
  ),
  OfflineChallenge(
    id: 'word-008',
    prompt: 'Unscramble: D A L N E R',
    answer: 'lander',
    hint: 'A spacecraft designed to touch down on a surface.',
    formatHints: {
      'word_guess': 'It is built to reach the surface of another world.',
    },
  ),
  OfflineChallenge(
    id: 'word-009',
    prompt: 'Unscramble: E R A T H',
    answer: 'heart',
    hint: 'The organ that pumps blood.',
    formatHints: {'word_guess': 'It beats continuously inside the chest.'},
  ),
  OfflineChallenge(
    id: 'word-010',
    prompt: 'Unscramble: B E R I D G',
    answer: 'bridge',
    hint: 'A structure built to cross an obstacle.',
    formatHints: {'word_guess': 'It can span a river or a road.'},
  ),
  OfflineChallenge(
    id: 'word-011',
    prompt: 'Unscramble: O X Y G E N',
    answer: 'oxygen',
    hint: 'A gas that humans need for respiration.',
    formatHints: {'word_guess': 'Its chemical symbol is O.'},
  ),
  OfflineChallenge(
    id: 'word-012',
    prompt: 'Unscramble: A N G L E T R I',
    answer: 'triangle',
    hint: 'A polygon with three sides.',
    formatHints: {'word_guess': 'Its interior angles add up to 180 degrees.'},
  ),
  OfflineChallenge(
    id: 'word-013',
    prompt: 'Unscramble: E Y B O A R D K',
    answer: 'keyboard',
    hint: 'A device with keys used to enter text.',
    formatHints: {'word_guess': 'Computer keys are arranged in rows.'},
  ),
  OfflineChallenge(
    id: 'word-014',
    prompt: 'Unscramble: R A I N F O R E S T',
    answer: 'rainforest',
    hint: 'A forest ecosystem with heavy rainfall.',
    formatHints: {
      'word_guess': 'The Amazon contains the largest tropical example.',
    },
  ),
  OfflineChallenge(
    id: 'word-015',
    prompt: 'Unscramble: E L I T T E A L S',
    answer: 'satellite',
    hint: 'An object that orbits a planet.',
    formatHints: {'word_guess': 'The Moon is Earth’s natural example.'},
  ),
  OfflineChallenge(
    id: 'word-016',
    prompt: 'Unscramble: N O V A L C O',
    answer: 'volcano',
    hint: 'An opening in Earth’s crust that can release lava.',
    formatHints: {'word_guess': 'Mount Kilimanjaro is a dormant example.'},
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
    category: 'Fictional detective',
    franchise: 'Sherlock Holmes stories',
    subjectType: 'Literary character',
  ),
  OfflineChallenge(
    id: 'character-002',
    prompt: 'A curious girl who follows a White Rabbit into a strange world.',
    answer: 'Alice',
    hint: 'Created by Lewis Carroll.',
    category: 'Fictional character',
    franchise: "Alice's Adventures in Wonderland",
    subjectType: 'Literary character',
  ),
  OfflineChallenge(
    id: 'character-003',
    prompt: 'A wooden puppet whose nose grows when he lies.',
    answer: 'Pinocchio',
    hint: 'Created by Carlo Collodi.',
    category: 'Fictional character',
    franchise: 'The Adventures of Pinocchio',
    subjectType: 'Literary character',
  ),
  OfflineChallenge(
    id: 'character-004',
    prompt: 'A young Kansas girl carried by a cyclone to the Land of Oz.',
    answer: 'Dorothy Gale',
    hint: 'Created by L. Frank Baum.',
    category: 'Fictional character',
    franchise: 'The Wonderful Wizard of Oz',
    subjectType: 'Literary character',
  ),
  OfflineChallenge(
    id: 'character-005',
    prompt: 'A clever archer associated with Sherwood Forest.',
    answer: 'Robin Hood',
    hint: 'A figure of English folklore.',
    category: 'Folklore hero',
    franchise: 'English folklore',
    subjectType: 'Folklore character',
  ),
  OfflineChallenge(
    id: 'character-006',
    prompt: 'A boy who never grows up and lives in Neverland.',
    answer: 'Peter Pan',
    hint: 'Created by J. M. Barrie.',
    category: 'Fictional character',
    franchise: 'Peter and Wendy',
    subjectType: 'Literary character',
  ),
  OfflineChallenge(
    id: 'character-007',
    prompt: 'A young sailor who travels with Jim Hawkins in Treasure Island.',
    answer: 'Jim Hawkins',
    hint: 'Created by Robert Louis Stevenson.',
    category: 'Fictional character',
    franchise: 'Treasure Island',
    subjectType: 'Literary character',
  ),
  OfflineChallenge(
    id: 'character-008',
    prompt: 'A small girl who visits a family of bears in the forest.',
    answer: 'Goldilocks',
    hint: 'A character from a traditional fairy tale.',
    category: 'Fairy-tale character',
    franchise: 'Goldilocks and the Three Bears',
    subjectType: 'Folklore character',
  ),
  OfflineChallenge(
    id: 'character-009',
    prompt: 'A boy who escapes to the Mississippi River with Huckleberry Finn.',
    answer: 'Tom Sawyer',
    hint: 'Created by Mark Twain.',
    category: 'Fictional character',
    franchise: 'The Adventures of Tom Sawyer',
    subjectType: 'Literary character',
  ),
  OfflineChallenge(
    id: 'character-010',
    prompt: 'A clever cat who tricks an ogre and helps his master.',
    answer: 'Puss in Boots',
    hint: 'A European fairy-tale character.',
    category: 'Fairy-tale character',
    franchise: 'Puss in Boots',
    subjectType: 'Folklore character',
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

/// Shared object catalog. Only records with a real local/bundled image are
/// eligible for Object Picture Mode; the remaining records serve Object Name.
const _bundledObjectChallengeRecords = <OfflineChallenge>[
  OfflineChallenge(
    id: 'object-electric-drill',
    prompt: 'Used for making holes in materials and driving screws.',
    answer: 'Electric drill',
    hint: 'A powered tool with a rotating bit.',
    category: 'Tools',
    difficulty: 'medium',
    acceptedAnswers: <String>['Drill', 'Power drill'],
    imageAssetPath: 'assets/app/objects/electric_drill.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Close_up_of_electric_drill.jpg',
  ),
  OfflineChallenge(
    id: 'object-kettle',
    prompt: 'Used to heat water for tea, coffee and cooking.',
    answer: 'Kettle',
    hint: 'It switches off after bringing water to a boil.',
    category: 'Kitchen',
    difficulty: 'easy',
    acceptedAnswers: <String>['Electric kettle', 'Tea kettle'],
    imageAssetPath: 'assets/app/objects/kettle.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Boilingkettle.jpg',
  ),
  OfflineChallenge(
    id: 'object-laptop',
    prompt: 'A portable computer with a screen and keyboard joined by a hinge.',
    answer: 'Laptop',
    hint: 'It can run on battery power.',
    category: 'Electronics',
    difficulty: 'easy',
    acceptedAnswers: <String>['Laptop computer', 'Notebook computer'],
    imageAssetPath: 'assets/app/objects/laptop.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Laptop_computer.jpg',
  ),
  OfflineChallenge(
    id: 'object-bicycle',
    prompt: 'A two-wheeled vehicle moved by pedalling.',
    answer: 'Bicycle',
    hint: 'It is balanced and steered with handlebars.',
    category: 'Vehicles',
    difficulty: 'easy',
    acceptedAnswers: <String>['Bike'],
    imageAssetPath: 'assets/app/objects/bicycle.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Green_bicycle.jpg',
  ),
  OfflineChallenge(
    id: 'object-umbrella',
    prompt: 'A portable canopy used to keep rain or strong sun off its holder.',
    answer: 'Umbrella',
    hint: 'It folds and opens around a central shaft.',
    category: 'Household',
    difficulty: 'easy',
    acceptedAnswers: <String>['Rain umbrella'],
    imageAssetPath: 'assets/app/objects/umbrella.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Umbrella_01.jpg',
  ),
  OfflineChallenge(
    id: 'object-pineapple',
    prompt: 'A tropical fruit with a spiky crown and sweet yellow flesh.',
    answer: 'Pineapple',
    hint: 'Its rough skin has diamond-shaped sections.',
    category: 'Food & Fruits',
    difficulty: 'easy',
    acceptedAnswers: <String>['Ananas'],
    imageAssetPath: 'assets/app/objects/pineapple.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Ripe_Pineapple.jpg',
  ),
  OfflineChallenge(
    id: 'object-football',
    prompt: 'A round ball kicked between teams in association football.',
    answer: 'Football',
    hint: 'It is usually patterned with pentagons and hexagons.',
    category: 'Sports',
    difficulty: 'easy',
    acceptedAnswers: <String>['Soccer ball', 'Football (soccer)'],
    imageAssetPath: 'assets/app/objects/football.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Soccer_ball_on_ground_-2_(48451893476).jpg',
  ),
  OfflineChallenge(
    id: 'object-hammer',
    prompt: 'A hand tool used to drive nails or strike materials.',
    answer: 'Hammer',
    hint: 'A common version has a flat face and a claw.',
    category: 'Tools',
    difficulty: 'easy',
    acceptedAnswers: <String>['Claw hammer'],
    imageAssetPath: 'assets/app/objects/hammer.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Hammer.jpg',
  ),
  OfflineChallenge(
    id: 'object-thermometer',
    prompt: 'An instrument used to measure temperature.',
    answer: 'Thermometer',
    hint: 'It may contain a sensor or a liquid column.',
    category: 'Medical & Science',
    difficulty: 'medium',
    acceptedAnswers: <String>['Temperature gauge'],

    imageAssetPath: 'assets/app/objects/openimages_thermometer.jpg',
    imageSource: 'https://www.flickr.com/photos/affinity23/5043750123/',
  ),
  OfflineChallenge(
    id: 'object-blender',
    prompt:
        'A kitchen appliance that blends or purées ingredients in a container.',
    answer: 'Blender',
    hint: 'Its motor spins blades beneath a jar.',
    category: 'Kitchen',
    difficulty: 'easy',
    acceptedAnswers: <String>['Food blender', 'Liquidizer'],

    imageAssetPath: 'assets/app/objects/openimages_blender.jpg',
    imageSource: 'https://www.flickr.com/photos/yourcastlesdecor/12317651403',
  ),
  OfflineChallenge(
    id: 'object-camera',
    prompt: 'A device used to capture still photographs or video.',
    answer: 'Camera',
    hint: 'It focuses light onto a sensor or film.',
    category: 'Electronics',
    difficulty: 'easy',
    acceptedAnswers: <String>['Digital camera', 'Photo camera'],

    imageAssetPath: 'assets/app/objects/openimages_camera.jpg',
    imageSource: 'https://www.flickr.com/photos/croco/252716102',
  ),
  OfflineChallenge(
    id: 'object-guitar',
    prompt: 'A stringed musical instrument usually played by plucking or strumming.',
    answer: 'Guitar',
    hint: 'A common version has six strings and a fretted neck.',
    category: 'Musical Instruments',
    difficulty: 'medium',
    acceptedAnswers: <String>['Acoustic guitar', 'Electric guitar'],

    imageAssetPath: 'assets/app/objects/openimages_guitar.jpg',
    imageSource: 'https://www.flickr.com/photos/rinzewind/29084731',
  ),
  OfflineChallenge(
    id: 'object-sofa',
    prompt: 'A long upholstered seat designed for several people.',
    answer: 'Sofa',
    hint: 'It is commonly placed in a living room.',
    category: 'Household',
    difficulty: 'easy',
    acceptedAnswers: <String>['Couch', 'Settee'],

    imageAssetPath: 'assets/app/objects/openimages_sofa.jpg',
    imageSource: 'https://www.flickr.com/photos/dachis/7696012010',
  ),
  OfflineChallenge(
    id: 'object-bed',
    prompt: 'Furniture used for sleeping or resting.',
    answer: 'Bed',
    hint: 'It usually has a mattress and frame.',
    category: 'Household',
    difficulty: 'easy',
    acceptedAnswers: <String>['Bedstead'],

    imageAssetPath: 'assets/app/objects/openimages_bed.jpg',
    imageSource: 'https://www.flickr.com/photos/anniemole/5046985461',
  ),
  OfflineChallenge(
    id: 'object-curtain',
    prompt: 'A hanging piece of fabric used to cover a window.',
    answer: 'Curtain',
    hint: 'It can be drawn open or closed.',
    category: 'Household',
    difficulty: 'medium',
    acceptedAnswers: <String>['Drape'],

    imageAssetPath: 'assets/app/objects/openimages_curtain.jpg',
    imageSource: 'https://www.flickr.com/photos/monochrome/9264832733',
  ),
  OfflineChallenge(
    id: 'object-clothes-iron',
    prompt:
        'A heated household appliance used to remove wrinkles from clothing.',
    answer: 'Clothes iron',
    hint: 'It glides over fabric on a flat soleplate.',
    category: 'Household',
    difficulty: 'easy',
    acceptedAnswers: <String>['Iron', 'Flat iron'],
  ),
  OfflineChallenge(
    id: 'object-spatula',
    prompt: 'A kitchen utensil used to turn, lift or spread food.',
    answer: 'Spatula',
    hint: 'Some versions have a broad, flat blade.',
    category: 'Kitchen',
    difficulty: 'medium',
    acceptedAnswers: <String>['Turner'],

    imageAssetPath: 'assets/app/objects/openimages_spatula.jpg',
    imageSource: 'https://www.flickr.com/photos/miran/14797258247',
  ),
  OfflineChallenge(
    id: 'object-toaster',
    prompt: 'A kitchen appliance that browns slices of bread with heat.',
    answer: 'Toaster',
    hint: 'Bread is lowered into slots.',
    category: 'Kitchen',
    difficulty: 'easy',
    acceptedAnswers: <String>['Bread toaster'],

    imageAssetPath: 'assets/app/objects/openimages_toaster.jpg',
    imageSource: 'https://www.flickr.com/photos/27620885@N02/2648334881',
  ),
  OfflineChallenge(
    id: 'object-router',
    prompt:
        'A device that directs data between a local network and the internet.',
    answer: 'Router',
    hint: 'It often provides Wi-Fi to nearby devices.',
    category: 'Electronics',
    difficulty: 'hard',
    acceptedAnswers: <String>['Wi-Fi router', 'Wireless router'],

    imageAssetPath: 'assets/app/objects/openimages_router.jpg',
    imageSource: 'https://www.flickr.com/photos/audioreservoir/14764070934',
  ),
  OfflineChallenge(
    id: 'object-projector',
    prompt: 'A device that displays an enlarged image on a screen or wall.',
    answer: 'Projector',
    hint: 'It is often used for presentations or films.',
    category: 'Electronics',
    difficulty: 'medium',
    acceptedAnswers: <String>['Video projector'],

    imageAssetPath: 'assets/app/objects/openimages_projector.jpg',
    imageSource: 'https://www.flickr.com/photos/grand_canyon_nps/6728176471',
  ),
  OfflineChallenge(
    id: 'object-printer',
    prompt: 'A machine that produces text or pictures on paper.',
    answer: 'Printer',
    hint: 'It may use ink or toner.',
    category: 'School & Office',
    difficulty: 'easy',
    acceptedAnswers: <String>['Computer printer'],

    imageAssetPath: 'assets/app/objects/openimages_printer.jpg',
    imageSource: 'https://www.flickr.com/photos/digitaldrew/4930418632',
  ),
  OfflineChallenge(
    id: 'object-wrench',
    prompt: 'A hand tool used to grip and turn nuts or bolts.',
    answer: 'Wrench',
    hint: 'Its opening fits around a fastener.',
    category: 'Tools',
    difficulty: 'medium',
    acceptedAnswers: <String>['Spanner'],

    imageAssetPath: 'assets/app/objects/openimages_wrench.jpg',
    imageSource: 'https://www.flickr.com/photos/free-stock/4904993670',
  ),
  OfflineChallenge(
    id: 'object-pliers',
    prompt: 'A hinged hand tool used to grip, bend or cut objects.',
    answer: 'Pliers',
    hint: 'It has two handles and a pair of jaws.',
    category: 'Tools',
    difficulty: 'medium',
    acceptedAnswers: <String>['Pair of pliers'],
  ),
  OfflineChallenge(
    id: 'object-motorcycle',
    prompt: 'A motor vehicle with two wheels ridden astride.',
    answer: 'Motorcycle',
    hint: 'The rider steers it with handlebars.',
    category: 'Vehicles',
    difficulty: 'medium',
    acceptedAnswers: <String>['Motorbike'],

    imageAssetPath: 'assets/app/objects/openimages_motorcycle.jpg',
    imageSource: 'https://www.flickr.com/photos/diaper/3725089974',
  ),
  OfflineChallenge(
    id: 'object-bus',
    prompt: 'A large road vehicle that carries many passengers along a route.',
    answer: 'Bus',
    hint: 'Passengers usually board through one or more doors.',
    category: 'Vehicles',
    difficulty: 'easy',
    acceptedAnswers: <String>['Coach'],
    imageAssetPath: 'assets/app/objects/bus.jpg',
    imageSource: 'https://www.loc.gov/item/2020722343/',
  ),
  OfflineChallenge(
    id: 'object-helicopter',
    prompt: 'An aircraft lifted and propelled by powered rotating blades.',
    answer: 'Helicopter',
    hint: 'It can hover and take off vertically.',
    category: 'Vehicles',
    difficulty: 'hard',
    acceptedAnswers: <String>['Chopper'],

    imageAssetPath: 'assets/app/objects/openimages_helicopter.jpg',
    imageSource: 'https://www.flickr.com/photos/rdecom/8268969055',
  ),
  OfflineChallenge(
    id: 'object-tractor',
    prompt: 'A powerful vehicle used to pull farm equipment.',
    answer: 'Tractor',
    hint: 'It is commonly used in fields.',
    category: 'Vehicles',
    difficulty: 'medium',
    acceptedAnswers: <String>['Farm tractor'],

    imageAssetPath: 'assets/app/objects/openimages_tractor.jpg',
    imageSource: 'https://www.flickr.com/photos/dwilliss/8001783802/',
  ),
  OfflineChallenge(
    id: 'object-compass',
    prompt: 'A navigation instrument that indicates direction.',
    answer: 'Compass',
    hint: 'Its magnetized needle points approximately north.',
    category: 'School & Office',
    difficulty: 'easy',
    acceptedAnswers: <String>['Magnetic compass'],
  ),
  OfflineChallenge(
    id: 'object-calculator',
    prompt: 'A small device or program used to perform arithmetic.',
    answer: 'Calculator',
    hint: 'It has number keys and a display.',
    category: 'School & Office',
    difficulty: 'easy',
    acceptedAnswers: <String>['Handheld calculator'],

    imageAssetPath: 'assets/app/objects/openimages_calculator.jpg',
    imageSource: 'https://www.flickr.com/photos/horiavarlan/4273218725',
  ),
  OfflineChallenge(
    id: 'object-stethoscope',
    prompt: 'A medical instrument used to listen to sounds inside the body.',
    answer: 'Stethoscope',
    hint: 'It has earpieces connected by tubing to a chest piece.',
    category: 'Medical & Science',
    difficulty: 'expert',
    acceptedAnswers: <String>['Doctor’s stethoscope', 'Doctors stethoscope'],
  ),
];

class _ObjectNameSeed {
  const _ObjectNameSeed(
    this.id,
    this.name,
    this.category,
    this.usedFor,
    this.hint,
    this.difficulty,
    this.aliases, {
    this.imageAssetPath,
    this.imageSource,
  });

  final String id;
  final String name;
  final String category;
  final String usedFor;
  final String hint;
  final String difficulty;
  final List<String> aliases;
  final String? imageAssetPath;
  final String? imageSource;
}

const _everydayObjectNameSeeds = <_ObjectNameSeed>[
  _ObjectNameSeed(
    'object-table',
    'Table',
    'Household',
    'A raised surface supported by legs, used for eating, working or placing items.',
    'It is often surrounded by chairs at mealtimes.',
    'easy',
    ['Dining table'],
    imageAssetPath: 'assets/app/objects/openimages_table.jpg',
    imageSource: 'https://www.flickr.com/photos/pollarduk/15063590348',
  ),
  _ObjectNameSeed(
    'object-dining-chair',
    'Dining chair',
    'Household',
    'A single-person seat designed for use at a table.',
    'It usually has a back and four legs.',
    'easy',
    ['Chair'],

    imageAssetPath: 'assets/app/objects/openimages_dining_chair.jpg',
    imageSource: 'https://www.flickr.com/photos/andybutkaj/402173682',
  ),
  _ObjectNameSeed(
    'object-cupboard',
    'Cupboard',
    'Household',
    'A cabinet with doors used to store household items.',
    'Kitchen dishes are often kept inside one.',
    'easy',
    ['Cabinet'],

    imageAssetPath: 'assets/app/objects/openimages_cupboard.jpg',
    imageSource: 'http://www.flickr.com/91087519@N00/181472989/',
  ),
  _ObjectNameSeed(
    'object-wardrobe',
    'Wardrobe',
    'Household',
    'A tall cabinet used to store clothes, often on hangers.',
    'It may have shelves and a hanging rail.',
    'easy',
    ['Clothes closet'],

    imageAssetPath: 'assets/app/objects/openimages_wardrobe.jpg',
    imageSource: 'https://www.flickr.com/photos/ufv/8631917839',
  ),
  _ObjectNameSeed(
    'object-mirror',
    'Mirror',
    'Household',
    'A reflective surface used to view an image of oneself or nearby objects.',
    'It reflects light to form an image.',
    'easy',
    ['Looking glass'],
  ),
  _ObjectNameSeed(
    'object-pillow',
    'Pillow',
    'Household',
    'A soft cushion placed under the head while resting or sleeping.',
    'It is usually covered with a pillowcase.',
    'easy',
    ['Head pillow'],

    imageAssetPath: 'assets/app/objects/openimages_pillow.jpg',
    imageSource: 'https://www.flickr.com/photos/13777424@N04/5573730601',
  ),
  _ObjectNameSeed(
    'object-blanket',
    'Blanket',
    'Household',
    'A large fabric covering used for warmth while resting or sleeping.',
    'It is spread over a bed or around a person.',
    'easy',
    ['Bed blanket'],
  ),
  _ObjectNameSeed(
    'object-desk-lamp',
    'Desk lamp',
    'Household',
    'A small electric lamp that directs light onto a desk or work surface.',
    'Many have an adjustable arm.',
    'easy',
    ['Table lamp'],
    imageAssetPath: 'assets/app/objects/desk_lamp.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:A_3M_Desk_Lamp.jpg',
  ),
  _ObjectNameSeed(
    'object-ceiling-fan',
    'Ceiling fan',
    'Household',
    'A powered fan fixed to a ceiling to circulate air in a room.',
    'Its blades rotate overhead.',
    'medium',
    ['Overhead fan'],
    imageAssetPath: 'assets/app/objects/ceiling_fan.JPG',
    imageSource: 'https://commons.wikimedia.org/wiki/File:01_Rotating_Ceiling_fan_at_640th_of_a_second.JPG',
  ),
  _ObjectNameSeed(
    'object-alarm-clock',
    'Alarm clock',
    'Household',
    'A clock that makes a sound or signal at a set time.',
    'People set it to wake up.',
    'easy',
    ['Wake-up clock'],
    imageAssetPath: 'assets/app/objects/alarm_clock.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Classic_alarm_clock_20180513.jpg',
  ),
  _ObjectNameSeed(
    'object-saucepan',
    'Saucepan',
    'Kitchen',
    'A deep cooking pan with a long handle, used to heat or simmer food.',
    'It is commonly used for sauces and small portions.',
    'easy',
    ['Small cooking pot'],
    imageAssetPath: 'assets/app/objects/saucepan.jpg',
    imageSource:
        'https://commons.wikimedia.org/wiki/File:Hahn_16cm_Saucepan.jpg',
  ),
  _ObjectNameSeed(
    'object-frying-pan',
    'Frying pan',
    'Kitchen',
    'A shallow pan used to fry or sauté food on a stove.',
    'It usually has a long handle.',
    'easy',
    ['Skillet'],
    imageAssetPath: 'assets/app/objects/frying_pan.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Out_of_the_Frying_Pan_-_Flickr_-_docoverachiever.jpg',
  ),
  _ObjectNameSeed(
    'object-cooking-pot',
    'Cooking pot',
    'Kitchen',
    'A deep vessel used to boil, stew or cook food.',
    'It usually has two short side handles.',
    'easy',
    ['Pot'],
    imageAssetPath: 'assets/app/objects/cooking_pot.jpg',
    imageSource:
        'https://commons.wikimedia.org/wiki/File:A_local_cooking_pot.jpg',
  ),
  _ObjectNameSeed(
    'object-dinner-plate',
    'Dinner plate',
    'Kitchen',
    'A flat dish used to serve a portion of food.',
    'It is larger than a saucer.',
    'easy',
    ['Plate'],
    imageAssetPath: 'assets/app/objects/dinner_plate.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:1965_-_Dinner_Plate_-_Shankweilers_-_Allentown_PA.jpg',
  ),
  _ObjectNameSeed(
    'object-bowl',
    'Bowl',
    'Kitchen',
    'A round, deep dish used to hold or serve food and liquids.',
    'Soup is commonly served in one.',
    'easy',
    ['Serving bowl'],

    imageAssetPath: 'assets/app/objects/openimages_bowl.jpg',
    imageSource: 'https://www.flickr.com/photos/norisa/16863771543',
  ),
  _ObjectNameSeed(
    'object-spoon',
    'Spoon',
    'Kitchen',
    'A utensil with a small bowl-shaped end used to eat, stir or serve food.',
    'It is useful for soup and porridge.',
    'easy',
    ['Eating spoon'],

    imageAssetPath: 'assets/app/objects/openimages_spoon.jpg',
    imageSource: 'https://www.flickr.com/photos/mauroescritor/13096150384',
  ),
  _ObjectNameSeed(
    'object-fork',
    'Fork',
    'Kitchen',
    'A utensil with prongs used to hold or lift food.',
    'It is often used together with a knife.',
    'easy',
    ['Eating fork'],

    imageAssetPath: 'assets/app/objects/openimages_fork.jpg',
    imageSource: 'https://www.flickr.com/photos/dindut/3746804404',
  ),
  _ObjectNameSeed(
    'object-kitchen-knife',
    'Kitchen knife',
    'Kitchen',
    'A sharp-edged utensil used to cut or prepare food.',
    'It should be handled carefully and stored safely.',
    'medium',
    ['Cooking knife'],

    imageAssetPath: 'assets/app/objects/openimages_kitchen_knife.jpg',
    imageSource: 'https://www.flickr.com/photos/capcase/4969434689',
  ),
  _ObjectNameSeed(
    'object-chopping-board',
    'Chopping board',
    'Kitchen',
    'A firm board that protects a worktop while food is cut.',
    'Food is placed on it before a knife is used.',
    'easy',
    ['Cutting board'],
  ),
  _ObjectNameSeed(
    'object-whisk',
    'Whisk',
    'Kitchen',
    'A kitchen tool used to beat or blend ingredients by hand.',
    'Its looped wires add air to eggs or cream.',
    'medium',
    ['Hand whisk'],
  ),
  _ObjectNameSeed(
    'object-grater',
    'Grater',
    'Kitchen',
    'A tool with sharp-edged holes used to shred food into smaller pieces.',
    'It is often used on cheese or vegetables.',
    'medium',
    ['Cheese grater'],
  ),
  _ObjectNameSeed(
    'object-microwave-oven',
    'Microwave oven',
    'Kitchen',
    'An electric appliance that heats or cooks food using microwave energy.',
    'Food is placed in its enclosed chamber.',
    'easy',
    ['Microwave'],
    imageAssetPath: 'assets/app/objects/microwave_oven.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:AKIRA_Microwave_Oven_in_Singapore_HDB.jpg',
  ),
  _ObjectNameSeed(
    'object-refrigerator',
    'Refrigerator',
    'Kitchen',
    'An appliance that keeps food cool to slow spoilage.',
    'It has insulated shelves and a chilled interior.',
    'easy',
    ['Fridge'],

    imageAssetPath: 'assets/app/objects/openimages_refrigerator.jpg',
    imageSource: 'https://www.flickr.com/photos/wwworks/9233825265',
  ),
  _ObjectNameSeed(
    'object-washing-machine',
    'Washing machine',
    'Household',
    'An appliance that washes clothes with water and detergent.',
    'A drum rotates during its wash cycle.',
    'easy',
    ['Clothes washer'],

    imageAssetPath: 'assets/app/objects/openimages_washing_machine.jpg',
    imageSource: 'https://www.flickr.com/photos/jwalsh_/2547917821',
  ),
  _ObjectNameSeed(
    'object-mobile-phone',
    'Mobile phone',
    'Electronics',
    'A portable device used for calls, messages and other digital tasks.',
    'It connects to cellular networks.',
    'easy',
    ['Cellphone', 'Mobile telephone'],

    imageAssetPath: 'assets/app/objects/openimages_mobile_phone.jpg',
    imageSource: 'https://www.flickr.com/photos/edans/8430496082',
  ),
  _ObjectNameSeed(
    'object-tablet-computer',
    'Tablet computer',
    'Electronics',
    'A portable touchscreen computer larger than a typical phone.',
    'It is usually operated directly with fingers.',
    'easy',
    ['Tablet'],

    imageAssetPath: 'assets/app/objects/openimages_tablet_computer.jpg',
    imageSource: 'https://www.flickr.com/photos/mac_ivan/4679802421',
  ),
  _ObjectNameSeed(
    'object-headphones',
    'Headphones',
    'Electronics',
    'A pair of speakers worn over or in the ears for private listening.',
    'They connect by cable or wirelessly.',
    'easy',
    ['Earphones'],
    imageAssetPath: 'assets/app/objects/headphones.JPG',
    imageSource: 'https://commons.wikimedia.org/wiki/File:AKG_Stereo_headphones_K-66.JPG',
  ),
  _ObjectNameSeed(
    'object-television',
    'Television',
    'Electronics',
    'An electronic display that receives or plays video and sound.',
    'It is commonly controlled from across the room.',
    'easy',
    ['TV'],
    imageAssetPath: 'assets/app/objects/television.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:1940s_DuMont_television_set_in_Early_Television_Museum.jpg',
  ),
  _ObjectNameSeed(
    'object-computer-mouse',
    'Computer mouse',
    'Electronics',
    'A hand-held input device used to move a pointer and select items on a computer.',
    'It often has buttons and a scroll wheel.',
    'easy',
    ['Mouse'],

    imageAssetPath: 'assets/app/objects/openimages_computer_mouse.jpg',
    imageSource: 'https://www.flickr.com/photos/fuzzcat/8291741616',
  ),
  _ObjectNameSeed(
    'object-computer-monitor',
    'Computer monitor',
    'Electronics',
    'A screen that displays images and information from a computer.',
    'It is separate from a laptop’s built-in display.',
    'easy',
    ['Display screen'],

    imageAssetPath: 'assets/app/objects/openimages_computer_monitor.jpg',
    imageSource: 'https://www.flickr.com/photos/lllnorikolll-300er/15502140378',
  ),
  _ObjectNameSeed(
    'object-remote-control',
    'Remote control',
    'Electronics',
    'A hand-held device that operates another device from a distance.',
    'It commonly sends commands using infrared light.',
    'easy',
    ['Remote'],
    imageAssetPath: 'assets/app/objects/tv_remote.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:AverMedia_RM-RH_Remote_control_(white_background)_edit.jpg',
  ),
  _ObjectNameSeed(
    'object-loudspeaker',
    'Loudspeaker',
    'Electronics',
    'A device that converts an audio signal into audible sound.',
    'It may be built into a radio or used separately.',
    'medium',
    ['Speaker'],

    imageAssetPath: 'assets/app/objects/openimages_loudspeaker.jpg',
    imageSource: 'https://www.flickr.com/photos/robertnelson/2435879529',
  ),
  _ObjectNameSeed(
    'object-power-bank',
    'Power bank',
    'Electronics',
    'A portable rechargeable battery used to charge other devices.',
    'It can charge a phone away from a wall socket.',
    'easy',
    ['Portable charger'],
  ),
  _ObjectNameSeed(
    'object-usb-flash-drive',
    'USB flash drive',
    'Electronics',
    'A small removable device used to store and transfer digital files.',
    'It plugs into a computer’s USB port.',
    'medium',
    ['Flash drive', 'Memory stick'],
  ),
  _ObjectNameSeed(
    'object-screwdriver',
    'Screwdriver',
    'Tools',
    'A hand tool used to turn screws with a matching tip.',
    'Common tips are flat and cross-shaped.',
    'easy',
    ['Driver'],

    imageAssetPath: 'assets/app/objects/openimages_screwdriver.jpg',
    imageSource: 'https://www.flickr.com/photos/mauroescritor/8271389606',
  ),
  _ObjectNameSeed(
    'object-handsaw',
    'Handsaw',
    'Tools',
    'A manually operated tool with a toothed blade used to cut material, often wood.',
    'It is moved back and forth by hand.',
    'medium',
    ['Hand saw'],
  ),
  _ObjectNameSeed(
    'object-tape-measure',
    'Tape measure',
    'Tools',
    'A flexible marked strip used to measure lengths or distances.',
    'The strip retracts into a small case.',
    'easy',
    ['Measuring tape'],
  ),
  _ObjectNameSeed(
    'object-ladder',
    'Ladder',
    'Tools',
    'A portable frame with steps or rungs used to climb to a higher place.',
    'It must be set on stable ground before climbing.',
    'easy',
    ['Step ladder'],

    imageAssetPath: 'assets/app/objects/openimages_ladder.jpg',
    imageSource: 'https://www.flickr.com/photos/94474582@N00/4032405238',
  ),
  _ObjectNameSeed(
    'object-axe',
    'Axe',
    'Tools',
    'A hand tool with a heavy bladed head used to split or cut wood.',
    'Its head is fixed to a long handle.',
    'medium',
    ['Hatchet'],
  ),
  _ObjectNameSeed(
    'object-shovel',
    'Shovel',
    'Outdoor & Nature',
    'A tool with a broad blade used to lift and move loose material such as soil.',
    'It is commonly used for digging or gardening.',
    'easy',
    ['Spade'],
  ),
  _ObjectNameSeed(
    'object-rake',
    'Rake',
    'Outdoor & Nature',
    'A long-handled tool used to gather leaves or loosen soil.',
    'Its head has a row of teeth.',
    'easy',
    ['Garden rake'],
  ),
  _ObjectNameSeed(
    'object-padlock',
    'Padlock',
    'Household',
    'A portable lock used to secure a gate, locker or container.',
    'A removable U-shaped shackle opens with a key or combination.',
    'medium',
    ['Combination lock'],

    imageAssetPath: 'assets/app/objects/openimages_padlock.jpg',
    imageSource: 'https://www.flickr.com/photos/wheatfields/2497773762',
  ),
  _ObjectNameSeed(
    'object-flashlight',
    'Flashlight',
    'Electronics',
    'A portable battery-powered light used to see in dark places.',
    'It sends a focused beam from one end.',
    'easy',
    ['Torch'],

    imageAssetPath: 'assets/app/objects/openimages_flashlight.jpg',
    imageSource: 'https://www.flickr.com/photos/cezaryborysiuk/4497211501',
  ),
  _ObjectNameSeed(
    'object-car',
    'Car',
    'Vehicles',
    'A road vehicle with an engine and seats for a small number of people.',
    'It is steered with a wheel and usually has four wheels.',
    'easy',
    ['Automobile'],
    imageAssetPath: 'assets/app/objects/car.jpg',
    imageSource: 'https://www.loc.gov/item/2018702362/',
  ),
  _ObjectNameSeed(
    'object-train',
    'Train',
    'Vehicles',
    'A series of connected rail vehicles pulled or pushed along a track.',
    'It carries passengers or freight between stations.',
    'easy',
    ['Railway train'],

    imageAssetPath: 'assets/app/objects/openimages_train.jpg',
    imageSource: 'https://www.flickr.com/photos/swampa/8767423640',
  ),
  _ObjectNameSeed(
    'object-boat',
    'Boat',
    'Vehicles',
    'A watercraft designed to float and travel on water.',
    'It may be moved by an engine, sail or oars.',
    'easy',
    ['Watercraft'],

    imageAssetPath: 'assets/app/objects/openimages_boat.jpg',
    imageSource: 'https://www.flickr.com/photos/jocke66/13011324264',
  ),
  _ObjectNameSeed(
    'object-airplane',
    'Airplane',
    'Vehicles',
    'A powered aircraft with fixed wings that carries people or cargo.',
    'It takes off and lands at an airport.',
    'easy',
    ['Aeroplane', 'Plane'],

    imageAssetPath: 'assets/app/objects/openimages_airplane.jpg',
    imageSource: 'https://www.flickr.com/photos/raver_mikey/6033521295',
  ),
  _ObjectNameSeed(
    'object-tuk-tuk',
    'Tuk-tuk',
    'Vehicles',
    'A small motorized three-wheeled vehicle used for local passenger transport.',
    'It is common in many East African towns.',
    'medium',
    ['Auto rickshaw', 'Three-wheeler'],
    imageAssetPath: 'assets/app/objects/tuk_tuk.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:(THA-Bangkok)_Tuk-tuk_%E0%B8%AA%E0%B8%815099_2024-02-10.jpg',
  ),
  _ObjectNameSeed(
    'object-exercise-book',
    'Exercise book',
    'School & Office',
    'A bound book of blank or lined pages used for schoolwork and notes.',
    'Students write lessons and answers in it.',
    'easy',
    ['Notebook'],
  ),
  _ObjectNameSeed(
    'object-ballpoint-pen',
    'Ballpoint pen',
    'School & Office',
    'A writing instrument that uses a small rotating ball to transfer ink to paper.',
    'Its ink cartridge ends in a tiny ball.',
    'easy',
    ['Pen'],
    imageAssetPath: 'assets/app/objects/ballpoint_pen.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:A_ballpoint_pen_in_Vietnam_(cropped).jpg',
  ),
  _ObjectNameSeed(
    'object-pencil',
    'Pencil',
    'School & Office',
    'A writing and drawing tool with a graphite core inside a casing.',
    'Its marks can usually be erased.',
    'easy',
    ['Graphite pencil'],

    imageAssetPath: 'assets/app/objects/openimages_pencil.jpg',
    imageSource: 'https://www.flickr.com/photos/paultomlin/2209499274',
  ),
  _ObjectNameSeed(
    'object-eraser',
    'Eraser',
    'School & Office',
    'A soft tool used to remove pencil marks from paper.',
    'It is sometimes attached to the end of a pencil.',
    'easy',
    ['Rubber'],
  ),
  _ObjectNameSeed(
    'object-ruler',
    'Ruler',
    'School & Office',
    'A straight marked tool used to measure short lengths and draw lines.',
    'It often has centimetre markings.',
    'easy',
    ['Straightedge'],

    imageAssetPath: 'assets/app/objects/openimages_ruler.jpg',
    imageSource:
        'https://www.flickr.com/photos/photographingtravis/20794905512',
  ),
  _ObjectNameSeed(
    'object-stapler',
    'Stapler',
    'School & Office',
    'A hand-operated device that fastens sheets of paper with a metal staple.',
    'Pressing its top drives a small metal fastener through paper.',
    'medium',
    ['Paper stapler'],
    imageAssetPath: 'assets/app/objects/stapler.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:A_KOKUYO_Stapler.jpg',
  ),
  _ObjectNameSeed(
    'object-scissors',
    'Scissors',
    'School & Office',
    'A hand tool with two pivoting blades used to cut paper, fabric or other material.',
    'It has two finger loops.',
    'easy',
    ['Shears'],
    imageAssetPath: 'assets/app/objects/scissors.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Crossed_scissors.jpg',
  ),
  _ObjectNameSeed(
    'object-first-aid-kit',
    'First aid kit',
    'Medical & Science',
    'A container holding basic supplies for treating minor injuries.',
    'It may contain dressings, gloves and antiseptic.',
    'easy',
    ['First-aid box'],
  ),
  _ObjectNameSeed(
    'object-bandage',
    'Bandage',
    'Medical & Science',
    'A strip or dressing used to cover or support an injured part of the body.',
    'It can help protect a wound or hold a dressing in place.',
    'easy',
    ['Dressing'],
    imageAssetPath: 'assets/app/objects/bandage.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:(US)_1_BANDAGE,_GAUZE,_COMPRESSED,_2001.201.jpg',
  ),
  _ObjectNameSeed(
    'object-wheelchair',
    'Wheelchair',
    'Medical & Science',
    'A wheeled chair that helps a person with limited mobility move around.',
    'It may be pushed by another person or propelled by its user.',
    'medium',
    ['Mobility chair'],

    imageAssetPath: 'assets/app/objects/openimages_wheelchair.jpg',
    imageSource: 'https://www.flickr.com/photos/departmentofed/11971488336/',
  ),
  _ObjectNameSeed(
    'object-eyeglasses',
    'Eyeglasses',
    'Clothing',
    'A frame with lenses worn in front of the eyes to correct or support vision.',
    'They rest on the nose and ears.',
    'easy',
    ['Glasses', 'Spectacles'],

    imageAssetPath: 'assets/app/objects/openimages_eyeglasses.jpg',
    imageSource: 'https://www.flickr.com/photos/sunatomohisa/6822954238',
  ),
  _ObjectNameSeed(
    'object-basketball',
    'Basketball',
    'Sports',
    'A ball used in a team sport where players score by throwing it through a raised hoop.',
    'It is larger than a handball and usually orange.',
    'easy',
    ['Basket ball'],
  ),
  _ObjectNameSeed(
    'object-volleyball',
    'Volleyball',
    'Sports',
    'A light ball hit over a net in an indoor or beach team sport.',
    'Players usually strike it with their hands or arms.',
    'easy',
    ['Volley ball'],
  ),
  _ObjectNameSeed(
    'object-tennis-racket',
    'Tennis racket',
    'Sports',
    'A handled frame with strings used to strike a tennis ball.',
    'Players use it on a court divided by a net.',
    'easy',
    ['Racquet'],

    imageAssetPath: 'assets/app/objects/openimages_tennis_racket.jpg',
    imageSource: 'https://www.flickr.com/photos/endlisnis/383317181',
  ),
  _ObjectNameSeed(
    'object-dumbbell',
    'Dumbbell',
    'Sports',
    'A short-handled weight lifted in one hand during exercise.',
    'A pair is often used for strength training.',
    'easy',
    ['Hand weight'],
    imageAssetPath: 'assets/app/objects/openimages_dumbbell.jpg',
    imageSource: 'https://www.flickr.com/photos/pistolsdrawn/2450912715',
  ),
  _ObjectNameSeed(
    'object-sports-whistle',
    'Whistle',
    'Sports',
    'A small device that makes a sharp sound when air passes through it.',
    'A referee may use it to stop a game.',
    'easy',
    ['Referee whistle'],
  ),
  _ObjectNameSeed(
    'object-shirt',
    'Shirt',
    'Clothing',
    'An upper-body garment that covers the torso and may have sleeves and a collar.',
    'It is commonly worn with trousers or a skirt.',
    'easy',
    ['Top'],

    imageAssetPath: 'assets/app/objects/openimages_shirt.jpg',
    imageSource: 'https://www.flickr.com/photos/adnanbangladesh/7818131664',
  ),
  _ObjectNameSeed(
    'object-shoes',
    'Shoes',
    'Clothing',
    'Footwear worn to protect the feet while walking or working.',
    'They usually come as a left-and-right pair.',
    'easy',
    ['Footwear'],
    imageAssetPath: 'assets/app/objects/shoes.jpg',
    imageSource: 'https://www.loc.gov/item/2016852995/',
  ),
  _ObjectNameSeed(
    'object-jacket',
    'Jacket',
    'Clothing',
    'A short outer garment worn over other clothes for warmth or protection.',
    'It usually opens at the front.',
    'easy',
    ['Coat'],

    imageAssetPath: 'assets/app/objects/openimages_jacket.jpg',
    imageSource: 'https://www.flickr.com/photos/joebeone/7316300986',
  ),
  _ObjectNameSeed(
    'object-belt',
    'Belt',
    'Clothing',
    'A narrow strap worn around the waist to hold up clothing or secure an outfit.',
    'It fastens with a buckle.',
    'easy',
    ['Waist belt'],

    imageAssetPath: 'assets/app/objects/openimages_belt.jpg',
    imageSource: 'https://www.flickr.com/photos/tynigh/5858109241',
  ),
  _ObjectNameSeed(
    'object-safety-helmet',
    'Safety helmet',
    'Clothing',
    'Protective headgear designed to reduce injury from impacts or falling objects.',
    'Construction workers and cyclists wear different types.',
    'medium',
    ['Hard hat', 'Helmet'],

    imageAssetPath: 'assets/app/objects/openimages_safety_helmet.jpg',
    imageSource: 'https://www.flickr.com/photos/moto_club4ag/16396206548',
  ),
  _ObjectNameSeed(
    'object-banana',
    'Banana',
    'Food & Fruits',
    'An elongated edible fruit that grows in clusters on a tropical plant.',
    'Its yellow peel is removed before eating.',
    'easy',
    ['Plantain'],
    imageAssetPath: 'assets/app/objects/banana.jpg',
    imageSource: 'https://commons.wikimedia.org/wiki/File:Banana_Fruit.JPG',
  ),
  _ObjectNameSeed(
    'object-apple',
    'Apple',
    'Food & Fruits',
    'A crisp fruit that is commonly eaten fresh or used in cooking.',
    'It grows on a tree and can be green, yellow, or red.',
    'easy',
    ['Cooking apple'],
    imageAssetPath: 'assets/app/objects/openimages_apple.jpg',
    imageSource: 'https://www.flickr.com/photos/zillay/6633779563',
  ),
  _ObjectNameSeed(
    'object-candle',
    'Candle',
    'Household',
    'A wax or similar cylinder that gives light as its wick burns.',
    'It is lit with a match or lighter and becomes shorter as it burns.',
    'easy',
    ['Wax candle'],
    imageAssetPath: 'assets/app/objects/openimages_candle.jpg',
    imageSource: 'https://www.flickr.com/photos/tico24/50306207',
  ),
  _ObjectNameSeed(
    'object-light-bulb',
    'Light bulb',
    'Household',
    'An electric device that produces light when connected to a power source.',
    'It fits into a lamp or ceiling fixture.',
    'easy',
    ['Bulb', 'Lamp bulb'],
    imageAssetPath: 'assets/app/objects/openimages_light_bulb.jpg',
    imageSource: 'https://www.flickr.com/photos/topbulb/14443120689',
  ),
  _ObjectNameSeed(
    'object-suitcase',
    'Suitcase',
    'Travel',
    'A portable case used to carry clothes and belongings while travelling.',
    'It usually has a handle and may have wheels.',
    'easy',
    ['Travel case', 'Luggage'],
    imageAssetPath: 'assets/app/objects/openimages_suitcase.jpg',
    imageSource: 'https://www.flickr.com/photos/tomandemma/3957263843',
  ),
  _ObjectNameSeed(
    'object-sunglasses',
    'Sunglasses',
    'Clothing',
    'Eyewear with tinted lenses that reduce bright sunlight reaching the eyes.',
    'People often wear them outdoors on bright days.',
    'easy',
    ['Shades', 'Sun glasses'],
    imageAssetPath: 'assets/app/objects/openimages_sunglasses.jpg',
    imageSource: 'https://www.flickr.com/photos/dennis/5569306918',
  ),
  _ObjectNameSeed(
    'object-door',
    'Door',
    'Household',
    'A hinged or sliding panel that opens or closes an entrance.',
    'It separates rooms or controls entry into a building.',
    'easy',
    ['Entry door'],
    imageAssetPath: 'assets/app/objects/openimages_door.jpg',
    imageSource: 'https://www.flickr.com/photos/pauljill/16233082679',
  ),
  _ObjectNameSeed(
    'object-coin',
    'Coin',
    'Money & Daily Life',
    'A small, flat piece of metal used as money.',
    'It often has a different design on each side.',
    'easy',
    ['Metal coin'],
    imageAssetPath: 'assets/app/objects/openimages_coin.jpg',
    imageSource: 'https://www.flickr.com/photos/markmorgantrinidad/7969406032',
  ),
  _ObjectNameSeed(
    'object-watermelon',
    'Watermelon',
    'Food & Fruits',
    'A large, juicy fruit with a green rind and usually red flesh.',
    'It is often cut into wedges and eaten cold.',
    'easy',
    ['Melon'],
    imageAssetPath: 'assets/app/objects/openimages_watermelon.jpg',
    imageSource: 'https://www.flickr.com/photos/purpleslog/3008648157',
  ),
];

final objectChallengeCatalog = <OfflineChallenge>[
  ..._bundledObjectChallengeRecords,
  for (final seed in _everydayObjectNameSeeds)
    OfflineChallenge(
      id: seed.id,
      prompt: seed.usedFor,
      answer: seed.name,
      hint: seed.hint,
      category: seed.category,
      difficulty: seed.difficulty,
      acceptedAnswers: seed.aliases,
      imageAssetPath: seed.imageAssetPath,
      imageSource: seed.imageSource,
    ),
];

List<OfflineChallenge> challengesForModule(
  String moduleId, {
  SessionConfiguration? configuration,
}) {
  final content = switch (moduleId) {
    'quiz' => quizChallenges,
    'word_play' => wordChallenges,
    'guess_character' => characterChallenges,
    'guess_objects' => objectChallengeCatalog,
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
  List<OfflineChallenge>? objectChallenges,
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
              .toList(growable: false),
  'guess_character' => characterChallenges,
  'guess_country_flags' => challengesForModule(
    'guess_country_flags',
    configuration: configuration,
  ),
  'guess_objects' => _objectChallengesForFormat(
    formatId,
    configuration,
    objectChallenges ?? objectChallengeCatalog,
  ),
  _ => const <OfflineChallenge>[],
};

List<OfflineChallenge> _objectChallengesForFormat(
  String formatId,
  SessionConfiguration? configuration,
  List<OfflineChallenge> challenges,
) {
  final hasPictureRound =
      configuration?.effectiveRoundFormatIds.contains('object_picture') ??
      false;
  return challenges
      .where((challenge) {
        final hasImage =
            challenge.imageFilePath != null || challenge.imageAssetPath != null;
        if (formatId == 'object_picture') {
          return hasImage &&
              (configuration == null ||
                  configuration.characterPictureCategory == 'All Categories' ||
                  challenge.category == configuration.characterPictureCategory);
        }
        if (formatId == 'object_name' && hasPictureRound) return !hasImage;
        return true;
      })
      .toList(growable: false);
}

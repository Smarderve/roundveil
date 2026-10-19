import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/domain/session/session_configuration.dart';
import 'package:roundveil/features/active_match/application/active_match_content.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('object catalog has distinct, described identities and aliases', () {
    expect(objectChallengeCatalog.length, 157);
    expect(
      objectChallengeCatalog.map((item) => item.id).toSet(),
      hasLength(objectChallengeCatalog.length),
    );
    expect(
      objectChallengeCatalog.map((item) => item.answer.toLowerCase()).toSet(),
      hasLength(objectChallengeCatalog.length),
    );
    for (final item in objectChallengeCatalog) {
      expect(item.prompt, isNotEmpty, reason: item.id);
      expect(item.hint, isNotEmpty, reason: item.id);
      expect(item.category, isNotEmpty, reason: item.id);
      expect(
        <String>{'easy', 'medium', 'hard', 'expert'},
        contains(item.difficulty),
        reason: item.id,
      );
    }
    expect(
      objectChallengeCatalog.map((item) => item.difficulty).toSet(),
      containsAll(<String>{'easy', 'medium', 'hard', 'expert'}),
    );
    expect(objectChallengeCatalog.first.acceptedAnswers, <String>[
      'Drill',
      'Power drill',
    ]);
  });

  test('Object Picture only includes its manifest-backed offline records', () {
    final pictureChallenges = challengesForFormat('object_picture');
    expect(pictureChallenges, hasLength(137));
    expect(
      pictureChallenges.every(
        (item) => item.imageAssetPath != null || item.imageFilePath != null,
      ),
      isTrue,
    );
    expect(challengesForFormat('object_name'), hasLength(157));
  });

  test('Object Picture category selection never substitutes other items', () {
    final kitchen = SessionConfiguration(
      players: const <PlayerConfiguration>[
        PlayerConfiguration(id: 'p1', displayName: 'Player 1'),
      ],
      selectedModuleIds: const <String>['guess_objects'],
      roundFormatIds: const <String>['object_picture'],
      roundFormatsExplicit: true,
      roundCount: 1,
      characterPictureCategory: 'Kitchen',
    );
    final selected = challengesForFormat(
      'object_picture',
      configuration: kitchen,
    );

    expect(selected.map((item) => item.id), <String>[
      'object-kettle',
      'object-blender',
      'object-spatula',
      'object-toaster',
      'object-saucepan',
      'object-frying-pan',
      'object-cooking-pot',
      'object-dinner-plate',
      'object-bowl',
      'object-spoon',
      'object-fork',
      'object-kitchen-knife',
      'object-microwave-oven',
      'object-refrigerator',
      'object-espresso-machine',
      'object-wok',
      'object-drinking-glass',
      'object-saucer',
      'object-teapot',
      'object-takeaway-cup',
    ]);
    expect(
      challengesForFormat(
        'object_picture',
        configuration: kitchen.copyWith(characterPictureCategory: 'Vehicles'),
      ).map((item) => item.id),
      <String>[
        'object-bicycle',
        'object-motorcycle',
        'object-bus',
        'object-helicopter',
        'object-tractor',
        'object-car',
        'object-train',
        'object-boat',
        'object-airplane',
        'object-tuk-tuk',
      ],
    );
  });

  test('character picture availability reports only approved renderable media without seeding files', () async {
    final temp = await Directory.systemTemp.createTemp('roundveil-summary-');
    addTearDown(() => temp.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temp,
    );

    final summary = await repository.loadPlayableSummary();

    expect(summary, hasLength(44));
    expect(summary.every((item) => item.collection == 'bundled'), isTrue);
    final chineseActors = summary
        .where((item) => item.category == 'Chinese Actors')
        .toList();
    expect(chineseActors, hasLength(5));
    expect(
      chineseActors.map((item) => item.name).toSet(),
      containsAll(<String>{
        'Jackie Chan',
        'Jet Li',
        'Donnie Yen',
        'Chow Yun-fat',
        'Bruce Lee',
      }),
    );
    for (final item in chineseActors) {
      expect(item.sourceUrl, startsWith('https://commons.wikimedia.org/'));
      expect(
        item.license.contains('CC BY') ||
            item.license.toLowerCase().contains('public domain'),
        isTrue,
        reason: item.name,
      );
      final data = await rootBundle.load(item.path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThanOrEqualTo(500), reason: item.name);
      expect(frame.image.height, greaterThanOrEqualTo(500), reason: item.name);
      codec.dispose();
      frame.image.dispose();
    }
    expect(
      Directory(
        '${temp.path}${Platform.pathSeparator}character_picture_library',
      ).listSync().whereType<File>().where(
        (file) =>
            file.path.toLowerCase().endsWith('.png') ||
            file.path.toLowerCase().endsWith('.jpg'),
      ),
      isEmpty,
      reason: 'Opening the mode picker must not copy the bundled images.',
    );
  });

  test(
    'every bundled object picture decodes and is represented in credits',
    () async {
      final manifest = jsonDecode(
        (await rootBundle.loadString('assets/app/objects/manifest.json')),
      ) as Map<String, dynamic>;
      final records = manifest['items'] as List<dynamic>;
      expect(records, hasLength(137));
      final manifestRecords = records.cast<Map<String, dynamic>>();
      final creditedIds = manifestRecords.map((record) => record['id']).toSet();
      final openImagesRecords = manifestRecords
          .where((record) => record['dataset'] == 'Open Images validation')
          .toList();
      expect(openImagesRecords, hasLength(106));
      expect(
        openImagesRecords.map((record) => record['datasetImageId']).toSet(),
        hasLength(106),
      );
      expect(
        openImagesRecords.map((record) => record['sha256']).toSet(),
        hasLength(106),
      );
      for (final record in openImagesRecords) {
        expect(record['license'], 'CC BY 2.0', reason: record['id'] as String);
        expect(
          record['source'],
          startsWith('http'),
          reason: record['id'] as String,
        );
        expect(record['creator'], isNotEmpty, reason: record['id'] as String);
      }
      final imageChallenges = objectChallengeCatalog.where(
        (challenge) => challenge.imageAssetPath != null,
      );
      expect(
        imageChallenges.map((challenge) => challenge.id).toSet(),
        creditedIds,
      );

      for (final challenge in imageChallenges) {
        expect(challenge.imageAssetPath, isNotNull, reason: challenge.id);
        final data = await rootBundle.load(challenge.imageAssetPath!);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(500), reason: challenge.id);
        expect(frame.image.height, greaterThan(300), reason: challenge.id);
        codec.dispose();
        frame.image.dispose();
      }
    },
  );
}

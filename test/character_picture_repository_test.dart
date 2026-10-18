import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';

Future<Uint8List> _testPng({
  ui.Color color = const ui.Color(0xFF214A76),
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(color, ui.BlendMode.src);
  final picture = recorder.endRecording();
  final image = await picture.toImage(800, 600);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  return bytes!.buffer.asUint8List();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'local Picture Mode images persist with source notes and deduplicate',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'roundveil-picture-test-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
        includeBundledImages: false,
      );
      final bytes = await _testPng();
      final first = await repository.addImageBytes(
        name: 'Family supplied subject',
        hint: 'A clue kept with this imported image.',
        extension: 'png',
        bytes: bytes,
        sourceTitle: 'Family archive',
        sourceUrl: 'local://family-archive',
        license: 'Owner supplied',
      );
      expect(first, isNotNull);
      expect(File(first!.path).existsSync(), isTrue);
      expect((first.width, first.height), (800, 600));

      final recreated = CharacterPictureRepository(
        directoryProvider: () async => temporary,
        includeBundledImages: false,
      );
      final loaded = await recreated.loadAll();
      expect(loaded, hasLength(1));
      expect(loaded.single.sourceTitle, 'Family archive');
      expect(loaded.single.license, 'Owner supplied');
      expect(loaded.single.hint, 'A clue kept with this imported image.');
      expect(loaded.single.collection, 'private');
      expect(await recreated.loadPrivate(), hasLength(1));
      expect(await recreated.loadBundled(), isEmpty);
      expect(
        await recreated.addImageBytes(
          name: 'Duplicate',
          extension: 'png',
          bytes: bytes,
        ),
        isNull,
      );

      await recreated.remove(loaded.single.id);
      expect(await repository.loadAll(), isEmpty);
    },
  );

  test('private deletion persists, removes only managed media, and blocks reimport', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'rv-picture-delete-',
    );
    addTearDown(() => temporary.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temporary,
      includeBundledImages: false,
    );
    final bytes = await _testPng();
    final deleted = await repository.addImageBytes(
      name: 'Test Character',
      category: 'Anime Characters',
      extension: 'png',
      bytes: bytes,
    );
    final kept = await repository.addImageBytes(
      name: 'Unrelated Character',
      category: 'Cartoon Characters',
      extension: 'png',
      bytes: await _testPng(color: const ui.Color(0xFF751A43)),
    );
    expect(deleted, isNotNull);
    expect(kept, isNotNull);
    final managedFile = File(deleted!.path);
    await repository.remove(deleted.id);
    expect(await managedFile.exists(), isFalse);

    final recreated = CharacterPictureRepository(
      directoryProvider: () async => temporary,
      includeBundledImages: false,
    );
    expect((await recreated.loadAll()).map((item) => item.name), [
      'Unrelated Character',
    ]);
    expect(
      await recreated.addImageBytes(
        name: 'Test Character',
        category: 'Anime Characters',
        extension: 'png',
        bytes: bytes,
      ),
      isNull,
    );
    expect((await recreated.loadPlayable()).map((item) => item.name), [
      'Unrelated Character',
    ]);
  });

  test('library reset hides existing private images but preserves files and new imports', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'rv-picture-cosplay-migration-',
    );
    addTearDown(() => temporary.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temporary,
      includeBundledImages: false,
    );
    await repository.loadAll(); // Writes the one-time migration sentinel.
    final legacy = await repository.addImageBytes(
      name: 'Naruto Uzumaki',
      category: 'Anime Characters',
      extension: 'png',
      bytes: await _testPng(),
      sourceTitle: 'Owner-supplied private local image',
    );
    expect(legacy, isNotNull);
    final legacyItem = legacy!;

    final indexFile = File(
      '${temporary.path}${Platform.pathSeparator}character_picture_library${Platform.pathSeparator}index.json',
    );
    final index =
        jsonDecode(await indexFile.readAsString()) as Map<String, Object?>;
    final hiddenIds = (index['hiddenIds']! as List<Object?>).cast<String>();
    final missingRecord = Map<String, Object?>.from(legacyItem.toJson())
      ..['id'] = 'legacy-missing-image'
      ..['name'] = 'Unresolved legacy record'
      ..['path'] = '${temporary.path}${Platform.pathSeparator}missing.png';
    (index['items']! as List<Object?>).add(missingRecord);
    hiddenIds.remove('migration:character-library-reset-20261018');
    index['hiddenIds'] = hiddenIds;
    await indexFile.writeAsString(jsonEncode(index));

    final migrated = await repository.loadAll();
    expect(
      migrated.singleWhere((item) => item.id == legacyItem.id).hidden,
      isTrue,
    );
    final migratedIndex =
        jsonDecode(await indexFile.readAsString()) as Map<String, Object?>;
    expect(
      (migratedIndex['items']! as List<Object?>)
          .whereType<Map<String, Object?>>()
          .any((item) => item['id'] == 'legacy-missing-image'),
      isTrue,
    );
    expect(
      (migratedIndex['hiddenIds']! as List<Object?>).contains(
        'legacy-missing-image',
      ),
      isTrue,
    );
    expect(File(legacyItem.path).existsSync(), isTrue);

    final newlyImported = await repository.addImageBytes(
      name: 'New authentic artwork',
      category: 'Anime Characters',
      extension: 'png',
      bytes: await _testPng(color: const ui.Color(0xFF751A43)),
      sourceTitle: 'Owner-supplied private local image',
    );
    expect(newlyImported, isNotNull);
    final newItem = newlyImported!;
    final afterNewImport = await repository.loadAll();
    expect(
      afterNewImport.singleWhere((item) => item.id == newItem.id).hidden,
      isFalse,
    );
    expect(await repository.loadPlayable(), hasLength(1));

    final restarted = CharacterPictureRepository(
      directoryProvider: () async => temporary,
      includeBundledImages: false,
    );
    expect(
      (await restarted.loadAll())
          .singleWhere((item) => item.id == legacyItem.id)
          .hidden,
      isTrue,
    );
  });

  test(
    'hidden character restores after restart but stays out of playable set',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'rv-picture-hidden-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
        includeBundledImages: false,
      );
      final item = await repository.addImageBytes(
        name: 'Hidden Character',
        extension: 'png',
        bytes: await _testPng(),
      );
      await repository.setHidden(item!.id, hidden: true);
      final recreated = CharacterPictureRepository(
        directoryProvider: () async => temporary,
        includeBundledImages: false,
      );
      expect((await recreated.loadAll()).single.hidden, isTrue);
      expect(await recreated.loadPlayable(), isEmpty);
      await recreated.setHidden(item.id, hidden: false);
      expect(await recreated.loadPlayable(), hasLength(1));
    },
  );

  test('Picture Mode rejects invalid and low-resolution files', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'roundveil-picture-invalid-',
    );
    addTearDown(() => temporary.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temporary,
      includeBundledImages: false,
    );
    expect(
      () => repository.addImageBytes(
        name: 'Not an image',
        extension: 'png',
        bytes: List<int>.filled(1200, 0),
      ),
      throwsFormatException,
    );
  });

  test(
    'reviewed image batches install privately and deduplicate identities',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'rv-bulk-import-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
        includeBundledImages: false,
      );
      final image = await _testPng();
      final candidate = PrivateCharacterImageImport(
        filename: 'Spider-Man.png',
        bytes: image,
        name: 'Spider-Man',
        category: 'Marvel Characters',
        franchise: 'Marvel',
        series: 'Spider-Man',
        aliases: const <String>['Peter Parker'],
        hint: 'Swings between buildings on web-lines.',
        difficulty: 'Easy',
        description: 'Metadata reference retained with local record.',
      );

      final first = await repository.importPrivateImageBatch([candidate]);
      expect(first.imported, 1);
      final installed = (await repository.loadPrivate()).single;
      expect(installed.name, 'Spider-Man');
      expect(installed.category, 'Marvel Characters');
      expect(installed.collection, 'private');
      expect(File(installed.path).existsSync(), isTrue);

      final repeated = await repository.importPrivateImageBatch([candidate]);
      expect(repeated.imported, 0);
      expect(repeated.duplicates, 1);
      expect(await repository.loadPrivate(), hasLength(1));
    },
  );

  test(
    'URL import requires explicit private-use confirmation and HTTPS',
    () async {
      final repository = CharacterPictureRepository(
        includeBundledImages: false,
      );
      await expectLater(
        repository.importPrivateImageUrl(
          uri: Uri.parse('http://images.example.test/spider-man.png'),
          name: 'Spider-Man',
          category: 'Marvel Characters',
          franchise: 'Marvel',
          hint: 'A clue',
          aliases: const <String>[],
          difficulty: 'Easy',
          attribution: '',
          permissionConfirmed: true,
        ),
        throwsFormatException,
      );
      await expectLater(
        repository.importPrivateImageUrl(
          uri: Uri.parse('https://images.example.test/spider-man.png'),
          name: 'Spider-Man',
          category: 'Marvel Characters',
          franchise: 'Marvel',
          hint: 'A clue',
          aliases: const <String>[],
          difficulty: 'Easy',
          attribution: '',
          permissionConfirmed: false,
        ),
        throwsFormatException,
      );
    },
  );

  test(
    'private collection package imports, deduplicates and exports metadata',
    () async {
      final temporary = await Directory.systemTemp.createTemp('rv-package-');
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
        includeBundledImages: false,
      );
      final image = await _testPng();
      final package = Archive()
        ..add(ArchiveFile.bytes('art/hero.png', image))
        ..add(
          ArchiveFile.string(
            'manifest.json',
            '{"schemaVersion":1,"items":[{"id":"hero-one","name":"Hero One","category":"Marvel","imageFilename":"hero.png","aliases":["Hero"],"hint":"A useful clue","subjectType":"Fictional character","franchise":"Example series","description":"A sample description","source":{"title":"Local source","url":"https://example.test/hero","license":"Personal collection","attribution":"Example artist"}}]}',
          ),
        );
      final packageBytes = ZipEncoder().encodeBytes(package);

      final first = await repository.importPackageBytes(packageBytes);
      expect(first.imported, 1);
      expect(first.errors, isEmpty);
      final loaded = (await repository.loadAll()).single;
      expect(loaded.id, 'hero-one');
      expect(loaded.category, 'Marvel');
      expect(loaded.aliases, ['Hero']);
      expect(loaded.sourceTitle, 'Local source');
      expect(loaded.subjectType, 'Fictional character');
      expect(loaded.franchise, 'Example series');
      expect(loaded.description, 'A sample description');
      expect(loaded.attribution, 'Example artist');
      expect(loaded.collection, 'private');

      final repeated = await repository.importPackageBytes(packageBytes);
      expect(repeated.imported, 0);
      expect(repeated.duplicates, 1);
      final exported = await repository.exportPackageBytes();
      final exportArchive = ZipDecoder().decodeBytes(exported);
      final manifest = exportArchive.files
          .singleWhere((entry) => entry.name == 'manifest.json')
          .readBytes()!;
      expect(String.fromCharCodes(manifest), contains('"category": "Marvel"'));
      expect(
        exportArchive.files.where((entry) => entry.name.endsWith('.png')),
        hasLength(1),
      );
    },
  );

  test('collection packages reject traversal paths before importing', () async {
    final temporary = await Directory.systemTemp.createTemp('rv-package-path-');
    addTearDown(() => temporary.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temporary,
      includeBundledImages: false,
    );
    final package = Archive()
      ..add(ArchiveFile.bytes('../outside.png', await _testPng()))
      ..add(
        ArchiveFile.string('manifest.json', '{"schemaVersion":1,"items":[]}'),
      );
    await expectLater(
      repository.importPackageBytes(ZipEncoder().encodeBytes(package)),
      throwsFormatException,
    );
    expect(await repository.loadAll(), isEmpty);
  });

  test('manual package reimport can restore only its selected deletion', () async {
    final temporary = await Directory.systemTemp.createTemp('rv-restore-');
    addTearDown(() => temporary.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temporary,
      includeBundledImages: false,
    );
    final image = await _testPng();
    final package = Archive()
      ..add(ArchiveFile.bytes('hero.png', image))
      ..add(
        ArchiveFile.string(
          'manifest.json',
          '{"schemaVersion":1,"items":[{"id":"restore-hero","name":"Hero","category":"Anime Characters","imageFilename":"hero.png","hint":"A hero","source":{}}]}',
        ),
      );
    final bytes = ZipEncoder().encodeBytes(package);

    expect((await repository.importPackageBytes(bytes)).imported, 1);
    await repository.remove('restore-hero');
    expect(await repository.loadRemovedCount(), 1);

    final declined = await repository.importPackageBytes(bytes);
    expect(declined.imported, 0);
    expect(declined.removed, 1);
    expect(declined.duplicates, 0);
    expect(await repository.loadAll(), isEmpty);
    expect(await repository.loadRemovedCount(), 1);

    final restored = await repository.importPackageBytes(
      bytes,
      restoreRemoved: true,
    );
    expect(restored.imported, 1);
    expect(restored.restored, 1);
    expect(restored.removed, 0);
    expect((await repository.loadAll()).single.name, 'Hero');
    expect(await repository.loadRemovedCount(), 0);
  });

  test('fresh installations seed verified bundled portraits offline', () async {
    final temporary = await Directory.systemTemp.createTemp('rv-builtin-');
    addTearDown(() => temporary.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temporary,
    );

  test(
    'fresh installation keeps rejected bundled portraits out of gameplay',
    () async {
      final temporary = await Directory.systemTemp.createTemp('rv-builtin-');
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
      );

      final items = await repository.loadPlayable();
      expect(items, isEmpty);
      expect(await repository.loadBundled(), isEmpty);
      expect(await repository.loadExcludedBundled(), hasLength(50));
      expect(await repository.loadPrivate(), isEmpty);
      final restarted = CharacterPictureRepository(
        directoryProvider: () async => temporary,
      );
      expect(await restarted.loadPlayable(), isEmpty);
      expect(await restarted.loadExcludedBundled(), hasLength(50));
    },
  );

  test(
    'rejected bundled portraits stay excluded across restart and reseeding',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'rv-builtin-exclude-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
      );
      expect(await repository.loadPlayable(), isEmpty);
      final excluded = await repository.loadExcludedBundled();
      expect(excluded, hasLength(50));
      final afterRestart = CharacterPictureRepository(
        directoryProvider: () async => temporary,
      );
      final loaded = await afterRestart.loadAll();
      expect(loaded, isEmpty);
      expect(await afterRestart.loadExcludedBundled(), hasLength(50));
    },
  );
}

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

    final items = await repository.loadAll();
    expect(items, hasLength(50));
    expect(items.every((item) => item.collection == 'bundled'), isTrue);
    expect(await repository.loadBundled(), hasLength(50));
    expect(await repository.loadPrivate(), isEmpty);
    expect(
      items.map((item) => item.name),
      containsAll([
        'George Washington',
        'Abraham Lincoln',
        'Sylvester Stallone',
        'Bruce Willis',
        'Tina Fey',
        'Charlie Hunnam',
        'Stone Cold Steve Austin',
        'Garrett Hedlund',
        'Charlie Day',
        'Andy Whitfield',
        'Zoe Saldana',
        'Karen Gillan',
        'Aamir Khan',
        'Amitabh Bachchan',
        'Aishwarya Rai Bachchan',
        'Deepika Padukone',
        'Katrina Kaif',
        'Rajinikanth',
        'Ranveer Singh',
        'Vidya Balan',
        'Rani Mukerji',
        'Anya Singh',
        'Mammootty',
        'Kareena Kapoor Khan',
        'Kamal Haasan',
        'Akshay Kumar',
        'Kajol',
        'Sonam Kapoor',
        'Sushmita Sen',
        'Lionel Messi',
        'Cristiano Ronaldo',
        'Neymar',
        'Kylian Mbappé',
        'Alex Morgan',
        'Mohamed Salah',
        'Pelé',
        'David Villa',
        'Marta',
        'Zinedine Zidane',
        'Tom Hanks',
        'Dwayne Johnson',
        'Emma Watson',
        'Meryl Streep',
        'Robert Downey Jr.',
        'Jimmy Carter',
        'George W. Bush',
        'Donald Trump',
        'Joe Biden',
        'Lyndon B. Johnson',
        'Gerald Ford',
      ]),
    );
    expect(items.every((item) => File(item.path).existsSync()), isTrue);
    expect(
      items.every(
        (item) =>
            item.width >= 400 &&
            item.height >= 400 &&
            (item.width >= 640 || item.height >= 640),
      ),
      isTrue,
    );
    expect(items.every((item) => item.license.isNotEmpty), isTrue);
    expect(
      items.every((item) => item.sourceUrl.startsWith('https://')),
      isTrue,
    );

    final reloaded = await repository.loadAll();
    expect(reloaded, hasLength(50));
    expect(reloaded.map((item) => item.sha256).toSet(), hasLength(50));
    expect(
      reloaded.where((item) => item.category == 'Indian Actors and Actresses'),
      hasLength(17),
    );
    expect(
      reloaded.where((item) => item.category == 'Footballers'),
      hasLength(10),
    );
    expect(
      reloaded.where((item) => item.category == 'Hollywood Actors'),
      hasLength(14),
    );
    expect(
      reloaded.where((item) => item.category == 'Historical Presidents'),
      hasLength(8),
    );
    expect(
      reloaded.where((item) => item.category == 'Athletes and Entertainers'),
      hasLength(1),
    );
    expect(
      reloaded.every(
        (item) =>
            item.sourceUrl.startsWith('https://') && item.license.isNotEmpty,
      ),
      isTrue,
    );
  });

  test(
    'bundled removal is an exclusion that survives reseeding and restart',
    () async {
      final temporary = await Directory.systemTemp.createTemp(
        'rv-builtin-exclude-',
      );
      addTearDown(() => temporary.delete(recursive: true));
      final repository = CharacterPictureRepository(
        directoryProvider: () async => temporary,
      );
      final initial = await repository.loadAll();
      final target = initial.first;
      final managedCopy = File(target.path);
      await repository.remove(target.id);
      expect(await managedCopy.exists(), isFalse);
      final afterRestart = CharacterPictureRepository(
        directoryProvider: () async => temporary,
      );
      final loaded = await afterRestart.loadAll();
      expect(loaded.length, initial.length - 1);
      expect(loaded.any((item) => item.id == target.id), isFalse);
    },
  );
}

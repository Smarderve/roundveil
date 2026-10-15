import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';

Future<Uint8List> _testPng() async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawColor(const ui.Color(0xFF214A76), ui.BlendMode.src);
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

      final recreated = CharacterPictureRepository(
        directoryProvider: () async => temporary,
        includeBundledImages: false,
      );
      final loaded = await recreated.loadAll();
      expect(loaded, hasLength(1));
      expect(loaded.single.sourceTitle, 'Family archive');
      expect(loaded.single.license, 'Owner supplied');
      expect(loaded.single.hint, 'A clue kept with this imported image.');
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

  test('fresh installations seed verified bundled portraits offline', () async {
    final temporary = await Directory.systemTemp.createTemp('rv-builtin-');
    addTearDown(() => temporary.delete(recursive: true));
    final repository = CharacterPictureRepository(
      directoryProvider: () async => temporary,
    );

    final items = await repository.loadAll();
    expect(items, hasLength(2));
    expect(
      items.map((item) => item.name),
      containsAll(['George Washington', 'Abraham Lincoln']),
    );
    expect(items.every((item) => File(item.path).existsSync()), isTrue);
    expect(
      items.every((item) => item.width >= 640 && item.height >= 400),
      isTrue,
    );
    expect(items.every((item) => item.license.isNotEmpty), isTrue);
    expect(
      items.every((item) => item.sourceUrl.startsWith('https://')),
      isTrue,
    );

    final reloaded = await repository.loadAll();
    expect(reloaded, hasLength(2));
    expect(reloaded.map((item) => item.sha256).toSet(), hasLength(2));
  });
}

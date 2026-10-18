import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const characterPictureCategories = <String>[
  'Marvel Characters',
  'DC Characters',
  'Anime Characters',
  'Cartoon Characters',
  'Disney Characters',
  'DreamWorks Characters',
  'Other Fictional Characters',
  'Indian Actors and Actresses',
  'Chinese Actors',
  'Hollywood Actors',
  'Footballers',
  'Historical Presidents',
  'Other People',
];

const _characterLibraryResetMigration =
    'migration:character-library-reset-20261018';

class CharacterPicture {
  const CharacterPicture({
    required this.id,
    required this.name,
    required this.path,
    this.category = 'Uncategorized',
    this.aliases = const <String>[],
    this.hint = '',
    this.sourceTitle = '',
    this.sourceUrl = '',
    this.license = '',
    this.attribution = '',
    this.subjectType = '',
    this.franchise = '',
    this.description = '',
    this.difficulty = 'Mixed',
    this.collection = 'private',
    this.width = 0,
    this.height = 0,
    this.sha256 = '',
    this.hidden = false,
  });

  final String id;
  final String name;
  final String path;
  final String category;
  final List<String> aliases;
  final String hint;
  final String sourceTitle;
  final String sourceUrl;
  final String license;
  final String attribution;
  final String subjectType;
  final String franchise;
  final String description;
  final String difficulty;
  final String collection;
  final int width;
  final int height;
  final String sha256;
  final bool hidden;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'path': path,
    'category': category,
    'aliases': aliases,
    'hint': hint,
    'sourceTitle': sourceTitle,
    'sourceUrl': sourceUrl,
    'license': license,
    'attribution': attribution,
    'subjectType': subjectType,
    'franchise': franchise,
    'description': description,
    'difficulty': difficulty,
    'collection': collection,
    'width': width,
    'height': height,
    'sha256': sha256,
    'hidden': hidden,
  };

  factory CharacterPicture.fromJson(Map<String, Object?> json) =>
      CharacterPicture(
        id: json['id']! as String,
        name: json['name']! as String,
        path: json['path']! as String,
        category: json['category'] as String? ?? 'Uncategorized',
        aliases: (json['aliases'] as List<Object?>? ?? const <Object?>[])
            .whereType<String>()
            .toList(growable: false),
        hint: json['hint'] as String? ?? '',
        sourceTitle: json['sourceTitle'] as String? ?? '',
        sourceUrl: json['sourceUrl'] as String? ?? '',
        license: json['license'] as String? ?? '',
        attribution: json['attribution'] as String? ?? '',
        subjectType: json['subjectType'] as String? ?? '',
        franchise: json['franchise'] as String? ?? '',
        description: json['description'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? 'Mixed',
        collection: json['collection'] as String? ?? 'private',
        width: json['width'] as int? ?? 0,
        height: json['height'] as int? ?? 0,
        sha256: json['sha256'] as String? ?? '',
        hidden: json['hidden'] as bool? ?? false,
      );

  CharacterPicture copyWith({String? collection, bool? hidden}) =>
      CharacterPicture(
        id: id,
        name: name,
        path: path,
        category: category,
        aliases: aliases,
        hint: hint,
        sourceTitle: sourceTitle,
        sourceUrl: sourceUrl,
        license: license,
        attribution: attribution,
        subjectType: subjectType,
        franchise: franchise,
        description: description,
        difficulty: difficulty,
        collection: collection ?? this.collection,
        width: width,
        height: height,
        sha256: sha256,
        hidden: hidden ?? this.hidden,
      );
}

class PicturePackageImportReport {
  const PicturePackageImportReport({
    required this.imported,
    required this.duplicates,
    this.removed = 0,
    this.restored = 0,
    required this.errors,
  });

  final int imported;
  final int duplicates;
  /// Entries matching a persistent removal that were deliberately not added.
  final int removed;
  /// Previously removed entries restored from this explicitly selected batch.
  final int restored;
  final List<String> errors;
}

class PrivateCharacterImageImport {
  const PrivateCharacterImageImport({
    required this.filename,
    required this.bytes,
    required this.name,
    required this.category,
    required this.franchise,
    required this.series,
    required this.aliases,
    required this.hint,
    required this.difficulty,
    this.description = '',
  });

  final String filename;
  final List<int> bytes;
  final String name;
  final String category;
  final String franchise;
  final String series;
  final List<String> aliases;
  final String hint;
  final String difficulty;
  final String description;
}

/// Private, offline image library for Character Picture Mode.
///
/// Nothing is downloaded or uploaded. Importing copies the chosen local image
/// into ROUNDVEIL's app-private data directory and retains optional provenance.
class CharacterPictureRepository {
  CharacterPictureRepository({
    Future<Directory> Function()? directoryProvider,
    this.includeBundledImages = true,
  }) : _directoryProvider = directoryProvider ?? _applicationDataDirectory;

  final Future<Directory> Function() _directoryProvider;
  final bool includeBundledImages;

  Future<Directory> get _libraryDirectory async {
    final root = await _directoryProvider();
    final library = Directory(
      '${root.path}${Platform.pathSeparator}character_picture_library',
    );
    await library.create(recursive: true);
    return library;
  }

  Future<File> get _indexFile async => File(
    '${(await _libraryDirectory).path}${Platform.pathSeparator}index.json',
  );

  Future<List<CharacterPicture>> loadAll() async {
    final file = await _indexFile;
    var items = <CharacterPicture>[];
    var indexItems = <CharacterPicture>[];
    var excludedBundledIds = <String>{};
    var hiddenIds = <String>{};
    var removedIds = <String>{};
    var removedImageHashes = <String>{};
    if (await file.exists()) {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, Object?> || decoded['items'] is! List) {
        throw const FormatException('Character picture index is invalid.');
      }
      excludedBundledIds = _readStringSet(decoded['excludedBundledIds']);
      hiddenIds = _readStringSet(decoded['hiddenIds']);
      removedIds = _readStringSet(decoded['removedIds']);
      removedImageHashes = _readStringSet(decoded['removedImageHashes']);
      indexItems = (decoded['items']! as List<Object?>)
          .map(
            (item) => CharacterPicture.fromJson(item! as Map<String, Object?>),
          )
          .toList();
      items = indexItems.where((item) => File(item.path).existsSync()).toList();
    }
    if (!hiddenIds.contains(_characterLibraryResetMigration)) {
      // The owner rejected the current Picture Mode library and asked to
      // rebuild it. Retain every managed private image and record for possible
      // review/restoration, but hide it from gameplay. Bundled entries are
      // persistently excluded so first-run seeding cannot silently restore
      // them. This migration touches only the character-picture index; player
      // profiles, hints, scores, object content and image files are untouched.
      for (final item in indexItems) {
        if (item.collection == 'bundled') {
          excludedBundledIds.add(item.id);
        }
        hiddenIds.add(item.id);
      }
      if (includeBundledImages) {
        try {
          final manifest = jsonDecode(
            await rootBundle.loadString(
              'assets/brand/character_pictures/manifest.json',
            ),
          );
          if (manifest is Map<String, Object?> && manifest['items'] is List) {
            for (final raw in manifest['items']! as List<Object?>) {
              if (raw is Map<String, Object?> && raw['id'] is String) {
                excludedBundledIds.add(raw['id']! as String);
              }
            }
          }
        } on FlutterError {
          // Unit tests and alternate builds may intentionally omit bundled media.
        }
      }
      hiddenIds.add(_characterLibraryResetMigration);
      await _writeIndex(
        indexItems,
        excludedBundledIds: excludedBundledIds,
        hiddenIds: hiddenIds,
      );
    }
    if (includeBundledImages) {
      items = await _installBundledImages(
        items,
        excludedIds: excludedBundledIds,
        removedIds: removedIds,
        removedImageHashes: removedImageHashes,
      );
    }
    items = items
        .map((item) => item.copyWith(hidden: hiddenIds.contains(item.id)))
        .toList(growable: false);
    return List<CharacterPicture>.unmodifiable(items);
  }

  Future<List<CharacterPicture>> loadPlayable() async =>
      (await loadAll()).where((item) => !item.hidden).toList(growable: false);

  Future<void> setHidden(String id, {required bool hidden}) async {
    final items = (await loadAll()).toList();
    if (!items.any((item) => item.id == id)) return;
    final state = await _readIndexState();
    final hiddenIds = state.hiddenIds;
    if (hidden) {
      hiddenIds.add(id);
    } else {
      hiddenIds.remove(id);
    }
    await _writeIndex(
      items
          .map((item) => item.copyWith(hidden: hiddenIds.contains(item.id)))
          .toList(),
      hiddenIds: hiddenIds,
    );
  }

  String catalogKey(String category, String name) =>
      'catalog:${category.toLowerCase()}|${name.toLowerCase()}';

  Future<Set<String>> loadHiddenCatalogKeys() async => (await _readIndexState())
      .hiddenIds
      .where((id) => id.startsWith('catalog:'))
      .toSet();

  Future<void> setCatalogHidden(
    String category,
    String name, {
    required bool hidden,
  }) async {
    final state = await _readIndexState();
    final key = catalogKey(category, name);
    if (hidden) {
      state.hiddenIds.add(key);
    } else {
      state.hiddenIds.remove(key);
    }
    await _writeIndex(await loadAll(), hiddenIds: state.hiddenIds);
  }

  Future<bool> isImageRemoved(String digest) async {
    if (digest.isEmpty) return false;
    return (await _readIndexState()).removedImageHashes.contains(digest);
  }

  Future<int> loadRemovedCount() async {
    final state = await _readIndexState();
    // A private deletion is represented by both its stable ID and its hash;
    // bundled exclusions have an ID only. Count those paired tombstones once,
    // while retaining legacy hashes that have no owner mapping.
    final removedIds = <String>{
      ...state.removedIds,
      ...state.excludedBundledIds,
    };
    final orphanedHashes = state.removedImageHashes
        .where((digest) => !state.removedImageOwners.containsKey(digest));
    return removedIds.length + orphanedHashes.length;
  }

  Future<List<({String id, String name, String category})>>
  loadExcludedBundled() async {
    try {
      final decoded = jsonDecode(
        await rootBundle.loadString(
          'assets/brand/character_pictures/manifest.json',
        ),
      ) as Map<String, Object?>;
      final excluded = (await _readIndexState()).excludedBundledIds;
      return (decoded['items']! as List<Object?>)
          .whereType<Map<String, Object?>>()
          .where((item) => excluded.contains(item['id']))
          .where(
            (item) =>
                item['id'] is String &&
                item['name'] is String &&
                item['category'] is String,
          )
          .map(
            (item) => (
              id: item['id']! as String,
              name: item['name']! as String,
              category: item['category']! as String,
            ),
          )
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }

  Future<void> restoreBundled(String id) async {
    final file = await _indexFile;
    final state = await _readIndexState();
    if (!state.excludedBundledIds.contains(id) &&
        !state.removedIds.contains(id)) {
      return;
    }
    final decoded = jsonDecode(
      await rootBundle.loadString(
        'assets/brand/character_pictures/manifest.json',
      ),
    ) as Map<String, Object?>;
    for (final raw in decoded['items']! as List<Object?>) {
      if (raw is! Map<String, Object?> || raw['id'] != id) continue;
      final assetPath = raw['assetPath'];
      if (assetPath is String) {
        final asset = await rootBundle.load(assetPath);
        final bytes = asset.buffer.asUint8List(
          asset.offsetInBytes,
          asset.lengthInBytes,
        );
        state.removedImageHashes.remove(sha256.convert(bytes).toString());
      }
      break;
    }
    state.excludedBundledIds.remove(id);
    state.removedIds.remove(id);
    state.removedImageOwners.removeWhere((_, ownerId) => ownerId == id);
    final items = await loadAll();
    // Persist the restored tombstone state first, then let the normal seeding
    // path reinstall the approved bundled asset on the next load.
    await file.writeAsString(
      jsonEncode(<String, Object?>{
        'schemaVersion': 2,
        'items': items.map((item) => item.toJson()).toList(),
        'excludedBundledIds': state.excludedBundledIds.toList()..sort(),
        'hiddenIds': state.hiddenIds.toList()..sort(),
        'removedIds': state.removedIds.toList()..sort(),
        'removedImageHashes': state.removedImageHashes.toList()..sort(),
        'removedImageOwners': state.removedImageOwners,
      }),
      flush: true,
    );
    await loadAll();
  }

  Future<
    ({
      Set<String> excludedBundledIds,
      Set<String> hiddenIds,
      Set<String> removedIds,
      Set<String> removedImageHashes,
      Map<String, String> removedImageOwners,
    })
  >
  _readIndexState() async {
    final file = await _indexFile;
    if (!await file.exists()) {
      return (
        excludedBundledIds: <String>{},
        hiddenIds: <String>{},
        removedIds: <String>{},
        removedImageHashes: <String>{},
        removedImageOwners: <String, String>{},
      );
    }
    final decoded =
        jsonDecode(await file.readAsString()) as Map<String, Object?>;
    return (
      excludedBundledIds: _readStringSet(decoded['excludedBundledIds']),
      hiddenIds: _readStringSet(decoded['hiddenIds']),
      removedIds: _readStringSet(decoded['removedIds']),
      removedImageHashes: _readStringSet(decoded['removedImageHashes']),
      removedImageOwners: _readStringMap(decoded['removedImageOwners']),
    );
  }

  Set<String> _readStringSet(Object? value) =>
      (value as List<Object?>? ?? const <Object?>[])
          .whereType<String>()
          .toSet();

  Map<String, String> _readStringMap(Object? value) =>
      Map<String, String>.fromEntries(
        (value as Map<Object?, Object?>? ?? const <Object?, Object?>{})
            .entries
            .where((entry) => entry.key is String && entry.value is String)
            .map(
              (entry) => MapEntry(
                entry.key! as String,
                entry.value! as String,
              ),
            ),
      );

  Future<List<CharacterPicture>> loadBundled() async => (await loadAll())
      .where((item) => item.collection == 'bundled')
      .toList(growable: false);

  Future<List<CharacterPicture>> loadPrivate() async => (await loadAll())
      .where((item) => item.collection == 'private')
      .toList(growable: false);

  Future<List<CharacterPicture>> _installBundledImages(
    List<CharacterPicture> current, {
    required Set<String> excludedIds,
    required Set<String> removedIds,
    required Set<String> removedImageHashes,
  }) async {
    const manifestAsset = 'assets/brand/character_pictures/manifest.json';
    final String manifestText;
    try {
      manifestText = await rootBundle.loadString(manifestAsset);
    } on FlutterError {
      return current;
    }
    final decoded = jsonDecode(manifestText);
    if (decoded is! Map<String, Object?> ||
        decoded['schemaVersion'] != 1 ||
        decoded['items'] is! List<Object?>) {
      throw const FormatException(
        'Bundled character picture manifest is invalid.',
      );
    }
    final result = current.toList();
    final knownIds = result.map((item) => item.id).toSet();
    final knownHashes = <String>{
      for (final item in result) await _digestFor(item),
    };
    final library = await _libraryDirectory;
    var changed = false;
    var collectionCorrected = false;
    for (final raw in decoded['items']! as List<Object?>) {
      if (raw is! Map<String, Object?>) continue;
      final id = raw['id'];
      final assetPath = raw['assetPath'];
      final name = raw['name'];
      final category = raw['category'];
      if (id is! String ||
          name is! String ||
          category is! String ||
          assetPath is! String ||
          !assetPath.startsWith('assets/brand/character_pictures/')) {
        continue;
      }
      if (excludedIds.contains(id) || removedIds.contains(id)) continue;
      if (knownIds.contains(id)) {
        final existingIndex = result.indexWhere((item) => item.id == id);
        if (existingIndex >= 0 &&
            result[existingIndex].collection != 'bundled') {
          result[existingIndex] = result[existingIndex].copyWith(
            collection: 'bundled',
          );
          collectionCorrected = true;
        }
        continue;
      }
      final extension = assetPath.split('.').last.toLowerCase();
      final asset = await rootBundle.load(assetPath);
      final bytes = asset.buffer.asUint8List(
        asset.offsetInBytes,
        asset.lengthInBytes,
      );
      // Bundled media has already been inspected when its manifest was
      // generated. Verify its actual header, dimensions, and SHA-256 here; do
      // not initialize a native image decoder for every 5K portrait during
      // first-run seeding. User-imported images still go through a bounded
      // decode in _validatedDimensions below.
      final dimensions = _readImageDimensions(extension, bytes);
      if (dimensions == null) continue;
      final (assetWidth, assetHeight) = dimensions;
      if (assetWidth < 400 ||
          assetHeight < 400 ||
          (assetWidth < 640 && assetHeight < 640)) {
        continue;
      }
      final digest = sha256.convert(bytes).toString();
      if (removedImageHashes.contains(digest)) continue;
      final expectedDigest = raw['sha256'] as String?;
      if (expectedDigest != null &&
          expectedDigest.isNotEmpty &&
          expectedDigest.toLowerCase() != digest) {
        continue;
      }
      final expectedWidth = raw['width'] as int?;
      final expectedHeight = raw['height'] as int?;
      if ((expectedWidth != null && expectedWidth != dimensions.$1) ||
          (expectedHeight != null && expectedHeight != dimensions.$2)) {
        continue;
      }
      if (!knownHashes.add(digest)) continue;
      final source = raw['source'] as Map<String, Object?>? ?? const {};
      final path = '${library.path}${Platform.pathSeparator}$id.$extension';
      await File(path).writeAsBytes(bytes, flush: true);
      result.add(
        CharacterPicture(
          id: id,
          name: name,
          path: path,
          category: category,
          aliases: (raw['aliases'] as List<Object?>? ?? const <Object?>[])
              .whereType<String>()
              .toList(growable: false),
          hint: raw['hint'] as String? ?? '',
          sourceTitle: source['title'] as String? ?? '',
          sourceUrl: source['url'] as String? ?? '',
          license: source['license'] as String? ?? '',
          attribution: source['attribution'] as String? ?? '',
          subjectType: raw['subjectType'] as String? ?? '',
          franchise: raw['franchise'] as String? ?? '',
          description: raw['description'] as String? ?? '',
          difficulty: raw['difficulty'] as String? ?? 'Mixed',
          collection: 'bundled',
          width: dimensions.$1,
          height: dimensions.$2,
          sha256: digest,
        ),
      );
      knownIds.add(id);
      changed = true;
    }
    if (changed || collectionCorrected) {
      await _writeIndex(
        result,
        excludedBundledIds: excludedIds,
        removedIds: removedIds,
        removedImageHashes: removedImageHashes,
      );
    }
    return result;
  }

  Future<List<CharacterPicture>> importImages({
    required String subjectName,
    String category = 'Other Fictional Characters',
    List<String> aliases = const <String>[],
    String hint = '',
    String sourceTitle = '',
    String sourceUrl = '',
    String license = '',
    String attribution = '',
    String subjectType = '',
    String franchise = '',
    String description = '',
    String difficulty = 'Mixed',
    String collection = 'private',
    Future<bool> Function(String name)? confirmRestore,
  }) async {
    final name = subjectName.trim();
    if (name.isEmpty) throw ArgumentError.value(name, 'subjectName');
    final files = await FilePicker.pickFiles(
      dialogTitle: 'Import Character Picture',
      type: FileType.image,
    );
    if (files.isEmpty) return loadAll();

    var imported = 0;
    for (final picked in files) {
      final extension = (picked.extension ?? '').toLowerCase();
      if (!const <String>{'png', 'jpg', 'jpeg', 'webp'}.contains(extension)) {
        continue;
      }
      final bytes = await picked.readAsBytes();
      final digest = sha256.convert(bytes).toString();
      final removed = await isImageRemoved(digest);
      if (removed &&
          (confirmRestore == null || !await confirmRestore(name))) {
        continue;
      }
      final item = await addImageBytes(
        name: files.length == 1 ? name : '$name ${imported + 1}',
        hint: hint,
        extension: extension,
        bytes: bytes,
        sourceTitle: sourceTitle,
        sourceUrl: sourceUrl,
        license: license,
        attribution: attribution,
        subjectType: subjectType,
        franchise: franchise,
        description: description,
        difficulty: difficulty,
        category: category,
        aliases: aliases,
        collection: collection,
        restoreRemoved: removed,
      );
      if (item != null) imported++;
    }
    if (imported == 0) {
      throw const FormatException(
        'No new supported images were imported. Use a clear PNG, JPEG, or WebP image above 1 KB.',
      );
    }
    return loadAll();
  }

  Future<CharacterPicture?> addImageBytes({
    required String name,
    required String extension,
    required List<int> bytes,
    String hint = '',
    String sourceTitle = '',
    String sourceUrl = '',
    String license = '',
    String attribution = '',
    String subjectType = '',
    String franchise = '',
    String description = '',
    String difficulty = 'Mixed',
    String category = 'Uncategorized',
    List<String> aliases = const <String>[],
    String collection = 'private',
    bool restoreRemoved = false,
  }) async {
    final safeName = name.trim();
    final ext = extension.toLowerCase() == 'jpeg'
        ? 'jpg'
        : extension.toLowerCase();
    if (safeName.isEmpty ||
        !const <String>{'png', 'jpg', 'webp'}.contains(ext) ||
        !_looksLikeSupportedImage(bytes) ||
        bytes.length < 1024) {
      throw const FormatException(
        'Use a valid PNG, JPEG, or WebP image with sufficient resolution.',
      );
    }
    final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    final frame = await codec.getNextFrame();
    final width = frame.image.width;
    final height = frame.image.height;
    frame.image.dispose();
    codec.dispose();
    if (width < 400 || height < 400 || (width < 640 && height < 640)) {
      throw const FormatException(
        'Picture Mode images must be at least 640 pixels on one side and 400 pixels on the other.',
      );
    }

    final existing = (await loadAll()).toList();
    final digest = sha256.convert(bytes).toString();
    final deletionState = await _readIndexState();
    if (deletionState.removedImageHashes.contains(digest)) {
      if (!restoreRemoved) return null;
      deletionState.removedImageHashes.remove(digest);
      final formerId = deletionState.removedImageOwners.remove(digest);
      if (formerId != null) deletionState.removedIds.remove(formerId);
    }
    for (final item in existing) {
      if (await _digestFor(item) == digest) return null;
    }
    final library = await _libraryDirectory;
    final id =
        'local-${DateTime.now().microsecondsSinceEpoch}-${existing.length}';
    final file = File('${library.path}${Platform.pathSeparator}$id.$ext');
    await file.writeAsBytes(bytes, flush: true);
    final item = CharacterPicture(
      id: id,
      name: safeName,
      path: file.path,
      category: category.trim().isEmpty ? 'Uncategorized' : category.trim(),
      aliases: aliases
          .map((alias) => alias.trim())
          .where((alias) => alias.isNotEmpty)
          .toSet()
          .toList(growable: false),
      hint: hint.trim(),
      sourceTitle: sourceTitle.trim(),
      sourceUrl: sourceUrl.trim(),
      license: license.trim(),
      attribution: attribution.trim(),
      subjectType: subjectType.trim(),
      franchise: franchise.trim(),
      description: description.trim(),
      difficulty: difficulty.trim(),
      collection: collection,
      width: width,
      height: height,
      sha256: digest,
    );
    await _writeIndex(
      <CharacterPicture>[...existing, item],
      removedIds: deletionState.removedIds,
      removedImageHashes: deletionState.removedImageHashes,
      removedImageOwners: deletionState.removedImageOwners,
    );
    return item;
  }

  /// Installs a reviewed batch as local private content, validating each image
  /// and preventing both byte-identical and duplicate-identity entries.
  Future<PicturePackageImportReport> importPrivateImageBatch(
    List<PrivateCharacterImageImport> batch, {
    bool restoreRemoved = false,
  }
  ) async {
    if (batch.length > 500) {
      throw const FormatException('A single import is limited to 500 images.');
    }
    var imported = 0;
    var duplicates = 0;
    var removed = 0;
    var restored = 0;
    final errors = <String>[];
    final acceptedIdentities = <String>{
      for (final item in await loadPrivate())
        '${item.category.toLowerCase()}|${item.name.toLowerCase()}',
    };
    for (final entry in batch) {
      final identity =
          '${entry.category.toLowerCase()}|${entry.name.toLowerCase()}';
      if (!acceptedIdentities.add(identity)) {
        duplicates++;
        continue;
      }
      try {
        final ext = entry.filename.split('.').last.toLowerCase();
        final digest = sha256.convert(entry.bytes).toString();
        final wasRemoved = await isImageRemoved(digest);
        if (wasRemoved && !restoreRemoved) {
          removed++;
          acceptedIdentities.remove(identity);
          continue;
        }
        final added = await addImageBytes(
          name: entry.name,
          extension: ext,
          bytes: entry.bytes,
          category: entry.category,
          aliases: entry.aliases,
          hint: entry.hint,
          franchise: entry.franchise,
          description: entry.description.isEmpty
              ? 'Series: ${entry.series}'
              : '${entry.description}\nSeries: ${entry.series}',
          subjectType: 'Fictional character',
          difficulty: entry.difficulty,
          sourceTitle: 'Owner-supplied private local image',
          sourceUrl: '',
          license: 'Owner confirmed private-use permission at import',
          attribution:
              'Image source supplied by owner; see original local file.',
          collection: 'private',
          restoreRemoved: wasRemoved,
        );
        if (added == null) {
          duplicates++;
          acceptedIdentities.remove(identity);
        } else {
          imported++;
          if (wasRemoved) restored++;
        }
      } on Object catch (error) {
        acceptedIdentities.remove(identity);
        errors.add(
          '${entry.filename}: ${error.toString().replaceFirst('FormatException: ', '')}',
        );
      }
    }
    return PicturePackageImportReport(
      imported: imported,
      duplicates: duplicates,
      removed: removed,
      restored: restored,
      errors: List<String>.unmodifiable(errors),
    );
  }

  /// Downloads a single owner-authorized image URL for private offline use.
  /// Only HTTPS URLs resolving to public IP addresses are fetched; redirects
  /// are rejected so a remote host cannot redirect the request to local hosts.
  Future<CharacterPicture?> importPrivateImageUrl({
    required Uri uri,
    required String name,
    required String category,
    required String franchise,
    required String hint,
    required List<String> aliases,
    required String difficulty,
    required String attribution,
    required bool permissionConfirmed,
    Future<bool> Function(String name)? confirmRestore,
  }) async {
    if (!permissionConfirmed) {
      throw const FormatException(
        'Confirm that the source terms permit a private offline copy.',
      );
    }
    if (uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort && uri.port != 443) {
      throw const FormatException('Use a public HTTPS image URL.');
    }
    final addresses = await InternetAddress.lookup(uri.host)
        .timeout(const Duration(seconds: 10));
    if (addresses.isEmpty ||
        addresses.any((address) => !_isPublicAddress(address))) {
      throw const FormatException(
        'The image host must resolve only to public IP addresses.',
      );
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 15));
      request.followRedirects = false;
      request.headers.set(
        HttpHeaders.acceptHeader,
        'image/png,image/jpeg,image/webp',
      );
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode != HttpStatus.ok ||
          response.contentLength > 25 * 1024 * 1024) {
        throw const FormatException(
          'The source must return one image under 25 MB without redirects.',
        );
      }
      final payload = BytesBuilder(copy: false);
      var total = 0;
      await for (final chunk in response.timeout(const Duration(seconds: 20))) {
        total += chunk.length;
        if (total > 25 * 1024 * 1024) {
          throw const FormatException('The image exceeds the 25 MB limit.');
        }
        payload.add(chunk);
      }
      final bytes = payload.takeBytes();
      final extension = _imageExtensionFromBytes(bytes);
      if (extension == null) {
        throw const FormatException(
          'The URL did not return a valid PNG, JPEG, or WebP image.',
        );
      }
      final digest = sha256.convert(bytes).toString();
      final removed = await isImageRemoved(digest);
      if (removed &&
          (confirmRestore == null || !await confirmRestore(name))) {
        return null;
      }
      return await addImageBytes(
        name: name,
        extension: extension,
        bytes: bytes,
        category: category,
        franchise: franchise,
        aliases: aliases,
        hint: hint,
        difficulty: difficulty,
        subjectType: 'Fictional character',
        sourceTitle: 'Owner-supplied private image URL',
        sourceUrl: uri.toString(),
        license: 'Owner confirmed source permits private offline use',
        attribution: attribution,
        collection: 'private',
        restoreRemoved: removed,
      );
    } finally {
      client.close(force: true);
    }
  }

  static bool _isPublicAddress(InternetAddress address) {
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv4) {
      return _isPublicIpv4(bytes);
    }
    if (bytes.every((byte) => byte == 0) ||
        (bytes.take(15).every((byte) => byte == 0) && bytes[15] == 1) ||
        bytes.first == 0xff ||
        (bytes.first & 0xfe) == 0xfc ||
        (bytes.first == 0xfe && (bytes[1] & 0xc0) == 0x80)) {
      return false;
    }
    if (bytes.take(10).every((byte) => byte == 0) &&
        bytes[10] == 0xff &&
        bytes[11] == 0xff) {
      return _isPublicIpv4(bytes.sublist(12));
    }
    return true;
  }

  static bool _isPublicIpv4(List<int> bytes) {
    final a = bytes[0], b = bytes[1];
    return a != 0 &&
        a != 10 &&
        a != 127 &&
        !(a == 169 && b == 254) &&
        !(a == 172 && b >= 16 && b <= 31) &&
        !(a == 192 && b == 168) &&
        !(a == 100 && b >= 64 && b <= 127) &&
        a < 224;
  }

  static String? _imageExtensionFromBytes(List<int> bytes) {
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47) {
      return 'png';
    }
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'jpg';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'webp';
    }
    return null;
  }

  /// Imports a private offline ZIP package. The archive contains one
  /// `manifest.json` and image files anywhere beneath its root. Manifest
  /// filenames must be basenames, so archive paths are never used as output
  /// paths. Invalid entries are reported while other valid entries are kept.
  Future<PicturePackageImportReport> importPackageBytes(
    List<int> packageBytes, {
    bool restoreRemoved = false,
  }
  ) async {
    if (packageBytes.isEmpty || packageBytes.length > 1024 * 1024 * 1024) {
      throw const FormatException('Picture package size is invalid.');
    }
    final archive = ZipDecoder().decodeBytes(packageBytes);
    var expandedBytes = 0;
    final filesByName = <String, ArchiveFile>{};
    for (final entry in archive.files) {
      if (!entry.isFile || entry.isSymbolicLink) continue;
      expandedBytes += entry.size;
      if (expandedBytes > 1024 * 1024 * 1024) {
        throw const FormatException('Picture package expands beyond 1 GB.');
      }
      final normalized = entry.name.replaceAll('\\', '/');
      if (normalized.startsWith('/') ||
          normalized.split('/').any((part) => part == '..')) {
        throw const FormatException('Picture package contains an unsafe path.');
      }
      final basename = normalized.split('/').last;
      if (filesByName.containsKey(basename)) {
        throw FormatException('Duplicate package filename: $basename');
      }
      filesByName[basename] = entry;
    }
    final manifests = filesByName.entries
        .where((entry) => entry.key.toLowerCase() == 'manifest.json')
        .toList(growable: false);
    if (manifests.length != 1) {
      throw const FormatException('Package must contain one manifest.json.');
    }
    final manifestBytes = manifests.single.value.readBytes();
    if (manifestBytes == null) {
      throw const FormatException('Picture package manifest is unreadable.');
    }
    final decoded = jsonDecode(utf8.decode(manifestBytes));
    if (decoded is! Map<String, Object?> ||
        decoded['schemaVersion'] != 1 ||
        decoded['items'] is! List<Object?>) {
      throw const FormatException('Unsupported picture package manifest.');
    }

    final existing = (await loadAll()).toList();
    final deletionState = await _readIndexState();
    final existingById = <String, CharacterPicture>{
      for (final item in existing) item.id: item,
    };
    final knownHashes = <String>{};
    for (final item in existing) {
      knownHashes.add(await _digestFor(item));
    }
    final seenIds = <String>{};
    final seenFiles = <String>{};
    final staged = <CharacterPicture>[];
    final errors = <String>[];
    var duplicates = 0;
    var removed = 0;
    var restored = 0;

    for (final raw in decoded['items']! as List<Object?>) {
      final itemIndex = staged.length + errors.length + duplicates + 1;
      try {
        if (raw is! Map<String, Object?>) {
          throw const FormatException('Entry must be an object.');
        }
        final id = raw['id'];
        final name = raw['name'];
        final category = raw['category'];
        final imageFilename = raw['imageFilename'];
        final hint = raw['hint'];
        final aliases = raw['aliases'];
        final source = raw['source'];
        if (id is! String ||
            !RegExp(r'^[A-Za-z0-9._-]{1,80}$').hasMatch(id) ||
            name is! String ||
            name.trim().isEmpty ||
            category is! String ||
            category.trim().isEmpty ||
            imageFilename is! String ||
            imageFilename.isEmpty ||
            imageFilename.contains('/') ||
            imageFilename.contains('\\') ||
            imageFilename == '.' ||
            imageFilename == '..' ||
            (hint != null && hint is! String) ||
            (aliases != null &&
                (aliases is! List<Object?> ||
                    aliases.any((value) => value is! String))) ||
            (source != null && source is! Map<String, Object?>)) {
          throw const FormatException('Entry metadata is missing or invalid.');
        }
        if (!seenIds.add(id)) {
          throw FormatException('Duplicate content ID: $id');
        }
        if (!seenFiles.add(imageFilename)) {
          throw FormatException('Image filename is reused: $imageFilename');
        }
        final image = filesByName[imageFilename];
        if (image == null) {
          throw FormatException('Image file not found: $imageFilename');
        }
        final imageBytes = image.readBytes();
        if (imageBytes == null) {
          throw FormatException('Image file is unreadable: $imageFilename');
        }
        final ext = imageFilename.split('.').last.toLowerCase();
        final digest = sha256.convert(imageBytes).toString();
        final wasRemoved = deletionState.removedImageHashes.contains(digest);
        if (wasRemoved && !restoreRemoved) {
          removed++;
          continue;
        }
        if (deletionState.removedIds.contains(id) && !wasRemoved) {
          duplicates++;
          continue;
        }
        final sameId = existingById[id];
        if (sameId != null && await _digestFor(sameId) != digest) {
          throw FormatException(
            'Content ID already exists with a different image: $id',
          );
        }
        if (sameId != null) {
          duplicates++;
          continue;
        }
        if (!knownHashes.add(digest)) {
          duplicates++;
          continue;
        }
        final dimensions = await _validatedDimensions(ext, imageBytes);
        if (dimensions == null) {
          throw FormatException(
            'Unsupported or low-resolution image: $imageFilename',
          );
        }
        if (wasRemoved) {
          deletionState.removedImageHashes.remove(digest);
          final formerId = deletionState.removedImageOwners.remove(digest);
          if (formerId != null) deletionState.removedIds.remove(formerId);
          deletionState.removedIds.remove(id);
          deletionState.excludedBundledIds.remove(id);
          restored++;
        }
        final metadata = source as Map<String, Object?>? ?? const {};
        staged.add(
          CharacterPicture(
            id: id,
            name: name.trim(),
            path: '',
            category: category.trim(),
            aliases: (aliases as List<Object?>? ?? const <Object?>[])
                .cast<String>()
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toSet()
                .toList(growable: false),
            hint: hint as String? ?? '',
            sourceTitle: metadata['title'] as String? ?? '',
            sourceUrl: metadata['url'] as String? ?? '',
            license: metadata['license'] as String? ?? '',
            attribution: metadata['attribution'] as String? ?? '',
            subjectType: raw['subjectType'] as String? ?? '',
            franchise: raw['franchise'] as String? ?? '',
            description: raw['description'] as String? ?? '',
            difficulty: raw['difficulty'] as String? ?? 'Mixed',
            collection: 'private',
            width: dimensions.$1,
            height: dimensions.$2,
            sha256: digest,
          ),
        );
        _pendingPackageImages[id] = (ext, imageBytes);
      } on Object catch (error) {
        errors.add(
          'Entry $itemIndex: ${error.toString().replaceFirst('FormatException: ', '')}',
        );
      }
    }

    final library = await _libraryDirectory;
    final imported = <CharacterPicture>[];
    try {
      for (final pending in staged) {
        final payload = _pendingPackageImages.remove(pending.id)!;
        final path =
            '${library.path}${Platform.pathSeparator}${pending.id}.${payload.$1 == 'jpeg' ? 'jpg' : payload.$1}';
        await File(path).writeAsBytes(payload.$2, flush: true);
        imported.add(
          CharacterPicture(
            id: pending.id,
            name: pending.name,
            path: path,
            category: pending.category,
            aliases: pending.aliases,
            hint: pending.hint,
            sourceTitle: pending.sourceTitle,
            sourceUrl: pending.sourceUrl,
            license: pending.license,
            attribution: pending.attribution,
            subjectType: pending.subjectType,
            franchise: pending.franchise,
            description: pending.description,
            difficulty: pending.difficulty,
            width: pending.width,
            height: pending.height,
            sha256: pending.sha256,
          ),
        );
      }
    } finally {
      _pendingPackageImages.clear();
    }
    await _writeIndex(
      <CharacterPicture>[...existing, ...imported],
      excludedBundledIds: deletionState.excludedBundledIds,
      removedIds: deletionState.removedIds,
      removedImageHashes: deletionState.removedImageHashes,
      removedImageOwners: deletionState.removedImageOwners,
    );
    return PicturePackageImportReport(
      imported: imported.length,
      duplicates: duplicates,
      removed: removed,
      restored: restored,
      errors: List<String>.unmodifiable(errors),
    );
  }

  /// Produces a portable ZIP for manually transferring this private library.
  Future<Uint8List> exportPackageBytes() async {
    final archive = Archive();
    final items = <Map<String, Object?>>[];
    for (final item in await loadPrivate()) {
      final image = File(item.path);
      if (!await image.exists()) continue;
      final bytes = await image.readAsBytes();
      final extension = item.path.split('.').last.toLowerCase();
      final filename = 'picture_${item.id}.$extension';
      archive.add(ArchiveFile.bytes(filename, bytes));
      items.add(<String, Object?>{
        'id': item.id,
        'name': item.name,
        'category': item.category,
        'imageFilename': filename,
        'aliases': item.aliases,
        'hint': item.hint,
        'subjectType': item.subjectType,
        'franchise': item.franchise,
        'description': item.description,
        'difficulty': item.difficulty,
        'source': <String, Object?>{
          'title': item.sourceTitle,
          'url': item.sourceUrl,
          'license': item.license,
          'attribution': item.attribution,
        },
      });
    }
    archive.add(
      ArchiveFile.string(
        'manifest.json',
        const JsonEncoder.withIndent('  ')
            .convert(<String, Object?>{'schemaVersion': 1, 'items': items}),
      ),
    );
    return ZipEncoder().encodeBytes(archive);
  }

  Future<void> remove(String id) async {
    final items = (await loadAll()).toList();
    final retained = items.where((item) => item.id != id).toList();
    final removed = items.where((item) => item.id == id).toList();
    if (removed.isEmpty) return;
    final state = await _readIndexState();
    final item = removed.single;
    state.removedIds.add(id);
    state.removedImageOwners.removeWhere((_, ownerId) => ownerId == id);
    if (item.collection == 'bundled') {
      state.excludedBundledIds.add(id);
    } else {
      final digest = await _digestFor(item);
      if (digest.isNotEmpty) {
        state.removedImageHashes.add(digest);
        state.removedImageOwners[digest] = id;
      }
    }
    final image = File(item.path);
    final libraryPath =
        '${(await _libraryDirectory).absolute.path}${Platform.pathSeparator}';
    if (await image.exists() && image.absolute.path.startsWith(libraryPath)) {
      await image.delete();
    }
    state.hiddenIds.remove(id);
    await _writeIndex(
      retained,
      excludedBundledIds: state.excludedBundledIds,
      hiddenIds: state.hiddenIds,
      removedIds: state.removedIds,
      removedImageHashes: state.removedImageHashes,
      removedImageOwners: state.removedImageOwners,
    );
  }

  Future<void> _writeIndex(
    List<CharacterPicture> items, {
    Set<String>? excludedBundledIds,
    Set<String>? hiddenIds,
    Set<String>? removedIds,
    Set<String>? removedImageHashes,
    Map<String, String>? removedImageOwners,
  }) async {
    final previous = await _readIndexState();
    final file = await _indexFile;
    await file.writeAsString(
      jsonEncode(<String, Object?>{
        'schemaVersion': 2,
        'items': items.map((item) => item.toJson()).toList(),
        'excludedBundledIds':
            (excludedBundledIds ?? previous.excludedBundledIds).toList()
              ..sort(),
        'hiddenIds': (hiddenIds ?? previous.hiddenIds).toList()..sort(),
        'removedIds': (removedIds ?? previous.removedIds).toList()..sort(),
        'removedImageHashes':
            (removedImageHashes ?? previous.removedImageHashes).toList()
              ..sort(),
        'removedImageOwners':
            removedImageOwners ?? previous.removedImageOwners,
      }),
      flush: true,
    );
  }

  final Map<String, (String, Uint8List)> _pendingPackageImages = {};

  Future<String> _digestFor(CharacterPicture item) async {
    if (item.sha256.isNotEmpty) return item.sha256;
    final file = File(item.path);
    return await file.exists()
        ? sha256.convert(await file.readAsBytes()).toString()
        : '';
  }

  Future<(int, int)?> _validatedDimensions(
    String extension,
    List<int> bytes,
  ) async {
    if (!const <String>{'png', 'jpg', 'jpeg', 'webp'}.contains(extension) ||
        !_looksLikeSupportedImage(bytes) ||
        bytes.length < 1024) {
      return null;
    }
    final dimensions = _readImageDimensions(extension, bytes);
    if (dimensions == null) return null;
    final (width, height) = dimensions;
    if (width < 400 || height < 400 || (width < 640 && height < 640)) {
      return null;
    }

    // Image validation only needs to prove the file decodes. Decoding original
    // 5K-7K portraits at full size can allocate hundreds of megabytes per image
    // and made first-run seeding exceed Flutter's 30-second test timeout. Read
    // intrinsic dimensions from the image header, then decode a small sample.
    final codec = await ui.instantiateImageCodec(
      bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
      targetWidth: width.clamp(1, 128),
      allowUpscaling: false,
    );
    final frame = await codec.getNextFrame();
    final decoded = (frame.image.width, frame.image.height);
    frame.image.dispose();
    codec.dispose();
    if (decoded.$1 < 1 || decoded.$2 < 1) return null;
    return dimensions;
  }

  static (int, int)? _readImageDimensions(String extension, List<int> bytes) {
    if (extension == 'png') {
      if (bytes.length < 24) return null;
      return (_uint32BigEndian(bytes, 16), _uint32BigEndian(bytes, 20));
    }
    if (extension == 'jpg' || extension == 'jpeg') {
      var offset = 2;
      while (offset + 3 < bytes.length) {
        if (bytes[offset] != 0xff) {
          offset++;
          continue;
        }
        while (offset < bytes.length && bytes[offset] == 0xff) {
          offset++;
        }
        if (offset >= bytes.length) return null;
        final marker = bytes[offset++];
        if (marker == 0xd8 ||
            marker == 0xd9 ||
            (marker >= 0xd0 && marker <= 0xd7) ||
            marker == 0x01) {
          continue;
        }
        if (offset + 1 >= bytes.length) return null;
        final segmentLength = (bytes[offset] << 8) | bytes[offset + 1];
        if (segmentLength < 2 || offset + segmentLength > bytes.length) {
          return null;
        }
        if (_isJpegStartOfFrame(marker)) {
          if (segmentLength < 7) return null;
          final height = (bytes[offset + 3] << 8) | bytes[offset + 4];
          final width = (bytes[offset + 5] << 8) | bytes[offset + 6];
          return (width, height);
        }
        offset += segmentLength;
      }
      return null;
    }
    if (extension == 'webp' && bytes.length >= 30) {
      final chunk = String.fromCharCodes(bytes.sublist(12, 16));
      if (chunk == 'VP8X') {
        final width = 1 + bytes[24] + (bytes[25] << 8) + (bytes[26] << 16);
        final height = 1 + bytes[27] + (bytes[28] << 8) + (bytes[29] << 16);
        return (width, height);
      }
      if (chunk == 'VP8 ' &&
          bytes[23] == 0x9d &&
          bytes[24] == 0x01 &&
          bytes[25] == 0x2a) {
        final width = (bytes[26] | (bytes[27] << 8)) & 0x3fff;
        final height = (bytes[28] | (bytes[29] << 8)) & 0x3fff;
        return (width, height);
      }
      if (chunk == 'VP8L' && bytes.length >= 25 && bytes[20] == 0x2f) {
        final width = 1 + bytes[21] + ((bytes[22] & 0x3f) << 8);
        final height =
            1 +
            ((bytes[22] >> 6) | (bytes[23] << 2) | ((bytes[24] & 0x0f) << 10));
        return (width, height);
      }
    }
    return null;
  }

  static int _uint32BigEndian(List<int> bytes, int offset) =>
      (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];

  static bool _isJpegStartOfFrame(int marker) =>
      marker == 0xc0 ||
      marker == 0xc1 ||
      marker == 0xc2 ||
      marker == 0xc3 ||
      marker == 0xc5 ||
      marker == 0xc6 ||
      marker == 0xc7 ||
      marker == 0xc9 ||
      marker == 0xca ||
      marker == 0xcb ||
      marker == 0xcd ||
      marker == 0xce ||
      marker == 0xcf;

  static bool _looksLikeSupportedImage(List<int> bytes) =>
      (bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4e &&
          bytes[3] == 0x47) ||
      (bytes.length >= 3 &&
          bytes[0] == 0xff &&
          bytes[1] == 0xd8 &&
          bytes[2] == 0xff) ||
      (bytes.length >= 12 &&
          String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP');

  static Future<Directory> _applicationDataDirectory() async {
    if (Platform.isWindows) {
      final root =
          Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'];
      if (root == null || root.isEmpty) {
        throw StateError('Windows application data directory is unavailable.');
      }
      return Directory('$root${Platform.pathSeparator}ROUNDVEIL');
    }
    if (Platform.isAndroid) {
      final packageRoot = Directory.systemTemp.parent;
      return Directory(
        '${packageRoot.path}${Platform.pathSeparator}files${Platform.pathSeparator}ROUNDVEIL',
      );
    }
    final root =
        Platform.environment['XDG_DATA_HOME'] ??
        Platform.environment['HOME'] ??
        Directory.current.path;
    return Directory('$root${Platform.pathSeparator}ROUNDVEIL');
  }
}

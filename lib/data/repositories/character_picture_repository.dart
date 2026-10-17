import 'dart:convert';
import 'dart:io';
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
  'Hollywood Actors',
  'Footballers',
  'Historical Presidents',
  'Other People',
];

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
      );

  CharacterPicture copyWith({String? collection}) => CharacterPicture(
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
  );
}

class PicturePackageImportReport {
  const PicturePackageImportReport({
    required this.imported,
    required this.duplicates,
    required this.errors,
  });

  final int imported;
  final int duplicates;
  final List<String> errors;
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
    if (await file.exists()) {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<String, Object?> || decoded['items'] is! List) {
        throw const FormatException('Character picture index is invalid.');
      }
      items = (decoded['items']! as List<Object?>)
          .map(
            (item) => CharacterPicture.fromJson(item! as Map<String, Object?>),
          )
          .where((item) => File(item.path).existsSync())
          .toList();
    }
    if (includeBundledImages) items = await _installBundledImages(items);
    return List<CharacterPicture>.unmodifiable(items);
  }

  Future<List<CharacterPicture>> loadBundled() async => (await loadAll())
      .where((item) => item.collection == 'bundled')
      .toList(growable: false);

  Future<List<CharacterPicture>> loadPrivate() async => (await loadAll())
      .where((item) => item.collection == 'private')
      .toList(growable: false);

  Future<List<CharacterPicture>> _installBundledImages(
    List<CharacterPicture> current,
  ) async {
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
      final dimensions = await _validatedDimensions(extension, bytes);
      if (dimensions == null) continue;
      final digest = sha256.convert(bytes).toString();
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
    if (changed || collectionCorrected) await _writeIndex(result);
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
    await _writeIndex(<CharacterPicture>[...existing, item]);
    return item;
  }

  /// Imports a private offline ZIP package. The archive contains one
  /// `manifest.json` and image files anywhere beneath its root. Manifest
  /// filenames must be basenames, so archive paths are never used as output
  /// paths. Invalid entries are reported while other valid entries are kept.
  Future<PicturePackageImportReport> importPackageBytes(
    List<int> packageBytes,
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
    await _writeIndex(<CharacterPicture>[...existing, ...imported]);
    return PicturePackageImportReport(
      imported: imported.length,
      duplicates: duplicates,
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
    final removed = items.where((item) => item.id == id);
    for (final item in removed) {
      final file = File(item.path);
      if (await file.exists()) await file.delete();
    }
    await _writeIndex(retained);
  }

  Future<void> _writeIndex(List<CharacterPicture> items) async {
    final file = await _indexFile;
    await file.writeAsString(
      jsonEncode(<String, Object?>{
        'schemaVersion': 2,
        'items': items.map((item) => item.toJson()).toList(),
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
    final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
    final frame = await codec.getNextFrame();
    final dimensions = (frame.image.width, frame.image.height);
    frame.image.dispose();
    codec.dispose();
    final (width, height) = dimensions;
    if (width < 400 || height < 400 || (width < 640 && height < 640)) {
      return null;
    }
    return dimensions;
  }

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

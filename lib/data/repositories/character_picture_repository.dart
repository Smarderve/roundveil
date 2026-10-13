import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';

class CharacterPicture {
  const CharacterPicture({
    required this.id,
    required this.name,
    required this.path,
    this.hint = '',
    this.sourceTitle = '',
    this.sourceUrl = '',
    this.license = '',
  });

  final String id;
  final String name;
  final String path;
  final String hint;
  final String sourceTitle;
  final String sourceUrl;
  final String license;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'path': path,
    'hint': hint,
    'sourceTitle': sourceTitle,
    'sourceUrl': sourceUrl,
    'license': license,
  };

  factory CharacterPicture.fromJson(Map<String, Object?> json) =>
      CharacterPicture(
        id: json['id']! as String,
        name: json['name']! as String,
        path: json['path']! as String,
        hint: json['hint'] as String? ?? '',
        sourceTitle: json['sourceTitle'] as String? ?? '',
        sourceUrl: json['sourceUrl'] as String? ?? '',
        license: json['license'] as String? ?? '',
      );
}

/// Private, offline image library for Character Picture Mode.
///
/// Nothing is downloaded or uploaded. Importing copies the chosen local image
/// into ROUNDVEIL's app-private data directory and retains optional provenance.
class CharacterPictureRepository {
  CharacterPictureRepository({Future<Directory> Function()? directoryProvider})
    : _directoryProvider = directoryProvider ?? _applicationDataDirectory;

  final Future<Directory> Function() _directoryProvider;

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
    if (!await file.exists()) return const <CharacterPicture>[];
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, Object?> || decoded['items'] is! List) {
      throw const FormatException('Character picture index is invalid.');
    }
    final items = (decoded['items']! as List<Object?>)
        .map((item) => CharacterPicture.fromJson(item! as Map<String, Object?>))
        .where((item) => File(item.path).existsSync())
        .toList(growable: false);
    return List<CharacterPicture>.unmodifiable(items);
  }

  Future<List<CharacterPicture>> importImages({
    required String subjectName,
    String hint = '',
    String sourceTitle = '',
    String sourceUrl = '',
    String license = '',
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
    final encoded = base64Url.encode(bytes);
    for (final item in existing) {
      final file = File(item.path);
      if (await file.exists() &&
          base64Url.encode(await file.readAsBytes()) == encoded) {
        return null;
      }
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
      hint: hint.trim(),
      sourceTitle: sourceTitle.trim(),
      sourceUrl: sourceUrl.trim(),
      license: license.trim(),
    );
    await _writeIndex(<CharacterPicture>[...existing, item]);
    return item;
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
        'schemaVersion': 1,
        'items': items.map((item) => item.toJson()).toList(),
      }),
      flush: true,
    );
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

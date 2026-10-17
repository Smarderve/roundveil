import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';
import 'package:roundveil/data/repositories/character_picture_catalog.dart';

/// Local-only content management for the user-owned Picture Mode collection.
class CharacterPictureLibraryPage extends StatefulWidget {
  const CharacterPictureLibraryPage({super.key});

  @override
  State<CharacterPictureLibraryPage> createState() =>
      _CharacterPictureLibraryPageState();
}

class _CharacterPictureLibraryPageState
    extends State<CharacterPictureLibraryPage> {
  final CharacterPictureRepository _repository = CharacterPictureRepository();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _hint = TextEditingController();
  final TextEditingController _source = TextEditingController();
  final TextEditingController _license = TextEditingController();
  final TextEditingController _franchise = TextEditingController();
  final TextEditingController _aliases = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _attribution = TextEditingController();
  final TextEditingController _imageUrl = TextEditingController();
  final TextEditingController _search = TextEditingController();
  late Future<List<CharacterPicture>> _items = _repository.loadAll();
  String _category = 'Marvel Characters';
  String _difficulty = 'Mixed';
  String _collectionFilter = 'all';
  String _categoryFilter = 'all';
  String _difficultyFilter = 'all';
  bool _showHidden = false;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _hint.dispose();
    _source.dispose();
    _license.dispose();
    _franchise.dispose();
    _aliases.dispose();
    _description.dispose();
    _attribution.dispose();
    _imageUrl.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the subject shown in the image.')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final items = await _repository.importImages(
        subjectName: _name.text,
        category: _category,
        aliases: _aliases.text
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList(growable: false),
        hint: _hint.text,
        franchise: _franchise.text,
        description: _description.text,
        sourceTitle: _source.text.trim(),
        sourceUrl: _source.text.trim().startsWith('http')
            ? _source.text.trim()
            : '',
        license: _license.text,
        attribution: _attribution.text,
        subjectType:
            _category.endsWith('Actors and Actresses') ||
                _category == 'Hollywood Actors' ||
                _category == 'Footballers' ||
                _category == 'Historical Presidents' ||
                _category == 'Other People'
            ? 'Person'
            : 'Fictional character',
        difficulty: _difficulty,
        collection: 'private',
      );
      if (!mounted) return;
      setState(() {
        _items = Future<List<CharacterPicture>>.value(items);
        _name.clear();
        _hint.clear();
        _aliases.clear();
        _description.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Picture collection updated offline.')),
      );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.toString().replaceFirst('FormatException: ', ''),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(CharacterPicture item) async {
    final bundled = item.collection == 'bundled';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          bundled ? 'Remove bundled character?' : 'Delete this character?',
        ),
        content: Text(
          bundled
              ? 'This bundled character will be excluded from your collection and games on this device.'
              : 'This removes the private-library record and its managed image from this device. Other files are not touched.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _repository.remove(item.id);
    if (!mounted) return;
    final updated = await _repository.loadAll();
    setState(() => _items = Future<List<CharacterPicture>>.value(updated));
  }

  Future<void> _toggleHidden(CharacterPicture item) async {
    await _repository.setHidden(item.id, hidden: !item.hidden);
    if (!mounted) return;
    final updated = await _repository.loadAll();
    setState(() => _items = Future<List<CharacterPicture>>.value(updated));
  }

  Future<void> _importPackage() async {
    setState(() => _busy = true);
    try {
      final selection = await FilePicker.pickFiles(
        dialogTitle: 'Import ROUNDVEIL character collection',
        type: FileType.custom,
        allowedExtensions: const <String>['zip'],
      );
      if (selection.isEmpty) return;
      final bytes = await selection.single.readAsBytes();
      final report = await _repository.importPackageBytes(bytes);
      if (!mounted) return;
      setState(() {
        _items = _repository.loadAll();
      });
      final detail = report.errors.isEmpty
          ? ''
          : ' ${report.errors.length} invalid record(s) skipped.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imported ${report.imported}; duplicate images skipped: ${report.duplicates}.$detail',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Collection import failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFolder() async {
    try {
      final path = await FilePicker.getDirectoryPath(
        dialogTitle: 'Choose a folder of character images',
      );
      if (path == null) return;
      final files = await Directory(path)
          .list(recursive: true, followLinks: false)
          .where((entry) => entry is File && _isImageFilename(entry.path))
          .cast<File>()
          .take(501)
          .toList();
      if (files.isEmpty) {
        throw const FormatException('No supported images were found.');
      }
      if (files.length > 500) {
        throw const FormatException(
          'Choose a folder with 500 images or fewer.',
        );
      }
      var totalBytes = 0;
      final images = <_BulkPictureImage>[];
      for (final file in files) {
        final bytes = await file.readAsBytes();
        totalBytes += bytes.length;
        if (totalBytes > 500 * 1024 * 1024) {
          throw const FormatException(
            'The selected folder exceeds the 500 MB import limit.',
          );
        }
        images.add(
          _BulkPictureImage(
            filename: file.path
                .substring(path.length)
                .replaceAll('\\', '/')
                .replaceFirst(RegExp(r'^/'), ''),
            bytes: bytes,
          ),
        );
      }
      await _reviewAndInstall(images);
    } on Object catch (error) {
      if (mounted) _showImportError(error);
    }
  }

  Future<void> _importImageZip() async {
    try {
      final selection = await FilePicker.pickFiles(
        dialogTitle: 'Choose a ZIP of character images',
        type: FileType.custom,
        allowedExtensions: const <String>['zip'],
      );
      if (selection.isEmpty) return;
      final bytes = await selection.single.readAsBytes();
      if (bytes.length > 500 * 1024 * 1024) {
        throw const FormatException('The ZIP must be smaller than 500 MB.');
      }
      final archive = ZipDecoder().decodeBytes(bytes);
      final images = <_BulkPictureImage>[];
      var expandedBytes = 0;
      for (final entry in archive.files) {
        if (!entry.isFile ||
            entry.isSymbolicLink ||
            !_isImageFilename(entry.name)) {
          continue;
        }
        if (entry.name.startsWith('/') ||
            entry.name
                .replaceAll('\\', '/')
                .split('/')
                .any((part) => part == '..')) {
          throw const FormatException('The ZIP contains an unsafe path.');
        }
        expandedBytes += entry.size;
        if (expandedBytes > 500 * 1024 * 1024 || images.length >= 500) {
          throw const FormatException(
            'The ZIP exceeds the 500-image / 500 MB import limit.',
          );
        }
        final imageBytes = entry.readBytes();
        if (imageBytes != null) {
          images.add(
            _BulkPictureImage(filename: entry.name, bytes: imageBytes),
          );
        }
      }
      if (images.isEmpty) {
        throw const FormatException('The ZIP contains no supported images.');
      }
      await _reviewAndInstall(images);
    } on Object catch (error) {
      if (mounted) _showImportError(error);
    }
  }

  static bool _isImageFilename(String path) => const <String>{
    'png',
    'jpg',
    'jpeg',
    'webp',
  }.contains(path.split('.').last.toLowerCase());

  String? _categoryHintFromPath(String path) {
    final segments = path.replaceAll('\\', '/').split('/');
    const hints = <String, String>{
      'marvel': 'Marvel Characters',
      'dc': 'DC Characters',
      'anime': 'Anime Characters',
      'cartoon': 'Cartoon Characters',
      'disney': 'Disney Characters',
      'dreamworks': 'DreamWorks Characters',
    };
    final found = <String>{};
    for (final segment in segments.take(segments.length - 1)) {
      final normalized = normalizeCharacterPictureName(segment);
      for (final entry in hints.entries) {
        if (normalized == entry.key || normalized == '${entry.key}characters') {
          found.add(entry.value);
        }
      }
    }
    return found.length == 1 ? found.single : null;
  }

  Future<void> _reviewAndInstall(List<_BulkPictureImage> images) async {
    final review = images
        .map((image) {
          final categoryHint = _categoryHintFromPath(image.filename);
          return _BulkPictureReviewItem(
            image,
            matchCharacterPictureCatalogFilename(
              image.filename.split('/').last,
              categoryHint: categoryHint,
            ),
          );
        })
        .toList(growable: false);
    var permissionConfirmed = false;
    final selected = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('REVIEW ${review.length} LOCAL IMAGES'),
          content: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 80).clamp(320.0, 760.0),
            height: (MediaQuery.sizeOf(context).height - 190).clamp(
              240.0,
              520.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Exact filenames are matched to the prepared character catalog. Correct uncertain matches or leave them skipped. No image is installed until you confirm.',
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: review.length,
                    itemBuilder: (context, index) {
                      final item = review[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 58,
                          height: 58,
                          child: Image.memory(
                            item.image.bytes,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                        title: Text(
                          item.image.filename,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: DropdownButton<String?>(
                          isExpanded: true,
                          value: item.entry?.id,
                          hint: const Text(
                            'Unmatched · skip or choose identity',
                          ),
                          items: <DropdownMenuItem<String?>>[
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('SKIP THIS IMAGE'),
                            ),
                            ...characterPictureCatalog.map(
                              (entry) => DropdownMenuItem<String?>(
                                value: entry.id,
                                child: Text(
                                  '${entry.name} · ${entry.category}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) => setDialogState(() {
                            item.entry = value == null
                                ? null
                                : characterPictureCatalog.firstWhere(
                                    (entry) => entry.id == value,
                                  );
                          }),
                        ),
                        trailing: item.entry == null
                            ? const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.white38,
                              )
                            : const Icon(
                                Icons.check_circle_outline,
                                color: Color(0xFF42D5E8),
                              ),
                      );
                    },
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: permissionConfirmed,
                  onChanged: (value) => setDialogState(
                    () => permissionConfirmed = value ?? false,
                  ),
                  title: const Text(
                    'I am authorized to keep and use these images in my private offline family collection.',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed:
                  permissionConfirmed &&
                      review.any((item) => item.entry != null)
                  ? () => Navigator.pop(dialogContext, true)
                  : null,
              child: Text(
                'INSTALL ${review.where((item) => item.entry != null).length} IMAGES',
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != true || !mounted) return;
    setState(() => _busy = true);
    try {
      final batch = <PrivateCharacterImageImport>[];
      for (final item in review) {
        final entry = item.entry;
        if (entry == null) continue;
        batch.add(
          PrivateCharacterImageImport(
            filename: item.image.filename,
            bytes: item.image.bytes,
            name: entry.name,
            category: entry.category,
            franchise: entry.franchise,
            series: entry.series,
            aliases: entry.aliases,
            hint: entry.hint,
            difficulty: entry.difficulty,
            description:
                'Series: ${entry.series}. Metadata reference: ${entry.reference}',
          ),
        );
      }
      final report = await _repository.importPrivateImageBatch(batch);
      if (!mounted) return;
      setState(() => _items = _repository.loadAll());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Installed ${report.imported}; duplicates skipped: ${report.duplicates}; invalid images: ${report.errors.length}.',
          ),
          duration: const Duration(seconds: 8),
        ),
      );
    } on Object catch (error) {
      if (mounted) _showImportError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFromImageUrl() async {
    final uri = Uri.tryParse(_imageUrl.text.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      _showImportError(
        const FormatException('Enter a public HTTPS image URL.'),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _PrivateUrlPermissionDialog(uri: uri),
    );
    if (confirmed != true || !mounted) return;
    final catalogEntry = characterPictureCatalog
        .where(
          (entry) =>
              normalizeCharacterPictureName(entry.name) ==
                  normalizeCharacterPictureName(_name.text) ||
              entry.aliases.any(
                (alias) =>
                    normalizeCharacterPictureName(alias) ==
                    normalizeCharacterPictureName(_name.text),
              ),
        )
        .firstOrNull;
    setState(() => _busy = true);
    try {
      final item = await _repository.importPrivateImageUrl(
        uri: uri,
        name: catalogEntry?.name ?? _name.text.trim(),
        category: catalogEntry?.category ?? _category,
        franchise: catalogEntry?.franchise ?? _franchise.text,
        hint: catalogEntry?.hint ?? _hint.text,
        aliases:
            catalogEntry?.aliases ??
            _aliases.text
                .split(',')
                .map((value) => value.trim())
                .where((value) => value.isNotEmpty)
                .toList(),
        difficulty: catalogEntry?.difficulty ?? _difficulty,
        attribution: _attribution.text,
        permissionConfirmed: true,
      );
      if (item == null) {
        throw const FormatException(
          'This image is already in the local collection.',
        );
      }
      if (!mounted) return;
      setState(() {
        _items = _repository.loadAll();
        _imageUrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved for offline private play.')),
      );
    } on Object catch (error) {
      if (mounted) _showImportError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showImportError(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString().replaceFirst('FormatException: ', '')),
      ),
    );
  }

  Future<void> _exportPackage() async {
    setState(() => _busy = true);
    try {
      final bytes = await _repository.exportPackageBytes();
      final destination = await FilePicker.saveFile(
        fileName: 'roundveil-character-collection.zip',
        bytes: Uint8List.fromList(bytes),
        dialogTitle: 'Export private character collection',
        type: FileType.custom,
        allowedExtensions: const <String>['zip'],
      );
      if (destination != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Private collection package exported.')),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Collection export failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showCharacterCatalog() async {
    final installed = await _repository.loadAll();
    final hiddenCatalogKeys = await _repository.loadHiddenCatalogKeys();
    if (!mounted) return;
    final installedIdentities = <String>{
      for (final item in installed)
        '${item.category}|${normalizeCharacterPictureName(item.name)}',
    };
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('FICTIONAL CHARACTER CATALOG · 60 IDENTITIES'),
          content: SizedBox(
            width: (MediaQuery.sizeOf(context).width - 80).clamp(320.0, 700.0),
            height: (MediaQuery.sizeOf(context).height - 190).clamp(
              240.0,
              520.0,
            ),
            child: ListView(
              children: <Widget>[
                for (final category in const <String>[
                  'Marvel Characters',
                  'DC Characters',
                  'Anime Characters',
                  'Cartoon Characters',
                  'Disney Characters',
                  'DreamWorks Characters',
                ])
                  Builder(
                    builder: (context) {
                      final entries = characterPictureCatalog
                          .where((entry) => entry.category == category)
                          .toList();
                      final count = entries
                          .where(
                            (entry) => installedIdentities.contains(
                              '$category|${normalizeCharacterPictureName(entry.name)}',
                            ),
                          )
                          .length;
                      return ExpansionTile(
                        title: Text(
                          '$category · $count/${entries.length} images',
                        ),
                        children: entries.map((entry) {
                          final hasImage = installedIdentities.contains(
                            '$category|${normalizeCharacterPictureName(entry.name)}',
                          );
                          final key = _repository.catalogKey(
                            category,
                            entry.name,
                          );
                          final hidden = hiddenCatalogKeys.contains(key);
                          return ListTile(
                            dense: true,
                            title: Text(entry.name),
                            subtitle: Text(
                              '${entry.series} · ${entry.difficulty} · ${entry.hint}${hasImage ? ' · INSTALLED' : ' · CATALOG ONLY'}${hidden ? ' · HIDDEN' : ''}',
                            ),
                            trailing: IconButton(
                              tooltip: hidden
                                  ? 'Restore catalog entry'
                                  : 'Hide catalog entry',
                              onPressed: () async {
                                await _repository.setCatalogHidden(
                                  category,
                                  entry.name,
                                  hidden: !hidden,
                                );
                                setDialogState(() {
                                  if (hidden) {
                                    hiddenCatalogKeys.remove(key);
                                  } else {
                                    hiddenCatalogKeys.add(key);
                                  }
                                });
                              },
                              icon: Icon(
                                hidden
                                    ? Icons.visibility_off_outlined
                                    : hasImage
                                    ? Icons.check_circle
                                    : Icons.image_not_supported_outlined,
                                color: hidden
                                    ? Colors.orangeAccent
                                    : hasImage
                                    ? const Color(0xFF42D5E8)
                                    : Colors.white38,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050D1C),
    appBar: AppBar(
      title: const Text('CHARACTER PICTURE LIBRARY'),
      backgroundColor: const Color(0xFF08182B),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Text(
                            'PRIVATE FAMILY COLLECTION · Choose a local image, enter its character details and category, then play offline. Nothing is uploaded. Keep privately imported images out of public builds unless you have redistribution permission.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 12),
                          SegmentedButton<String>(
                            segments: const <ButtonSegment<String>>[
                              ButtonSegment(
                                value: 'all',
                                label: Text('ALL LOCAL'),
                              ),
                              ButtonSegment(
                                value: 'bundled',
                                label: Text('BUNDLED'),
                              ),
                              ButtonSegment(
                                value: 'private',
                                label: Text('PRIVATE FAMILY'),
                              ),
                            ],
                            selected: <String>{_collectionFilter},
                            onSelectionChanged: (value) =>
                                setState(() => _collectionFilter = value.first),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: <Widget>[
                              SizedBox(
                                width: 240,
                                child: TextField(
                                  controller: _search,
                                  decoration: const InputDecoration(
                                    labelText: 'Search by character',
                                    isDense: true,
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              SizedBox(
                                width: 220,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _categoryFilter,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Filter category',
                                    isDense: true,
                                  ),
                                  items: <DropdownMenuItem<String>>[
                                    const DropdownMenuItem(
                                      value: 'all',
                                      child: Text('All categories'),
                                    ),
                                    ...characterPictureCategories.map(
                                      (value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(
                                          value,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) => setState(
                                    () => _categoryFilter = value ?? 'all',
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: DropdownButtonFormField<String>(
                                  initialValue: _difficultyFilter,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Difficulty',
                                    isDense: true,
                                  ),
                                  items:
                                      const <String>[
                                            'all',
                                            'Easy',
                                            'Medium',
                                            'Hard',
                                            'Expert',
                                            'Mixed',
                                          ]
                                          .map(
                                            (value) => DropdownMenuItem(
                                              value: value,
                                              child: Text(
                                                value == 'all'
                                                    ? 'All difficulty'
                                                    : value,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) => setState(
                                    () => _difficultyFilter = value ?? 'all',
                                  ),
                                ),
                              ),
                              FilterChip(
                                label: const Text('Show hidden'),
                                selected: _showHidden,
                                onSelected: (value) =>
                                    setState(() => _showHidden = value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ExpansionTile(
                            tilePadding: EdgeInsets.zero,
                            title: const Text('ADD OR IMPORT CHARACTERS'),
                            children: <Widget>[
                              Wrap(
                                spacing: 10,
                                runSpacing: 8,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 220,
                                    child: TextField(
                                      controller: _name,
                                      decoration: const InputDecoration(
                                        labelText: 'Subject name',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 300,
                                    child: TextField(
                                      controller: _imageUrl,
                                      keyboardType: TextInputType.url,
                                      decoration: const InputDecoration(
                                        labelText: 'Authorized HTTPS image URL',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: TextField(
                                      controller: _hint,
                                      decoration: const InputDecoration(
                                        labelText: 'Optional individual hint',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 260,
                                    child: TextField(
                                      controller: _source,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Source title or URL (optional)',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 190,
                                    child: TextField(
                                      controller: _license,
                                      decoration: const InputDecoration(
                                        labelText: 'License note (optional)',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _category,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Character category',
                                        isDense: true,
                                      ),
                                      items: characterPictureCategories
                                          .map(
                                            (value) => DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _category = value);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 190,
                                    child: TextField(
                                      controller: _franchise,
                                      decoration: const InputDecoration(
                                        labelText: 'Film / series / franchise',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: TextField(
                                      controller: _aliases,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Accepted names (comma-separated)',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: TextField(
                                      controller: _description,
                                      decoration: const InputDecoration(
                                        labelText: 'Identity/context note',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: TextField(
                                      controller: _attribution,
                                      decoration: const InputDecoration(
                                        labelText: 'Creator / attribution',
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _difficulty,
                                      isExpanded: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Difficulty',
                                        isDense: true,
                                      ),
                                      items:
                                          const <String>[
                                                'Easy',
                                                'Medium',
                                                'Hard',
                                                'Expert',
                                                'Mixed',
                                              ]
                                              .map(
                                                (value) =>
                                                    DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    ),
                                              )
                                              .toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _difficulty = value);
                                        }
                                      },
                                    ),
                                  ),
                                  FilledButton.icon(
                                    onPressed: _busy ? null : _import,
                                    icon: const Icon(
                                      Icons.add_photo_alternate_outlined,
                                    ),
                                    label: Text(
                                      _busy ? 'IMPORTING…' : 'IMPORT PICTURE',
                                    ),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _busy ? null : _importPackage,
                                    icon: const Icon(Icons.archive_outlined),
                                    label: const Text('IMPORT COLLECTION ZIP'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _busy ? null : _importFolder,
                                    icon: const Icon(
                                      Icons.folder_open_outlined,
                                    ),
                                    label: const Text('REVIEW IMAGE FOLDER'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : _showCharacterCatalog,
                                    icon: const Icon(
                                      Icons.auto_stories_outlined,
                                    ),
                                    label: const Text('VIEW CHARACTER CATALOG'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _busy ? null : _importImageZip,
                                    icon: const Icon(Icons.archive_outlined),
                                    label: const Text('REVIEW IMAGE ZIP'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : _importFromImageUrl,
                                    icon: const Icon(Icons.download_outlined),
                                    label: const Text('SAVE URL IMAGE'),
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _busy ? null : _exportPackage,
                                    icon: const Icon(Icons.ios_share_rounded),
                                    label: const Text('EXPORT COLLECTION ZIP'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0x335AD9FF)),
                    FutureBuilder<List<CharacterPicture>>(
                      future: _items,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Library could not be read: ${snapshot.error}',
                            ),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final allItems = snapshot.data!;
                        final items = allItems
                            .where(
                              (item) =>
                                  _collectionFilter == 'all' ||
                                  item.collection == _collectionFilter,
                            )
                            .where((item) => _showHidden || !item.hidden)
                            .where(
                              (item) =>
                                  _categoryFilter == 'all' ||
                                  item.category == _categoryFilter,
                            )
                            .where(
                              (item) =>
                                  _difficultyFilter == 'all' ||
                                  item.difficulty == _difficultyFilter,
                            )
                            .where(
                              (item) => item.name.toLowerCase().contains(
                                _search.text.trim().toLowerCase(),
                              ),
                            )
                            .toList(growable: false);
                        if (items.isEmpty) {
                          return const Center(
                            child: Text(
                              'No pictures in this collection yet. Import a local image with its name, category and useful clue. Images stay on this device.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }
                        final hiddenCount = allItems
                            .where((item) => item.hidden)
                            .length;
                        final visibleCount = allItems.length - hiddenCount;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                              child: Text(
                                '${allItems.length} characters · $visibleCount visible to games · $hiddenCount hidden',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(18),
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 190,
                                    mainAxisExtent: 220,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return DecoratedBox(
                                  key: ValueKey<String>(item.id),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B1B2E),
                                    border: Border.all(
                                      color: const Color(0x4460D9FF),
                                    ),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Image.file(
                                          File(item.path),
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, _, _) => const Icon(
                                            Icons.broken_image_outlined,
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                '${item.collection == 'bundled' ? 'BUNDLED' : 'INSTALLED · PRIVATE'}${item.hidden ? ' · HIDDEN' : ''}',
                                                style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item.difficulty,
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          8,
                                          4,
                                          4,
                                          8,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: item.hidden
                                                  ? 'Restore ${item.name} to games'
                                                  : 'Hide ${item.name} from games',
                                              onPressed: () =>
                                                  _toggleHidden(item),
                                              icon: Icon(
                                                item.hidden
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                              ),
                                            ),
                                            IconButton(
                                              tooltip:
                                                  item.collection == 'bundled'
                                                  ? 'Exclude ${item.name}'
                                                  : 'Delete ${item.name}',
                                              onPressed: () => _remove(item),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BulkPictureImage {
  const _BulkPictureImage({required this.filename, required this.bytes});

  final String filename;
  final Uint8List bytes;
}

class _BulkPictureReviewItem {
  _BulkPictureReviewItem(this.image, this.entry);

  final _BulkPictureImage image;
  CharacterPictureCatalogEntry? entry;
}

class _PrivateUrlPermissionDialog extends StatefulWidget {
  const _PrivateUrlPermissionDialog({required this.uri});

  final Uri uri;

  @override
  State<_PrivateUrlPermissionDialog> createState() =>
      _PrivateUrlPermissionDialogState();
}

class _PrivateUrlPermissionDialogState
    extends State<_PrivateUrlPermissionDialog> {
  bool confirmed = false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('SAVE A PRIVATE IMAGE'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(widget.uri.host),
        const SizedBox(height: 12),
        const Text(
          'ROUNDVEIL only fetches this URL once. It does not determine whether the source permits downloading or offline use.',
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: confirmed,
          onChanged: (value) => setState(() => confirmed = value ?? false),
          title: const Text(
            'I checked the source terms and am authorized to save and use this image privately offline.',
          ),
        ),
      ],
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('CANCEL'),
      ),
      FilledButton(
        onPressed: confirmed ? () => Navigator.pop(context, true) : null,
        child: const Text('DOWNLOAD IMAGE'),
      ),
    ],
  );
}

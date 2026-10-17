import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:roundveil/data/repositories/character_picture_repository.dart';

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
  late Future<List<CharacterPicture>> _items = _repository.loadAll();
  String _category = 'Marvel Characters';
  String _difficulty = 'Mixed';
  String _collectionFilter = 'all';
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
    await _repository.remove(item.id);
    if (mounted) {
      setState(() {
        _items = _repository.loadAll();
      });
    }
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
                      ButtonSegment(value: 'all', label: Text('ALL LOCAL')),
                      ButtonSegment(value: 'bundled', label: Text('BUNDLED')),
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
                            labelText: 'Source title or URL (optional)',
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
                            labelText: 'Accepted names (comma-separated)',
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
                                    (value) => DropdownMenuItem<String>(
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
                        icon: const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(_busy ? 'IMPORTING…' : 'IMPORT PICTURE'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _busy ? null : _importPackage,
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('IMPORT COLLECTION ZIP'),
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
            ),
            const Divider(height: 1, color: Color(0x335AD9FF)),
            Expanded(
              child: FutureBuilder<List<CharacterPicture>>(
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  final allItems = snapshot.data!;
                  final items = allItems
                      .where(
                        (item) =>
                            _collectionFilter == 'all' ||
                            item.collection == _collectionFilter,
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
                  return GridView.builder(
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
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1B2E),
                          border: Border.all(color: const Color(0x4460D9FF)),
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
                              padding: const EdgeInsets.fromLTRB(8, 4, 4, 8),
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
                                    tooltip: 'Remove ${item.name}',
                                    onPressed: () => _remove(item),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

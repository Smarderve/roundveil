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
  late Future<List<CharacterPicture>> _items = _repository.loadAll();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _hint.dispose();
    _source.dispose();
    _license.dispose();
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
        hint: _hint.text,
        sourceTitle: _source.text.trim(),
        sourceUrl: _source.text.trim().startsWith('http')
            ? _source.text.trim()
            : '',
        license: _license.text,
      );
      if (!mounted) return;
      setState(() {
        _items = Future<List<CharacterPicture>>.value(items);
        _name.clear();
        _hint.clear();
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
                    'Images stay on this device. Import a clear PNG, JPEG or WebP; add a source link and license note when you have them. ROUNDVEIL does not download or upload images.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
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
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pictures yet. Import photos or character artwork you are permitted to use.',
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

import 'package:flutter_test/flutter_test.dart';
import 'package:roundveil/data/repositories/character_picture_catalog.dart';

void main() {
  test(
    'fictional catalog contains ten fully described entries per category',
    () {
      const categories = <String>[
        'Marvel Characters',
        'DC Characters',
        'Anime Characters',
        'Cartoon Characters',
        'Disney Characters',
        'DreamWorks Characters',
      ];
      expect(characterPictureCatalog, hasLength(60));
      expect(
        characterPictureCatalog.map((entry) => entry.id).toSet(),
        hasLength(60),
      );
      for (final category in categories) {
        final entries = characterPictureCatalog
            .where((entry) => entry.category == category)
            .toList();
        expect(entries, hasLength(10), reason: category);
        expect(
          entries.every(
            (entry) =>
                entry.name.isNotEmpty &&
                entry.franchise.isNotEmpty &&
                entry.series.isNotEmpty &&
                entry.hint.isNotEmpty &&
                entry.aliases.isNotEmpty &&
                entry.reference.contains('https://'),
          ),
          isTrue,
          reason: category,
        );
      }
    },
  );

  test('catalog matcher accepts exact filenames and aliases only', () {
    expect(
      matchCharacterPictureCatalogFilename('Spider-Man.webp')?.id,
      'marvel-spider-man',
    );
    expect(
      matchCharacterPictureCatalogFilename('Kakarot.jpeg')?.id,
      'anime-goku',
    );
    expect(
      matchCharacterPictureCatalogFilename(
        'Batman.jpg',
        categoryHint: 'Marvel Characters',
      ),
      isNull,
    );
    expect(matchCharacterPictureCatalogFilename('unknown-hero.png'), isNull);
  });
}

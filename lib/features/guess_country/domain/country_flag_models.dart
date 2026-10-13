enum CountryDifficulty { easy, medium, hard, expert, mixed, unrated }

enum CountryRegion {
  africa,
  europe,
  asia,
  americas,
  northAmerica,
  southAmerica,
  oceania,
  other,
  worldwide,
}

class CountryFlag {
  const CountryFlag({
    required this.id,
    required this.name,
    required this.aliases,
    required this.region,
    required this.difficulty,
    required this.assetPath,
    required this.aspectRatio,
    required this.hint,
  });

  final String id;
  final String name;
  final Set<String> aliases;
  final CountryRegion region;
  final CountryDifficulty difficulty;
  final String assetPath;
  final double aspectRatio;
  final String hint;
}

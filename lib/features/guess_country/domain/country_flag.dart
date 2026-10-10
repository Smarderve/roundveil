enum CountryDifficulty { easy, medium, hard, expert, mixed }

enum CountryRegion { africa, americas, asia, europe, oceania, worldwide }

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

const firstSliceFlags = <CountryFlag>[
  CountryFlag(
    id: 'BR',
    name: 'Brazil',
    aliases: {'brasil'},
    region: CountryRegion.americas,
    difficulty: CountryDifficulty.easy,
    assetPath: 'assets/app/flags/br.svg',
    aspectRatio: 10 / 7,
    hint: 'South America',
  ),
  CountryFlag(
    id: 'CA',
    name: 'Canada',
    aliases: <String>{},
    region: CountryRegion.americas,
    difficulty: CountryDifficulty.easy,
    assetPath: 'assets/app/flags/ca.svg',
    aspectRatio: 2,
    hint: 'North America',
  ),
  CountryFlag(
    id: 'FR',
    name: 'France',
    aliases: <String>{},
    region: CountryRegion.europe,
    difficulty: CountryDifficulty.easy,
    assetPath: 'assets/app/flags/fr.svg',
    aspectRatio: 3 / 2,
    hint: 'Europe',
  ),
  CountryFlag(
    id: 'JP',
    name: 'Japan',
    aliases: <String>{},
    region: CountryRegion.asia,
    difficulty: CountryDifficulty.easy,
    assetPath: 'assets/app/flags/jp.svg',
    aspectRatio: 3 / 2,
    hint: 'Asia',
  ),
  CountryFlag(
    id: 'KE',
    name: 'Kenya',
    aliases: <String>{},
    region: CountryRegion.africa,
    difficulty: CountryDifficulty.medium,
    assetPath: 'assets/app/flags/ke.svg',
    aspectRatio: 3 / 2,
    hint: 'East Africa',
  ),
  CountryFlag(
    id: 'US',
    name: 'United States',
    aliases: {'united states of america', 'usa', 'us'},
    region: CountryRegion.americas,
    difficulty: CountryDifficulty.easy,
    assetPath: 'assets/app/flags/us.svg',
    aspectRatio: 1.9,
    hint: 'North America',
  ),
  CountryFlag(
    id: 'ZA',
    name: 'South Africa',
    aliases: <String>{},
    region: CountryRegion.africa,
    difficulty: CountryDifficulty.hard,
    assetPath: 'assets/app/flags/za.svg',
    aspectRatio: 3 / 2,
    hint: 'Southern Africa',
  ),
];

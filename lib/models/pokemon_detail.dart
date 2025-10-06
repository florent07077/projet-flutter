class PokemonStat {
  final int baseStat;
  final int effort;
  final String name;

  PokemonStat({
    required this.baseStat,
    required this.effort,
    required this.name,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(
      baseStat: json['base_stat'] as int,
      effort: json['effort'] as int,
      name: (json['stat'] as Map<String, dynamic>)['name'] as String,
    );
  }
}

class PokemonType {
  final String name;

  PokemonType({required this.name});

  factory PokemonType.fromJson(Map<String, dynamic> json) {
    return PokemonType(
      name: (json['type'] as Map<String, dynamic>)['name'] as String,
    );
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonStat> stats;
  final List<PokemonType> types;
  final Map<String, dynamic>? sprites;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.stats,
    required this.types,
    this.sprites,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      height: json['height'] as int,
      weight: json['weight'] as int,
      stats: (json['stats'] as List)
          .map((e) => PokemonStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      types: (json['types'] as List)
          .map((e) => PokemonType.fromJson(e as Map<String, dynamic>))
          .toList(),
      sprites: json['sprites'] as Map<String, dynamic>?,
    );
  }
}

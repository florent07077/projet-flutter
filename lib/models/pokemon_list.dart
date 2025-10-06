class PokemonListItem {
  final String name;
  final String url;

  PokemonListItem({required this.name, required this.url});

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

class PokemonList {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  PokemonList({required this.count, this.next, this.previous, required this.results});

  factory PokemonList.fromJson(Map<String, dynamic> json) {
    return PokemonList(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List).map((e) => PokemonListItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

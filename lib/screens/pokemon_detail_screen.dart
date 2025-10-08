import 'package:flutter/material.dart';
import '../models/pokemon_detail.dart';
import '../services/poke_api.dart';
import '../services/pokemon_likes_manager.dart';
import 'pokemon_like_screen.dart'; // uniquement si tu veux naviguer vers la page des likes
// Pour naviguer vers la page des likes

class PokemonDetailScreen extends StatefulWidget {
  final String pokemonUrlOrName;

  const PokemonDetailScreen({super.key, required this.pokemonUrlOrName});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokeApi _api = PokeApi();
  late Future<PokemonDetail> _futureDetail;

  bool _isLiked(int id) => PokemonLikesManager.isLiked(id);

  void _toggleLike(int id) {
    PokemonLikesManager.toggleLike(id);
  }

  @override
  void initState() {
    super.initState();
    _futureDetail = _api.fetchPokemonDetail(widget.pokemonUrlOrName);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokemonDetail>(
      future: _futureDetail,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Erreur: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Données manquantes')),
          );
        }

        final p = snapshot.data!;
        final Color typeColor = p.types.isNotEmpty
            ? _getColorForType(p.types.first.name)
            : Colors.grey;

        return ValueListenableBuilder<List<int>>(
          valueListenable: PokemonLikesManager.likedIdsNotifier,
          builder: (context, likedIds, _) {
            return Scaffold(
              appBar: AppBar(
                title: Text('#${p.id} ${_capitalize(p.name)}'),
                backgroundColor: typeColor,
                actions: [
                  IconButton(
                    icon: Icon(
                      _isLiked(p.id) ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked(p.id) ? Colors.red : Colors.white,
                    ),
                    onPressed: () => _toggleLike(p.id),
                  ),
                ],
              ),
              body: Container(
                color: typeColor.withOpacity(0.2),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            if (p.sprites != null)
                              Image.network(
                                p.sprites!['front_default'] ?? '',
                                height: 120,
                                width: 120,
                                errorBuilder: (_, __, ___) => const SizedBox(),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _infoChip('Height', '${p.height}'),
                          const SizedBox(width: 8),
                          _infoChip('Weight', '${p.weight}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Types',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            icon: Icon(
                              _isLiked(p.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isLiked(p.id) ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleLike(p.id),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        children: p.types
                            .map(
                              (t) => Chip(
                                label: Text(_capitalize(t.name)),
                                backgroundColor: _getColorForType(
                                  t.name,
                                ).withOpacity(0.7),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Stats',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ...p.stats.map(
                        (s) => ListTile(
                          title: Text(_capitalize(s.name)),
                          trailing: Text('${s.baseStat}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoChip(String label, String value) =>
      Chip(label: Text('$label: $value'));

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.redAccent;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return const Color.fromARGB(255, 162, 81, 255);
      case 'ice':
        return Colors.cyan;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.black54;
      case 'fairy':
        return Colors.pinkAccent;
      case 'poison':
        return const Color.fromARGB(255, 83, 0, 198);
      case 'bug':
        return const Color.fromARGB(255, 134, 166, 48);
      case 'flying':
        return const Color.fromARGB(255, 255, 255, 255);
      case 'ground':
        return const Color.fromARGB(255, 146, 121, 0);
      case 'rock':
        return const Color.fromARGB(255, 255, 162, 0);
      case 'steel':
        return const Color.fromARGB(255, 192, 192, 192);
      case 'ghost':
        return const Color.fromARGB(255, 89, 89, 89);
      default:
        return Colors.grey;
    }
  }
}

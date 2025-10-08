import 'package:flutter/material.dart';
import '../services/poke_api.dart';
import '../models/pokemon_list.dart';
import '../services/pokemon_likes_manager.dart';
import 'pokemon_detail_screen.dart';

class PokemonLikeScreen extends StatefulWidget {
  const PokemonLikeScreen({super.key});

  @override
  State<PokemonLikeScreen> createState() => _PokemonLikeScreenState();
}

class _PokemonLikeScreenState extends State<PokemonLikeScreen> {
  final PokeApi _api = PokeApi();
  List<PokemonListItem> _likedItems = [];

  @override
  void initState() {
    super.initState();
    _loadLikedPokemon();
  }

  Future<void> _loadLikedPokemon() async {
    final list = await _api.fetchPokemonList(limit: 1302, offset: 0);
    setState(() {
      _likedItems = list.results
          .where(
            (it) =>
                PokemonLikesManager.isLiked(_extractIdFromUrl(it.url) ?? -1),
          )
          .toList();
    });
  }

  int? _extractIdFromUrl(String url) {
    try {
      final parts = url.split('/');
      for (var i = parts.length - 1; i >= 0; i--) {
        final p = parts[i];
        if (p.isNotEmpty) return int.tryParse(p);
      }
    } catch (_) {}
    return null;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  bool _isLiked(int id) => PokemonLikesManager.isLiked(id);

  void _toggleLike(int id) {
    PokemonLikesManager.toggleLike(id);
    setState(() {
      _likedItems.removeWhere((it) => _extractIdFromUrl(it.url) == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: PokemonLikesManager.likedIdsNotifier,
      builder: (context, likedIds, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Pokémon Likés',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color.fromARGB(213, 161, 0, 0),
          ),
          body: _likedItems.isEmpty
              ? const Center(child: Text('Aucun Pokémon en favori'))
              : ListView.separated(
                  itemCount: _likedItems.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _likedItems[index];
                    final id = _extractIdFromUrl(item.url);
                    final spriteUrl =
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

                    return ListTile(
                      leading: Image.network(spriteUrl, width: 56, height: 56),
                      title: Text('#$id ${_capitalize(item.name)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (id != null)
                            IconButton(
                              icon: Icon(
                                _isLiked(id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isLiked(id) ? Colors.red : Colors.grey,
                              ),
                              onPressed: () => _toggleLike(id),
                            ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                PokemonDetailScreen(pokemonUrlOrName: item.url),
                          ),
                        );
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}

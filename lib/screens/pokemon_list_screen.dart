import 'package:flutter/material.dart';
import '../models/pokemon_list.dart';
import '../services/poke_api.dart';
import '../services/pokemon_likes_manager.dart';
import 'pokemon_detail_screen.dart';
import 'pokemon_like_screen.dart';

class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  final PokeApi _api = PokeApi();
  late Future<PokemonList> _futureList;
  List<PokemonListItem> _items = [];
  List<PokemonListItem> _filtered = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _futureList = _api.fetchPokemonList(limit: 1302, offset: 0);
    _futureList
        .then((value) {
          setState(() {
            _items = value.results;
            _filtered = List.from(_items);
          });
        })
        .catchError((_) {});
    _searchController.addListener(_onSearchChanged);
  }

  bool _isLiked(int id) => PokemonLikesManager.isLiked(id);

  void _toggleLike(int id) {
    PokemonLikesManager.toggleLike(id);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: PokemonLikesManager.likedIdsNotifier,
      builder: (context, likedIds, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(213, 161, 0, 0),
            title: const Text('Pokédex', style: TextStyle(color: Colors.white)),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PokemonLikeScreen(),
                    ),
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Recherche par nom ou id...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 203, 203),
                      suffixIcon: _isSearching
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (q) => _onSearchSubmitted(q),
                  ),
                ),
              ),
            ),
          ),
          body: FutureBuilder<PokemonList>(
            future: _futureList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.results.isEmpty) {
                return const Center(child: Text('Aucun Pokémon trouvé'));
              }

              return _buildListView();
            },
          ),
        );
      },
    );
  }

  Widget _buildListView() {
    final display = _filtered.isNotEmpty ? _filtered : _items;
    return ListView.separated(
      itemCount: display.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = display[index];
        final id = _extractIdFromUrl(item.url);
        final spriteUrl = id != null
            ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png'
            : null;

        return ListTile(
          leading: spriteUrl != null
              ? Image.network(spriteUrl, width: 56, height: 56)
              : const SizedBox(width: 56, height: 56),
          title: Text(
            '${id != null ? '#$id' : '#?'} ${_capitalize(item.name)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (id != null)
                IconButton(
                  icon: Icon(
                    _isLiked(id) ? Icons.favorite : Icons.favorite_border,
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
                builder: (_) => PokemonDetailScreen(pokemonUrlOrName: item.url),
              ),
            );
          },
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  int? _extractIdFromUrl(String url) {
    try {
      final parts = url.split('/');
      for (var i = parts.length - 1; i >= 0; i--) {
        final p = parts[i];
        if (p.isNotEmpty) {
          final id = int.tryParse(p);
          if (id != null) return id;
          break;
        }
      }
    } catch (_) {}
    return null;
  }

  void _onSearchChanged() {
    final q = _searchController.text.trim();
    setState(() {
      _isSearching = q.isNotEmpty;
      if (q.isEmpty) {
        _filtered = List.from(_items);
      } else {
        final lower = q.toLowerCase();
        _filtered = _items.where((it) {
          if (it.name.toLowerCase().contains(lower)) return true;
          final id = _extractIdFromUrl(it.url);
          if (id != null && id.toString() == lower) return true;
          return false;
        }).toList();
      }
    });
  }

  Future<void> _onSearchSubmitted(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;
    try {
      final detail = await _api.fetchPokemonDetail(query);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              PokemonDetailScreen(pokemonUrlOrName: detail.id.toString()),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun Pokémon trouvé pour "$query"')),
      );
    }
  }
}

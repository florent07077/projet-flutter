import 'package:flutter/material.dart';

import '../models/pokemon_detail.dart';
import '../services/poke_api.dart';

class PokemonDetailScreen extends StatefulWidget {
  final String pokemonUrlOrName;

  const PokemonDetailScreen({super.key, required this.pokemonUrlOrName});

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  final PokeApi _api = PokeApi();
  late Future<PokemonDetail> _futureDetail;

  @override
  void initState() {
    super.initState();
    _futureDetail = _api.fetchPokemonDetail(widget.pokemonUrlOrName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiche Pokémon')),
      body: FutureBuilder<PokemonDetail>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Données manquantes'));
          }

          final p = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text('#${p.id} ${_capitalize(p.name)}', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      if (p.sprites != null)
                        Image.network(p.sprites!['front_default'] ?? '', height: 120, width: 120, errorBuilder: (_, __, ___) => const SizedBox()),
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
                Text('Types', style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: p.types.map((t) => Chip(label: Text(_capitalize(t.name)))).toList(),
                ),
                const SizedBox(height: 12),
                Text('Stats', style: Theme.of(context).textTheme.titleMedium),
                ...p.stats.map((s) => ListTile(
                      title: Text(_capitalize(s.name)),
                      trailing: Text('${s.baseStat}'),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoChip(String label, String value) => Chip(label: Text('$label: $value'));

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

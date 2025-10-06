import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../models/pokemon_list.dart';
import '../models/pokemon_detail.dart';

class PokeApi {
  static const String base = 'https://pokeapi.co/api/v2';

  final http.Client _client;

  PokeApi({http.Client? client}) : _client = client ?? http.Client();

  Future<PokemonList> fetchPokemonList({
    int limit = 100,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$base/pokemon?limit=$limit&offset=$offset');
    final res = await _client.get(uri);
    if (res.statusCode == 200) {
      return compute(_parsePokemonList, res.body);
    }
    throw Exception('Failed to load pokemon list: ${res.statusCode}');
  }

  static PokemonList _parsePokemonList(String body) {
    final Map<String, dynamic> jsonMap =
        json.decode(body) as Map<String, dynamic>;
    return PokemonList.fromJson(jsonMap);
  }

  Future<PokemonDetail> fetchPokemonDetail(String urlOrName) async {
    Uri uri;
    if (urlOrName.startsWith('http')) {
      uri = Uri.parse(urlOrName);
    } else {
      uri = Uri.parse('$base/pokemon/$urlOrName');
    }
    final res = await _client.get(uri);
    if (res.statusCode == 200) {
      return compute(_parsePokemonDetail, res.body);
    }
    throw Exception('Failed to load pokemon detail: ${res.statusCode}');
  }

  static PokemonDetail _parsePokemonDetail(String body) {
    final Map<String, dynamic> jsonMap =
        json.decode(body) as Map<String, dynamic>;
    return PokemonDetail.fromJson(jsonMap);
  }
}

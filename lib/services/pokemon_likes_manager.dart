import 'package:flutter/material.dart';

class PokemonLikesManager {
  static final ValueNotifier<List<int>> likedIdsNotifier = ValueNotifier([]);

  static void toggleLike(int id) {
    final current = List<int>.from(likedIdsNotifier.value);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    likedIdsNotifier.value = current;
  }

  static bool isLiked(int id) => likedIdsNotifier.value.contains(id);
}

import 'package:flutter/material.dart';
import 'package:shelter/services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  // key: shelter name, value: isFavorite
  final Map<String, bool> _favorites = {};

  Map<String, bool> get favorites => _favorites;

  /// DB에서 즐겨찾기 상태 불러오기 (앱 시작 시 한 번만)
  Future<void> loadFavorites(List<String> tableNames) async {
    _favorites.clear();
    for (final table in tableNames) {
      final favoriteList = await FavoriteService().getFavoritesInTable(table);
      for (final name in favoriteList) {
        _favorites[name] = true;
      }
    }
    notifyListeners();
  }

  /// 이름 기준 즐겨찾기 여부 조회
  bool isFavorite(String name) => _favorites[name] ?? false;

  /// 즐겨찾기 토글 및 상태 반영
  Future<void> toggleFavorite(String tableName, String name) async {
    final newValue = await FavoriteService().toggleFavorite(tableName, name);
    _favorites[name] = newValue == 1;
    notifyListeners();
  }
}

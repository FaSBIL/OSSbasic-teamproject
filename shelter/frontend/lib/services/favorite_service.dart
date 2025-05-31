import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shelter/models/shelter.dart';
import 'package:path_provider/path_provider.dart';

class FavoriteService {
  static const dbFileName = 'shelters.db';

  Future<Database> _getDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, dbFileName);
    return openDatabase(dbPath);
  }

  Future<Database> getDatabase() {
    return _getDatabase();
  }

  /// 즐겨찾기 여부 확인
  Future<bool> isFavorite(String tableName, String name) async {
    final db = await _getDatabase();
    final result = await db.query(
      tableName,
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['isFavorite'] == 1;
    }
    return false;
  }

  /// 즐겨찾기 토글
  Future<int> toggleFavorite(String tableName, String name) async {
    final db = await _getDatabase();
    final current = await isFavorite(tableName, name);
    final newValue = current ? 0 : 1;

    await db.update(
      tableName,
      {'isFavorite': newValue},
      where: 'name = ?',
      whereArgs: [name],
    );

    return newValue; // 변경된 값 리턴
  }

  /// 해당 테이블에서 즐겨찾기된 shelter 목록 반환
  Future<List<String>> getFavoritesInTable(String tableName) async {
    final db = await _getDatabase();
    final result = await db.query(
      tableName,
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// 모든 테이블에서 즐겨찾기된 shelter 이름 리스트 반환
  Future<List<String>> getAllFavorites(List<String> tableNames) async {
    final db = await _getDatabase();
    final allFavorites = <String>[];

    for (final tableName in tableNames) {
      final result = await db.query(
        tableName,
        where: 'isFavorite = ?',
        whereArgs: [1],
      );
      allFavorites.addAll(result.map((row) => row['name'] as String));
    }

    return allFavorites;
  }

  Future<List<Shelter>> getFavoriteShelterObjects(String tableName) async {
    final db = await _getDatabase();
    final result = await db.query(
      tableName,
      where: 'isFavorite = ?',
      whereArgs: [1],
    );

    return result.map((map) => Shelter.fromMap(map)).toList();
  }
}

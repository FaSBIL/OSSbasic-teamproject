import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:latlong2/latlong.dart';
Future<Database> loadDatabase() async {
  final dbName = 'shelters.db';
  final documentsDir = await getApplicationDocumentsDirectory();
  final dbPath = join(documentsDir.path, dbName);

  if (!File(dbPath).existsSync()) {
    print('[DB] 복사 시작: $dbName');
    ByteData data = await rootBundle.load('shelter_db/$dbName');
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes, flush: true);
    print('[DB] 복사 완료: $dbName');
  } else {
    print('[DB] 이미 존재함: $dbName');
  }

  return openDatabase(dbPath);
}
Future<String> getRegionFromLatLng(double lat, double lon) async {
  // TODO: 위도경도 기반 지역 결정 로직 필요
  // 현재는 테스트용으로 충북 반환
  return 'chungbuk';
}

Future<Database> loadRegionDatabase(String region) async {
  final dbName = 'region_$region.db';
  final documentsDir = await getApplicationDocumentsDirectory();
  final dbPath = join(documentsDir.path, dbName);

  if (!File(dbPath).existsSync()) {
    print('[DB] 지역 DB 복사 시작: $dbName');
    ByteData data = await rootBundle.load('assets/region_graphs/$dbName');
    List<int> bytes = data.buffer.asUint8List();
    await File(dbPath).writeAsBytes(bytes, flush: true);
    print('[DB] 지역 DB 복사 완료: $dbName');
  } else {
    print('[DB] 지역 DB 이미 존재함: $dbName');
  }

  return openDatabase(dbPath);
}

Future<Map<int, LatLng>> loadRegionDbByNode(String region) async {
  final db = await loadRegionDatabase(region);
  final nodes = await db.query('nodes');
  final nodeMap = <int, LatLng>{};
  for (final row in nodes) {
    nodeMap[row['id'] as int] = LatLng(row['lat'] as double, row['lon'] as double);
  }
  return nodeMap;
}

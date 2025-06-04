import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/services/user_location.dart';

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
Future<String> getRegionFromLatLng(double latitude, double longitude) async {
  final locationService = UserLocationService();
  final location = await locationService.getNearestLocation(latitude, longitude);
  final doName = location['do'];

  // 행정구역명 → DB 파일명 매핑
  const regionMap = {
    '서울특별시': 'seoul',
    '부산광역시': 'busan',
    '대구광역시': 'daegu',
    '인천광역시': 'incheon',
    '광주광역시': 'gwangju',
    '대전광역시': 'daejeon',
    '울산광역시': 'ulsan',
    '세종특별자치시': 'sejong',
    '경기도': 'gyeonggi',
    '강원특별자치도': 'gangwon',
    '충청북도': 'chungbuk',
    '충청남도': 'chungnam',
    '전북특별자치도': 'jeonbuk',
    '전라남도': 'jeonnam',
    '경상북도': 'gyeongbuk',
    '경상남도': 'gyeongnam',
    '제주특별자치도': 'jeju',
  };

  final region = regionMap[doName];

  if (region == null) {
    throw Exception('알 수 없는 행정구역입니다: $doName');
  }

  return region;
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

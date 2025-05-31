import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../utils/db_loader.dart';
import '../models/shelter.dart';

class ShelterService {
  late Database _db;

  Future<void> initialize() async {
    _db = await loadDatabase();
    print('[Service] shelters.db initialized');
  }

  // 지역 + 유형 필터로 대피소 가져오기
  Future<List<Shelter>> getSheltersByRegionAndType(String region, String type) async {
    final rows = await _db.query(
      region.toLowerCase(),
      where: '$type = ?',
      whereArgs: [1],
      columns: ['name', 'address', 'latitude', 'longitude'],
    );
    return rows.map((row) {
      return Shelter.fromMap({
        ...row,
        'type': type,
        'civil': type == 'civil' ? 1 : 0,
        'earthquake': type == 'earthquake' ? 1 : 0,
        'tsunami': type == 'tsunami' ? 1 : 0,
      });
    }).toList();
  }

  // ✅ 다익스트라 경로 계산용: 해당 지역의 모든 대피소 반환
  Future<List<Shelter>> getAllShelters(String region) async {
    final rows = await _db.query(
      region.toLowerCase(),
      columns: ['name', 'address', 'latitude', 'longitude'],
    );
    return rows.map((row) => Shelter.fromMap(row)).toList();
  }

  // ✅ 현재 위치에서 가장 가까운 대피소 하나 반환
  Future<Shelter?> findNearestShelter(double lat, double lon, String region, {String? type}) async {
    final rows = await _db.rawQuery('''
      SELECT name, address, latitude, longitude
      FROM ${region.toLowerCase()}
      ${type != null ? 'WHERE $type = 1' : ''}
      ORDER BY ((latitude - ?) * (latitude - ?) + (longitude - ?) * (longitude - ?)) ASC
      LIMIT 1
    ''', [lat, lat, lon, lon]);

    if (rows.isNotEmpty) {
      return Shelter.fromMap({
        ...rows.first,
        'type': type,
        'civil': type == 'civil' ? 1 : 0,
        'earthquake': type == 'earthquake' ? 1 : 0,
        'tsunami': type == 'tsunami' ? 1 : 0,
      });
    }
    return null;
  }

  // ✅ 초성 추출 유틸
  String getChosung(String text) {
    const List<String> cho = ['ㄱ','ㄲ','ㄴ','ㄷ','ㄸ','ㄹ','ㅁ','ㅂ','ㅃ','ㅅ','ㅆ','ㅇ','ㅈ','ㅉ','ㅊ','ㅋ','ㅌ','ㅍ','ㅎ'];
    String result = '';
    for (int i = 0; i < text.length; i++) {
      int code = text.codeUnitAt(i) - 0xAC00;
      if (code >= 0 && code <= 11171) {
        result += cho[code ~/ 588];
      } else {
        result += text[i];
      }
    }
    return result;
  }

  // ✅ 키워드 기반 대피소 통합 검색
  Future<List<Shelter>> searchShelters(String keyword, {String? type}) async {
    const regionTables = [
      'seoul','busan','daegu','incheon','gwangju','daejeon','ulsan','sejong',
      'gyeonggi','gangwon','chungbuk','chungnam','jeonbuk','jeonnam','gyeongbuk','gyeongnam','jeju'
    ];

    final chosungKeyword = getChosung(keyword);
    List<Shelter> result = [];

    for (final region in regionTables) {
      try {
        final rows = await _db.query(
          region,
          columns: ['name', 'address', 'latitude', 'longitude'],
          where: type != null ? '$type = ?' : null,
          whereArgs: type != null ? [1] : null,
        );

        for (final row in rows) {
          final name = row['name']?.toString() ?? '';
          final address = row['address']?.toString() ?? '';
          if (name.contains(keyword) ||
              address.contains(keyword) ||
              getChosung(name).contains(chosungKeyword) ||
              getChosung(address).contains(chosungKeyword)) {
            result.add(Shelter.fromMap({
              ...row,
              'type': type,
              'civil': type == 'civil' ? 1 : 0,
              'earthquake': type == 'earthquake' ? 1 : 0,
              'tsunami': type == 'tsunami' ? 1 : 0,
            }));
          }
        }
      } catch (e) {
        print('❌ [$region] 검색 실패: $e');
      }
    }

    return result;
  }

  Future<void> close() async {
    await _db.close();
  }
}

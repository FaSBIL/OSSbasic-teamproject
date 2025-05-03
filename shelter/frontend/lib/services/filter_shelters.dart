import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/db_loader.dart';

class ShelterService {
  late Database _civilDb;
  late Database _earthquakeDb;
  late Database _tsunamiDb;

  Future<void> initialize() async {
    // loadDatabase 유틸리티를 사용하여 DB 초기화
    _civilDb = await loadDatabase('civilSheltersByRegion.db');
    _earthquakeDb = await loadDatabase('earthquakeSheltersByRegion.db');
    _tsunamiDb = await loadDatabase('tsunamiShelters.db');
    print('[Service] Databases initialized'); // 초기화 완료 로그 추가
  }

  Future<List<Map<String, dynamic>>> getCivilShelters(String region) async {
    if (_civilDb == null) {
      throw Exception('Database not initialized');
    }
    return await _civilDb.query(
      'civil_$region',
      columns: ['name', 'address', 'latitude', 'longitude'],
    );
  }

  Future<List<Map<String, dynamic>>> getEarthquakeShelters(
    String region,
  ) async {
    return await _earthquakeDb.query(
      'earthquake_$region',
      columns: ['name', 'address', 'latitude', 'longitude'],
    );
  }

  Future<List<Map<String, dynamic>>> getTsunamiShelters(String region) async {
    return await _tsunamiDb.query(
      'tsunami_shelters',
      columns: ['name', 'address', 'latitude', 'longitude'],
    );
  }

  Future<void> close() async {
    await _civilDb.close();
    await _earthquakeDb.close();
    await _tsunamiDb.close();
  }
}

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ShelterService {
  late Database _civilDb;
  late Database _earthquakeDb;
  late Database _tsunamiDb;

  Future<void> initialize() async {
    // 민방위 대피소 DB 초기화
    _civilDb = await openDatabase(
      join(await getDatabasesPath(), 'civilSheltersByRegion.db'),
    );

    // 지진 옥외 대피소 DB 초기화
    _earthquakeDb = await openDatabase(
      join(await getDatabasesPath(), 'earthquakeSheltersByRegion.db'),
    );

    // 지진해일 대피소 DB 초기화
    _tsunamiDb = await openDatabase(
      join(await getDatabasesPath(), 'tsunamiShelters.db'),
    );
  }

  Future<List<Map<String, dynamic>>> getCivilShelters(String region) async {
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

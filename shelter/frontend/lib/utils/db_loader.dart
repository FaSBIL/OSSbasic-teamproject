import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> loadDatabase(String dbName) async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final dbPath = '${documentsDir.path}/$dbName';

  // 이미 복사돼 있는지 확인
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

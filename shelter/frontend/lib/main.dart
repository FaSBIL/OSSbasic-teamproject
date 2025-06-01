import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shelter/controllers/tts_controller.dart';
import 'screens/test/test04.dart';
import 'routes/AppRoutes.dart';
import 'screens/home.dart';
import './services/background_service.dart';
import 'package:provider/provider.dart';
import 'package:shelter/provider/favorite_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<void> copyDatabaseFromAssets() async {
  final dir = await getApplicationDocumentsDirectory();
  final dbPath = '${dir.path}/shelters.db';

  if (await File(dbPath).exists()) {
    print('[DB] 이미 복사됨');
    return;
  }

  // assets에서 읽어서 내부저장소에 복사
  final data = await rootBundle.load('assets/shelter_db/shelters.db');
  final bytes = data.buffer.asUint8List();
  await File(dbPath).writeAsBytes(bytes, flush: true);

  print('[DB] 복사 완료');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await copyDatabaseFromAssets();
  final ttsController = TTSController();
  await ttsController.loadBackgroundSetting();

  if (ttsController.isBackgroundEnabled) {
    await initializeService();
    FlutterBackgroundService().startService();
  }
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoriteProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '대피소 앱', // 앱의 기본 제목 (iOS나 일부 안드로이드에서 사용됨)
      theme: ThemeData(
        fontFamily: 'NotoSansKR', // 앱 전체에서 사용할 기본 글꼴
      ),

      routes: AppRoutes.routes,
      home: HomeScreen(), // 앱 실행 시 처음 보여줄 화면
      debugShowCheckedModeBanner: false, // 오른쪽 상단 디버그 배너 제거
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shelter/controllers/tts_controller.dart';
import 'screens/test/test04.dart';
import 'routes/AppRoutes.dart';
import 'screens/home.dart';
import './services/background_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ttsController = TTSController();
  await ttsController.loadBackgroundSetting();

  if(ttsController.isBackgroundEnabled){
    await initializeService();
    FlutterBackgroundService().startService();
  }
  runApp(const MyApp());
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

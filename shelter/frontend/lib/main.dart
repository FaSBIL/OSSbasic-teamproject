import 'package:flutter/material.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';
import 'screens/test.dart';
import 'routes/AppRoutes.dart';
import 'screens/location_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: const HomeScreen(), // 앱 실행 시 처음 보여줄 화면
      debugShowCheckedModeBanner: false, // 오른쪽 상단 디버그 배너 제거
    );
  }
}

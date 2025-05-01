import 'package:flutter/material.dart'; // Flutter의 기본 UI 패키지를 가져옴
import 'package:shelter/screens/settings/SettingsMainScreens.dart';
import 'screens/test.dart';
import 'routes/AppRoutes.dart';

void main() {
  // 앱의 시작점 (main 함수)
  runApp(const MyApp()); // MyApp 위젯을 실행해서 앱을 시작함
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

      initialRoute: AppRoutes.settings,
      routes: AppRoutes.routes,
      home: const SettingsMainScreen(), // 앱 실행 시 처음 보여줄 화면
      debugShowCheckedModeBanner: false, // 오른쪽 상단 디버그 배너 제거
    );
  }
}

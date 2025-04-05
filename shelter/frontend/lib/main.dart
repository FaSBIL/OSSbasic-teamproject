import 'package:flutter/material.dart'; // Flutter의 기본 UI 패키지를 가져옴
import 'screens/shelter_map_screen.dart'; // 대피소 지도 화면 위젯을 가져옴 (사용자 정의 파일)

void main() {
  // 앱의 시작점 (main 함수)
  runApp(const MyApp()); // MyApp 위젯을 실행해서 앱을 시작함
}

class MyApp extends StatelessWidget {
  // 앱 전체의 루트 위젯 (StatelessWidget: 상태를 가지지 않는 위젯)
  const MyApp({super.key}); // 생성자

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '대피소 앱', // 앱의 기본 제목 (iOS나 일부 안드로이드에서 사용됨)
      theme: ThemeData(
        fontFamily: 'NotoSansKR', // 앱 전체에서 사용할 기본 글꼴
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14), // 기본 텍스트 크기 설정
          bodyLarge: TextStyle(fontWeight: FontWeight.bold), // 큰 텍스트는 굵게 표시
        ),
      ),
      home: const ShelterMapScreen(), // 앱 실행 시 처음 보여줄 화면
      debugShowCheckedModeBanner: false, // 오른쪽 상단 디버그 배너 제거
    );
  }
}

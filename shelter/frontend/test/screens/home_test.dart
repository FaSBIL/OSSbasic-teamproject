import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shelter/screens/home.dart';
import 'package:shelter/component/input/MainInput.dart';
import 'package:shelter/screens/search/search_screen.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';

void main() {
  // Geolocator 채널 설정: 위치 서비스 활성 & 권한 허용, 임의 위치 반환
  const MethodChannel geoChannel = MethodChannel(
    'flutter.baseflow.com/geolocator',
  );
  setUp(() {
    geoChannel.setMockMethodCallHandler((call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return true; // 위치 서비스 활성화됨
        case 'checkPermission':
          return 2; // 권한 허용
        case 'requestPermission':
          return 2; // 이미 허용됨
        case 'getCurrentPosition':
          return {
            "latitude": 37.5665,
            "longitude": 126.9780,
            "timestamp": 0,
            "accuracy": 0.0,
            "altitude": 0.0,
            "heading": 0.0,
            "speed": 0.0,
            "speed_accuracy": 0.0,
          };
      }
      return null;
    });
  });

  testWidgets('HomeScreen 초기 UI 구성 요소 확인 및 네비게이션 동작 테스트', (
    WidgetTester tester,
  ) async {
    // HomeScreen을 MaterialApp으로 감싸 펌프
    await tester.pumpWidget(MaterialApp(home: HomeScreen()));
    await tester.pump(); // 첫 프레임 렌더링

    // 주요 UI 위젯들이 빌드되었는지 확인
    expect(
      find.byType(MainInput),
      findsOneWidget,
      reason: '검색 입력 위젯이 표시되어야 합니다.',
    );
    expect(
      find.byIcon(Icons.gps_fixed_rounded),
      findsOneWidget,
      reason: '현재 위치 버튼 아이콘이 표시되어야 합니다.',
    );

    // MainInput 위젯 참조
    final mainInput = tester.widget<MainInput>(find.byType(MainInput));

    // MainInput의 onTap이 null이 아니어야 하며, 호출 시 SearchScreen으로 전환
    expect(
      mainInput.onTap,
      isNotNull,
      reason: 'MainInput의 onTap 콜백이 정의되어야 합니다.',
    );
    mainInput.onTap!(); // 널 체크 후 호출
    await tester.pumpAndSettle();
    expect(
      find.byType(SearchScreen),
      findsOneWidget,
      reason: '검색 화면으로 전환되어야 합니다.',
    );

    // 뒤로 돌아와서 (SearchScreen pop)
    Navigator.of(tester.element(find.byType(SearchScreen))).pop();
    await tester.pumpAndSettle();

    // MainInput의 onMenuTap이 null이 아니어야 하며, 호출 시 SettingsMainScreen으로 전환
    expect(
      mainInput.onMenuTap,
      isNotNull,
      reason: 'MainInput의 onMenuTap 콜백이 정의되어야 합니다.',
    );
    mainInput.onMenuTap!(); // 널 체크 후 호출
    await tester.pumpAndSettle();
    expect(
      find.byType(SettingsMainScreen),
      findsOneWidget,
      reason: '설정 메인 화면으로 전환되어야 합니다.',
    );
  });
}

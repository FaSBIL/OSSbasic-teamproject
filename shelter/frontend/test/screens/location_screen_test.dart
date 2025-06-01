import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shelter/screens/location_screen.dart';

void main() {
  const MethodChannel geoChannel = MethodChannel(
    'flutter.baseflow.com/geolocator',
  );

  testWidgets('위치 서비스 비활성화 시 오류 메시지 출력', (WidgetTester tester) async {
    // 위치 서비스 비활성화 및 권한 요청 흐름 모의
    geoChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'isLocationServiceEnabled') {
        return false; // 서비스 비활성화로 응답
      }
      return null;
    });

    await tester.pumpWidget(MaterialApp(home: LocationScreen()));
    // "현재 위치 가져오기" 버튼 탭
    await tester.tap(find.text('현재 위치 가져오기'));
    await tester.pumpAndSettle();
    // 오류 메시지가 화면에 표시되는지 확인
    expect(find.text('위치 서비스가 비활성화되어 있습니다.'), findsOneWidget);
  });

  testWidgets('현재 위치 조회 중 예외 발생 시 메시지 표시', (WidgetTester tester) async {
    // 위치 서비스 활성화 + 권한 허용 -> 그러나 getCurrentPosition에서 예외 발생 시나리오
    geoChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'isLocationServiceEnabled') return true;
      if (call.method == 'checkPermission') return 2; // 권한 허용 상태
      if (call.method == 'getCurrentPosition') {
        throw PlatformException(
          code: 'ERROR',
          message: 'Location error',
        ); // 위치 조회 중 에러 발생
      }
      return null;
    });

    await tester.pumpWidget(MaterialApp(home: LocationScreen()));
    await tester.tap(find.text('현재 위치 가져오기'));
    await tester.pumpAndSettle();
    // 지역명 조회 오류 메시지가 표시되는지 확인 (getNearestLocation 실패 포함)
    expect(find.textContaining('지역명을 찾는 중 오류 발생'), findsOneWidget);
  });
}

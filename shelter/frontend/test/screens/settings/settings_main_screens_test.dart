import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';
import 'package:shelter/routes/AppRoutes.dart';
import 'package:shelter/screens/settings/VoiceGuideScreen.dart';
import 'package:shelter/screens/settings/BackgroundActivityScreen.dart';

void main() {
  testWidgets('설정 메인 화면 UI 및 네비게이션 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsMainScreen(),
        routes: AppRoutes.routes, // Named route 사용을 위해 AppRoutes 등록
      ),
    );

    // 설정 목록의 아이템들이 올바르게 표시되는지 확인
    expect(find.text('음성 안내'), findsOneWidget);
    expect(find.text('백그라운드 동작'), findsOneWidget);
    expect(find.text('GPS'), findsOneWidget);
    expect(find.text('ON'), findsOneWidget);
    expect(find.text('앱 정보'), findsOneWidget);
    expect(find.text('version 1.0'), findsOneWidget);

    // "음성 안내" 항목 탭 -> VoiceGuideScreen로 이동
    await tester.tap(find.text('음성 안내'));
    await tester.pumpAndSettle();
    expect(find.byType(VoiceGuideScreen), findsOneWidget);

    // 되돌아가기
    Navigator.of(tester.element(find.byType(VoiceGuideScreen))).pop();
    await tester.pumpAndSettle();

    // "백그라운드 동작" 항목 탭 -> BackgroundActivityScreen로 이동
    await tester.tap(find.text('백그라운드 동작'));
    await tester.pumpAndSettle();
    expect(find.byType(BackgroundActivityScreen), findsOneWidget);
  });
}

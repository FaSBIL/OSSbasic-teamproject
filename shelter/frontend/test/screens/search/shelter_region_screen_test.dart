import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/screens/search/shelter_region_screen.dart';
import 'package:shelter/screens/search/shelter_list_screen.dart';

void main() {
  testWidgets('지역 리스트 UI 및 항목 탭 시 동작 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ShelterRegionScreen()));

    // 일부 지역명이 리스트에 표시되는지 확인
    expect(find.text('서울특별시'), findsOneWidget);
    expect(find.text('제주특별자치도'), findsOneWidget);

    // 리스트 항목 탭 -> ShelterListScreen으로 이동 및 파라미터 전달 확인
    await tester.tap(find.text('서울특별시'));
    await tester.pumpAndSettle();
    // ShelterListScreen 화면이 푸시되었는지 확인
    expect(find.byType(ShelterListScreen), findsOneWidget);
    // 전달된 region 파라미터가 일치하는지 확인
    final screen = tester.widget<ShelterListScreen>(
      find.byType(ShelterListScreen),
    );
    expect(screen.region, '서울특별시');
  });
}

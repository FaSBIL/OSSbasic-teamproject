import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/routes/AppRoutes.dart';
import 'package:shelter/screens/search/search_result_screen.dart';

void main() {
  testWidgets('검색 결과 화면 초기 상태 및 인자 처리 테스트', (WidgetTester tester) async {
    // MaterialApp을 사용하여 searchResult 경로로 네비게이션
    await tester.pumpWidget(
      MaterialApp(
        home: Container(), // 임시 홈
        routes: AppRoutes.routes,
      ),
    );
    // searchResult 라우트로 이동 (키워드 전달)
    Navigator.of(
      tester.element(find.byType(Container)),
    ).pushNamed(AppRoutes.searchResult, arguments: '테스트키워드');
    await tester.pumpAndSettle();

    // SearchResultScreen 위젯이 나타났는지 및 전달된 키워드가 반영됐는지 확인
    expect(find.byType(SearchResultScreen), findsOneWidget);
    expect(
      find.text('검색: "테스트키워드"'),
      findsOneWidget,
      reason: 'AppBar 제목에 검색 키워드가 표시되어야 합니다.',
    );

    // SearchResultScreen 위젯의 keyword 속성이 올바르게 설정되었는지 확인
    final searchResultScreen = tester.widget<SearchResultScreen>(
      find.byType(SearchResultScreen),
    );
    expect(searchResultScreen.keyword, '테스트키워드');

    // 초기 로딩 인디케이터 표시 확인 (데이터 로드 중 상태)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

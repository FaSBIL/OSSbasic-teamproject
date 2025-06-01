import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/screens/home.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/component/input/MainInput.dart';
// import 'package:shelter/screens/search/SearchScreen.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('HomeScreen 로직 테스트', () {
    test('대피소 상태에 따른 _getMarkerColor 결과 검증', () {
      final home = HomeScreen();
      final state = home.createState() as dynamic;

      // 1) 지진 대피소만 true
      final s1 = Shelter(
        name: 'A',
        address: 'Addr',
        latitude: 0.0,
        longitude: 0.0,
        earthquakeSafe: true,
        tsunamiSafe: false,
      );
      final c1 = state._getMarkerColor(s1) as Color;
      expect(c1, Colors.purple);

      // 2) 해일 대피소만 true
      final s2 = Shelter(
        name: 'B',
        address: 'Addr',
        latitude: 0.0,
        longitude: 0.0,
        earthquakeSafe: false,
        tsunamiSafe: true,
      );
      final c2 = state._getMarkerColor(s2) as Color;
      expect(c2, Colors.green);

      // 3) 둘 다 false
      final s3 = Shelter(
        name: 'C',
        address: 'Addr',
        latitude: 0.0,
        longitude: 0.0,
        earthquakeSafe: false,
        tsunamiSafe: false,
      );
      final c3 = state._getMarkerColor(s3) as Color;
      expect(c3, AppColors.blue);
    });

    // testWidgets('검색창 탭 시 SearchScreen으로 이동', (WidgetTester tester) async {
    //   await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    //   await tester.pumpAndSettle();

    //   expect(find.byType(MainInput), findsOneWidget);

    //   await tester.tap(find.byType(MainInput));
    //   await tester.pumpAndSettle();

    //   expect(find.byType(SearchScreen), findsOneWidget);
    // });

    // testWidgets('설정 버튼 탭 시 SettingsMainScreens로 이동', (
    //   WidgetTester tester,
    // ) async {
    //   await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    //   await tester.pumpAndSettle();

    //   // MainInput 내부에 Icon(Icons.settings) 형태로 메뉴 버튼이 있다고 가정
    //   final settingsIcon = find.byIcon(Icons.settings);
    //   expect(settingsIcon, findsOneWidget);

    //   await tester.tap(settingsIcon);
    //   await tester.pumpAndSettle();

    //   expect(find.byType(SettingsMainScreens), findsOneWidget);
    // });

    test('최근 검색어 저장 로직 - 최대 10개 유지 및 최신순', () async {
      final home = HomeScreen();
      final state = home.createState() as dynamic;

      // 기존에 9개의 검색어 세팅
      SharedPreferences.setMockInitialValues({
        'recent_searches': List<String>.generate(9, (i) => 'Old$i'),
      });

      // 새로운 검색어 저장
      await state._saveRecentSearch('NewKeyword');

      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('recent_searches')!;
      expect(saved.length, lessThanOrEqualTo(10));
      expect(saved.first, 'NewKeyword');
    });
  });
}

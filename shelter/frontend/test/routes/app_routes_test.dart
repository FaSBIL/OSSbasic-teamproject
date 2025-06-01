import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelter/routes/AppRoutes.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';
import 'package:shelter/screens/settings/VoiceGuideScreen.dart';
// import 'package:shelter/screens/background/BackgroundActivityScreen.dart';
// import 'package:shelter/screens/search/SearchResultScreen.dart';
// import 'package:shelter/screens/location/ShelterRegionScreen.dart';

void main() {
  group('AppRoutes 경로 상수값 검증', () {
    test('경로 상수들이 올바른 문자열을 갖고 있는지 확인', () {
      expect(AppRoutes.settings, '/settings');
      expect(AppRoutes.voiceGuide, '/voiceGuide');
      expect(AppRoutes.backgroundActivity, '/backgroundActivity');
      expect(AppRoutes.location, '/location');
      expect(AppRoutes.shelterRegion, '/shelterRegion');
      expect(AppRoutes.searchResult, '/searchResult');
    });
  });

  group('AppRoutes.routes 맵 검증', () {
    test('모든 경로 상수가 routes 맵에 키로 존재하고, builder가 WidgetBuilder 타입인지 확인', () {
      final routeMap = AppRoutes.routes;
      expect(
        routeMap.keys.toSet(),
        containsAll(<String>{
          AppRoutes.settings,
          AppRoutes.voiceGuide,
          AppRoutes.backgroundActivity,
          AppRoutes.location,
          AppRoutes.shelterRegion,
          AppRoutes.searchResult,
        }),
      );

      expect(routeMap[AppRoutes.settings], isNotNull);
      expect(routeMap[AppRoutes.settings], isA<WidgetBuilder>());
      expect(routeMap[AppRoutes.voiceGuide], isA<WidgetBuilder>());
      expect(routeMap[AppRoutes.backgroundActivity], isA<WidgetBuilder>());
      expect(routeMap[AppRoutes.location], isA<WidgetBuilder>());
      expect(routeMap[AppRoutes.shelterRegion], isA<WidgetBuilder>());
      expect(routeMap[AppRoutes.searchResult], isA<WidgetBuilder>());
    });

    // testWidgets('"settings" 경로로 네비게이트 시 SettingsMainScreens가 렌더링되는지 확인', (
    //   WidgetTester tester,
    // ) async {
    //   final routeMap = AppRoutes.routes;

    //   await tester.pumpWidget(
    //     MaterialApp(
    //       initialRoute: '/',
    //       routes: {
    //         '/': (context) => const Scaffold(body: Text('Home')),
    //         ...routeMap,
    //       },
    //     ),
    //   );

    //   await tester.runAsync(() async {
    //     Navigator.of(
    //       tester.element(find.text('Home')),
    //     ).pushNamed(AppRoutes.settings);
    //     await tester.pumpAndSettle();
    //   });

    //   expect(find.byType(SettingsMainScreens), findsOneWidget);
    // });

    // testWidgets('"searchResult" 경로로 네비게이트 시 SearchResultScreen이 렌더링되는지 확인', (
    //   WidgetTester tester,
    // ) async {
    //   final routeMap = AppRoutes.routes;

    //   await tester.pumpWidget(
    //     MaterialApp(
    //       initialRoute: '/',
    //       routes: {
    //         '/': (context) => const Scaffold(body: Text('Home')),
    //         ...routeMap,
    //       },
    //     ),
    //   );

    //   await tester.runAsync(() async {
    //     Navigator.of(
    //       tester.element(find.text('Home')),
    //     ).pushNamed(AppRoutes.searchResult, arguments: {'keyword': '테스트'});
    //     await tester.pumpAndSettle();
    //   });

    //   expect(find.byType(SearchResultScreen), findsOneWidget);
    // });
  });
}

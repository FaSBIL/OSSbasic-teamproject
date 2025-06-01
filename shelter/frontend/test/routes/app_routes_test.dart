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
    test('모든 경로 상수가 routes 맵의 키로 존재', () {
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
    });

    // test('각 경로가 올바른 위젯 빌더와 매핑되는지 확인', () {
    //   final routeMap = AppRoutes.routes;

    //   // SettingsMainScreens
    //   final settingsBuilder = routeMap[AppRoutes.settings];
    //   expect(settingsBuilder, isNotNull);
    //   expect(settingsBuilder!(null), isA<SettingsMainScreens>());

    //   // VoiceGuideScreen
    //   final voiceBuilder = routeMap[AppRoutes.voiceGuide];
    //   expect(voiceBuilder!(null), isA<VoiceGuideScreen>());

    //   // BackgroundActivityScreen
    //   final backgroundBuilder = routeMap[AppRoutes.backgroundActivity];
    //   expect(backgroundBuilder!(null), isA<BackgroundActivityScreen>());

    //   // ShelterRegionScreen
    //   final regionBuilder = routeMap[AppRoutes.shelterRegion];
    //   expect(regionBuilder!(null), isA<ShelterRegionScreen>());

    //   // SearchResultScreen (이 위젯은 생성자에 인자를 받기 때문에, null을 넣어도 객체는 생성됨)
    //   final searchBuilder = routeMap[AppRoutes.searchResult];
    //   final maybeSearchWidget = searchBuilder!({'keyword': '테스트'});
    //   expect(maybeSearchWidget, isA<SearchResultScreen>());
    // });
  });
}

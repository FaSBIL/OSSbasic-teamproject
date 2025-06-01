import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/routes/AppRoutes.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';
import 'package:shelter/screens/settings/VoiceGuideScreen.dart';
import 'package:shelter/screens/settings/BackgroundActivityScreen.dart';
import 'package:shelter/screens/location_screen.dart';
import 'package:shelter/screens/search/shelter_region_screen.dart';
import 'package:shelter/screens/search/search_result_screen.dart';

void main() {
  testWidgets('AppRoutes 매핑이 올바른 위젯을 생성하는지 검증', (WidgetTester tester) async {
    // 임의의 BuildContext를 얻기 위해 빈 위젯 펌프
    await tester.pumpWidget(Container());
    final context = tester.element(find.byType(Container));

    // 모든 static 경로 키가 routes 맵에 존재하는지 확인
    expect(AppRoutes.routes.containsKey(AppRoutes.settings), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.voiceGuide), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.backgroundActivity), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.location), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.shelterRegion), isTrue);
    expect(AppRoutes.routes.containsKey(AppRoutes.searchResult), isTrue);

    // 각 경로 키에 대해 routes 맵이 올바른 화면 위젯을 반환하는지 확인 (searchResult는 특별 처리)
    expect(
      AppRoutes.routes[AppRoutes.settings]!(context),
      isA<SettingsMainScreen>(),
    );
    expect(
      AppRoutes.routes[AppRoutes.voiceGuide]!(context),
      isA<VoiceGuideScreen>(),
    );
    expect(
      AppRoutes.routes[AppRoutes.backgroundActivity]!(context),
      isA<BackgroundActivityScreen>(),
    );
    expect(
      AppRoutes.routes[AppRoutes.location]!(context),
      isA<LocationScreen>(),
    );
    expect(
      AppRoutes.routes[AppRoutes.shelterRegion]!(context),
      isA<ShelterRegionScreen>(),
    );

    // searchResult 경로는 인자를 필요로 하므로, 빌더 함수 자체가 정의되어 있는지만 확인
    expect(AppRoutes.routes[AppRoutes.searchResult], isNotNull);
  });
}

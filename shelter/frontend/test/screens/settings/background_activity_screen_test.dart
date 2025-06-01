import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/screens/settings/BackgroundActivityScreen.dart';
import 'package:shelter/component/settingItem/ToggleSwitch.dart';

void main() {
  setUp(() {
    // 각 테스트마다 SharedPreferences 초기화
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('초기 백그라운드 설정값에 따라 토글 상태 반영', (WidgetTester tester) async {
    // 1) 기본값 (isBackgroundEnabled 미설정) -> 토글 OFF
    await tester.pumpWidget(MaterialApp(home: BackgroundActivityScreen()));
    await tester.pump(); // initState 수행
    ToggleSwitch toggle = tester.widget(find.byType(ToggleSwitch));
    expect(toggle.isOn, isFalse, reason: '기본 상태에서는 백그라운드 동작 설정이 꺼져 있어야 합니다.');
    // 2) 사전에 설정값 ON인 경우 -> 토글 ON
    SharedPreferences.setMockInitialValues({'isBackgroundEnabled': true});
    await tester.pumpWidget(MaterialApp(home: BackgroundActivityScreen()));
    await tester.pump();
    toggle = tester.widget(find.byType(ToggleSwitch));
    expect(
      toggle.isOn,
      isTrue,
      reason: '설정값이 저장된 경우 토글이 해당 값(true)을 반영해야 합니다.',
    );
  });

  testWidgets('백그라운드 동작 토글 On/Off 시 설정값 저장 및 서비스 동작 호출', (
    WidgetTester tester,
  ) async {
    // 초기 상태: OFF
    SharedPreferences.setMockInitialValues({'isBackgroundEnabled': false});
    await tester.pumpWidget(MaterialApp(home: BackgroundActivityScreen()));
    await tester.pump();
    // 토글 스위치 가져오기
    ToggleSwitch toggle = tester.widget(find.byType(ToggleSwitch));
    expect(toggle.isOn, isFalse);

    // 1) 토글 ON
    toggle.onChanged!(true);
    await tester.pump();
    // SharedPreferences에 값 저장 확인
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool('isBackgroundEnabled'),
      isTrue,
      reason: '토글 ON 시 설정값이 true로 저장되어야 함',
    );

    // 2) 토글 OFF
    toggle = tester.widget(find.byType(ToggleSwitch)); // 최신 위젯 가져오기
    toggle.onChanged!(false);
    await tester.pump();
    expect(
      prefs.getBool('isBackgroundEnabled'),
      isFalse,
      reason: '토글 OFF 시 설정값이 false로 저장되어야 함',
    );
  });
}

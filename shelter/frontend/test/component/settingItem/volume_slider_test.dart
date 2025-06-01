import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/component/settingItem/VolumeSlider.dart';

void main() {
  testWidgets('VolumeSlider 활성/비활성 상태 UI 테스트', (WidgetTester tester) async {
    // 활성 상태 (enabled=true)
    bool called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: VolumeSlider(
          value: 0.5,
          onChanged: (_) => called = true,
          enabled: true,
        ),
      ),
    );
    Opacity opacityWidget = tester.widget(find.byType(Opacity));
    expect(opacityWidget.opacity, 1.0, reason: '활성 상태에서는 Opacity=1.0이어야 함');
    Slider slider = tester.widget(find.byType(Slider));
    expect(slider.onChanged, isNotNull);
    // 아이콘 표시 확인
    expect(find.byIcon(Icons.volume_mute), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);

    // 콜백 동작 테스트: onChanged를 수동 호출
    slider.onChanged!(0.7);
    expect(called, isTrue, reason: '슬라이더 조작 시 onChanged 콜백 호출되어야 함');

    // 비활성 상태 (enabled=false)
    await tester.pumpWidget(
      MaterialApp(
        home: VolumeSlider(value: 0.3, onChanged: (_) {}, enabled: false),
      ),
    );
    opacityWidget = tester.widget(find.byType(Opacity));
    expect(opacityWidget.opacity, 0.5, reason: '비활성 상태에서는 Opacity=0.5로 반투명 처리');
    slider = tester.widget(find.byType(Slider));
    expect(
      slider.onChanged,
      isNull,
      reason: '비활성 상태에서는 Slider onChanged가 null이어야 함',
    );
  });
}

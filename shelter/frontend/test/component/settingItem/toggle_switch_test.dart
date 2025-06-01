import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/component/settingItem/ToggleSwitch.dart';

void main() {
  testWidgets('ToggleSwitch isOn 값에 따른 UI 변화 확인', (WidgetTester tester) async {
    // isOn=true인 경우 -> 내부 원이 오른쪽 정렬
    await tester.pumpWidget(
      MaterialApp(home: ToggleSwitch(isOn: true, onChanged: (_) {})),
    );
    AnimatedAlign alignWidget = tester.widget(find.byType(AnimatedAlign));
    expect(alignWidget.alignment, Alignment.centerRight);
    // isOn=false인 경우 -> 내부 원이 왼쪽 정렬
    await tester.pumpWidget(
      MaterialApp(home: ToggleSwitch(isOn: false, onChanged: (_) {})),
    );
    alignWidget = tester.widget(find.byType(AnimatedAlign));
    expect(alignWidget.alignment, Alignment.centerLeft);
  });

  testWidgets('ToggleSwitch 탭 시 onChanged 콜백 호출 및 값 토글 확인', (
    WidgetTester tester,
  ) async {
    bool latestValue = false;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return ToggleSwitch(
              isOn: latestValue,
              onChanged: (val) {
                // 호출될 때 latestValue 갱신 및 상태 반영
                latestValue = val;
                setState(() {});
              },
            );
          },
        ),
      ),
    );

    // 초기 false -> 탭하면 true로 변경
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(latestValue, isTrue, reason: '토글 OFF->ON 전환 시 onChanged로 true 값 전달');
    // 한 번 더 탭 -> false로 변경
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();
    expect(
      latestValue,
      isFalse,
      reason: '토글 ON->OFF 전환 시 onChanged로 false 값 전달',
    );
  });
}

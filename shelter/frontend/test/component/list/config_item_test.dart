import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/component/list/ConfigItem.dart';
import 'package:shelter/component/list/BaseListItem.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/theme/typography.dart';

void main() {
  testWidgets('ConfigItem 위젯 표시 내용 검증', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ConfigItem(label: 'GPS', value: 'OFF')),
    );

    // 라벨과 값 텍스트가 올바르게 표시되는지 확인
    expect(find.text('GPS'), findsOneWidget);
    expect(find.text('OFF'), findsOneWidget);

    // 값 텍스트 스타일이 subtitle 스타일 + darkGray 색상인지 확인
    final Text valueText = tester.widget(find.text('OFF'));
    expect(valueText.style!.fontSize, AppTextStyles.subtitle.fontSize);
    expect(valueText.style!.fontWeight, AppTextStyles.subtitle.fontWeight);
    expect(valueText.style!.color, AppColors.darkGray);
  });
}

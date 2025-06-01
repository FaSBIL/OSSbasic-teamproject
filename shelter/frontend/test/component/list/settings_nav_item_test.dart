import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/component/list/SettingsNavItem.dart';
import 'package:shelter/component/list/BaseListItem.dart';
import 'package:shelter/component/icon/IconUtils.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/theme/typography.dart';

void main() {
  testWidgets('SettingsNavItem 위젯 표시 및 탭 동작 테스트', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsNavItem(label: '테스트항목', onTap: () => tapped = true),
      ),
    );

    // 라벨 텍스트와 아이콘 표시 확인
    expect(find.text('테스트항목'), findsOneWidget);
    expect(
      find.byIcon(AppIcons.arrowLeft),
      findsOneWidget,
      reason: '우측 화살표 아이콘 표시',
    );

    // 탭 제스처 시 onTap 콜백 호출 여부 확인
    await tester.tap(find.text('테스트항목'));
    expect(tapped, isTrue, reason: 'SettingsNavItem 탭 시 onTap 콜백이 호출되어야 함');
  });
}

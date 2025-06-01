import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shelter/component/list/BaseListItem.dart';
import 'package:shelter/theme/color.dart';

void main() {
  testWidgets('BaseListItem 구성 요소 및 탭 동작 테스트', (WidgetTester tester) async {
    bool tapped = false;
    // leading, subtitle, trailing이 모두 있는 경우와 onTap 콜백 지정
    await tester.pumpWidget(
      MaterialApp(
        home: BaseListItem(
          leading: Icon(Icons.star),
          title: Text('제목'),
          subtitle: Text('부제목'),
          trailing: Text('추가정보'),
          onTap: () => tapped = true,
        ),
      ),
    );

    // 모든 요소의 텍스트와 아이콘 표시 확인
    expect(find.text('제목'), findsOneWidget);
    expect(find.text('부제목'), findsOneWidget);
    expect(find.text('추가정보'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    // 탭 시 onTap 콜백 호출 확인
    await tester.tap(find.text('제목')); // 제목 영역을 탭 (InkWell 영역에 포함됨)
    expect(tapped, isTrue);
  });

  testWidgets('BaseListItem 필수 요소만 있는 경우 레이아웃 테스트', (
    WidgetTester tester,
  ) async {
    // title만 있고 다른 요소 없는 경우에도 에러 없이 렌더링 되는지
    await tester.pumpWidget(
      MaterialApp(home: BaseListItem(title: Text('제목만 있음'))),
    );

    expect(find.text('제목만 있음'), findsOneWidget);
    expect(
      find.byType(Divider),
      findsOneWidget,
      reason: '하단 구분선 Divider가 렌더링되어야 함',
    );
  });
}

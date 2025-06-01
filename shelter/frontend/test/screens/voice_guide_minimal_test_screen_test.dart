import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/controllers/tts_controller.dart';
import 'package:shelter/screens/test/test04.dart';
import 'package:shelter/screens/settings/VoiceGuideScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('초기 로딩 시 인디케이터 표시 후 버튼 노출', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VoiceGuideMinimalTestScreen()),
    );

    // 처음에는 _isReady = false 이므로 CircularProgressIndicator가 보여야 한다
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 비동기 로딩 완료 (SharedPreferences에서 설정값 읽은 뒤)
    await tester.pumpAndSettle();

    // 로딩이 끝나면 두 개의 버튼이 보여야 함
    expect(find.text('안내를 시작합니다'), findsOneWidget);
    expect(find.text('설정 화면으로'), findsOneWidget);
  });

  testWidgets('안내 시작 버튼 탭 시 TTSController 동작 확인', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VoiceGuideMinimalTestScreen()),
    );
    await tester.pumpAndSettle();

    final tts = TTSController();

    // 1) 음성 비활성화 후 버튼 탭 → 내부에서 예외 없이 리턴
    await tts.setVoiceEnabled(false);
    await tester.tap(find.text('안내를 시작합니다'));
    await tester.pump();
    expect(tts.isVoiceEnabled, isFalse);

    // 2) 음성 활성화 후 버튼 탭 → 내부에서 예외 없이 TTS.play 호출
    await tts.setVoiceEnabled(true);
    await tester.tap(find.text('안내를 시작합니다'));
    await tester.pump();
    expect(tts.isVoiceEnabled, isTrue);
  });

  testWidgets('"설정 화면으로" 버튼 탭 시 VoiceGuideScreen으로 네비게이션', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: VoiceGuideMinimalTestScreen()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('설정 화면으로'));
    await tester.pumpAndSettle();

    expect(find.byType(VoiceGuideScreen), findsOneWidget);
  });
}

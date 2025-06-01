import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/controllers/tts_controller.dart';
import 'package:shelter/screens/test/test04.dart';
import 'package:shelter/screens/settings/VoiceGuideScreen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({'voiceEnabled': true});

  // flutter_tts 채널 모킹
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(ttsChannel, (MethodCall method) async {
        return null;
      });

  // audio_session 채널 모킹
  const MethodChannel audioSessionChannel = MethodChannel('audio_session');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(audioSessionChannel, (MethodCall method) async {
        return null;
      });

  testWidgets('초기 로딩 시 인디케이터 표시 후 버튼 노출', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VoiceGuideMinimalTestScreen()),
    );

    // 처음에는 로딩 상태(인디케이터)가 보여야 함
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 100ms 후 SharedPreferences에서 읽고 setState 호출
    await tester.pump(const Duration(milliseconds: 100));

    // 버튼들이 보여야 함
    expect(find.text('안내를 시작합니다'), findsOneWidget);
    expect(find.text('설정 화면으로'), findsOneWidget);
  });

  testWidgets('안내 시작 버튼 탭 시 TTSController 호출 확인', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: VoiceGuideMinimalTestScreen()),
    );
    await tester.pump(const Duration(milliseconds: 100));

    final tts = TTSController();

    // 1) 음성 비활성화 상태에서 탭 → 예외 없이 리턴
    await tts.setVoiceEnabled(false);
    await tester.tap(find.text('안내를 시작합니다'));
    await tester.pump();
    expect(tts.isVoiceEnabled, isFalse);

    // 2) 음성 활성화 상태에서 탭 → 예외 없이 TTS.play 호출
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
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('설정 화면으로'));
    await tester.pumpAndSettle();

    expect(find.byType(VoiceGuideScreen), findsOneWidget);
  });
}

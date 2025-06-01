import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/screens/settings/VoiceGuideScreen.dart';
import 'package:shelter/component/settingItem/ToggleSwitch.dart';
import 'package:shelter/component/settingItem/VolumeSlider.dart';
import 'package:shelter/controllers/tts_controller.dart';

void main() {
  // TTS 및 오디오 세션 관련 MethodChannel 모의 설정
  const MethodChannel ttsChannel = MethodChannel('flutter_tts');
  const MethodChannel audioSessionChannel = MethodChannel('audio_session');
  // 호출 기록 변수
  bool speakCalled = false;
  String? spokenText;
  double? setVolumeValue;
  setUpAll(() {
    // 공유 환경 초기화 (음성안내 기본값 등)
    SharedPreferences.setMockInitialValues({});
    // TTS 채널 핸들러: 주요 메소드 호출을 캐치하여 기록
    ttsChannel.setMockMethodCallHandler((call) async {
      switch (call.method) {
        case 'speak':
          speakCalled = true;
          spokenText = call.arguments as String;
          return 1;
        case 'stop':
          // stop 호출시 따로 처리할 내용 없지만 호출 기록 가능
          return 1;
        case 'setVolume':
          setVolumeValue = call.arguments as double;
          return 1;
        case 'setLanguage':
        case 'setSpeechRate':
        case 'setPitch':
          return 1;
      }
      return null;
    });
    // 오디오 세션 채널: 항상 성공 응답
    audioSessionChannel.setMockMethodCallHandler((call) async => true);
  });

  setUp(() {
    // 각 테스트마다 상태 초기화
    speakCalled = false;
    spokenText = null;
    setVolumeValue = null;
    // 음성안내 관련 설정 기본값 리셋
    SharedPreferences.setMockInitialValues({
      'voiceEnabled': true,
      'ttsVolume': 1.0,
      'allowVoiceInSilentMode': false,
    });
  });

  testWidgets('VoiceGuideScreen 초기 로딩 시 프로그레스 표시 및 완료 후 UI 전환', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: VoiceGuideScreen()));
    // 초기 로딩 인디케이터 표시 확인
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // 비동기 초기화 완료되도록 충분히 대기
    await tester.pumpAndSettle();
    // 프로그레스가 사라지고 토글 및 슬라이더 UI가 나타나는지 확인
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(ToggleSwitch), findsOneWidget);
    expect(find.byType(VolumeSlider), findsOneWidget);
  });

  testWidgets('음성 안내 On/Off 토글 시 상태 변화 및 슬라이더 활성/비활성 확인', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: VoiceGuideScreen()));
    await tester.pumpAndSettle(); // 초기 로딩 완료

    // 초기 상태: 음성 안내 On(true) 가정
    ToggleSwitch toggle = tester.widget(find.byType(ToggleSwitch));
    expect(toggle.isOn, isTrue, reason: '초기 음성안내 설정은 활성 상태여야 합니다.');
    Slider volumeSlider = tester.widget(find.byType(Slider));
    expect(
      volumeSlider.onChanged,
      isNotNull,
      reason: '음성안내 ON 상태에서는 볼륨 슬라이더가 활성이어야 합니다.',
    );

    // 음성 안내 끄기로 토글 (ToggleSwitch의 onChanged 콜백 직접 호출)
    toggle.onChanged!(false);
    await tester.pump(); // 상태 업데이트 반영
    toggle = tester.widget(find.byType(ToggleSwitch));
    expect(toggle.isOn, isFalse, reason: '토글을 끈 후 isOn 상태가 false여야 합니다.');
    volumeSlider = tester.widget(find.byType(Slider));
    expect(
      volumeSlider.onChanged,
      isNull,
      reason: '음성안내 OFF 상태에서는 슬라이더가 비활성화되어야 합니다.',
    );

    // 다시 켜기로 토글
    toggle.onChanged!(true);
    await tester.pump();
    toggle = tester.widget(find.byType(ToggleSwitch));
    expect(toggle.isOn, isTrue);
    volumeSlider = tester.widget(find.byType(Slider));
    expect(volumeSlider.onChanged, isNotNull);
  });

  testWidgets('볼륨 슬라이더 이동 시 TTS 볼륨 설정 및 미리듣기 음성 출력', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: VoiceGuideScreen()));
    await tester.pumpAndSettle(); // 초기 설정 완료

    // 초기 볼륨 값에서 슬라이더 값을 변경 -> TTSController.setVolume & speak 호출 확인
    final sliderFinder = find.byType(Slider);
    Slider sliderWidget = tester.widget(sliderFinder);
    // 슬라이더 onChanged 콜백 직접 호출 (예: 0.5 -> 0.8)
    sliderWidget.onChanged!(0.8);
    await tester.pump(); // setState 반영

    // flutter_tts 채널을 통해 setVolume 및 speak 메소드가 호출되었는지 확인
    expect(
      setVolumeValue,
      equals(0.8),
      reason: '볼륨 슬라이더 변경시 TTS 볼륨이 0.8로 설정되어야 합니다.',
    );
    expect(speakCalled, isTrue, reason: '볼륨 조절 시 안내 멘트가 재생되어야 합니다.');
    expect(spokenText, equals('안내를 시작합니다.'), reason: '미리듣기 음성의 텍스트가 올바른지 확인');
  });
}

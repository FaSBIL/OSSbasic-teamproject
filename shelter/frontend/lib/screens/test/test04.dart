import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../settings/VoiceGuideScreen.dart';

class VoiceGuideMinimalTestScreen extends StatefulWidget {
  const VoiceGuideMinimalTestScreen({super.key});

  @override
  State<VoiceGuideMinimalTestScreen> createState() => _VoiceGuideMinimalTestScreenState();
}

class _VoiceGuideMinimalTestScreenState extends State<VoiceGuideMinimalTestScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isVoiceEnabled = true;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _loadVoiceSetting();
  }

  Future<void> _loadVoiceSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _isVoiceEnabled = prefs.getBool('voiceEnabled') ?? true;
    setState(() {
      _isReady = true;
    });
  }

  void _speak() async {
    final prefs = await SharedPreferences.getInstance();
    final isVoiceEnabled = prefs.getBool('voiceEnabled') ?? true;
    if (!_isVoiceEnabled) {
    print('[DEBUG] 음성 OFF로 재생되지 않음');
    return;
    }

    print('[DEBUG] 음성 재생을 시작함');

    await _flutterTts.setLanguage("ko-KR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak("안내를 시작합니다.");
  }

  void _goToSetting() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VoiceGuideScreen()),
    );

    setState(() => _isReady = false); // 로딩 상태로 해서
    await _loadVoiceSetting();        // ← 완전히 읽기 완료될 때까지 기다립니다
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('안내 테스트')),
      body: Center(
        child: _isReady
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.volume_up),
                    label: const Text("안내를 시작합니다"),
                    onPressed: _speak,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.settings),
                    label: const Text("설정 화면으로"),
                    onPressed: _goToSetting,
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
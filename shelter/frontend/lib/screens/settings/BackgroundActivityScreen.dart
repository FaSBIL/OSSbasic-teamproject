import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../../component/settingItem/ToggleSwitch.dart';
import '../../controllers/tts_controller.dart';

class BackgroundActivityScreen extends StatefulWidget {
  const BackgroundActivityScreen({super.key});

  @override
  State<BackgroundActivityScreen> createState() =>
      _BackgroundActivityScreenState();
}

class _BackgroundActivityScreenState extends State<BackgroundActivityScreen> {
  final TTSController _ttsController = TTSController();
  bool isBackgroundEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSetting(); // 초기화 
  }

  Future<void> _initSetting() async {
    await _ttsController.loadBackgroundSetting();
    setState(() {
      isBackgroundEnabled = _ttsController.isBackgroundEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text('백그라운드 동작', style: AppTextStyles.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('앱을 닫아도 네비게이션 계속', style: AppTextStyles.subtitle),
                ToggleSwitch(
                  isOn: isBackgroundEnabled,
                  onChanged: (value) async {
                    setState(() => isBackgroundEnabled = value);
                    await _ttsController.saveBackgroundSetting(value);
                    if(value) {
                      FlutterBackgroundService().startService();
                    }else {
                      FlutterBackgroundService().invoke('stopService');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              '백그라운드 동작을 활성화하면 앱을 닫아도 음성 안내가 계속됩니다.\n'
              '배터리 소모가 증가하므로 사용 상황에 따라 설정해 주세요.\n'
              '※ 백그라운드 실행을 위해 배터리 최적화가 꺼져 있어야 합니다.\n'
              '※ 일부 기기에서는 설정에서 별도로 허용이 필요합니다.',
              style: AppTextStyles.bodyGray,
            ),
          ],
        ),
      ),
    );
  }
}

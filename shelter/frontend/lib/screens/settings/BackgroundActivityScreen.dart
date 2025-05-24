import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../../component/settingItem/ToggleSwitch.dart';

class BackgroundActivityScreen extends StatefulWidget {
  const BackgroundActivityScreen({super.key});

  @override
  State<BackgroundActivityScreen> createState() =>
      _BackgroundActivityScreenState();
}

class _BackgroundActivityScreenState extends State<BackgroundActivityScreen> {
  bool isBackgroundEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white(context),
      appBar: AppBar(
        backgroundColor: AppColors.white(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black(context)),
        title: Text('백그라운드 동작', style: AppTextStyles.title(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('앱을 닫아도 네비게이션 계속', style: AppTextStyles.subtitle(context)),
                ToggleSwitch(
                  isOn: isBackgroundEnabled,
                  onChanged:
                      (value) => setState(() {
                        isBackgroundEnabled = value;
                      }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              '백그라운드 동작을 활성화하면 앱을 닫아도 음성 안내가 계속됩니다.\n'
              '배터리 소모가 증가하므로 사용 상황에 따라 설정해 주세요.',
              style: AppTextStyles.captionGray(context),
            ),
          ],
        ),
      ),
    );
  }
}

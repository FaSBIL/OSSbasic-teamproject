import 'package:flutter/material.dart';
import 'package:shelter/routes/AppRoutes.dart';
import '../../component/list/SettingsNavItem.dart';
import '../../component/list/ConfigItem.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';

class SettingsMainScreen extends StatelessWidget {
  const SettingsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('설정', style: AppTextStyles.title),
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: AppColors.lightGray),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),

                SettingsNavItem(
                  label: '음성 안내',
                  onTap:
                      () => Navigator.pushNamed(context, AppRoutes.voiceGuide),
                ),
                SettingsNavItem(
                  label: '백그라운드 동작',
                  onTap:
                      () => Navigator.pushNamed(
                        context,
                        AppRoutes.backgroundActivity,
                      ),
                ),
                SettingsNavItem(
                  label: '테마 모드',
                  onTap:
                      () => Navigator.pushNamed(context, AppRoutes.themeMode),
                ),

                const SizedBox(height: 8),

                const ConfigItem(label: 'GPS', value: 'ON'),
                const ConfigItem(label: '앱 정보', value: 'version 1.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

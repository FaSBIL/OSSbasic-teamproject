import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelter/theme/theme_manager.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../../component/icon/IconUtils.dart';

class ThemeModeScreen extends StatelessWidget {
  const ThemeModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final currentMode = themeManager.themeMode;

    final List<String> modes = ['라이트 모드', '다크 모드', '자동 전환'];
    final List<ThemeMode> modeValues = [
      ThemeMode.light,
      ThemeMode.dark,
      ThemeMode.system,
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text('테마 모드', style: AppTextStyles.title(context)),
      ),
      body: ListView.separated(
        itemCount: modes.length,
        separatorBuilder:
            (context, index) => const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.lightGray,
            ),
        itemBuilder: (context, index) {
          final isSelected = currentMode == modeValues[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(modes[index], style: AppTextStyles.subtitle(context)),
            trailing:
                isSelected
                    ? const Icon(AppIcons.check, color: AppColors.blue)
                    : null,
            onTap: () {
              themeManager.setThemeMode(modeValues[index]);
            },
          );
        },
      ),
    );
  }
}


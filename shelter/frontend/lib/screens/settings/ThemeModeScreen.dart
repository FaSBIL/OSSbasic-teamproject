import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';

class ThemeModeScreen extends StatefulWidget {
  const ThemeModeScreen({super.key});

  @override
  State<ThemeModeScreen> createState() => _ThemeModeScreenState();
}

class _ThemeModeScreenState extends State<ThemeModeScreen> {
  int selectedIndex = 2; // 기본값: 자동 전환

  final List<String> modes = ['라이트 모드', '다크 모드', '자동 전환'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: const Text('테마 모드', style: AppTextStyles.title),
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
          final isSelected = index == selectedIndex;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(modes[index], style: AppTextStyles.subtitle),
            trailing:
                isSelected
                    ? const Icon(Icons.check, color: AppColors.blue)
                    : null,
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
              // 여기서 실제 테마 변경 처리도 나중에 연결 가능
            },
          );
        },
      ),
    );
  }
}

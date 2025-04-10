import 'package:flutter/material.dart';
import 'package:shelter/screens/test02.dart';
import '../component/Inputs/MainInput.dart';
import '../component/buttons/FavoriteButton.dart';
import '../component/buttons/GpsButton.dart';
import '../component/buttons/NavButton.dart';
import '../component/icon/IconUtils.dart';
import '../component/icon/customIcon.dart';
import '../component/list/ConfigItem.dart';
import '../component/list/EvacuationSiteItem.dart';
import '../component/list/FavoriteListItem.dart';
import '../component/list/HistoryListItem.dart';
import '../component/list/SettingsNavItem.dart';
import '../component/list/ThemeModeItem.dart';
import '../component/settingItem/ToggleSwitch.dart';
import '../component/settingItem/VolumeSlider.dart';
import '../theme/color.dart';
import '../theme/typography.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool isSoundOn = false;
  double volume = 0.5;
  int selectedIndex = 0;

  void _handleTap(String name) {
    debugPrint('$name 아이콘이 탭되었습니다');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // メインコンテンツ（スクロール可能）
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 150, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      CustomIcon(iconData: AppIcons.starRound, backgroundColor: AppColors.paleBlue, color: AppColors.blue, borderColor: AppColors.paleBlue),
                      CustomIcon(iconData: AppIcons.location, backgroundColor: AppColors.paleBlue, color: AppColors.blue, borderColor: AppColors.paleBlue),
                      CustomIcon(iconData: AppIcons.history, backgroundColor: AppColors.lightGray, color: AppColors.darkGray),
                      CustomIcon(iconData: AppIcons.tsunami, color: AppColors.black),
                      CustomIcon(iconData: AppIcons.earthquake, color: AppColors.black),
                      CustomIcon(iconData: AppIcons.menu, color: AppColors.black, size: 28.0, isClickable: true, borderRadius: 3.0, onTap: () => _handleTap('menu')),
                      CustomIcon(iconData: AppIcons.arrowRight, size: 24, isClickable: true, borderRadius: 3.0, onTap: () => _handleTap('arrowRight')),
                      CustomIcon(iconData: AppIcons.arrowLeft, size: 24, isClickable: true, borderRadius: 3.0, onTap: () => _handleTap('arrowLeft')),
                      CustomIcon(iconData: AppIcons.check, color: AppColors.blue, size: 28, borderRadius: 3.0),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text("제목0내요요!!요요요0", style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  const GpsButton(),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomIcon(iconData: AppIcons.star, backgroundColor: AppColors.paleBlue, color: AppColors.blue, borderColor: AppColors.paleBlue),
                      const SizedBox(width: 12),
                      const NavButton(text: '안내 시작'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const FavoriteButton(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('음성 안내', style: AppTextStyles.subtitle),
                      const SizedBox(width: 12),
                      ToggleSwitch(
                        isOn: isSoundOn,
                        onChanged: (value) {
                          setState(() => isSoundOn = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  VolumeSlider(
                    value: volume,
                    onChanged: (newVolume) {
                      setState(() => volume = newVolume);
                    },
                  ),
                  const SizedBox(height: 32),
                  ThemeModeItem(label: '라이트 모드', isSelected: selectedIndex == 0, onTap: () => setState(() => selectedIndex = 0)),
                  ThemeModeItem(label: '다크 모드', isSelected: selectedIndex == 1, onTap: () => setState(() => selectedIndex = 1)),
                  ThemeModeItem(label: '자동 전환', isSelected: selectedIndex == 2, onTap: () => setState(() => selectedIndex = 2)),
                  const SizedBox(height: 32),
                  SettingsNavItem(label: '음성 안내 설정', onTap: () => debugPrint('음성 안내 설정 클릭')),
                  SettingsNavItem(label: '백그라운드 실행', onTap: () => debugPrint('백그라운드 실행 클릭')),
                  SettingsNavItem(label: '테마 모드', onTap: () => debugPrint('테마 모드 클릭')),
                  const SizedBox(height: 23),
                  ConfigItem(label: "GPS 상태", value: "ON"),
                  ConfigItem(label: "앱 버전", value: "v1.0.2"),
                  const SizedBox(height: 23),
                  HistoryListItem(title: "대피소 이름23", isFavorite: false),
                  HistoryListItem(title: "대피소 이름50", isFavorite: true),
                  const SizedBox(height: 23),
                  FavoriteListItem(title: "서울역 대피소", address: "서울특별시 중구 세종대로 1"),
                  FavoriteListItem(title: "강남역 대피소", address: "울특별시 강남구 강남대로 400..."),
                  const SizedBox(height: 23),
                  EvacuationSiteItem(title: '대피소 이름23', address: '주소 00000000000000000000'),
                  EvacuationSiteItem(title: '서울특별시청 대피소', address: '서울특별시 중구 세종대로 110'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // 入力フィールド（固定位置）
          Positioned(
            top: 75,
            left: 16,
            right: 16,
            child: MainInput(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Test02Screen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
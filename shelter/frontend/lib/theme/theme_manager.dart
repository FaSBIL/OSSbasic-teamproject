import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 테마 모드 관라 : ChangeNotifier를 상속하여 상태 변경 시 위젯을 알림
class ThemeManager with ChangeNotifier {
  static const String _key = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode; //현재 테마 모드를 반환함

  // SharePreferences에서 테마 모드 값을 불러와 설정하는 함수
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 2;
    _themeMode = ThemeMode.values[index];
    notifyListeners();
  }

  // 새로운 테머 모드를 설정하고 SharedPreferences에 저장하는 함수
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, ThemeMode.values.indexOf(mode));
    notifyListeners();
  }
}
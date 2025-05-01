import 'package:flutter/material.dart';
import '../screens/settings/SettingsMainScreens.dart';
import '../screens/settings/VoiceGuideScreen.dart';
import '../screens/settings/BackgroundActivityScreen.dart';
import '../screens/settings/ThemeModeScreen.dart';
import '../screens/shelter_list.dart';

class AppRoutes {
  static const String settings = '/settings';
  static const String voiceGuide = '/voiceGuide';
  static const String backgroundActivity = '/backgroundActivity';
  static const String themeMode = '/themeMode';
  static const String shelterList = '/shelterList';

  static Map<String, WidgetBuilder> routes = {
    settings: (context) => const SettingsMainScreen(),
    voiceGuide: (context) => const VoiceGuideScreen(),
    backgroundActivity: (context) => const BackgroundActivityScreen(),
    themeMode: (context) => const ThemeModeScreen(),
    shelterList: (context) => const ShelterListScreen(),
  };
}

import 'package:flutter/material.dart';
import '../screens/settings/SettingsMainScreens.dart';
import '../screens/settings/VoiceGuideScreen.dart';
import '../screens/settings/BackgroundActivityScreen.dart';
import '../screens/settings/ThemeModeScreen.dart';
import '../screens/location_screen.dart';

class AppRoutes {
  static const String settings = '/settings';
  static const String voiceGuide = '/voiceGuide';
  static const String backgroundActivity = '/backgroundActivity';
  static const String themeMode = '/themeMode';
  static const String location = '/location';

  static Map<String, WidgetBuilder> routes = {
    settings: (context) => const SettingsMainScreen(),
    voiceGuide: (context) => const VoiceGuideScreen(),
    backgroundActivity: (context) => const BackgroundActivityScreen(),
    themeMode: (context) => const ThemeModeScreen(),
    location: (context) => const LocationScreen(),
  };
}

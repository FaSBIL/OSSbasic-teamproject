import 'package:flutter/material.dart';
import '../screens/settings/SettingsMainScreens.dart';
import '../screens/settings/VoiceGuideScreen.dart';
import '../screens/settings/BackgroundActivityScreen.dart';
import '../screens/location_screen.dart';
import '../screens/search/shelter_region_screen.dart';
import '../screens/search/search_result_screen.dart';
import '../screens/navigation/navigation_screen.dart';

class AppRoutes {
  static const String settings = '/settings';
  static const String voiceGuide = '/voiceGuide';
  static const String backgroundActivity = '/backgroundActivity';
  static const String themeMode = '/themeMode';
  static const String location = '/location';
  static const String shelterRegion = '/shelterRegion';
  static const String searchResult = '/searchResult';
  static const String navigation = '/navigation';

  static Map<String, WidgetBuilder> routes = {
    settings: (context) => const SettingsMainScreen(),
    voiceGuide: (context) => const VoiceGuideScreen(),
    backgroundActivity: (context) => const BackgroundActivityScreen(),
    location: (context) => const LocationScreen(),
    shelterRegion: (context) => ShelterRegionScreen(),

    navigation: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return NavigationScreen(
        start: args['start'],
        destination: args['destination'],
        shelter: args['shelter'],
      );
    },

    searchResult: (context) {
      final keyword = ModalRoute.of(context)!.settings.arguments as String;
      return SearchResultScreen(keyword: keyword);
    },
    shelterRegion: (context) => ShelterRegionScreen(),
  };
}

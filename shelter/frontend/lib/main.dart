import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelter/theme/theme_manager.dart';

import 'routes/AppRoutes.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';
import 'package:shelter/screens/home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final themeManager = ThemeManager();
  await themeManager.loadTheme(); //SharedPreferences에서 테마 불러오기

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeManager,
      child: const MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: '대피소 앱',
      theme: ThemeData.light().copyWith(
      // 앱의 기본 제목 (iOS나 일부 안드로이드에서 사용됨)
        textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'NotoSansKR',
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
      // 앱의 기본 제목 (iOS나 일부 안드로이드에서 사용됨)
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'NotoSansKR',
        ),
      ),
      themeMode: themeManager.themeMode, // 테마 적용
      routes: AppRoutes.routes,
      //home: HomeScreen(), // 앱 실행 시 처음 보여줄 화면
      home: SettingsMainScreen(),
      debugShowCheckedModeBanner: false, // 오른쪽 상단 디버그 배너 제거
    );
  }
}

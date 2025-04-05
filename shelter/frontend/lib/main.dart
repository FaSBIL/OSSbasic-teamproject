import 'package:flutter/material.dart';
import 'screens/shelter_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '대피소 앱',
      theme: ThemeData(
        fontFamily: 'NotoSansKR', // ✅ 여기가 맞는 위치야
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 14),
          bodyLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const ShelterMapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

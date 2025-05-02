import 'package:flutter/material.dart';
import '../component/map/mapbox.dart';
import '../component/input/MainInput.dart';
import '../component/buttons/GpsButton.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<MapboxState> mapboxKey = GlobalKey<MapboxState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Mapbox(
            key: mapboxKey,
            latitude: 37.5665,
            longitude: 126.9780,
            zoom: 14.0,
          ),

          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: SafeArea(
              child: MainInput(
                onTap: () {
                  print(" MainInput 눌림"); // 테스트 코드
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const SearchScreen()),
                  // );
                },
              ),
            ),
          ),

          // 설정 버튼
          Positioned(
            top: 74,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                //설정 화면으로 이동
              },
            ),
          ),

          // 필터 버튼 (해일, 지진, 홍수, 화재)
          Positioned(
            top: 160,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton(Icons.pool, '해일'),
                  _buildFilterButton(Icons.show_chart, '지진'),
                  _buildFilterButton(Icons.sailing, '홍수'),
                  _buildFilterButton(Icons.local_fire_department, '화재'),
                ],
              ),
            ),
          ),

          // 현재 위치 버튼
          Positioned(
            bottom: 24,
            right: 16,
            child: GpsButton(
              onPressed: () {
                mapboxKey.currentState?.moveToCurrentLocation();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 필터 버튼 위젯
  Widget _buildFilterButton(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

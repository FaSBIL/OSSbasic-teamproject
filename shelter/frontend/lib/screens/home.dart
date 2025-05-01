import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도 배경
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(37.5665, 126.9780), // 서울의 위도와 경도
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),

          // 검색창
          Positioned(
            top: 60,
            left: 16,
            right: 60,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text("대피소 검색", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),

          // 설정 버튼
          Positioned(
            top: 60,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // 설정 화면으로 이동
              },
            ),
          ),

          // 필터 버튼 (해일, 지진, 홍수, 화재)
          Positioned(
            top: 120,
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
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                // 현재 위치 이동 기능
              },
              child: const Icon(Icons.my_location, color: Colors.black),
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

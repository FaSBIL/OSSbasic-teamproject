import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/user_location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserLocationService _locationService = UserLocationService();
  LatLng? _currentPosition; // 사용자 위치 저장
  String _errorMessage = ''; // 오류 메시지 저장
  late Stream<Position> _positionStream; // 실시간 위치 스트림

  @override
  void initState() {
    super.initState();
    _initializePositionStream(); // 실시간 위치 스트림 초기화
    _setInitialLocation(); // 초기 위치 설정
  }

  void _initializePositionStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터 이상 이동 시 업데이트
      ),
    );

    _positionStream.listen(
      (Position position) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _errorMessage = '';
        });
      },
      onError: (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      },
    );
  }

  Future<void> _setInitialLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도 배경
          FlutterMap(
            options: MapOptions(
              initialCenter:
                  _currentPosition ?? LatLng(37.5665, 126.9780), // 서울의 위도와 경도
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
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
              ), // <-- Properly closed Row widget
            ),
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

          // 오류 메시지 표시
          if (_errorMessage.isNotEmpty)
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
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
                // 현재 위치 버튼을 눌렀을 때 초기 위치로 이동
                if (_currentPosition != null) {
                  setState(() {
                    // 지도 중심을 현재 위치로 이동
                  });
                }
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

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/screens/navigation/navigation_screen.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/utils/distance_calculator.dart' as calc;
import 'package:shelter/map/shelter_osm_map.dart';
import 'package:flutter_map/flutter_map.dart';

class NavigationPreviewScreen extends StatefulWidget {
  final LatLng start;
  final LatLng destination;

  const NavigationPreviewScreen({
    super.key,
    required this.start,
    required this.destination,
  });

  @override
  State<NavigationPreviewScreen> createState() =>
      _NavigationPreviewScreenState();
}

class _NavigationPreviewScreenState extends State<NavigationPreviewScreen> {
  String distance = '계산 중...';

  @override
  void initState() {
    super.initState();
    _loadDistance();
  }

  Future<void> _loadDistance() async {
    final result = await calc.DistanceCalculator.calculateDistanceWithTime(
      widget.start.latitude,
      widget.start.longitude,
      widget.destination.latitude,
      widget.destination.longitude,
    );

    setState(() {
      distance = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('경로 미리보기')),
      body: Stack(
        children: [
          Positioned.fill(
            child: ShelterOsmMap(
              mapController: MapController(),
              initialCenter: widget.start,
              shelterMarkers: [
                Marker(
                  width: 60,
                  height: 60,
                  point: widget.start,
                  child: const Icon(Icons.my_location, color: AppColors.blue),
                ),
                Marker(
                  width: 60,
                  height: 60,
                  point: widget.destination,
                  child: const Icon(Icons.location_on, color: Colors.red),
                ),
              ],
              currentPosition: widget.start,
            ),
          ),

          // 거리 정보 + 길 안내 버튼
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 왼쪽 정보
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '최단거리',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  distance.split(' ').first, // "11분" 등 앞단만 추출
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  distance.split(' ').length > 1
                                      ? distance.split(' ')[1]
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),

                        // 오른쪽 아이콘 + 텍스트
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => NavigationScreen(
                                      start: widget.start,
                                      destination: widget.destination,
                                    ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: const BoxDecoration(
                                  color: AppColors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.turn_right,
                                  color: AppColors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                '경로상세',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

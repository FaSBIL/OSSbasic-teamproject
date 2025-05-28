import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/utils/distance_calculator.dart' as calc;
import 'package:flutter_map/flutter_map.dart';
import 'package:shelter/map/shelter_map.dart';
import 'package:shelter/component/bottomSheet/ShelterBottomSheet.dart';
import 'package:shelter/component/bottomSheet/data/ShelterDetailView.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shelter/models/shelter.dart';

Position createMockPosition(LatLng latLng) {
  return Position(
    latitude: latLng.latitude,
    longitude: latLng.longitude,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );
}

class NavigationScreen extends StatefulWidget {
  final LatLng start;
  final LatLng destination;
  final Shelter shelter;

  const NavigationScreen({
    super.key,
    required this.start,
    required this.destination,
    required this.shelter,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  bool showNavigation = false;
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
      appBar: AppBar(title: Text(showNavigation ? '실시간 길 안내' : '경로 미리보기')),
      body: Stack(
        children: [
          // 지도
          Positioned.fill(
            child: ShelterMap(
              currentPosition: widget.start,
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
                  child: const Icon(Icons.location_on, color: AppColors.blue),
                ),
              ],
            ),
          ),

          // 바텀시트
          ShelterBottomSheet(
            mode: SheetMode.detail,
            child:
                showNavigation
                    ? _buildNavigationInfo()
                    : ShelterDetailView(
                      shelters: {
                        'name': widget.shelter.name,
                        'address': widget.shelter.address,
                        'latitude': widget.shelter.latitude,
                        'longitude': widget.shelter.longitude,
                        'earthquake': widget.shelter.earthquakeSafe ? 1 : 0,
                        'tsunami': widget.shelter.tsunamiSafe ? 1 : 0,
                        'isFavorite': widget.shelter.isFavorite ? 1 : 0,
                      },
                      currentPosition: createMockPosition(widget.start),
                      onFavoriteToggle: (_) {},
                      onNavigate: (_) {
                        setState(() {
                          showNavigation = true;
                        });
                      },
                    ),
          ),
        ],
      ),
    );
  }

  // 실시간 안내 UI (임시)
  Widget _buildNavigationInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('실시간 길 안내 기능은 추후 구현될 예정', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            '출발지: ${widget.start.latitude}, ${widget.start.longitude}',
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '도착지: ${widget.destination.latitude}, ${widget.destination.longitude}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '예상 거리 및 소요 시간: $distance',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

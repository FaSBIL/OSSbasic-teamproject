import 'package:flutter/material.dart';
import 'package:shelter/map/shelter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:shelter/component/input/MainInput.dart';
import 'package:shelter/component/buttons/GpsButton.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shelter/map/user_marker.dart';
import 'package:shelter/services/user_location.dart';
import 'package:shelter/services/filter_shelters.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/widgets/shelter_detail_card.dart';
import 'package:shelter/screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentPosition;
  List<Marker> _shelterMarkers = [];
  final MapController _mapController = MapController();

  final ShelterService _shelterService = ShelterService(); // 대피소 서비스
  Shelter? _selectedShelter; // 선택된 대피소 정보를 담는 변수

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    try {
      final locationService = UserLocationService();
      final position = await locationService.getCurrentLocation();
      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = currentLatLng;
      });

      _mapController.move(currentLatLng, 16.0); // 가까운 줌레벨로 설정

      await _shelterService.initialize();

      // 반경 거리 계산용 도구
      final distance = latlng.Distance();
      final maxDistance = 3000.0; // 반경 3km 이내 (단위: 미터)

      final allRegions = [
        'seoul',
        'busan',
        'daegu',
        'incheon',
        'gwangju',
        'daejeon',
        'ulsan',
        'sejong',
        'gyeonggi',
        'gangwon',
        'chungbuk',
        'chungnam',
        'jeonbuk',
        'jeonnam',
        'gyeongbuk',
        'gyeongnam',
        'jeju',
      ];

      List<Shelter> nearbyShelters = [];

      for (final region in allRegions) {
        try {
          final civilShelters = await _shelterService
              .getSheltersByRegionAndType(region, 'civil');
          final earthquakeShelters = await _shelterService
              .getSheltersByRegionAndType(region, 'earthquake');
          final tsunamiShelters = await _shelterService
              .getSheltersByRegionAndType(region, 'tsunami');

          final allShelters = [
            ...civilShelters,
            ...earthquakeShelters,
            ...tsunamiShelters,
          ];

          final filtered =
              allShelters.where((shelter) {
                final shelterLatLng = LatLng(
                  shelter.latitude,
                  shelter.longitude,
                );
                final dist = distance(currentLatLng, shelterLatLng);
                return dist <= maxDistance;
              }).toList();

          nearbyShelters.addAll(filtered);
        } catch (e) {
          print('❌ [$region] 지역 대피소 로딩 실패: $e');
        }
      }

      setState(() {
        _shelterMarkers =
            nearbyShelters.map((shelter) {
              return Marker(
                width: 60,
                height: 60,
                point: LatLng(shelter.latitude, shelter.longitude),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedShelter = shelter;
                    });
                  },
                  child: const Icon(Icons.location_pin, color: Colors.green),
                ),
              );
            }).toList();
      });
    } catch (e) {
      print('❌ 위치 또는 대피소 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? LatLng(37.5665, 126.9780),
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.shelter_map',
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 60,
                      height: 60,
                      child: LocationMarker(
                        size: 40,
                        heading: 0.0, // 나중에 방향 값 쓸 거면 여기에 넣기
                      ),
                    ),
                  ..._shelterMarkers,
                ],
              ),
            ],
          ),

          //검색창
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: MainInput(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
              searchText: '', // 또는 최근 검색어, 상태값 등
            ),
          ),

          // 현재 위치 버튼
          Positioned(
            bottom: 280,
            right: 16,
            child: GpsButton(mapController: _mapController),
          ),
          if (_selectedShelter != null)
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: ShelterDetailCard(shelter: _selectedShelter!),
            ),
        ],
      ),
    );
  }
}

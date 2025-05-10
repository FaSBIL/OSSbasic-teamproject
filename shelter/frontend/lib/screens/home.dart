import 'package:flutter/material.dart';
import 'package:shelter/map/shelter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/component/input/MainInput.dart';
import 'package:shelter/component/buttons/GpsButton.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shelter/services/user_location.dart';
import 'package:shelter/services/filter_shelters.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/widgets/shelter_detail_card.dart';

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
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      await _shelterService.initialize();

      // 대피소 불러오기 + 마커 만들기
      final regionInfo = await locationService.getNearestLocation(
        position.latitude,
        position.longitude,
      );

      final regionNameToCode = {
        '서울특별시': 'seoul',
        '부산광역시': 'busan',
        '대구광역시': 'daegu',
        '인천광역시': 'incheon',
        '광주광역시': 'gwangju',
        '대전광역시': 'daejeon',
        '울산광역시': 'ulsan',
        '세종특별자치시': 'sejong',
        '경기도': 'gyeonggi',
        '강원특별자치도': 'gangwon',
        '충청북도': 'chungbuk',
        '충청남도': 'chungnam',
        '전북특별자치도': 'jeonbuk',
        '전라북도': 'jeonbuk',
        '전라남도': 'jeonnam',
        '경상북도': 'gyeongbuk',
        '경상남도': 'gyeongnam',
        '제주특별자치도': 'jeju',
      };
      final regionCode =
          regionNameToCode[regionInfo['do']?.trim() ?? ''] ?? 'chungbuk';

      final shelters = await _shelterService.getCivilSheltersAsModel(
        regionCode,
      );

      setState(() {
        _shelterMarkers =
            shelters.map((shelter) {
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
      print('위치 또는 대피소 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도
          ShelterMap(
            currentPosition: _currentPosition,
            shelterMarkers: _shelterMarkers,
            mapController: _mapController,
          ),

          //검색창
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: MainInput(
              onTap: () {
                // 검색 페이지로 이동하거나 검색 기능 실행
                print('검색창 선택됨');
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

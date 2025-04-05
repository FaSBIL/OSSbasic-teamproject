import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // 지도 위젯 패키지
import 'package:latlong2/latlong.dart'; // 위경도 좌표용 패키지
import 'package:geolocator/geolocator.dart'; // ✅ GPS 위치 사용을 위한 패키지 추가
import 'dart:async'; // ✅ 위치 스트림을 위한 import

import '../widgets/search_bar.dart'; // 상단 검색창 위젯
import '../widgets/loading_indicator.dart'; // 로딩 스피너 UI

import '../widgets/zoom_control_buttons.dart';
import '../widgets/current_location_button.dart';
import '../widgets/guide_start_button.dart';
import '../widgets/shelter_slider.dart';

class ShelterMapScreen extends StatefulWidget {
  const ShelterMapScreen({super.key});

  @override
  State<ShelterMapScreen> createState() => _ShelterMapScreenState();
}

class _ShelterMapScreenState extends State<ShelterMapScreen> {
  bool isLoading = false;

  LatLng? currentPosition; // ✅ 현재 위치 저장
  StreamSubscription<Position>? _positionStreamSubscription; // ✅ 스트림 구독 변수

  /// ✅ 지도 컨트롤러 추가
  final MapController _mapController = MapController();
  final List<Map<String, String>> shelterList = [
    {
      'name': '성심당 본점',
      'address': '대전 중구 대종로480번길 15',
      'distance': '도보 5분 (400m)',
    },
    {
      'name': '대전역 대피소',
      'address': '대전 동구 중앙로215번길 7',
      'distance': '도보 10분 (800m)',
    },
    {
      'name': '한밭대학교 대피소',
      'address': '대전 유성구 대학로 291',
      'distance': '도보 15분 (1.2km)',
    },
  ];

  /// ✅ 실시간 위치 추적 시작
  void startTrackingLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // ✅ 위치 스트림을 수신하고 상태 업데이트
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10m 이상 움직일 때만 갱신
      ),
    ).listen((Position position) {
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startTrackingLocation(); // ✅ 앱 실행 시 위치 추적 시작
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // ✅ 앱 종료 시 위치 추적 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 1. 지도 영역 (OpenStreetMap 사용)
          FlutterMap(
            mapController: _mapController, // ✅ 지도 컨트롤러 적용
            options: MapOptions(
              initialCenter:
                  currentPosition ?? LatLng(37.5665, 126.9780), // ✅ 현재 위치 사용
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),

              /// ✅ 현재 위치 마커
              if (currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: Color.fromARGB(255, 241, 15, 15),
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),

          /// 2. 상단 메뉴 버튼 + 검색창
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, size: 30),
                  onPressed: () {
                    // 설정 화면으로 이동
                  },
                ),
                const SizedBox(width: 10),
                const Expanded(child: SearchBarWidget()),
              ],
            ),
          ),

          /// 3. 하단 대피소 정보 카드 or 로딩 중 표시 + 안내 시작 버튼
          Positioned(
            bottom: 30, // 버튼보다 위로 띄우기
            left: 0,
            right: 0,
            child:
                isLoading
                    ? const LoadingIndicator()
                    : ShelterSlider(
                      shelterList: shelterList,
                      onShelterSelected: (shelter) {
                        final LatLng target = shelter['latLng'];
                        _mapController.move(
                          target,
                          _mapController.camera.zoom,
                        ); // ✅ 지도 이동
                      },
                    ),
          ),

          /// ✅ 4. 오른쪽 하단: 확대/축소 + 현재 위치 버튼
          Positioned(
            bottom: 200,
            right: 20,
            child: Column(
              children: [
                ZoomControlButtons(mapController: _mapController),
                const SizedBox(height: 10),
                CurrentLocationButton(
                  currentPosition: currentPosition,
                  mapController: _mapController,
                ),
              ],
            ),
          ),

          /// 5. 하단 안내 시작 버튼 (항상 고정됨)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GuideStartButton(
              onPressed: () {
                print('안내 시작');
              },
            ),
          ),
        ],
      ),
    );
  }
}
